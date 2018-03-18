(in-package :varjo.internals)

(defgeneric %add-function (func-name func-spec env))
(defgeneric %add-symbol-binding (var-name val env))
(defgeneric %get-symbol-macro-spec (macro-name env))
(defgeneric %uniform-name (thing env))
(defgeneric (setf compiled-functions) (val e key))
(defgeneric (setf metadata-for-flow-id) (value flow-id env))
(defgeneric (setf metadata-for-scope) (data env))
(defgeneric add-alt-ephemeral-constructor-function (src-type-name alt-type-name))
(defgeneric add-compiler-macro (macro env))
(defgeneric add-equivalent-name (existing-name new-name))
(defgeneric add-external-function (name in-args uniforms code &optional valid-glsl-versions))
(defgeneric add-form-binding (func/macro env))
(defgeneric add-global-compiler-macro (macro))
(defgeneric add-global-form-binding (func/macro))
(defgeneric add-symbol-binding (var-name val env))
(defgeneric add-symbol-macro (macro-name macro context env))
(defgeneric all-cached-compiled-functions (e))
(defgeneric all-functions (object))
(defgeneric ast-kindp (node kind))
(defgeneric ast-typep (node type))
(defgeneric binding-in-higher-scope-p (binding env))
(defgeneric block-name-string (block-name))
(defgeneric build-external-function (func env base-env))
(defgeneric cast-code-inner (varjo-type src-obj cast-to-type))
(defgeneric compile-form (code env))
(defgeneric compile-literal (code env &key errorp))
(defgeneric compile-place (code env &key allow-unbound))
(defgeneric compiled-functions (e key))
(defgeneric copy-compiled (code-obj &key type-set current-line to-block
                                      emit-set return-set
                                      stemcells out-of-scope-args
                                      place-tree pure node-tree
                                      used-types))
(defgeneric delete-external-function (name in-args-types))
(defgeneric expand-input-variable (stage var-type input-variable env))
(defgeneric find-form-binding-by-literal (name env))
(defgeneric find-global-form-binding-by-literal (name))
(defgeneric flow-id-origins (node &optional error-on-missingp context))
(defgeneric func-need-arguments-compiledp (func))
(defgeneric functions (object))
(defgeneric get-external-function-by-name (name env))
(defgeneric get-flow-id-for-stem-cell (stem-cell-symbol e))
(defgeneric get-form-binding (name env))
(defgeneric get-global-compiler-macro (macro-name))
(defgeneric get-global-form-binding (name))
(defgeneric get-macro (macro-name env))
(defgeneric get-stemcell-name-for-flow-id (id env))
(defgeneric get-symbol-binding (symbol respect-scope-rules env))
(defgeneric get-symbol-macro (macro-name env))
(defgeneric in-block-name-for (stage))
(defgeneric map-environments (func e))
(defgeneric merge-compiled (objs &key type-set emit-set return-set
                                   current-line to-block
                                   stemcells out-of-scope-args
                                   place-tree pure node-tree))
(defgeneric metadata-for-flow-id (metadata-kind flow-id env))
(defgeneric metadata-for-scope (metadata-kind env))
(defgeneric origin-name (origin))
(defgeneric out-block-name-for (stage))
(defgeneric post-initialise (object))
(defgeneric primary-type (compiled))
(defgeneric primitive-in (pp))
(defgeneric qualifier= (qual-a qual-b))
(defgeneric qualify-type (type qualifiers))
(defgeneric raw-ids (flow-id))
(defgeneric record-func-usage (func env))
(defgeneric shadow-function (func shadowed-type new-type &key))
(defgeneric to-arg-form (uniform))
(defgeneric type->type-spec (type))
(defgeneric type-spec->type (spec &optional flow-id))
(defgeneric used-external-functions (e))
(defgeneric v-array-type-of (element-type dimensions flow-id))
(defgeneric v-casts-to (from-type to-type))
(defgeneric v-casts-to-p (from-type to-type))
(defgeneric v-element-type (object))
(defgeneric v-glsl-size (type))
(defgeneric v-make-type (type flow-id &rest args))
(defgeneric v-make-uninitialized (type env &key glsl-name function-scope read-only))
(defgeneric v-make-value (type env &key glsl-name function-scope read-only))
(defgeneric v-name-map (env))
(defgeneric v-place-function-p (f))
(defgeneric v-primary-type-eq (a b))
(defgeneric v-special-functionp (func))
(defgeneric v-superclass (type))
(defgeneric v-type-eq (a b))
(defgeneric v-type-of (func))
(defgeneric v-typep (a b))
(defgeneric val-origins (node &optional error-on-missingp))
(defgeneric valid-for-contextp (func env))
(defgeneric qualifiers (obj))
