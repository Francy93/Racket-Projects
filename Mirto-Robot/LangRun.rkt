#lang racket
(require "FSM-dynamic.rkt" "AsipMain.rkt")
(provide (all-defined-out))

(define LANG_SET '( "GO" "STOP" "WAIT" "RIGHT" "LEFT" "BACK" "go" "stop" "wait" "right" "left" "back" ))
(define EXPR_SET '( "GO" "STOP" "WAIT" "RIGHT" "LEFT" "BACK" "go" "stop" "wait" "right" "left" "back" "|" ")" "(" "*" "+" ))
(define LANGUAGE empty)



(define (SYNTAX_CHECK LANG EXPR)
    ;(println LANG)
    (set! LANG  (if (or (string-contains? (first LANG) " ") (for/or ([i LANG_SET])  (i . equal? . (first LANG)) ) )
                    (let() (displayln "SETTLER LANG")(SETTLER (first LANG))) (char->list (first LANG) )
                )
    );(displayln "next")
    (set! EXPR  (if (or (string-contains? (first EXPR) " ") (for/or ([i EXPR_SET])  (i . equal? . (first EXPR)) ) )
                    (let() (displayln "SETTLER EXPR")(SETTLER (first EXPR))) (char->list (first EXPR) )
                )
    );(displayln "next2")
    (set! LANGUAGE LANG )
    ;(println LANGUAGE)  ;(println EXPR)

    (define CHECK
        (if (and (not (for/and ([i LANG])  (#t . equal? . (for/or ([j LANG_SET])  (j . equal? . i) )  )   ) )
                 (not (for/and ([i EXPR])  (#t . equal? . (for/or ([j EXPR_SET])  (j . equal? . i) )  )   ) )
            )
            1 ;"1 means: Language set expected does not match the one entered")
            (if (FSM2 LANG EXPR)  0 2) ; 0 means good, language match!  -   2 means: Language and expression dont mach
        )
    )
    CHECK
)




(define (FUN_LANG) 
    (define (INSTRUCTIONS DIRECTION)
        (cond
            [   (or (equal? DIRECTION "GO")    (equal? DIRECTION "go"))     (setMotors 150  150)    ]
            [   (or (equal? DIRECTION "STOP")  (equal? DIRECTION "stop"))   (setMotors 0    0  )    ]
            [   (or (equal? DIRECTION "RIGHT") (equal? DIRECTION "right"))  (setMotors 150  0  )    ]
            [   (or (equal? DIRECTION "LEFT")  (equal? DIRECTION "left"))   (setMotors 0    150)    ]
            [   (or (equal? DIRECTION "BACK")  (equal? DIRECTION "back"))   (setMotors -50  -50)    ]
            [   else (displayln "Waiting")    ]
        )
        ; 
    )
    (displayln "START LANG_LOOP") 
    (open-asip)
    (let LOOP [ (L LANGUAGE) (COUNT 200) (INS (first LANGUAGE)) ]
        ;(display L) (displayln COUNT)
        (INSTRUCTIONS INS)
        (cond 
            [	(empty? L)  null  ]
            [   (equal? COUNT 0)   (LOOP (rest L) 200 INS)  ]
            [   (or (equal? "wait" (first L)) (equal? "WAIT" (first L)) )  (LOOP L (sub1 COUNT) INS)  ]
            [   else   (LOOP (rest L) COUNT (first L) )   ]
        )
    )
    (close-asip) ;<--- this might be needed to be removed !
    (displayln "STOP LANG_LOOP")
)