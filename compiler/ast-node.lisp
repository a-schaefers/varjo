(in-package :varjo)
(in-readtable fn:fn-reader)

(defclass ast-node ()
  ((starting-env :initarg :starting-env :reader ast-starting-env)
   (ending-env :initarg :ending-env :reader ast-ending-env)
   (kind :initarg :kind :reader ast-kind)
   (return-type :initarg :return-type :reader ast-return-type)
   (flow-id :initarg :flow-id :reader ast-flow-id)
   (flow-id-origin :initarg :flow-id-origin :initform :incomplete
		   :reader ast-flow-id-origin)
   (val-origin :initarg :val-origin :initform :incomplete
	       :reader ast-val-origin)
   (parent :initarg :parent :initform :incomplete :reader ast-parent)
   (args :initarg :args :initform nil :reader ast-args)))

(defmethod get-var (var-name (node ast-node))
  (get-var var-name (ast-starting-env node)))

(defmethod ast-kindp (node kind)
  (let* ((actual-kind (ast-kind node)))
    (cond
      ((typep kind 'v-function) (eq kind actual-kind))
      ((typep actual-kind 'v-function) (eq kind (name actual-kind)))
      (t (eq kind actual-kind)))))



(defmethod ast-typep (node type)
  (let ((type (if (or (typep type 'v-spec-type) (typep type 'v-t-type))
		  type
		  (type-spec->type type))))
    (v-typep (ast-return-type node) type)))


(defmethod flow-id-origins ((node ast-node)
			   &optional r error-on-missingp)
  (labels ((get-seen (raw-id)
	     (or (gethash raw-id r)
		 (when error-on-missingp
		   (error "Could not find origin for ~s" raw-id))))

	   (per-id (val-id node)
	     (let ((raw (slot-value val-id 'val)))
	       (or (get-seen raw)
		   (setf (gethash raw r) (cons raw node)))))

	   (per-flow-id (flow-id node)
	     (flatten (mapcar λ(per-id _ node)
			      (ids flow-id))))

	   (get-origins (node)
	     (mapcar λ(per-flow-id _ node) (listify (ast-flow-id node)))))
    (typecase r
      (hash-table (get-origins node))
      (null (ast-flow-id-origin node)))))

(defmethod val-origins ((node ast-node) &optional r error-on-missingp)
  (labels ((get-seen (raw-id errorp)
	     (or (gethash raw-id r)
		 (when errorp
		   (error "Could not find origin for ~s" raw-id))))

	   (f-origin (val-id fcall-node)
	     (let* ((func (ast-kind fcall-node))
		    (return-pos (slot-value val-id 'return-pos)))
	       (mapcar λ(get-seen (slot-value _ 'val) t)
		       (ids (nth return-pos (flow-ids func))))))

	   (per-id (val-id node)
	     (let ((raw (slot-value val-id 'val)))
	       (or (get-seen raw error-on-missingp)
		   (setf (gethash raw r)
			 (if (typep (ast-kind node) 'v-user-function)
			     (f-origin val-id node)
			     node)))))

	   (per-flow-id (flow-id node)
	     (flatten (mapcar λ(per-id _ node) (ids flow-id))))

	   (get-origins (node)
	     (mapcar λ(per-flow-id _ node) (listify (ast-flow-id node)))))
    (typecase r
      (hash-table (get-origins node))
      (null (ast-val-origin node)))))


(defmethod flow-ids ((node ast-node))
  (ast-flow-id node))

(defparameter *node-kinds* '(:get :get-stemcell :get-v-value :literal))

(defun ast-node! (kind args return-type flow-id starting-env ending-env)
  (assert (if (keywordp kind)
	      (member kind *node-kinds*)
	      t))
  (make-instance 'ast-node
		 :kind kind
		 :args (listify args)
		 :return-type return-type
		 :flow-id flow-id
		 :starting-env starting-env
		 :ending-env ending-env))

(defun copy-ast-node (node
		      &key
			(kind nil set-kind)
			(args nil set-args)
			(return-type nil set-return-type)
			(flow-id nil set-flow-id)
			(flow-id-origin nil set-fio)
			(starting-env nil set-starting-env)
			(ending-env nil set-ending-env)
			(parent nil set-parent))
  (make-instance
   'ast-node
   :kind (if set-kind kind (ast-kind node))
   :args (if set-args args (ast-args node))
   :return-type (if set-return-type return-type (ast-return-type node))
   :flow-id (if set-flow-id flow-id (ast-flow-id node))
   :flow-id-origin (if set-fio flow-id-origin (ast-flow-id-origin node))
   :starting-env (if set-starting-env starting-env (ast-starting-env node))
   :ending-env (if set-ending-env ending-env (ast-ending-env node))
   :parent (if set-parent parent (ast-parent node))))

(defun walk-ast (func from-node &key include-parent)
  (labels ((walk-node (ast &key parent)
	     (if (eq ast :ignored)
		 :ignored
		 (typecase ast
		   (ast-node
		    (let ((args `(,ast
				  ,#'walk-node
				  ,@(when include-parent `(:parent ,parent)))))
		      (apply func args)))
		   (list (mapcar λ(walk-node _ :parent parent) ast))
		   (t ast)))))
    (typecase from-node
      (code (walk-node (node-tree from-node) :parent nil))
      (varjo-compile-result (walk-node (ast from-node) :parent nil))
      (ast-node (walk-node from-node :parent nil))
      (t (error "object with the invalid type ~s passed to ast->code"
		(type-of from-node))))))

(defun visit-ast-nodes (func x)
  (labels ((f (node walk)
	     (funcall func node)
	     (with-slots (args) node
	       (mapcar walk args))))
    (walk-ast #'f x)
    t))

(defun filter-ast-nodes (func x)
  (let (r)
    (visit-ast-nodes λ(when (funcall func _) (push _ r)) x)
    (reverse r)))

(defun ast->pcode (x &key show-flow-ids)
  (labels ((f (node walk)
	     (with-slots (kind args) node
	       (let ((name (if (typep kind 'v-function)
			       (name kind)
			       kind)))
		 `(,@(when show-flow-ids
			   (ast-flow-id node))
		     ,name ,@(mapcar walk args))))))
    (walk-ast #'f x)))

(defun ast->code (x &key changes)
  (let ((change-map (make-hash-table :test #'eq)))
    (labels ((prep-changes (form)
	       (let ((nodes (remove-if-not λ(typep _ 'ast-node) form)))
		 (assert (= (length nodes) 1))
		 (let* ((node (first nodes)))
		   (setf (gethash node change-map) form))))

	     (serialize-node (node walk)
	       (with-slots (kind args) node
		 (if (keywordp kind)
		     (case kind
		       (:get (first args))
		       (:get-stemcell (first args))
		       (:literal (first args))
		       (t (error "invalid node kind ~s found in result"
		       		 kind)))
		     `(,kind ,@(mapcar walk args)))))

	     (f (node walk)
	       (let* ((expanded (serialize-node node walk)))
		 (vbind (form found) (gethash node change-map)
		   (if found
		       (subst expanded node form)
		       expanded)))))

      (map 'nil #'prep-changes changes)
      (walk-ast #'f x))))