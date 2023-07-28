#lang racket
; AsipButtons.rkt
; ASIP Button extension
; allow an callback event handler to be registered for a pin
; - to be called when the pin goes high - i.e. when the button is pressed.
; need  "AsipMain.rkt". Or something that provides digital-read.

(require "AsipMain.rkt")

(provide on-button-pressed stopPolling)

(define oldPinValues (make-hash)) ; store previous values
(define registeredCallbacks (make-hash)) ; store callback functions

(define on-button-pressed (lambda (pin callback)
                            (hash-set! registeredCallbacks pin callback)
                            )
  )

(define pollButtonPins (lambda ()
                       (testButtonPins)
                         (sleep 0.1) ; let other things have a go!
                         (pollButtonPins))
  )

; test all registered button pins. If pressed, do the callback.
; store the current pin val in oldPinValues.
(define testButtonPins (lambda ()
                         (hash-for-each registeredCallbacks
                                        (lambda (pin callback)
                                          (let ((pinVal  (digital-read  pin)))
                                           (cond
                                           ((and (equal? pinVal HIGH)  (equal? (hash-ref oldPinValues pin LOW) LOW))
                                          ; then Low-to-HIGH transition:  button just pressed
                                          (callback)
                                           )
                                           ); end cond
                                           (hash-set! oldPinValues pin pinVal)
                                            )
                         ))))

(define pollThread (thread (lambda () (pollButtonPins))))
(define stopPolling (lambda () (kill-thread pollThread)))