;; This software is Copyright (c) 2012 Chris Bagley
;; (techsnuffle<at>gmail<dot>com)
;; Chris Bagley grants you the rights to
;; distribute and use this software as governed
;; by the terms of the Lisp Lesser GNU Public License
;; (http://opensource.franz.com/preamble.html),
;; known as the LLGPL.
(in-package :varjo)

;; [TODO] ensure all cast lists have the correct order.

;; spec types are to handle the manifest ugliness of the glsl spec.
;; dear god just one txt file with every permutation of every glsl
;; function would have save me so many hours work.
(defclass v-spec-type () 
  ((place :initform t :initarg :place :reader v-placep)))
(defclass v-tfd (v-spec-type) ())
(defclass v-tf (v-tfd) ()) ;; float vec*
(defclass v-td (v-tfd) ()) ;; double dvec*
(defclass v-tb (v-spec-type) ()) ;; bool bvec*
(defclass v-tiu (v-spec-type) ())
(defclass v-i-ui (v-spec-type) ()) ;; int uint
(defclass v-ti (v-tiu) ()) ;; int ivec*
(defclass v-tu (v-tiu) ()) ;; uint uvec*
(defclass v-tvec (v-spec-type) ()) ;;vec* uvec* ivec* [notice no dvec]

(defclass v-array (v-container) 
  ((element-type :initform nil :initarg :element-type :reader v-element-type)
   (dimensions :initform nil :initarg :dimensions :accessor v-dimensions)))
(defmethod v-glsl-string ((object v-array))
  (format nil "~a ~~a~{[~a]~}" (v-element-type object) (v-dimensions object)))

(defclass v-none (v-t-type) ())

(defclass v-stream (v-type) ())

(defclass v-function (v-type)
  ((restriction :initform nil :initarg :restriction :accessor v-restriction)
   (argument-spec :initform nil :initarg :arg-spec :accessor v-argument-spec)
   (code :initform nil :initarg :code :accessor v-code)
   (glsl-string :initform "" :initarg :glsl-string :reader v-glsl-string)
   (glsl-name :initarg :glsl-name :accessor v-glsl-string)
   (return-spec :initform nil :initarg :return-spec :accessor v-return-spec)
   (place :initform nil :initarg :place :accessor v-placep)
   (glsl-spec-matching :initform nil :initarg :glsl-spec-matching :reader v-glsl-spec-matchingp)))

(defclass v-struct (v-type)
  ((restriction :initform nil :initarg :restriction :accessor v-restriction)
   (glsl-string :initform "" :initarg :glsl-string :reader v-glsl-string)
   (slots :initform nil :initarg :slots :reader v-slots)))

(defclass v-user-struct (v-struct) ())

(defclass v-fake-struct (v-user-struct)
  ((fake-type-name :initform nil :initarg :fake-type-name :accessor v-fake-type-name)
   (restriction :initform nil :initarg :restriction :accessor v-restriction)
   (glsl-string :initform "" :initarg :glsl-string :reader v-glsl-string)
   (slots :initform nil :initarg :slots :reader v-slots)))

(defclass v-error (v-type) 
  ((payload :initform nil :initarg :payload :accessor v-payload)))

(defclass v-void (v-t-type)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "void" :reader v-glsl-string)))

(defclass v-bool (v-type v-tb) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bool" :reader v-glsl-string)))

(defclass v-number (v-type) ())
(defclass v-int (v-number v-ti v-i-ui)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "int" :reader v-glsl-string)
   (casts-to :initform '(v-uint v-float v-double))))
(defclass v-uint (v-number v-tu v-i-ui)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uint" :reader v-glsl-string)
   (casts-to :initform '(v-float v-double))))
(defclass v-float (v-number v-tf)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "float" :reader v-glsl-string)
   (casts-to :initform '(v-double))))
(defclass v-short-float (v-number) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "short-float" :reader v-glsl-string)))
(defclass v-double (v-number v-td) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "double" :reader v-glsl-string)))

(defclass v-container (v-type)
  ((element-type :initform nil :reader v-element-type)
   (dimensions :initform nil :accessor v-dimensions)))

(defclass v-matrix (v-container) ())
(defclass v-mat2 (v-matrix) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat2" :reader v-glsl-string)
   (element-type :initform 'v-float :reader v-element-type)
   (dimensions :initform '(2 2) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2))))
(defclass v-mat3 (v-matrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat3" :reader v-glsl-string)
   (element-type :initform 'v-float :reader v-element-type)
   (dimensions :initform '(3 3) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3))))
(defclass v-mat4 (v-matrix)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "mat4" :reader v-glsl-string)
   (element-type :initform 'v-float :reader v-element-type)
   (dimensions :initform '(4 4) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4))))
(defclass V-MAT2X2 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x2" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(2 2) :reader v-dimensions)
   (glsl-size :initform 2)))
(defclass V-MAT2X3 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x3" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(2 3) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2x3))))
(defclass V-MAT2X4 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat2x4" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(2 4) :reader v-dimensions)
   (glsl-size :initform 2)
   (casts-to :initform '(v-dmat2x4))))
(defclass V-MAT3X2 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x2" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(3 2) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3x2))))
(defclass V-MAT3X3 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x3" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(3 3) :reader v-dimensions)
   (glsl-size :initform 3)))
(defclass V-MAT3X4 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat3x4" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(3 4) :reader v-dimensions)
   (glsl-size :initform 3)
   (casts-to :initform '(v-dmat3x4))))
(defclass V-MAT4X2 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x2" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(4 2) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4x2))))
(defclass V-MAT4X3 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x3" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(4 3) :reader v-dimensions)
   (glsl-size :initform 4)
   (casts-to :initform '(v-dmat4x3))))
(defclass V-MAT4X4 (v-matrix)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "mat4x4" :reader v-glsl-string)
   (element-type :initform 'V-FLOAT :reader v-element-type)
   (dimensions :initform '(4 4) :reader v-dimensions)
   (glsl-size :initform 4)))

(defclass v-vector (v-container) ())
(defclass v-fvector (v-vector v-tf v-tvec) ())

(defclass v-vec2 (v-fvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "vec2" :reader v-glsl-string)
   (element-type :initform 'v-float :reader v-element-type)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-dvec2))))
(defclass v-vec3 (v-fvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "vec3" :reader v-glsl-string)
   (element-type :initform 'v-float :reader v-element-type)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-dvec3))))
(defclass v-vec4 (v-fvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "vec4" :reader v-glsl-string)
   (element-type :initform 'v-float :reader v-element-type)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-dvec4))))

(defclass v-bvector (v-vector v-tb) ())
(defclass v-bvec2 (v-bvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bvec2" :reader v-glsl-string)
   (element-type :initform 'v-bool :reader v-element-type)
   (dimensions :initform '(2) :reader v-dimensions)))
(defclass v-bvec3 (v-bvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bvec3" :reader v-glsl-string)
   (element-type :initform 'v-bool :reader v-element-type)
   (dimensions :initform '(3) :reader v-dimensions)))
(defclass v-bvec4 (v-bvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "bvec4" :reader v-glsl-string)
   (element-type :initform 'v-bool :reader v-element-type)
   (dimensions :initform '(4) :reader v-dimensions)))

(defclass v-uvector (v-vector v-tu) ())
(defclass v-uvec2 (v-uvector v-tvec)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uvec2" :reader v-glsl-string)
   (element-type :initform 'v-uint :reader v-element-type)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-dvec2 v-vec2))))
(defclass v-uvec3 (v-uvector)
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uvec3" :reader v-glsl-string)
   (element-type :initform 'v-uint :reader v-element-type)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-dvec3 v-vec3))))
(defclass v-uvec4 (v-uvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "uvec4" :reader v-glsl-string)
   (element-type :initform 'v-uint :reader v-element-type)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-dvec4 v-vec4))))

(defclass v-ivector (v-vector v-ti) ())
(defclass v-ivec2 (v-ivector v-tvec) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec2" :reader v-glsl-string)
   (element-type :initform 'v-int :reader v-element-type)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-uvec2 v-vec2 v-dvec2))))
(defclass v-ivec3 (v-ivector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec3" :reader v-glsl-string)
   (element-type :initform 'v-int :reader v-element-type)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-uvec3 v-vec3 v-dvec3))))
(defclass v-ivec4 (v-ivector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec4" :reader v-glsl-string)
   (element-type :initform 'v-int :reader v-element-type)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-uvec4 v-vec4 v-dvec4))))

(defclass v-dvector (v-vector) ())
(defclass v-dvec2 (v-dvector v-td) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec2" :reader v-glsl-string)
   (element-type :initform 'v-dnt :reader v-element-type)
   (dimensions :initform '(2) :reader v-dimensions)
   (casts-to :initform '(v-uvec2 v-vec2 v-dvec2))))
(defclass v-dvec3 (v-dvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec3" :reader v-glsl-string)
   (element-type :initform 'v-dnt :reader v-element-type)
   (dimensions :initform '(3) :reader v-dimensions)
   (casts-to :initform '(v-uvec3 v-vec3 v-dvec3))))
(defclass v-dvec4 (v-dvector) 
  ((core :initform t :reader core-typep)
   (glsl-string :initform "ivec4" :reader v-glsl-string)
   (element-type :initform 'v-dnt :reader v-element-type)
   (dimensions :initform '(4) :reader v-dimensions)
   (casts-to :initform '(v-uvec4 v-vec4 v-dvec4))))

(defclass v-sampler (v-type) ())
(defclass V-ISAMPLER-1D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-1D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-1D-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-1d-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-2D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-2D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-2D-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-2d-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-2D-MS (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-2d-MS" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-2D-MS-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-2d-MS-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-2D-RECT (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-2d-Rect" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-3D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-3d" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-BUFFER (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-Buffer" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-CUBE (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-Cube" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-ISAMPLER-CUBE-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "isampler-Cube-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-1D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-1D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-1D-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-1d-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-1D-ARRAY-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-1d-Array-Shadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-1D-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-1d-Shadow" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-ARRAY-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-Array-Shadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-MS (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-MS" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-MS-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-MS-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-RECT (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-Rect" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-RECT-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-Rect-Shadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-2D-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-2d-Shadow" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-3D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-3d" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-BUFFER (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-Buffer" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-CUBE (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-Cube" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-CUBE-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-Cube-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-CUBE-ARRAY-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-Cube-Array-Shadow" :reader
                glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass v-sampler-CUBE-SHADOW (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "sampler-Cube-Shadow" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-1D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-1D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-1D-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-1d-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-2D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-2D" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-2D-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-2d-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-2D-MS (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-2d-MS" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-2D-MS-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-2d-MS-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-2D-RECT (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-2d-Rect" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-3D (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-3d" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-BUFFER (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-Buffer" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-CUBE (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-Cube" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))
(defclass V-USAMPLER-CUBE-ARRAY (v-sampler)
  ((core :initform T :reader core-typep)
   (glsl-string :initform "usampler-Cube-Array" :reader v-glsl-string)
   (element-type :initform 'V-VEC4 :reader v-element-type)))

;;----------------------------------------------------------------------

(defun v-spec-typep (obj)
  (and (typep obj 'v-spec-type)
       (not (typep obj 'v-type))))

(defmethod v-type-name ((type v-t-type)) ;; this used to be v-type (I think)
  (class-name (class-of type)))
;; (defmethod v-type-name ((type v-spec-type))
;;   (class-name (class-of type)))

(defmethod v-type-name ((type v-array))
  (list (v-element-type type) (v-dimensions type)))

(defun type-spec->type (spec &key place)  
  (cond ((null spec) (error 'unknown-type-spec :type-spec spec))
        ((symbolp spec) 
         (let ((type (make-instance (if (keywordp spec) (symb 'v- spec) spec))))
           (when (slot-exists-p type 'place) 
             (setf (slot-value type 'place) place))
           type))
        ((listp spec)
         (destructuring-bind (type dimensions) spec
           (make-instance 'v-array :element-type (if (keywordp spec)
                                                     (symb 'v- type)
                                                     type)
                          :place place
                          :dimensions dimensions)))
        (t (error 'unknown-type-spec :type-spec spec))))

(defmethod v-glsl-size ((type t))
  (slot-value type 'glsl-size))

(defmethod v-glsl-size ((type v-array))
  (* (apply #'* (v-dimensions type)) 
     (slot-value (v-element-type type) 'glsl-size)))

(defmethod v-type-eq ((a v-type) (b v-type))
  (eq (v-type-name a) (v-type-name b)))
(defmethod v-type-eq ((a v-type) (b symbol))
  (eq (v-type-name a) (v-type-name (type-spec->type b))))
(defmethod v-type-eq ((a v-type) (b list))
  (eq (v-type-name a) (v-type-name (type-spec->type b))))

(defmethod v-typep ((a v-type) (b v-type))
  (typep a (v-type-name b)))
(defmethod v-typep ((a v-type) b)
  (typep a (v-type-name (type-spec->type b))))

(defmethod v-casts-to-p (from-type to-type)
  (not (null (v-casts-to from-type to-type))))

(defmethod v-casts-to ((from-type v-type) (to-type symbol))
  (if (typep from-type to-type)
      from-type
      (when (slot-exists-p from-type 'casts-to)
        (loop :for cast :in (slot-value from-type 'casts-to)
           :for cast-type = (type-spec->type cast)
           :if (typep cast-type to-type) :return cast-type))))

(defun find-mutual-cast-type (&rest types)
  (let ((names (loop :for type :in types
                         :collect (if (typep type 'v-t-type)
                                      (v-type-name type)
                                      type))))
    (if (loop :for name :in names :always (eq name (first names)))
        (first names)
        (let* ((all-casts (sort (loop :for type :in types :for name :in names :collect
                                   (cons name
                                         (if (symbolp type)
                                             (slot-value (make-instance type) 
                                                         'casts-to) 
                                             (slot-value type 'casts-to))))
                                #'> :key #'length))
               (master (first all-casts))
               (rest-casts (rest all-casts)))
          (first (sort (loop :for type :in master 
                          :if (loop :for casts :in rest-casts 
                                 :always (find type casts))
                          :collect type) #'> :key #'v-superior-score))))))

(let ((order-or-superiority '(v-double v-float v-int v-uint v-vec2 v-ivec2 
                              v-uvec2 v-vec3 v-ivec3 v-uvec3 v-vec4 v-ivec4
                              v-uvec4 v-mat2 v-mat2x2 v-mat3 v-mat3x3 v-mat4
                              v-mat4x4)))
  (defun v-superior-score (type)
    (or (position type order-or-superiority) -1))
  (defun v-superior (x y) 
    (< (or (position x order-or-superiority) -1)
       (or (position y order-or-superiority) -1))))

(defun v-superior-type (&rest types)
  (first (sort types #'v-superior)))

(defgeneric v-special-functionp (func))

(defmethod v-special-functionp ((func v-function))
  (eq :special (v-glsl-string func)))

(defun v-errorp (obj) (typep obj 'v-error))

(defmethod post-initialise ((object v-t-type)))
(defmethod post-initialise ((object v-container))
  (setf (v-dimensions object) (listify (v-dimensions object))))

(defmethod initialize-instance :after ((type-obj v-t-type) &rest initargs)
  (declare (ignore initargs))
  (post-initialise type-obj))
