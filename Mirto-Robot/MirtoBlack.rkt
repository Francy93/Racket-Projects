#lang racket
 (require "AsipMain.rkt")
 (provide (all-defined-out))


(define previousTime (current-inexact-milliseconds)) 
(define currenTime 0)  
(define interval 3000)
(define irSensors (list 0 1 2))

#|(define irLoop (lambda ()
   (set! currenTime (current-inexact-milliseconds))
   (cond ( (>  (- currenTime previousTime) interval)
              
              (map (lambda (i) (printf "IR sensor ~a -> ~a; " i (getIR i))) irSensors)
              (printf "\n")
              (set! previousTime (current-inexact-milliseconds))
            )
          )
    (sleep 0.02)

    (cond ((not (and (leftBump?) (rightBump?)))
          (irLoop)
          )
    ) 
                 )
) |#


#|(define sensorsLoop (lambda ()

               
                      (set! cicle-counter (add1 cicle-counter))
                      (displayln cicle-counter)
                      (cond
                        [  (or (leftBump?) (rightBump?))
                                (stopMotors)
                                (setMotors -90 0)
                                (sleep 1.5)
                                (setMotors 150 150)
                              
                        ]
                      )
                          
                   (unless (> cicle-counter 100
                             ) (sensorsLoop))))|#







(define cicle-counter 0)
(define sensorcheck (lambda ()
           
           (set! cicle-counter (add1 cicle-counter))
           (displayln cicle-counter)
           (set! currenTime (current-inexact-milliseconds))
                           
  (cond  

           (
             (>  (- currenTime previousTime) interval)
                (map (lambda (i) (printf "IR sensor ~a -> ~a; " i (getIR i))) irSensors)
                (printf "\n")
                (set! previousTime (current-inexact-milliseconds))
            )
  )

  (cond 
                 
             [(>= (getIR 0) 200) 
               (setMotors 30 30)]
                
             [else (setMotors 30 30)
                (w2-stopMotor)]

  )

  (cond
              [  (or (leftBump?) (rightBump?))
                     (stopMotors)
                     (setMotors -90 0)
                     (setMotors 150 150)                             
              ]
  )            
               (unless (> cicle-counter 200
                             ) (sensorcheck))
                     )
)           
    
                
(define (BlackLine)

 (set! cicle-counter 0)
   (open-asip)
   
              (enableIR 50)
              (getIR 0)
              (enableBumpers 100)

              (sensorcheck)
              (stopMotors)
    
    (close-asip)
                    
)

