(in-package :varjo)

(add-equivalent-name 'cl:length 'rtg-math.vectors:length)

(v-defun x (a) "~a.x" (v-bvec2) v-bool :v-place-index 0)
(v-defun x (a) "~a.x" (v-bvec3) v-bool :v-place-index 0)
(v-defun x (a) "~a.x" (v-bvec4) v-bool :v-place-index 0)
(v-defun x (a) "~a.x" (v-dvec2) v-double :v-place-index 0)
(v-defun x (a) "~a.x" (v-dvec3) v-double :v-place-index 0)
(v-defun x (a) "~a.x" (v-dvec4) v-double :v-place-index 0)
(v-defun x (a) "~a.x" (v-ivec2) v-int :v-place-index 0)
(v-defun x (a) "~a.x" (v-ivec3) v-int :v-place-index 0)
(v-defun x (a) "~a.x" (v-ivec4) v-int :v-place-index 0)
(v-defun x (a) "~a.x" (v-uvec2) v-uint :v-place-index 0)
(v-defun x (a) "~a.x" (v-uvec3) v-uint :v-place-index 0)
(v-defun x (a) "~a.x" (v-uvec4) v-uint :v-place-index 0)
(v-defun x (a) "~a.x" (v-vec2) v-float :v-place-index 0)
(v-defun x (a) "~a.x" (v-vec3) v-float :v-place-index 0)
(v-defun x (a) "~a.x" (v-vec4) v-float :v-place-index 0)

(v-defun y (a) "~a.y" (v-bvec2) v-bool :v-place-index 0)
(v-defun y (a) "~a.y" (v-bvec3) v-bool :v-place-index 0)
(v-defun y (a) "~a.y" (v-bvec4) v-bool :v-place-index 0)
(v-defun y (a) "~a.y" (v-dvec2) v-double :v-place-index 0)
(v-defun y (a) "~a.y" (v-dvec3) v-double :v-place-index 0)
(v-defun y (a) "~a.y" (v-dvec4) v-double :v-place-index 0)
(v-defun y (a) "~a.y" (v-ivec2) v-int :v-place-index 0)
(v-defun y (a) "~a.y" (v-ivec3) v-int :v-place-index 0)
(v-defun y (a) "~a.y" (v-ivec4) v-int :v-place-index 0)
(v-defun y (a) "~a.y" (v-uvec2) v-uint :v-place-index 0)
(v-defun y (a) "~a.y" (v-uvec3) v-uint :v-place-index 0)
(v-defun y (a) "~a.y" (v-uvec4) v-uint :v-place-index 0)
(v-defun y (a) "~a.y" (v-vec2) v-float :v-place-index 0)
(v-defun y (a) "~a.y" (v-vec3) v-float :v-place-index 0)
(v-defun y (a) "~a.y" (v-vec4) v-float :v-place-index 0)

(v-defun z (a) "~a.z" (v-vec3)  v-float :v-place-index 0)
(v-defun z (a) "~a.z" (v-bvec3) v-bool :v-place-index 0)
(v-defun z (a) "~a.z" (v-ivec3) v-int :v-place-index 0)
(v-defun z (a) "~a.z" (v-uvec3) v-uint :v-place-index 0)
(v-defun z (a) "~a.z" (v-dvec3) v-double :v-place-index 0)
(v-defun z (a) "~a.z" (v-vec4)  v-float :v-place-index 0)
(v-defun z (a) "~a.z" (v-bvec4) v-bool :v-place-index 0)
(v-defun z (a) "~a.z" (v-ivec4) v-int :v-place-index 0)
(v-defun z (a) "~a.z" (v-uvec4) v-uint :v-place-index 0)
(v-defun z (a) "~a.z" (v-dvec4) v-double :v-place-index 0)

(v-defun w (a) "~a.w" (v-vec4) v-float :v-place-index 0)
(v-defun w (a) "~a.w" (v-bvec4) v-bool :v-place-index 0)
(v-defun w (a) "~a.w" (v-ivec4) v-int :v-place-index 0)
(v-defun w (a) "~a.w" (v-uvec4) v-uint :v-place-index 0)
(v-defun w (a) "~a.w" (v-dvec4) v-double :v-place-index 0)


;; m3

(v-defun rtg-math.matrix3:make (a b c d e f g h i)
  "mat3(~a,~a,~a,~a,~a,~a,~a,~a,~a)"
  (v-float v-float v-float v-float v-float v-float v-float v-float v-float)
  v-mat3)

(v-defun m3:melm (m r c) "~a[~a, ~a]" (v-mat3 v-int v-int)
	 v-float)

(v-defun m3:melm (m r c) "~a[~a, ~a]" (v-dmat3 v-int v-int)
	 v-double)


(v-defun m3:identity () "mat3(1.0)" () v-mat3)
(v-defun m3:0! () "mat3(0.0)" () v-mat3)

(v-defun m3:from-columns (a b c) "mat3(~a, ~a, ~a)" (v-vec3 v-vec3 v-vec3)
	 v-mat3)

;; m4

(v-defun rtg-math.matrix4:make (a b c d e f g h i j k l m n o p)
  "mat4(~a,~a,~a,~a,~a,~a,~a,~a,~a,~a,~a,~a,~a,~a,~a,~a)"
  (v-float v-float v-float v-float v-float v-float v-float v-float v-float
           v-float v-float v-float v-float v-float v-float v-float v-float)
  v-mat4)

(v-defun m4:melm (m r c) "~a[~a, ~a]" (v-mat4 v-int v-int)
	 v-float)

(v-defun m4:melm (m r c) "~a[~a, ~a]" (v-dmat4 v-int v-int)
	 v-double)

(v-defun m4:identity () "mat4(1.0)" () v-mat4)
(v-defun m4:0! () "mat4(0.0)" () v-mat4)

(v-defun m4:from-columns (a b c d) "mat4(~a, ~a, ~a, ~a)"
	 (v-vec4 v-vec4 v-vec4 v-vec4) v-mat3)

(v-defun rtg-math.matrix4:to-mat3 (m) "mat3(~a)" (v-mat4) v-mat3)

(v-defun v2! (x) "vec2(~a)" (v-float) v-vec2)
(v-defun v2! (x y) "vec2(~a, ~a)" (v-float v-float) v-vec2)
(v-defun v2!double (x) "dvec2(~a)" (v-double) v-dvec2)
(v-defun v2!double (x y) "dvec2(~a, ~a)" (v-double v-double) v-dvec2)
(v-defun v2!int (x) "ivec2(~a)" (v-int) v-ivec2)
(v-defun v2!int (x y) "ivec2(~a, ~a)" (v-int v-int) v-ivec2)
(v-defun v2!uint (x) "uvec2(~a)" (v-uint) v-uvec2)
(v-defun v2!uint (x y) "uvec2(~a, ~a)" (v-uint v-uint) v-uvec2)

(v-defun v3! (x) "vec3(~a)" (v-float) v-vec3)
(v-defun v3! (x y) "vec3(~a, ~a)" (v-float v-float) v-vec3)
(v-defun v3! (x y z) "vec3(~a, ~a, ~a)" (v-float v-float v-float) v-vec3)
(v-defun v3!double (x) "dvec3(~a)" (v-double) v-dvec3)
(v-defun v3!double (x y) "dvec3(~a, ~a)" (v-double v-double) v-dvec3)
(v-defun v3!double (x y z) "dvec3(~a, ~a, ~a)" (v-double v-double v-double) v-dvec3)
(v-defun v3!int (x) "ivec3(~a)" (v-int) v-ivec3)
(v-defun v3!int (x y) "ivec3(~a, ~a)" (v-int v-int) v-ivec3)
(v-defun v3!int (x y z) "ivec3(~a, ~a, ~a)" (v-int v-int v-int) v-ivec3)
(v-defun v3!uint (x) "uvec3(~a)" (v-uint) v-uvec3)
(v-defun v3!uint (x y) "uvec3(~a, ~a)" (v-uint v-uint) v-uvec3)
(v-defun v3!uint (x y z) "uvec3(~a, ~a, ~a)" (v-uint v-uint v-uint) v-uvec3)

(v-defun v4! (x) "vec4(~a)" (v-float) v-vec4)
(v-defun v4! (x y) "vec4(~a, ~a)" (v-float v-float) v-vec4)
(v-defun v4! (x y z) "vec4(~a, ~a, ~a)" (v-float v-float v-float) v-vec4)
(v-defun v4! (x y z w) "vec4(~a, ~a, ~a, ~a)" (v-float v-float v-float v-float) v-vec4)
(v-defun v4!double (x) "dvec4(~a)" (v-double) v-dvec4)
(v-defun v4!double (x y) "dvec4(~a, ~a)" (v-double v-double) v-dvec4)
(v-defun v4!double (x y z) "dvec4(~a, ~a, ~a)" (v-double v-double v-double) v-dvec4)
(v-defun v4!double (x y z w) "dvec4(~a, ~a, ~a, ~a)" (v-double v-double v-double v-double) v-dvec4)
(v-defun v4!int (x) "ivec4(~a)" (v-int) v-ivec4)
(v-defun v4!int (x y) "ivec4(~a, ~a)" (v-int v-int) v-ivec4)
(v-defun v4!int (x y z) "ivec4(~a, ~a, ~a)" (v-int v-int v-int) v-ivec4)
(v-defun v4!int (x y z w) "ivec4(~a, ~a, ~a, ~a)" (v-int v-int v-int v-int) v-ivec4)
(v-defun v4!uint (x) "uvec4(~a)" (v-uint) v-uvec4)
(v-defun v4!uint (x y) "uvec4(~a, ~a)" (v-uint v-uint) v-uvec4)
(v-defun v4!uint (x y z) "uvec4(~a, ~a, ~a)" (v-uint v-uint v-uint) v-uvec4)
(v-defun v4!uint (x y z w) "uvec4(~a, ~a, ~a, ~a)" (v-uint v-uint v-uint v-uint) v-uvec4)
