#lang racket
 (require data/gvector)

(define (char->list x)
    (define LST '())
    (cond 
        [   (char? x)   (set! LST (cons (string x) LST))    LST   ]
        [   (string? x) (set! LST (map (lambda (x) (string x)) (string->list x)) )   LST   ]
        [   else        (displayln "; char->list: contract violation")
                        (displayln ";   expected: (or/c string? char?)")
                        (displayln (~a ";   given: " x))
        ]
    )
)
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| T M ||||||||||||||||||||||||||||||||||||||||||||||||||||
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| ALGORITHMS |||||||||||||||||||||||||||||||||||||||||||||||||

(struct INS (C_STATE    C_VALUE    N_VALUE    N_STATE    H_DIR) #:transparent)

;(define TEST (INS 'Sl  0  1 'S3 'R)) 
;(INS-element name of_a_Specific INStruction)

(define ALGO_ADDICTION   ;BINARY ADDICTION
    (list 0
          (INS 'Sl  1  1 'Sl 'R)
          (INS 'Sl  0  0 'Sl 'R)
          (INS 'Sl 'b 'b 'S2 'L)
          (INS 'S2  1  0 'S2 'L)
          (INS 'S2  0  1 'S0 '_)
          (INS 'S2 'b  1 'S0 '_)
    )
)

(define ALGO_CONVERT   ;CONVERTING 1s in 0s and vice versa
    (list 
        (INS 'Sl  0  1 'Sl 'R) 
        (INS 'Sl  1  0 'Sl 'R) 
        (INS 'Sl 'b 'b 'S2 'L) 
        (INS 'S2  0  0 'S2 'L) 
        (INS 'S2  1  1 'S2 'L) 
        (INS 'S2 'b 'b 'S0 'R)
    )
)



;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| TM EMULATOR ||||||||||||||||||||||||||||||||||||||||||||||||

(define (TM_EMU    TAPE  ALGO)
    (define DONE 0)
    (cond
        [  (list? TAPE)   (set! TAPE (list->gvector TAPE))  ]
        [  (string? TAPE) (set! TAPE (list->gvector (char->list TAPE)))  ]
        [  (number? TAPE) (set! TAPE (list->gvector (char->list (number->string TAPE))))  ]
        [  (symbol? TAPE) (set! TAPE (list->gvector (char->list (symbol->string TAPE))))]
    )
    (let LOOP [    (REF 0)   (STATE (INS-C_STATE(second ALGO)))    ] ; inside REF there's 0, we call the struct and we put the current state (e.g. 'S1)
        ;(println REF) (println STATE) (println TAPE)
        (when (number?(first ALGO)) (set!-values (REF ALGO) (values (first ALGO)(rest ALGO))) ) ; here we take off the number 0  and we evaluate the rest
        (cond
            [   (equal? (~a STATE) "S0")  (set!-values (DONE TAPE) (values 1 (gvector->list TAPE)) ); here we check if the state is equal to "S0" in which case if it is, means that we are done
                (set! TAPE (remove* (list 'b "b") TAPE)) ;here we remove at the end all the 'b, which are the blanks
            ]
            ;[   (number? (first ALGO))   (LOOP  (first ALGO) STATE)  ]
            [   (not(< -1 REF (gvector-count TAPE)))
                (if(< REF 0) (let()(gvector-insert! TAPE 0 'b)(set! REF (add1 REF))) (gvector-add! TAPE 'b))
                (LOOP  REF STATE)
            ]
            [   else (define CURRENT empty)
                    ;(with-handlers  ([exn:fail:contract? (λ (EXN) empty) ])
                        (map(lambda(x)  (when(and (equal?(INS-C_STATE x)STATE) (equal?(~a(INS-C_VALUE x))(~a(gvector-ref TAPE REF))) )
                                            (set! CURRENT (reverse(cons x (reverse CURRENT))))
                            )           )
                            ALGO
                        )
                    ;)
                    ;(displayln CURRENT)
                    (unless (empty? CURRENT)
                            (set! CURRENT (first CURRENT))
                            (gvector-set! TAPE REF (INS-N_VALUE CURRENT) )
                            (LOOP   (if (equal? "_" (~a(INS-H_DIR CURRENT))) REF (if (equal? "R" (~a(INS-H_DIR CURRENT))) (add1 REF) (sub1 REF)) )
                                    (INS-N_STATE CURRENT)
                            )
                    )
            ]
        )
    )
    (newline) (if (equal? DONE 0) (displayln "Halt not accepted") (displayln (~a "Halt accepted  ->  " TAPE))) (newline)
)


;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| TEST |||||||||||||||||||||||||||||||||||||||||||||||||||||

(TM_EMU '101010 ALGO_ADDICTION)