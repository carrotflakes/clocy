(in-package :cl-user)
(defpackage clocy-test
  (:use :cl
        :clocy
        :prove))
(in-package :clocy-test)

;; NOTE: To run this test file, execute `(asdf:test-system :clocy)' in your Lisp.

(plan nil)


(subtest "get-time"
         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :second 10 :now time)))
           (is (get-time gen) (encode-universal-time 10 2 3 4 5 2006))
           (is (next gen)     (encode-universal-time 10 2 3 4 5 2006))
           (is (get-time gen) (encode-universal-time 10 3 3 4 5 2006))
           (is (next gen)     (encode-universal-time 10 3 3 4 5 2006))))

(subtest "day"
         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :day 0 :now time)))
           (is (next gen) (encode-universal-time 0 0 0 8 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 15 5 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :day '(0 4) :now time)))
           (is (next gen) (encode-universal-time 0 0 0 5 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 8 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 12 5 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :day :monday :now time)))
           (is (next gen) (encode-universal-time 0 0 0 8 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 15 5 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :day '(:monday :friday) :now time)))
           (is (next gen) (encode-universal-time 0 0 0 5 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 8 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 12 5 2006)))

         (let* ((time (encode-universal-time 0 0 0 1 1 2017))
                (gen (all :year 2017
                          :month :every
                          :date 13
                          :day :friday
                          :now time)))
           (is (next gen) (encode-universal-time 0 0 0 13 1 2017))
           (is (next gen) (encode-universal-time 0 0 0 13 10 2017))
           (is (next gen) nil)))

(subtest "all"
         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :second 10 :now time)))
           (is (next gen) (encode-universal-time 10 2 3 4 5 2006))
           (is (next gen) (encode-universal-time 10 3 3 4 5 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :date 10 :now time)))
           (is (next gen) (encode-universal-time 0 0 0 10 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 10 6 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :hour 9 :minute 8 :second 7 :now time)))
           (is (next gen) (encode-universal-time 7 8 9 4 5 2006))
           (is (next gen) (encode-universal-time 7 8 9 5 5 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :date 10 :minute 11 :now time)))
           (is (next gen) (encode-universal-time 0 11 0 10 5 2006))
           (is (next gen) (encode-universal-time 0 11 0 10 6 2006)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :date 10 :hour :every :minute 11 :now time)))
           (is (next gen) (encode-universal-time 0 11 0 10 5 2006))
           (is (next gen) (encode-universal-time 0 11 1 10 5 2006)))

         (let* ((time (encode-universal-time 58 59 23 4 5 2006))
                (gen (all :now time)))
           (is (next gen) (encode-universal-time 58 59 23 4 5 2006))
           (is (next gen) (encode-universal-time 59 59 23 4 5 2006))
           (is (next gen) (encode-universal-time 0 0 0 5 5 2006))
           (is (next gen) (encode-universal-time 1 0 0 5 5 2006)))

         (let* ((time (encode-universal-time 2 59 3 4 5 2006))
                (gen (all :second 1 :now time)))
           (is (next gen) (encode-universal-time 1 0 4 4 5 2006))
           (is (next gen) (encode-universal-time 1 1 4 4 5 2006)))

         (let* ((time (encode-universal-time 59 59 3 4 5 2006))
                (gen (all :hour 1 :now time)))
           (is (next gen) (encode-universal-time 0 0 1 5 5 2006)))

         (let* ((time (encode-universal-time 59 59 23 31 5 2006))
                (gen (all :hour 1 :now time)))
           (is (next gen) (encode-universal-time 0 0 1 1 6 2006)))

         (let* ((time (encode-universal-time 59 59 23 31 12 2006))
                (gen (all :hour 1 :now time)))
           (is (next gen) (encode-universal-time 0 0 1 1 1 2007)))

         (let* ((time (encode-universal-time 1 2 3 4 5 1999))
                (gen (all :month 2 :date 29 :now time)))
           (is (next gen) (encode-universal-time 0 0 0 29 2 2000))
           (is (next gen) (encode-universal-time 0 0 0 29 2 2004))
           (is (next gen) (encode-universal-time 0 0 0 29 2 2008)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2095))
                (gen (all :month 2 :date 29 :now time)))
           (is (next gen) (encode-universal-time 0 0 0 29 2 2096))
           (is (next gen) (encode-universal-time 0 0 0 29 2 2104)))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :year 2006 :month 5 :date 4 :hour 3 :minute 2 :now time)))
           (is (next gen) (encode-universal-time 1 2 3 4 5 2006))
           (is (next gen) nil))

         (let* ((time (encode-universal-time 1 2 3 4 5 2006))
                (gen (all :year 2006 :month 5 :date 4 :hour 3 :minute 2 :second 0 :now time)))
           (is (next gen) nil)))


(subtest "once"
         (let* ((time 7743600) ;; = 1900/4/1 (sun) 00:00:00
                (gen (once :date 2 :now time)))
           (is (next gen) (+ time (* 1 24 60 60)))
           (is (next gen) nil))

         (let* ((time 7743600)
                (gen (once :hour 1 :now time)))
           (is (next gen) (+ time (* 1 60 60)))
           (is (next gen) nil))

         (let* ((time 7743600)
                (gen (once :minute 1 :now time)))
           (is (next gen) (+ time (* 1 60)))
           (is (next gen) nil))

         (let* ((time 7743600)
                (gen (once :second 1 :now time)))
           (is (next gen) (+ time 1))
           (is (next gen) nil)))


(subtest "after"
         (let* ((time 10000000)
                (gen (after :day 1 :now time)))
           (is (next gen) (+ time (* 1 24 60 60)))
           (is (next gen) nil))

         (let* ((time 10000000)
                (gen (after :hour 1 :now time)))
           (is (next gen) (+ time (* 1 60 60)))
           (is (next gen) nil))

         (let* ((time 10000000)
                (gen (after :minute 1 :now time)))
           (is (next gen) (+ time (* 1 60)))
           (is (next gen) nil))

         (let* ((time 10000000)
                (gen (after :second 1 :now time)))
           (is (next gen) (+ time (* 1)))
           (is (next gen) nil))

         (let* ((time 10000000)
                (gen (after :day 1 :hour 1 :minute 1 :second 1 :now time)))
           (is (next gen) (+ time (+ (* (+ (* (+ (* 1 24) 1) 60) 1) 60) 1)))
           (is (next gen) nil)))


(subtest "repeat"
         (let* ((time 10000000)
                (gen (repeat :hour 1 :now time)))
           (is (next gen) (+ time (* 1 60 60)))
           (is (next gen) (+ time (* 2 60 60)))
           (is (next gen) (+ time (* 3 60 60))))

         (let* ((time 10000000)
                (gen (repeat :minute 1 :now time)))
           (is (next gen) (+ time (* 1 60)))
           (is (next gen) (+ time (* 2 60))))

         (let* ((time 10000000)
                (gen (repeat :second 1 :now time)))
           (is (next gen) (+ time (* 1)))
           (is (next gen) (+ time (* 2)))))


(finalize)
