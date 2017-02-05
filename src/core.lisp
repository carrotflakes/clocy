(in-package :cl-user)
(defpackage clocy.core
  (:use :cl :clocy.util)
  (:export #:make-specifier
           #:next-time
           #:specifier-duration
           #:year
           #:month
           #:date
           #:day
           #:hour
           #:minute
           #:second))
(in-package :clocy.core)


(defstruct specifier
  (year nil)
  (month nil)
  (date nil)
  (day nil)
  (hour nil)
  (minute nil)
  (second nil))


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

    (multiple-value-bind
          (second minute hour date month year) (decode-universal-time now)
      (labels ((step-year ()
                 (cond
                   ((null spec-year)
                    (step-year))
                   ((listp spec-year)
                    (dolist (spec-year spec-year)
                      (cond
                        ((< year spec-year)
                         (setf year spec-year
                               month 1
                               date 1
                               hour 0 minute 0 second 0)
                         (when (step-month)
                           (return t)))
                        ((= year spec-year)
                         (when (step-month)
                           (return t))))))
                   ((typep spec-year 'number)
                    (cond
                      ((< year spec-year)
                       (setf year spec-year
                             month 1
                             date 1
                             hour 0 minute 0 second 0)
                       (step-month))
                      ((= year spec-year)
                       (step-month))))
                   ((eq spec-year :every)
                    (or (step-month)
                        (dotimes (i 400)
                          (incf year)
                          (setf month 1
                                date 1
                                hour 0 minute 0 second 0)
                          (when (step-month)
                            (return t)))))))

               (step-month ()
                 (cond
                   ((null spec-month)
                    (step-date))
                   ((listp spec-month)
                    (dolist (spec-month spec-month)
                      (cond
                        ((< month spec-month)
                         (setf month spec-month
                               date 1
                               hour 0 minute 0 second 0)
                         (when (step-date)
                           (return t)))
                        ((= month spec-month)
                         (when (step-date)
                           (return t))))))
                   ((typep spec-month 'number)
                    (cond
                      ((< month spec-month)
                       (setf month spec-month
                             date 1
                             hour 0 minute 0 second 0)
                       (step-date))
                      ((= month spec-month)
                       (step-date))))
                   ((eq spec-month :every)
                    (or (step-date)
                        (loop
                           while (< month 12)
                           do (incf month)
                             (setf date 1
                                   hour 0 minute 0 second 0)
                             (when (step-date)
                               (return t)))))))

               (step-date ()
                 (cond
                   ((null spec-date)
                    (step-day))
                   ((listp spec-date)
                    (dolist (spec-date spec-date)
                      (cond
                        ((and (< date spec-date)
                              (<= spec-date (days-in-month year month)))
                         (setf date spec-date
                               hour 0 minute 0 second 0)
                         (when (step-day)
                           (return t)))
                        ((= date spec-date)
                         (when (step-day)
                           (return t))))))
                   ((typep spec-date 'number)
                    (cond
                      ((and (< date spec-date)
                            (<= spec-date (days-in-month year month)))
                       (setf date spec-date
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
                             (setf hour 0 minute 0 second 0)
                             (when (step-day)
                               (return t)))))))

               (step-day ()
                 (cond
                   ((null spec-day)
                    (step-hour))
                   ((numberp spec-day)
                    (when (equal (compute-day year month date) spec-day)
                      (step-hour)))
                   ((listp spec-day)
                    (when (member (compute-day year month date)
                                  spec-day
                                  :test #'equal)
                      (step-hour)))))

               (step-hour ()
                 (cond
                   ((null spec-hour)
                    (step-minute))
                   ((listp spec-hour)
                    (dolist (spec-hour spec-hour)
                      (cond
                        ((< hour spec-hour)
                         (setf hour spec-hour minute 0 second 0)
                         (when (step-minute)
                           (return t)))
                        ((= hour spec-hour)
                         (when (step-minute)
                           (return t))))))
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
                   ((listp spec-minute)
                    (dolist (spec-minute spec-minute)
                      (cond
                        ((< minute spec-minute)
                         (setf minute spec-minute second 0)
                         (when (step-second)
                           (return t)))
                        ((= minute spec-minute)
                         (when (step-second)
                           (return t))))))
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
                           while (< minute 59)
                           do (incf minute)
                             (setf second 0)
                             (when (step-second)
                               (return t)))))))

               (step-second ()
                 (cond
                   ((null spec-second)
                    (end))
                   ((listp spec-second)
                    (dolist (spec-second spec-second)
                      (when (<= second spec-second)
                        (setf second spec-second)
                        (when (end)
                          (return t)))))
                   ((typep spec-second 'number)
                    (when (<= second spec-second)
                      (setf second spec-second)
                      (end)))
                   ((eq spec-second :every)
                    (or (end)
                        (loop
                           while (< second 59)
                           do (incf second)
                             (when (end)
                               (return t)))))))

               (end ()
                 (let ((time (encode-universal-time second minute hour date month year)))
                   (when next-time
                     (return-from next-time (values next-time time)))
                   (setf next-time time)
                   nil)))

        (step-year)
        (values next-time nil)))))
