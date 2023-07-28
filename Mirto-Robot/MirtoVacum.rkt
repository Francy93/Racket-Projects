#lang racket
(require "AsipMain.rkt")
(provide (all-defined-out))

(define cicle-counter1 0)

(define (Vacum)

	(set! cicle-counter1 0)

    (open-asip)
           
        (enableBumpers 50)          
        (setMotors 30 30)
        (sensorsLoop)
        (stopMotors)         
       
    (close-asip)
                
)


(define (sensorsLoop)
	(set! cicle-counter1 (add1 cicle-counter1))
	(displayln cicle-counter1)
	(cond
		[   (or (leftBump?) (rightBump?))

			(setLCDMessage "There's been an accident" 0)
			(stopMotors)
			(playTone 264 400)
			(playTone 264 400)
			(playTone 297 1000)
			(playTone 264 1000)
			(playTone 352 1000)
			(playTone 330 2000)
			(playTone 264 250)
			(playTone 264 250)
			(playTone 297 1000)
			(playTone 264 1000)
			(playTone 396 1000)
			(playTone 352 2000)
			(playTone 264 250)
			(playTone 264 1000)
			(playTone 530 1000)
			(playTone 352 500)
			(playTone 352 250)
			(playTone 330 1000)
			(playTone 297 2000)
			(playTone 466 250)
			(playTone 466 250)
			(playTone 440 1000)
			(playTone 352 1000)
			(playTone 296 1000)
			(playTone 352 2000)
			(sleep 1.5) 

			(setMotors -90 0)
			(sleep 1.5)
			(setMotors 150 150)
		]
    )
    (unless (> cicle-counter1 25000 ) (sensorsLoop) )
)