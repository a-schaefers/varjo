(in-package :varjo)
(in-readtable :fn.reader)

;;============================================================
;; The mess of creation

(defmethod build-external-function ((func external-function) env)
  (labels ((expand-macros-for-external-func (form)
             (pipe-> (form env)
               (equalp #'symbol-macroexpand-pass
                       #'macroexpand-pass
                       #'compiler-macroexpand-pass))))
    (with-slots (name in-args uniforms code glsl-versions) func
      (vbind (compiled-func maybe-def-code)
          (build-function name
                          (append in-args
                                  (when uniforms `(&uniform ,@uniforms)))
                          (expand-macros-for-external-func code)
                          nil
                          env)
        ;; Here we check that we haven't got any behaviour that, while legal for
        ;; main or local funcs, would be undesired in external functions
        (when maybe-def-code
          (assert (null (out-vars maybe-def-code)))
          (assert (null (current-line maybe-def-code)))
          (assert (null (flow-ids maybe-def-code)))
          (assert (null (multi-vals maybe-def-code)))
          (assert (null (mutations maybe-def-code)))
          (assert (null (out-of-scope-args maybe-def-code)))
          (assert (null (place-tree maybe-def-code)))
          (assert (null (returns maybe-def-code)))
          (assert (null (to-block maybe-def-code)))
          (assert (typep (code-type maybe-def-code) 'v-none)))
        (values compiled-func maybe-def-code)))))

(defun build-function (name args body allowed-implicit-args env)
  ;;
  ;; Check that the args are correctly formatted, we could just let
  ;; type-spec->type take care of this, however this way we get to
  ;; give better error messages (and also impose extra limitations
  (unless (function-raw-args-validp args)
    (error 'bad-make-function-args
           :func-name name
           :arg-specs (remove-if #'function-raw-arg-validp args)))
  ;;
  ;; Parse the types
  (let ((arg-types (mapcar λ(type-spec->type (second _)) args)))
    (if (some λ(typep _ 'v-compile-time-value) arg-types)
        (make-new-function-with-ctvs name args body allowed-implicit-args env)
        (make-regular-function name args body allowed-implicit-args env))))


(defun make-regular-function (name args body allowed-implicit-args env)
  (let* ((mainp (eq name :main))
         (func-env (make-func-env env mainp allowed-implicit-args))
         (in-arg-flow-ids (mapcar (lambda (_)
                                    (declare (ignore _))
                                    (flow-id!))
                                  args))
         (arg-glsl-names (loop :for (name) :in args :collect
                            (lisp-name->glsl-name name env)))
         (body-env (reduce
                    (lambda (func-env tripple)
                      (dbind (arg glsl-name flow-ids) tripple
                        (dbind (name type-spec) arg
                          (add-var name
                                   (v-make-value type-spec func-env
                                                 :glsl-name glsl-name
                                                 :flow-ids flow-ids)
                                   func-env))))
                    (mapcar #'list args arg-glsl-names in-arg-flow-ids)
                    :initial-value (if mainp
                                       func-env
                                       (remove-main-method-flag-from-env
                                        func-env))))
         (body-obj (compile-form `(%return (progn ,@body)) body-env))
         (implicit-args (extract-implicit-args name allowed-implicit-args
                                               (normalize-out-of-scope-args
                                                (out-of-scope-args body-obj))
                                               func-env))
         (glsl-name (if mainp "main" (lisp-name->glsl-name name func-env)))
         (primary-return (first (returns body-obj)))
         (multi-return-vars (rest (returns body-obj)))
         (type (if mainp (type-spec->type 'v-void) primary-return)))
    ;;
    (unless (or mainp primary-return) (error 'no-function-returns :name name))
    (when (v-typep type (type-spec->type :none))
      (error 'function-with-no-return-type :func-name name))
    (let* ((arg-pairs (loop :for (nil type) :in args
                         :for name :in arg-glsl-names :collect
                         `(,(v-glsl-string (type-spec->type type)) ,name)))
           (out-arg-pairs (loop :for mval :in multi-return-vars :for i :from 1
                             :for name = (v-glsl-name (multi-val-value mval)) :collect
                             `(,(v-glsl-string (v-type (multi-val-value mval)))
                                ,name)))
           (in-out-args
            ;; {TODO} handle multiple returns
            (when (and (typep type 'v-function-type)
                       (ctv type)
                       (implicit-args (ctv type)))
              (let ((closure (ctv type)))
                (append (in-out-args closure)
                        (implicit-args closure)))))
           (sigs (if mainp
                     (signatures body-obj)
                     (cons (gen-function-signature glsl-name arg-pairs
                                                   out-arg-pairs type
                                                   implicit-args
                                                   in-out-args)
                           (signatures body-obj))))
           (func-glsl-def (gen-function-body-string
                           glsl-name (unless mainp arg-pairs)
                           out-arg-pairs type body-obj
                           implicit-args in-out-args))
           (func (func-spec->user-function
                  (v-make-f-spec name
                                 (gen-function-transform
                                  glsl-name args
                                  multi-return-vars
                                  implicit-args)
                                 nil ;;{TODO} should be context
                                 (mapcar #'second args)
                                 (cons type multi-return-vars)
                                 :glsl-name glsl-name
                                 :implicit-args implicit-args
                                 :in-out-args in-out-args
                                 :flow-ids (flow-ids body-obj)
                                 :in-arg-flow-ids in-arg-flow-ids)
                  func-env))
           (code-obj (copy-code body-obj
                                :type (type-spec->type 'v-none)
                                :current-line nil
                                :signatures sigs
                                :to-block nil
                                :returns nil
                                :out-vars (out-vars body-obj)
                                :multi-vals nil
                                :place-tree nil
                                :out-of-scope-args implicit-args
                                :flow-ids nil)))
      (values (make-instance 'compiled-function-result
                             :function-obj func
                             :signatures (signatures code-obj)
                             :ast (node-tree body-obj)
                             :used-types (used-types code-obj)
                             :glsl-code func-glsl-def
                             :stemcells (stemcells code-obj)
                             :out-vars (out-vars code-obj))
              code-obj))))

(defun make-new-function-with-ctvs (name args body allowed-implicit-args
                                    env)
  (let ((mainp (eq name :main)))
    (assert (not (eq name :main)))
    (let* ((env (make-func-env env mainp allowed-implicit-args))
           (func (func-spec->user-function
                  (v-make-f-spec name nil nil (mapcar #'second args) nil
                                 :code (list args body))
                  env))
           ;; {TODO} this ↓↓↓↓↓↓↓↓↓↓↓↓ is a horrible hack
           (ast-body (if (= 1 (length body))
                         (first body)
                         `(progn ,@body)))
           (ast (ast-node! :code-section
                           ast-body
                           (type-spec->type 'v-none)
                           nil env env)))
      (values (make-instance 'compiled-function-result
                             :function-obj func
                             :signatures nil
                             :ast ast
                             :used-types nil
                             :glsl-code nil
                             :stemcells nil
                             :out-vars nil)
              (code! :type (type-spec->type 'v-none)
                     :place-tree nil
                     :node-tree (ast-node! :code-section
                                           ast-body
                                           (type-spec->type 'v-none)
                                           nil env env)
                     :flow-ids nil)))))


(defun function-raw-args-validp (raw-args)
  (every #'function-raw-arg-validp raw-args))

(defun function-raw-arg-validp (raw-arg)
  "Basic checks to validate the argument forms for the function"
  (and (listp raw-arg)
       (>= (length raw-arg) 2)
       (not (null (first raw-arg)))
       (symbolp (first raw-arg))
       (not (keywordp (first raw-arg)))
       (type-specp (second raw-arg))))

(defun extract-implicit-args (name allowed-implicit-args
                              normalized-out-of-scope-args env)
  (let ((result (remove-if λ(= (v-function-scope _)
                               (v-function-scope env))
                           normalized-out-of-scope-args)))
    (if (or (eq allowed-implicit-args t)
            (and (listp allowed-implicit-args)
                 (every λ(member _ allowed-implicit-args)
                        allowed-implicit-args)))
        result
        (when result
          (error 'illegal-implicit-args :func-name name)))))

(defun make-func-env (env mainp allowed-implicit-args)
  (if mainp
      (fresh-environment env :function-scope (1+ (v-function-scope env))
                         :context (cons :main (v-context env))
                         :allowed-outer-vars allowed-implicit-args)
      (fresh-environment env :function-scope (1+ (v-function-scope env))
                         :allowed-outer-vars allowed-implicit-args)))