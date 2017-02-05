#|
  This file is a part of clocy project.
  Copyright (c) 2016 Carrotflakes (carrotflakes@gmail.com)
|#

#|
  Author: Carrotflakes (carrotflakes@gmail.com)
|#

(in-package :cl-user)
(defpackage clocy-asd
  (:use :cl :asdf))
(in-package :clocy-asd)

(defsystem clocy
  :version "0.1"
  :author "Carrotflakes"
  :license "LLGPL"
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "util")
                 (:file "core" :depends-on ("util"))
                 (:file "clocy" :depends-on ("core")))))
  :description "Clocy computes the next time from the time specification."
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op clocy-test))))
