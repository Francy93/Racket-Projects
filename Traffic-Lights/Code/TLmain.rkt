#lang racket

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| SOBs ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;---------------------------------------------------------------------------------------- COVERED
;20	    Demonstrate personal time management skills, arriving on time for scheduled sessions, using the available time productively and not missing sessions without excellent reason.
;22	    Use some simple built in data structures in Racket, such as lists, strings, vectors or sets, explain the properties of the structures you are using and how the various structures you might have chosen differ.
;23     Use diagrams to explain simple data structures such as lists.
;25     Write a simple program using the struct command to implement a simple data structure and explain how it works.
;27	    Show that you understand the important difference between mutable and immutable objects, using fragments of racket code to illustrate the use of both.
;256	Write a function that uses vectors to solve a simple problem.
;278    Demonstrate an understanding of indexed addressing.
;295	For a given Racket program (either one provided or one you have written), produce a list of test cases to test it. Explain the choice of test cases.
;296	Use machine models, such as EFSMs or state machines, to illustrate the execution of computer programs.
;300	Discuss the respective advantages and disadvantages of different data structures, justifying choices for particular problems.
;507	Working individually or in a small group, find at least two aspects of Racket that have not been explicitly taught, research them and demonstrate the ability to use them in sensible ways. Fluency and a deep understanding are not expected, but independent study and a willingness to engage with the literature must be shown.
;525	Formalise aspects of the design of a simple system, and present this to a small group using the formalism to discuss specific system properties.
;601	Use diagrams to visualise and explain functions and variable environments.
;603	For a given Racket program (either one provided or one you have written), implement test cases and assertions.

;---------------------------------------------------------------------------------------- IN PROGRESS
;31   	Demonstrate a simple understanding of more complex data structures such as graphs and trees.
;559	Write a program that uses graphs to solve a simple problem.
;254	Write a function that uses trees to solve a simple problem.
;255	Write a function that uses stacks to solve a simple problem.
;274	Explain how a stack is used to evaluate expressions.
;279	Design a pneumatic system using over five components. Explain your circuit to your tutor and discuss possible uses in industry.
;562	Express the type of a polymorphic function.
;584	Use Racket to design a pneumatic control system, for example for traffic lights.



;*****************************************************************************************************************************************
;********************************************************************* START *************************************************************
;*****************************************************************************************************************************************

(require "components/AsipMain.rkt" rackunit) ;"components/AsipButtons.rkt")
(provide (all-defined-out))



;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| ARDUINO PIN MODE SETUP |||||||||||||||||||||||||||||||||||||||||||||||||||||

(define asipLibrary ;asip minimal program to blink pin 13 every second
    (λ ()
        (open-asip)
        (for ((i (in-range 2 16) ))    ;this "for cicle" sets as output the pins from 2 to 15. (even though there's written 16)
            (set-pin-mode! i OUTPUT_MODE)
        )
        (set-pin-mode! 16 INPUT_MODE) ;this instraction sets as input the pin 16 button
        ;(set-pin-mode! 13 OUTPUT_MODE) ;this was the original one
    )         ; end of lambda
)             ; end of setup
(asipLibrary) ;calling the asip library function to set arduino as it suits us



;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| GLOBAL VARIABLES |||||||||||||||||||||||||||||||||||||||||||||||||||||||||

; --------------------------------------------------------------------------------------- PIN / ARDUINO VARIABLES
;; -- (OUTPUT)  Pedestrian set   (P)
;(define pGreen        11 ) ;; pedestrian waiting Yellow light 11
;(define pYellow       12 )
;(define pRed          13 )
;(define speaker       14 ) ;; aqustic signal    14
;;
(struct pedStates (green yellow red speaker) #:mutable) ; this is the "struct command" which is the equivalent of the known object in OOP
(define P (pedStates 11 12 13 14 ))
(digital-write 13 HIGH)
;; -- (OUTPUT)  UrbanLights
(define urbanLights   15 ) ;; value brightness sensor PIN PORT    15
;;(pedStates-green P)
;; -- (INPUT)   Button setting
(define buttonPort    16 ) ;; variable containing the input PIN PORT    16
(define sensorPort    3  )


; --------------------------------------------------------------------------------------- COMMON VARIABLES

(define transSleep    4  ) ;CUSTOMIZABLE duration in seconds of yellow lights
(define standardSleep 10 ) ;CUSTOMIZABLE duration in seconds of standard lights
(define pedSleep      7  ) ;CUSTOMIZABLE duration in seconds of pedestrian lights
(define bufferSleep   3  ) ;CUSTOMIZABLE duration in seconds of buffer/red lights
(define brightTrigger 990)

(define button        0  ) ;the button value will be setted here by a function "(buttonCall)" that retrives it from the input pin of arduino
(define buttonAbuse   0  ) ;the buttonAbuse is a variable which will be used to store the verifying value of the button overcall
(define brightCountON 0  )
(define brightCountOFF 0 )


;---------------------------------------------------------------------------------------- STANDARD STATES VECTORS

(define A  '( (green 2) (yellow 3)  (red 4) )  )
(define B  '( (green 5) (yellow 6)  (red 7) )  )
(define C  '( (green 8) (yellow 9) (red 10) )  )

(define TLsPin (vector A B C) )


(define stateG  '(green red red) )
(define stateY '(yellow red red) )
(define stateR    '(red red red) )

(define sequence (vector-immutable stateR stateG stateY) )



;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| CHECK TEST CASES ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

(check equal? #t (number? brightTrigger) "You didn't enter a number")
(check equal? #t (and (> brightTrigger 0) (< brightTrigger 1025)) "You entered a wrong value")

(check equal? #t (number? bufferSleep) "You didn't enter a number")
(check equal? #t (number? pedSleep) "You didn't enter a number")
(check equal? #t (number? standardSleep) "You didn't enter a number")
(check equal? #t (number? transSleep) "You didn't enter a number")



;||||||||||||||||||||||||||||||||||||||||||||||||||||||| REDSTATE, INPUT CHECKING & CICLES |||||||||||||||||||||||||||||||||||||||||||||||||||

(define (TrLts-redState) ;this function sets the roundabout into a stop state allowing pedestrians to cross the road
  (digital-write (pedStates-green P) LOW)
  (digital-write (pedStates-red P) HIGH)
  (for-each 
        (lambda (x)
            (digital-write (second (assoc 'red x)) HIGH)
        )
        (vector->list TLsPin)
    )                                      ;as a next step we are going to set as HIGH every pin rlated to red lights
)

(define (buttonCheck)  ;this function is ment to be used to get the button value and set it into the "button" varable
    (cond
        [   (= button 0)   (set! button (digital-read buttonPort))   ] ;if the button has a value of 0, then set the variable "button" with the current button input state
        [   else   (digital-write (pedStates-yellow P)   HIGH)   ]
    )
    button             ;return the "button" value
)

(define (brightCheck n)  ;this function is ment to be used to get the brightness sensor value and set it into the "brightAvarage" variable
    (unless (= n 0) (sleep 0.02)) ;(displayln (analog-read sensorPort))
    (cond
        [   (< (analog-read sensorPort) brightTrigger)
            (set! brightCountON (add1 brightCountON))
            (unless (< brightCountON 200)   (digital-write urbanLights HIGH) (set!-values (brightCountON brightCountOFF) (values 0 0) )  )
        ]
        [   else   (set! brightCountOFF (add1 brightCountOFF))
            (unless (< brightCountOFF 200)   (digital-write urbanLights LOW) (set!-values (brightCountON brightCountOFF) (values 0 0) )  )
        ]
    )
    (unless (< n 1)   (brightCheck (sub1 n)) )
)

(define (pedLoop times)           ;this function enclose the loop for the pedestrian state ("(pedStates-green P) HIGH")
    (digital-write (pedStates-yellow P) LOW)
    (digital-write (pedStates-red P) LOW)
    (digital-write (pedStates-green P) HIGH)   ;ex (TrLts-redState). Why "TrLts-redState" has been replaced with the current instruction? Because has been spotted a ridundancy on its superfluity since we are suppose to get untill here by being already in a "redState"
    (for ((i 2))                  ;this loop is going to run one more loop. Why? because this first loop is ment to make the "pYello" light blinking, whilst, the below loop will reproduce the beeping sound
        (for ((j 2))              ;"2" is the amount of cicles. Why 2? because every cicle is made of "(sleep 0.05)" and "(sleep 0.20)", as we know 0.05 + 0.20 is 0.25, hence, 0.25 x "2" is 1/2 second, ultimatelly 1/2 second x 2 cicles of the previous "for loop" is 1 second beeping, plus the recorsive loop which usually will be 5 cicles
            (for ((beep 50))      ;"50" is the amount of cicles (milliseconds) that the speaker will kepp playing
                (digital-write (pedStates-speaker P)  1)
                (digital-write (pedStates-speaker P)  0)
            )
            (brightCheck 10)      ;ex (sleep 0.2)
        )
        (digital-write (pedStates-yellow P)   HIGH)
    )
    (digital-write (pedStates-yellow P) LOW)   ;shut down the pedestrian yellow light
    (unless (= times 1) (pedLoop (sub1 times)) )

    (TrLts-redState)
)

(define (wait state)                 ;IMPORTANT for MICHAEL! this doesn't look like a function but it is, in fact, this is a new/faster way to define a function
    (define milliSec (* state 50))   ;conversion* from "state" (SECONDS) to "state x 50 CICLES"    (from seconds to cicles)  (in programming, every cicle (iteration) leasts 1 millisecond)
    (define (counter cicles)         ;"cicles" is ment to be a variable containing the number of ciles to run i.e. 500    (conversion* 5 x 50 = 500 ciles)
        (cond 
            [   (<= cicles 0) 0   ]     ;if the cicles ran out, then don't do anything "(null)", namely, don't run any further recursion
            [   (= buttonAbuse 1)   (buttonCheck) (brightCheck 1) (counter (sub1 cicles)) (set! buttonAbuse 0)   ];this condition has been made to avoid abuses of the button
            [   (= (buttonCheck) 1)  (cond  ;this is the condition to get out of the loop if the button has been pressed
                                        [   (= state standardSleep)   (brightCheck 1) (counter (- cicles 2 ))   ] ;get out the loop faster if this loop is cicleing a "standardSleep"
                                        [   (= state transSleep)   (digital-write (pedStates-yellow P)   HIGH) (brightCheck cicles)   ]
                                        [   else
                                            (digital-write (pedStates-yellow P)   HIGH)
                                            (brightCheck cicles) 
                                            (pedLoop pedSleep)
                                            (set!-values (button buttonAbuse) (values 0 1) )
                                            (wait bufferSleep)
                                            (set! buttonAbuse 1) 
                                        ]   ;run the "redState" if this loop is cicleing a "transState", then set the value of "button" to 0 and the value of buttonAbuse to 1
                                    )
            ]
            [   (> cicles 0)   (brightCheck 1) (counter (sub1 cicles) )   ] ;sleep for 0.02 seconds, e.g.: "sleep 0.02" will be cicled "case" times =  If "cicle" were 500, then 0.02 seconds x 500 is 5 (5 seconds sleeping) easy! ;)
        )
    )
    (counter milliSec) ;the first value represent the seconds to wait and the following one multiplies the first one for a certain operation which the "(seconds)" function will do
)



;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| SEQUENCES |||||||||||||||||||||||||||||||||||||||||||||||||||||||||

(let loop ()
;________________________________________________________________________________________ (CORE OPERATION) STATES SETTING & RELATIONS
    (for-each
        (lambda (state)
            (for-each
                (lambda (intersaction)
                    (cond
                        [   (equal? intersaction (vector-ref TLsPin 0))
                            (digital-write (second (assoc (first  state) intersaction)) HIGH)
                        ]
                        [   (equal? intersaction (vector-ref TLsPin 1))
                            (digital-write (second (assoc (second state) intersaction)) HIGH)
                        ]
                        [   (equal? intersaction (vector-ref TLsPin 2))
                            (digital-write (second (assoc (third  state) intersaction)) HIGH)
                        ]
                    )
                )
                (vector->list TLsPin)
            )
;________________________________________________________________________________________ LIGHTS OFF & WAITNG

            (define (clear) ;this function sets all the lights off
                        (for-each 
                            (lambda (x)
                                (digital-write (second (first  x)) LOW)
                                (digital-write (second (second x)) LOW)
                                (digital-write (second (third  x)) LOW)
                            )
                            (vector->list TLsPin)
                        )
            )

            (cond
                [   (equal? state stateG)
                    (wait standardSleep)
                    (clear)
                ]
                [   (equal? state stateY)
                    (wait transSleep)
                    (clear)
                ]
                [   (equal? state stateR)
                    (wait bufferSleep)
                    (clear)  
                ]
            )
        )
        (vector->list sequence)
    )
;________________________________________________________________________________________ (IMPORTANT) INTERSACTION SWITCHING
  
    (set! TLsPin
        (vector-map 
            (lambda (x)
                (cond
                    [   (= 0 (vector-member x TLsPin) )   (vector-ref TLsPin 1)   ]
                    [   (= 1 (vector-member x TLsPin) )   (vector-ref TLsPin 2)   ]
                    [   (= 2 (vector-member x TLsPin) )   (vector-ref TLsPin 0)   ]
                )
            )
            TLsPin
        )
    )

   (loop)
)
