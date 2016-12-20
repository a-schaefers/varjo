(in-package :varjo.tests)

;;------------------------------------------------------------
;; Helper macros

(defmacro compile-vert (args version &body body)
  (destructuring-bind (in-args uniforms) (split-arguments args '(&uniform))
    `(first
      (v-compile ',uniforms ,version
                 :vertex '(,in-args ,@body)))))

(defmacro compile-frag (args version &body body)
  (destructuring-bind (in-args uniforms) (split-arguments args '(&uniform))
    `(first
      (v-compile ',uniforms ,version
                 :fragment '(,in-args ,@body)))))

(defun ast-stabalizes-p (compile-result &optional (depth 0) (max-depth 20))
  "Returns t if compile the ast->code of compile-result gives the same ast
   It is allowed to recompile up to 'max-depth' times in order to find
   convergence"
  (let* ((code (ast->code compile-result))
         (version (varjo::get-version-from-context-list
                   (context compile-result)))
         (recomp (first (v-compile (uniforms compile-result) version
                                   (stage-type compile-result)
                                   (list (in-args compile-result)
                                         code))))
         (recomp-code (ast->code recomp)))
    (or (values (equal code recomp-code) depth)
        (when (< depth max-depth)
          (ast-stabalizes-p recomp (incf depth))))))

(defmacro finishes-p (form)
  `(is (typep ,form 'varjo-compile-result)))

(defmacro glsl-contains-p (regex &body form)
  (assert (= 1 (length form)))
  `(is (cl-ppcre:all-matches ,regex (glsl-code ,(first form)))))

(defmacro glsl-doesnt-contain-p (regex &body form)
  (assert (= 1 (length form)))
  `(is (null (cl-ppcre:all-matches ,regex (glsl-code ,(first form))))))

;;------------------------------------------------------------

(5am:def-suite test-all)

(5am:in-suite test-all)

(5am:test build-0
  (finishes-p
   (compile-vert () :450
     (v! 0 0 0 0))))

(5am:test build-1
  (finishes-p
   (compile-vert () :450
     (v! 0 0 0 0)
     (v! 0 0 0 0))))

(5am:test build-2
  (finishes-p
   (compile-vert () :450
     (let ((x 1))
       (v! 0 x 1 2))
     (v! 0 0 0 0))))

(5am:test build-3
  (finishes-p
   (compile-vert () :450
     (let ((x 1)
           (y 2))
       (v! x y 1 2))
     (v! 0 0 0 0))))

(5am:test build-4
  (finishes-p
   (compile-vert () :450
     (labels ((test () 1))
       (test))
     (v! 0 0 0 0))))

(5am:test build-5
  (signals varjo-conditions:could-not-find-function
    (compile-vert () :450
      (labels ((test () 1))
        (test))
      (v! 0 (test) 0 0))))

(5am:test build-6
  (signals varjo-conditions:symbol-unidentified
    (compile-vert () :450
      (let ((x 1)
            (y 2))
        (v! 0 x 1 2))
      (v! 0 0 y 0))))

(5am:test build-7
  (finishes-p
   (compile-vert () :450
     (labels ((test () 1))
       (v! 0 (test) 0 0)))))

(5am:test build-8
  (finishes-p
   (compile-vert () :450
     (let ((x 2))
       (labels ((test () x))
         (v! 0 (test) 0 0))))))

(5am:test build-9
  (signals varjo-conditions:setq-type-match
    (compile-vert () :450
      ())))

(5am:test build-10
  (finishes-p
   (compile-vert () :450
     (labels ((test ((x :int)) (values x 2)))
       (v! 0 (test 1))
       (v! 0 0 0 0)))))

(5am:test build-11
  (finishes-p
   (compile-vert () :450
     (values (v! 1 2 3 4)
             (v! 1 2)))))

(5am:test build-12
  (finishes-p
   (compile-vert () :450
     (labels ((test ((x :int)) (values (v! 0 0 0 0) 2)))
       (test 1)))))

(5am:test build-13
  (finishes-p
   (compile-vert () :450
     (labels ((test ((x :int)) (values x 2)))
       (v! 0 (int (test 1)) 0 0)))))


(5am:test build-14
  (finishes-p
   (compile-vert () :450
     (values (v! 1 2 3 4)
             (v! 1 2))
     (v! 10 20 30 40))))

(5am:test build-15
  (finishes-p
   (compile-vert () :450
     (labels ((test ((x :int)) (values (v! 0 0 0 0) 2)))
       (test 1)
       (v! 10 20 30 40)))))

(5am:test build-16
  (finishes-p
   (compile-vert () :450
     (labels ((test ((x :int)) (values x 2)))
       (v! 0 (int (test 1)) 0 0)
       (v! 10 20 30 40)))))

(5am:test build-17
  (finishes-p
   (compile-vert () :450
     (let ((x 1))
       (let ((y 2)
             (z 3))
         (v! x y z)
         (%if (> x 2)
              (setq x y)
              (setq x z))
         (v! x 2 3 4))))))

(5am:test build-18
  (finishes-p
   (compile-vert () :450
     (let ((x 0)
           (z 1))
       (v! x z)
       (switch x
         (0 (setq z 1))
         (1 (setq z x))
         (2 z))
       (v! x z 3 4)))))

(5am:test build-19
  (finishes-p
   (compile-vert () :450
     (let ((x 0)
           (z 1))
       (v! x z)
       (while (< x 10)
         (setq x z)
         (setq z (+ 1 1)))
       (v! x z 3 4)))))

(5am:test build-20
  (finishes-p
   (compile-vert () :450
     (let ((x 1)
           (y 2)
           (z 3))
       (v! x y 0 0)))))

(5am:test build-21
  (finishes-p
   (compile-vert () :450
     (multiple-value-bind (x y) (values 1 2)
       (v! 0 0 0 0)))))

(5am:test build-22
  ;; trying to use gl-frag-coord in vertex shader
  (signals varjo-conditions:symbol-unidentified
    (compile-vert (&uniform (iresolution :vec2) (iglobaltime :float)) :450
      (let* (((z :vec2) (/ (* 1.15 (- (* (s~ gl-frag-coord :xy) 2.0)
                                      (s~ iResolution :xy)))
                           (y iResolution)))
             (vtemp (v2! 0.0 1.5708))
             (vtime (v2! (* .05 iGlobalTime)))
             (an  (- (* 0.51 (cos (+ vtemp vtime)))
                     (* 0.25 (cos (+ vtemp vtime vtime)))))
             (f 1e20))
        (for (i 0) (< i 120) (++ i)
             (let ((xz (x z)) (yz (y z)))
               (setf z (+ an (v! (- (* xz xz) (* yz yz))
                                 (* 2.0 xz yz)))
                     f (min f (dot z z)))))
        (setf f (+ 1.0 (/ (log f) 16)))
        (v! f (* f f) (* f f f ) 1.0)))))

(5am:test build-23
  ;; same as build-22 but in fragment shader
  (finishes-p
   (compile-frag (&uniform (iresolution :vec2) (iglobaltime :float)) :450
     (let* (((z :vec2) (/ (* 1.15 (- (* (s~ gl-frag-coord :xy) 2.0)
                                     (s~ iResolution :xy)))
                          (y iResolution)))
            (vtemp (v2! 0.0 1.5708))
            (vtime (v2! (* .05 iGlobalTime)))
            (an  (- (* 0.51 (cos (+ vtemp vtime)))
                    (* 0.25 (cos (+ vtemp vtime vtime)))))
            (f 1e20))
       (for (i 0) (< i 120) (++ i)
            (let ((xz (x z)) (yz (y z)))
              (setf z (+ an (v! (- (* xz xz) (* yz yz))
                                (* 2.0 xz yz)))
                    f (min f (dot z z)))))
       (setf f (+ 1.0 (/ (log f) 16)))
       (v! f (* f f) (* f f f ) 1.0)))))


(5am:test build-24
  ;; same as build-22 but in fragment shader
  (is (ast-stabalizes-p
       (compile-frag (&uniform (iresolution :vec2) (iglobaltime :float)) :450
         (let* (((z :vec2) (/ (* 1.15 (- (* (s~ gl-frag-coord :xy) 2.0)
                                         (s~ iResolution :xy)))
                              (y iResolution)))
                (vtemp (v2! 0.0 1.5708))
                (vtime (v2! (* .05 iGlobalTime)))
                (an  (- (* 0.51 (cos (+ vtemp vtime)))
                        (* 0.25 (cos (+ vtemp vtime vtime)))))
                (f 1e20))
           (for (i 0) (< i 120) (++ i)
                (let ((xz (x z)) (yz (y z)))
                  (setf z (+ an (v! (- (* xz xz) (* yz yz))
                                    (* 2.0 xz yz)))
                        f (min f (dot z z)))))
           (setf f (+ 1.0 (/ (log f) 16)))
           (v! f (* f f) (* f f f ) 1.0))))))

;;------------------------------------------------------------

(5am:test build-25
  (finishes-p
   (compile-vert () :450
     (let ((fn (labels ((test ((x :int)) x))
                 #'test)))
       (v! 0 0 0 0)))))

(5am:test build-26
  (finishes-p
   (compile-vert () :450
     (let ((fn (labels ((test ((x :int)) x))
                 #'test)))
       (funcall fn 10)
       (v! 0 0 0 0)))))

(5am:test build-27
  (glsl-doesnt-contain-p "FN;"
    (compile-vert () :450
      (let ((fn (labels ((test ((x :int)) x))
                  #'test)))
        fn
        (v! 0 0 0 0)))))

(5am:test build-28
  (glsl-doesnt-contain-p "FN;"
    (compile-vert () :450
      (let ((fn (labels ((test ((x :int)) x))
                  #'test)))
        (labels ((foo ((ffn (function (:int) :int)))
                   (funcall ffn 10)))
          (foo fn))
        (v! 0 0 0 0)))))

(5am:test build-29
  (signals varjo-conditions:closures-not-supported
    (varjo.tests::compile-vert () :450
      (let* ((y 10)
             (fn (labels ((test ((x :int)) (* y x)))
                   #'test)))
        (v! 0 0 0 0)))))

(5am:test build-30
  (signals varjo-conditions:cross-scope-mutate
    (varjo.tests::compile-vert () :450
      (let* ((y 10)
             (fn (labels ((test ((x :int))
                            (setf y 2)
                            x))
                   #'test)))
        (funcall fn 10)
        (v! 0 0 0 0)))))

(5am:test build-31
  (signals varjo-conditions:cross-scope-mutate
    (varjo.tests::compile-vert () :450
      (let* ((y 10)
             (fn (labels ((test ((x :int)) x))
                   #'test)))
        (labels ((foo ((ffn (function (:int) :int)))
                   (setf y 2)
                   (funcall ffn 10)))
          (foo fn))
        (v! 0 0 0 0)))))

(5am:test build-32
  (signals varjo-conditions:symbol-unidentified
    (varjo.tests::compile-vert () :450
      (labels ((foo ((ffn (function (:int) :int)))
                 (funcall ffn y)))
        (let ((y 10))
          (foo (lambda ((a :int)) a))))
      (v! 0 0 0 0))))
