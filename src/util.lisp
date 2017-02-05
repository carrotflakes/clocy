(in-package :cl-user)
(defpackage clocy.util
  (:use :cl)
  (:export #:leap-year-p
           #:days-in-month
           #:compute-day
           #:duration))
(in-package :clocy.util)


(defun leap-year-p (year)
  (or (and (= (mod year 4) 0)
           (/= (mod year 100) 0))
      (= (mod year 400) 0)))

(defun days-in-month (year month)
  (case month
    ((1 3 5 7 8 10 12) 31)
    ((4 6 9 11) 30)
    ((2) (if (leap-year-p year)
             29
             28))))

(defun compute-day (year month date)
  (when (<= month 2)
    (decf year)
    (incf month 12))
  (mod (+ date
          (floor (* 26 (+ month 1)) 10)
          (mod year 100)
          (floor (mod year 100) 4)
          (+ (* 5 (floor year 100))
             (floor (floor year 100) 4))
          5)
       7))

(defun duration (day hour minute second)
  (+ (* 60
        (+ (* 60
              (+ (* 24
                    (or day 0))
                 (or hour 0)))
           (or minute 0)))
     (or second 0)))
