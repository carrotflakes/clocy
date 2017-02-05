(in-package :cl-user)
(defpackage clocy
  (:use :cl :clocy.core)
  (:import-from :clocy.util
                #:duration)
  (:export #:once
           #:all
           #:after
           #:repeat
           #:get-time
           #:next))
(in-package :clocy)


(defstruct once-generator
  time)

(defstruct all-generator
  time
  next-time
  specifier)

(defstruct after-generator
  time)

(defstruct repeat-generator
  time
  delta-time)


(defun day-id (day)
  (case day
    ((:monday)    0)
    ((:tuesday)   1)
    ((:wednesday) 2)
    ((:thursday)  3)
    ((:friday)    4)
    ((:saturday)  5)
    ((:sunday)    6)
    (otherwise   day)))

(defun specifier-item-prepare (item)
  (cond
    ((null item) item)
    ((eq item :every) item)
    ((listp item) (sort item #'<))
    (t item)))

(defun specifier-prepare (specifier)
  (with-slots (year
               month
               date
               day
               hour
               minute
               second)
      specifier

    ;; 1 => (list 1)
    (setf year (specifier-item-prepare year))
    (setf month (specifier-item-prepare month))
    (setf date (specifier-item-prepare date))
    (setf hour (specifier-item-prepare hour))
    (setf minute (specifier-item-prepare minute))
    (setf second (specifier-item-prepare second))
    (cond
      ((null day))
      ((eq day :every))
      ((listp day) (setf day (mapcar #'day-id day)))
      (day (setf day (list (day-id day)))))

    ;; fill every
    (when (null year)
      (setf year :every)
      (when (null month)
        (setf month :every)
        (when (null date)
          (setf date :every)
          (when (and (null hour) (null day))
            (setf hour :every)
            (when (null minute)
              (setf minute :every)
              (when (null second)
                (setf second :every)))))))))


(defun once (&key year month date day hour minute second
               (now (get-universal-time)))
  (let ((specifier (make-specifier :year year
                                   :month month
                                   :date date
                                   :day day
                                   :hour hour
                                   :minute minute
                                   :second second)))
    (specifier-prepare specifier)
    (make-once-generator   :time  (next-time specifier now))))

(defun all (&key year month date day hour minute second
              (now (get-universal-time)))
  (let ((specifier (make-specifier :year year
                                   :month month
                                   :date date
                                   :day day
                                   :hour hour
                                   :minute minute
                                   :second second)))
    (specifier-prepare specifier)
    (multiple-value-bind (prev next) (next-time specifier now)
      (make-all-generator :specifier specifier
                          :time prev
                          :next-time next))))

(defun after (&key day hour minute second
                (now (get-universal-time)))
  (let ((delta-time (duration day hour minute second)))
    (make-after-generator :time (+ now delta-time))))

(defun repeat (&key day hour minute second
                 (now (get-universal-time)))
  (let ((delta-time (duration day hour minute second)))
    (make-repeat-generator :time (+ now delta-time)
                           :delta-time delta-time)))


(defun get-time (generator)
  (slot-value generator 'time))


(defgeneric next (generator))

(defmethod next ((generator once-generator))
  (prog1
      (once-generator-time generator)
    (setf (once-generator-time generator) nil)))

(defmethod next ((generator all-generator))
  (with-slots (time next-time specifier) generator
    (prog1
        time
      (if next-time
          (multiple-value-bind (prev next)
              (next-time specifier next-time)
            (setf time prev
                  next-time next))
          (setf time nil)))))

(defmethod next ((generator after-generator))
  (prog1
      (after-generator-time generator)
    (setf (after-generator-time generator) nil)))

(defmethod next ((generator repeat-generator))
  (prog1
      (repeat-generator-time generator)
    (incf (repeat-generator-time generator)
          (repeat-generator-delta-time generator))))
