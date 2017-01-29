(in-package :cl-user)
(defpackage clocy
  (:use :cl)
  (:export #:make-generator
           #:generate-next))
(in-package :clocy)

(defstruct specifier
  year
  month
  date
  day
  hour
  minute
  second)

(defstruct next-generator
  time
  end)

(defstruct all-generator
  specifier
  last-time)

(defstruct after-generator
  delta-time
  last-time
  end)

(defstruct repeat-generator
  delta-time
  last-time)

(defun leap-year-p (year)
  (or (and (= (mod year 4) 0)
           (/= (mod year 100) 0))
      (= (mod year 400) 0)))

(defun days-in-month (year month)
  (case month
    ((1 3 5 7 8 10 12) 31)
    ((4 6 9 11) 30)
    ((2) (if (leap-year-p year)
             28
             29))))

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

(defun next-time (specifier now)
  (unless now
    (return-from next-time (values nil nil)))
  (let ((spec-year   (specifier-year   specifier))
        (spec-month  (specifier-month  specifier))
        (spec-date   (specifier-date   specifier))
        (spec-day    (specifier-day    specifier))
        (spec-hour   (specifier-hour   specifier))
        (spec-minute (specifier-minute specifier))
        (spec-second (specifier-second specifier))
        (next-time nil))
    (declare (ignore spec-day))
    (multiple-value-bind
          (second minute hour date month year day) (decode-universal-time now)
      (labels ((step-year ()
                 (cond
                   ((typep spec-year 'number)
                    (cond
                      ((< year spec-year)
                       (setf year spec-year
                             month 1
                             date 1
                             day (compute-day year month date)
                             hour 0 minute 0 second 0)
                       (step-month))
                      ((= year spec-year)
                       (step-month))))
                   ((member spec-year '(:every nil))
                    (or (step-month)
                        (dotimes (i 8)
                          (incf year)
                          (setf month 1
                                date 1
                                day (compute-day year month date)
                                hour 0 minute 0 second 0)
                          (when (step-month)
                            (return t)))))))

               (step-month ()
                 (cond
                   ((null spec-month)
                    (step-date))
                   ((typep spec-month 'number)
                    (cond
                      ((< month spec-month)
                       (setf month spec-month
                             date 1
                             day (compute-day year month date)
                             hour 0 minute 0 second 0)
                       (step-date))
                      ((= month spec-month)
                       (step-date))))
                   ((eq spec-month :every)
                    (or (step-date)
                        (loop ; TODO (:year 2016 :month :every) と (:month :every) の違いについて・・・
                           while (< month 12)
                           do (incf month)
                             (setf date 1
                                   day (compute-day year month date)
                                   hour 0 minute 0 second 0)
                             (when (step-date)
                               (return t)))))))

               (step-date ()
                 (cond
                   ((null spec-date)
                    (step-day))
                   ((typep spec-date 'number)
                    (cond
                      ((< date spec-date)
                       (setf date spec-date
                             day (compute-day year month date)
                             hour 0 minute 0 second 0)
                       (step-day))
                      ((= date spec-date)
                       (step-day))))
                   ((eq spec-date :every)
                    (or (step-day)
                        (loop
                           with days = (days-in-month year month)
                           while (< date days)
                           do (incf date)
                             (setf day (compute-day year month date)
                                   hour 0 minute 0 second 0)
                             (when (step-day)
                               (return t)))))))

                                        ; step-day はどうしようかな。 year month date と排他にしようかな
               #|
               (step-day ()
                 (cond
                   ((null spec-day)
                    (step-hour))
                   ((typep spec-day 'number)
                    (cond ; むずかしい！
                      ((< date spec-day)
                       (setf date spec-date
                             day (compute-day year month date)
                             hour 0 minute 0 second 0)
                       (step-day))
                      ((= date spec-date)
                       (step-day))))
                   ((eq spec-date :every)
                    (or (step-day)
                        (loop
                           with days = (days-in-month year month)
                           while (<= month days)
                           do (incf date)
                             (setf day (compute-day year month date)
                                   hour 0 minute 0 second 0)
                             (when (step-day)
               (return t)))))))|#

               (step-day () ; TODO
                 (step-hour))

               (step-hour ()
                 (cond
                   ((null spec-hour)
                    (step-minute))
                   ((typep spec-hour 'number)
                    (cond
                      ((< hour spec-hour)
                       (setf hour spec-hour minute 0 second 0)
                       (step-minute))
                      ((= hour spec-hour)
                       (step-minute))))
                   ((eq spec-hour :every)
                    (or (step-minute)
                        (loop
                           while (< hour 12)
                           do (incf hour)
                             (setf minute 0 second 0)
                             (when (step-minute)
                               (return t)))))))

               (step-minute ()
                 (cond
                   ((null spec-minute)
                    (step-second))
                   ((typep spec-minute 'number)
                    (cond
                      ((< minute spec-minute)
                       (setf minute spec-minute second 0)
                       (step-second))
                      ((= minute spec-minute)
                       (step-second))))
                   ((eq spec-minute :every)
                    (or (step-second)
                        (loop
                           while (< minute 60)
                           do (incf minute)
                             (setf second 0)
                             (when (step-second)
                               (return t)))))))

               (step-second ()
                 (cond
                   ((null spec-second))
                   ((typep spec-second 'number)
                    (when (<= second spec-second)
                      (setf second spec-second)))
                   ((eq spec-minute :every)))
                 (let ((time (encode-universal-time second minute hour date month year)))
                   (when next-time
                     (return-from next-time (values next-time time)))
                   (setf next-time time)
                   nil)))

        (step-year)
        (values next-time nil)))))


(defun specifier-duration (specifier)
  (with-slots (day hour minute second) specifier
      (+ (* 60
            (+ (* 60
                  (+ (* 24
                        (or day 0))
                     (or hour 0)))
               (or minute 0)))
         (or second 0))))

(defun make-generator (specs &optional (now (get-universal-time)))
  (let ((specifier (apply #'make-specifier (cdr specs))))
    (cond
      ((string= (first specs) 'next)
       (make-next-generator   :time  (next-time specifier now)
                              :end   nil))
      ((string= (first specs) 'all)
       (make-all-generator    :specifier  specifier
                              :last-time  now))
      ((string= (first specs) 'after)
       (make-after-generator  :delta-time (specifier-duration specifier)
                              :last-time now
                              :end        nil))
      ((string= (first specs) 'repeat)
       (make-repeat-generator :delta-time (specifier-duration specifier)
                              :last-time now)))))

(defgeneric generate-next (generator))

(defmethod generate-next ((generator next-generator))
  (unless (next-generator-end generator)
    (setf (next-generator-end generator) t)
    (next-generator-time generator)))

(defmethod generate-next ((generator all-generator))
  (multiple-value-bind (next-time last-time)
      (next-time (all-generator-specifier generator)
                 (all-generator-last-time generator))
    (setf (all-generator-last-time generator) last-time)
    next-time))

(defmethod generate-next ((generator after-generator))
  (unless (after-generator-end generator)
    (setf (after-generator-end generator) t)
    (+ (after-generator-last-time generator)
       (after-generator-delta-time generator))))

(defmethod generate-next ((generator repeat-generator))
    (setf (repeat-generator-last-time generator) (+ (repeat-generator-last-time generator)
                                                    (repeat-generator-delta-time generator))))
