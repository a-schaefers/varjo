(in-package :varjo.tests)

(defmacro profile-all-varjo ()
  (let ((packages '(:varjo.utils
                    :vari.types
                    :varjo.internals
                    :varjo.api
                    :vari.glsl
                    :vari.cl
                    :vari
                    :varjo
                    :vas-string-metrics
                    :split-sequence
                    :parse-float
                    :alexandria
                    :cl-ppcre)))
    `(sb-profile:profile
      ,@(loop :for p :in packages :append
           (let ((pkg (find-package p)))
             (loop :for s :being :the symbol :in p
                :when (and (eq pkg (symbol-package s)) (fboundp s))
                :collect s))))))

(defmacro unprofile-all-varjo ()
  (let ((packages '(:varjo.utils
                    :vari.types
                    :varjo.internals
                    :varjo.api
                    :vari.glsl
                    :vari.cl
                    :vari
                    :varjo
                    :vas-string-metrics
                    :split-sequence
                    :parse-float
                    :alexandria
                    :cl-ppcre)))
    `(progn
       (sb-profile:unprofile
        ,@(loop :for p :in packages :append
             (let ((pkg (find-package p)))
               (loop :for s :being :the symbol :in p
                  :when (and (eq pkg (symbol-package s)) (fboundp s))
                  :collect s))))
       (sb-profile:reset))))

(defun gooo (stages)
  (sb-profile:reset)
  (time
   (loop :for i :below 30 :do
      (rolling-translate stages)))
  (sb-profile:report))

(defun hmm (stage)
  (sb-profile:reset)
  (time
   (loop :for i :below 10 :do
      (translate stage)))
  (sb-profile:report))


;; (require :sb-sprof)
;;
;; (defun kick-off (stage)
;;   (sb-sprof:reset)
;;   (sb-sprof:start-profiling :sample-interval 0.001)
;;   (loop :for i :below 10000 :do
;;      (translate stage))
;;   (sb-sprof:stop-profiling)
;;   (sb-sprof:report :type :flat))
