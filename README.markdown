# Clocy

Clocy provides APIs used by developing a timer application like a cron.

## Usage

``` LISP
;; Get the current time.
(get-universal-time) ;; => 4/2/2017 12:52:21


;; Get the next 12:00:00, and more.
(let ((timer (clocy:all :hour 12 :minute 0 :second 0)))
   (clocy:next timer) ;; => 5/2/2017 12:00:00
   (clocy:next timer) ;; => 6/2/2017 12:00:00
   )

;; Get the time after 1.5 hours.
(let ((gen (clocy:after :hour 1 :minute 30)))
   (clocy:get-time timer) ;; => 5/2/2017 14:22:21
   )
```

## Installation

```
$ ros install carrotflakes/clocy
```

## APIs
not yet.

### function: once
### function: all
### function: after
### function: repeat
### function: get-time
### function: next


## Author

* Carrotflakes (carrotflakes@gmail.com)

## Copyright

Copyright (c) 2016 Carrotflakes (carrotflakes@gmail.com)

## License

Licensed under the LLGPL License.
