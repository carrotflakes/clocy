(in-package :cl-user)
(defpackage clocy-test
  (:use :cl
        :clocy
        :prove))
(in-package :clocy-test)

;; NOTE: To run this test file, execute `(asdf:test-system :clocy)' in your Lisp.

(plan nil)

#|
(let* ((time 7743600) ; 1900/4/1 (sun) 00:00:00
       (gen (make-generator '(:next :date 2) time)))
  (is (generate-next gen) (+ time (* 1 24 60 60)))
  (is (generate-next gen) (+ time (* (+ 30 1) 24 60 60))))

(let* ((time 7743600)
       (gen (make-generator '(:next :hour 1) time)))
  (is (generate-next gen) (+ time (* 1 60 60)))
  (is (generate-next gen) (+ time (* 25 60 60)))
  (is (generate-next gen) (+ time (* 49 60 60))))

(let* ((time 7743600)
       (gen (make-generator '(:next :minute 1) time)))
  (is (generate-next gen) (+ time (* 1 60)))
  (is (generate-next gen) (+ time (* 61 60))))

(let* ((time 7743600)
       (gen (make-generator '(:next :second 1) time)))
  (is (generate-next gen) (+ time 1))
  (is (generate-next gen) (+ time 61)))


(let* ((time 10000000)
       (gen (make-generator '(:after :day 1) time)))
  (is (generate-next gen) (+ time (* 1 24 60 60)))
  (is (generate-next gen) nil))

(let* ((time 10000000)
       (gen (make-generator '(:after :hour 1) time)))
  (is (generate-next gen) (+ time (* 1 60 60)))
  (is (generate-next gen) nil))

(let* ((time 10000000)
       (gen (make-generator '(:after :minute 1) time)))
  (is (generate-next gen) (+ time (* 1 60)))
  (is (generate-next gen) nil))

(let* ((time 10000000)
       (gen (make-generator '(:after :second 1) time)))
  (is (generate-next gen) (+ time (* 1)))
  (is (generate-next gen) nil))

(let* ((time 10000000)
       (gen (make-generator '(:after :day 1 :hour 1 :minute 1 :second 1) time)))
  (is (generate-next gen) (+ time (+ (* (+ (* (+ (* 1 24) 1) 60) 1) 60) 1)))
  (is (generate-next gen) nil))


(let* ((time 10000000)
       (gen (make-generator '(:repeat :hour 1) time)))
  (is (generate-next gen) (+ time (* 1 60 60)))
  (is (generate-next gen) (+ time (* 2 60 60))))

(let* ((time 10000000)
       (gen (make-generator '(:repeat :minute 1) time)))
  (is (generate-next gen) (+ time (* 1 60)))
  (is (generate-next gen) (+ time (* 2 60))))

(let* ((time 10000000)
       (gen (make-generator '(:repeat :second 1) time)))
  (is (generate-next gen) (+ time (* 1)))
  (is (generate-next gen) (+ time (* 2))))
|#

(finalize)
