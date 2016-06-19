#|
  This file is a part of clocy project.
  Copyright (c) 2016 Carrotflakes (carrotflakes@gmail.com)
|#

(in-package :cl-user)
(defpackage clocy-test-asd
  (:use :cl :asdf))
(in-package :clocy-test-asd)

(defsystem clocy-test
  :author "Carrotflakes"
  :license "LLGPL"
  :depends-on (:clocy
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "clocy"))))
  :description "Test system for clocy"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
