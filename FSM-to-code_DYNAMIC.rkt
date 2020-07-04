#lang racket
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

(define (SETTLER STR)
    (let LOOP [ (C (char->list STR)) (TEMP_L empty) (TEMP_S "") ]
        ;(println STR) (println C) (println TEMP_L) (println TEMP_S)
        (cond
            [   (empty? C) (set! STR (if (equal? "" TEMP_S) TEMP_L (reverse(cons TEMP_S (reverse TEMP_L)))))  STR   ]  ;(displayln STR) ]
            [   (or (equal? "|" (first C)) (equal? "*" (first C)) (equal? "+" (first C)) (equal? ")" (first C)) (equal? "(" (first C)) )
                (LOOP  (rest C)  (reverse(cons (first C)(if (equal? "" TEMP_S)(reverse TEMP_L)(cons TEMP_S (reverse TEMP_L)))))  "" )
            ]
            [   (equal? " " (first C))   (LOOP  (rest C)  (if (equal? "" TEMP_S) TEMP_L (reverse(cons TEMP_S (reverse TEMP_L))))  "" )  ]
            [   else   (LOOP  (rest C)  TEMP_L  (~a TEMP_S (first C))  )   ]
        )
    )
)




;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||| DYNAMIC  F S M |||||||||||||||||||||||||||||||||||||||||||||||||
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


(define (FSM2 SEQUENCE EXPRESSION)
;----------------------------------------------- FROM STRING TO LIST OF STRINGS ----------------------------------------
    (newline)  
    (unless (list? SEQUENCE)   (set! SEQUENCE   (if (string-contains? SEQUENCE   " ") (SETTLER SEQUENCE  ) (char->list SEQUENCE  ))) )
    (unless (list? EXPRESSION) (set! EXPRESSION (if (string-contains? EXPRESSION " ") (SETTLER EXPRESSION) (char->list EXPRESSION))) )



;----------------------------------------- FROM HUMAN SEQUENCE TO MACHINE SEQUENCE ----------------------------------------
    
    (define SEQUENCE_LIST empty)
    (let LOOP [   (S SEQUENCE)     (TEMP empty)   ]
        ;(println S) (println TEMP)
        (cond
            [   (empty? S) (set! SEQUENCE_LIST (reverse (cons TEMP SEQUENCE_LIST)))   ]
            [   (or (empty? TEMP) (equal? (first S) (last TEMP)) )   (set! TEMP (cons (first S) TEMP))   (LOOP (rest S) TEMP)   ]
            [   else   (set! SEQUENCE_LIST (cons TEMP SEQUENCE_LIST))    (LOOP S empty)   ]
        )
    )



;----------------------------------------- FROM HUMAN EXPRESSION TO MACHINE EXPRESSION --------------------------------------------

    (define-values (EXPRESSION_LIST TEMP_BR TEMP_OR JUMP) (values empty empty empty empty))
    (let LOOP [   (S EXPRESSION)     (TEMP empty)     (PAR 1)     (OR 0)    (OR2 empty)    ]
        ;(displayln (~a "par"PAR "  " "or"OR "   " "temp"TEMP "       " "tempBr"TEMP_BR "       " "tempOr"TEMP_OR "    OORR2" S) )
        (cond ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - END OR CORRECTIONS -  -  -  -  -  -  -  -  -  -  -  -   
            [   (or (and(empty? S) (< OR 1))                          (equal? "|" (if (not(empty? S))(last S)empty))
                    (equal? "+"(if (not(empty? S))(first S)empty))    (equal? "*"(if (not(empty? S))(first S)empty))
                    (and(equal?"|"(if (>(length S)2)(second S)empty)) (or (equal? ")" (third S)) (equal? "+" (third S)) (equal? "*" (third S)) ))
                    (and (< PAR 2)                                    (equal? ")" (if (not(empty? S))(first S)empty)) )
                    (and (<  (count (λ(x)(equal? x ")")) S)  PAR)     (equal? "(" (if (not(empty? S))(first S)empty)) )
                )      ;(displayln(~a "SSSSSSSSSSSSS" S))
                (cond 
                    [   (and (empty? S) (equal? PAR 1))   (set! EXPRESSION_LIST TEMP)  ]   ; END !!!!!!!!!!!!!!!!!!!!!!!!!
                    [   (or (and (< PAR 2) (equal? ")" (first S)))    (and (<  (count (λ(x)(equal? x ")")) S)  PAR) (equal? "(" (first S))) )
                        (displayln "Brackets correction 111")         (LOOP (rest S) TEMP PAR OR OR2)     
                    ]
                    [   (and(equal?"|"(if (> (length S)1) (second S) empty))
                            (or (equal? ")" (if (< (length S)3) empty (third S)))
                                (equal? "+" (if (< (length S)3) empty (third S)))
                                (equal? "*" (if (< (length S)3) empty (third S)))
                            )
                        )       (displayln "ORs, Simbols or brackets correction 222")
                        (if (or(= 4 (length S))   (equal? ")" (fourth S)))  
                            (LOOP (cons (first S)(rest(rest S))) TEMP PAR OR OR2)
                            (LOOP (cons (first S)(cons (second S)(rest(rest(rest S))))) TEMP PAR OR OR2)
                        )
                    ]
                    [   (or (equal? "+"(if (= 0 (length S)) empty (first S)))   (equal? "*"(if (= 0 (length S)) empty (first S))))
                        (displayln "Simbols correction 333")                    (LOOP (rest S) TEMP PAR OR OR2)
                    ]
                    [   (equal? "|"(if (= 0 (length S)) empty (last S)))        (displayln "ORs correction 444")  
                        (LOOP (reverse (rest (reverse S))) TEMP PAR OR OR2)
                    ]
                    [   else    (displayln (~a" Wrong amount of brackets or simbols"))     (set! JUMP '("|"))   ]
                )
            ] 
              ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  ORs ITERATIONS -  -  -  -  -  -  -  -  -  -  -  -   
            [   (or (equal? "|" (if(not(empty? S))(first S)empty)) (and (< (length S) 2)(> OR 0)) (and (>= OR PAR) (> PAR 1) (equal? ")" (first S))) )
                (cond
                    [   (or (and (< (length S) 2)(> OR 0))   (and (>= OR PAR) (equal? ")" (if (not (empty? S)) (first S) empty)) ) )
                        (if (and (< (length S) 2)(> OR 0)) 
                            (set!-values (JUMP TEMP_OR)
                                (values (if (not(empty? S)) (rest S) empty)
                                        (if (>  (length OR2 ) 0)
                                            (if (> (length S) 0)
                                                (reverse(cons"|"(cons(if(>(length TEMP)0) (reverse(cons (last S)(reverse TEMP))) (last S)) (reverse OR2))))
                                                (reverse(cons"|"(if (>(length TEMP) 0) 
                                                                    (cons (if (= 1 (length TEMP)) (first TEMP) TEMP) (reverse OR2))
                                                                    (reverse OR2)
                                                )       )       )
                                            )
                                            (if (> (length S) 0)
                                                (list (if (> (length TEMP) 0) (reverse (cons (last S) (reverse TEMP))) (last S)) "|")
                                                (if (>  (length TEMP) 0) (list (if (= 1 (length TEMP)) (first TEMP) TEMP) "|") empty)
                                            )   
                                )       )                                         
                            )
                            (set!-values (JUMP TEMP_OR)
                                (values S   (if (> (length OR2) 0)
                                                (reverse (cons "|" (cons (if (= 1 (length TEMP)) (first TEMP) TEMP)  (reverse OR2))) )
                                                (if (not(empty? TEMP))   (if (= (length TEMP) 1)    (list(first TEMP) "|")  (list TEMP "|")) empty)
                                )           )
                            )
                        )
                    ]
                    [   (and (equal? "|" (first S))    (not(>= OR PAR)) )
                            (LOOP (rest S) empty PAR PAR empty)
  #|(displayln TEMP_OR)|#       (unless (empty? TEMP_OR) (set! TEMP (cons (if (= (length TEMP) 1) (first TEMP) TEMP)   TEMP_OR)))    ;(displayln (~a "   temptemp   " TEMP "     "))
                            (LOOP JUMP TEMP PAR OR OR2)
                    ]
                    [   (and (equal? "|" (first S)) (>= OR PAR) )
                        (LOOP   (rest S)   empty   PAR   (add1 OR)  (if (empty? TEMP)    OR2 
                                                                        (reverse(cons(if(= 1 (length TEMP)) (first TEMP) TEMP)(reverse OR2)))
                        )                                           )
                    ]
                )
            ] ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - BRACKETS ITERATIONS -  -  -  -  -  -  -  -  -  -  -  -   
            [   (or (equal? "(" (first S)) (and (> PAR 1) (equal? ")" (first S))) )
                (cond
                    [   (equal? "(" (first S))
                        (LOOP (rest S) empty (add1 PAR) 0 OR2)
                        (LOOP JUMP (if (empty? TEMP_BR) TEMP (reverse (cons TEMP_BR (reverse TEMP))))  PAR OR OR2)
                    ]
                    [    else   (if (and (> (length S) 1) (or (equal? (second S) "*")(equal? (second S) "+"))) 
                                    (set!-values (JUMP TEMP_BR)
                                        (values (rest(rest S)) (reverse (cons (second S) (if (equal? "|"(if (empty? TEMP)(last TEMP) empty))
                                                                                             (list TEMP)(list TEMP)
                                        )                      )        )                )
                                    )
                                    (set!-values (JUMP TEMP_BR) (values (rest S) TEMP ) )
                                )
                    ]
                )
            ] ;-  -  -  -  -  -  -  -  -  -  -  -   -  -  - STARS OR PLUS WRAPPING -  -  -  -  -  -  -  -  -  -  -  -   
            [   (and (> (length S) 1) (or (equal? (second S) "*")(equal? (second S) "+")))
                (if  (= (length S) 2)
                    (LOOP   (reverse (cons (list (first S) (second S))  (reverse TEMP)))   empty    PAR    OR    OR2)
                    (LOOP   (rest (rest S))   (reverse (cons (list (first S) (second S))  (reverse TEMP)))    PAR    OR    OR2)
                )   
            ] 
              ;-  -  -  -  -  -  -  -  -  -  -  -   -  -  - CHARACTERS ADDICTION -  -  -  -  -  -  -  -  -  -  -  -   -  -  - 
            [   else   (LOOP   (rest S)   (reverse (cons (first S) (reverse TEMP)))    PAR    OR    OR2)   ]
        )
    )



;-------------------------------------------- MACHINE SEQUENCE AND MACHINE EXPRESSION COMPARISON --------------------------------------------
 
    (define-values (I DONE) (values 0 0))
    (let LOOP [(S SEQUENCE_LIST) (E (list EXPRESSION_LIST))]
                                                                      ;(displayln (~a "String "S "    Expression "E))
        (cond
            [   (and(or (empty? S) (empty? E)) (not (list? (if (< 0 (length E)) (first E) 0)))  )
                (if (and (empty? S) (empty? E))
                    (let () (set! I 1) (set! DONE 1))                 ;(displayln "Sequence and Espression match!")   ]
                    null                                              ;(displayln "Some of them isn't empty")         ]
                )
            ]
            [   (or (list? (first E)) );(equal? "|"(last(first E)))  (equal? "*"(last(first E)))  (equal? "+"(last(first E))) )
                (cond
                    [   (or (equal? "|"(last(first E))) 
                            (and(or(equal? "*"(last(first E)))(equal?"+"(last(first E))))
                                (= 2(length(first E)))
                                (if(list?(first(first E))) (equal? "|"(last(first E))) #f)
                            )
                        )
                        (if (equal? "|"(last(first E)))
                            (for-each(lambda(x) (when (= DONE 0)(LOOP S (cons x (rest E)))) )(reverse(rest(reverse(first E)))))
                            (LOOP S (append(map(lambda(x) (list x (last(first E))))(reverse(rest(reverse(first(first E))))) )(rest E)) )
                        )
                    ]
                    [   (or (equal? "*"(last(first E))) (equal? "+"(last(first E))) )
                        (if (equal? "*"(last(first E)))
                            (let() (set! E (cons(reverse(rest(reverse (first E)))) (rest E)) )
                                   (LOOP S (rest E))
                                   (when (= DONE 0)      (let LOOP2 [(X (first E)) (BREACK 0)]
                                       (LOOP S (append X (rest E)) )
                                       (when(and (= I 0) (= DONE 0) (< BREACK (length(flatten S))))  (LOOP2 (append(first E) X) (add1 BREACK)) )
                                       ;(set! I 0) ;this latter is useless
                                   )                     )
                            )
                            (let() (set! E (cons(reverse(rest(reverse (first E)))) (rest E)) )
                                   (when (= DONE 0)      (let LOOP3 [(X (first E)) (BREACK 0)]
                                       (LOOP S (append X (rest E)) )
                                       (when(and (= I 0) (= DONE 0) (< BREACK (length(flatten S))))  (LOOP3 (append(first E) X) (add1 BREACK)) )
                                       ;(set! I 0) ;this latter is useless
                                   )                     )
                            )
                        )
                    ]
                    [   else   #|(displayln "else")|#   (LOOP S (append (first E) (rest E)) )   ]
                )
            ]
            [   (equal? (first E) (first(first S)))         ;(displayln "equal")
                (if (= 1 (length(first S)))
                    (LOOP (rest S) (rest E))    ;deleting the "S" empty list and going ahead
                    (LOOP (cons (rest (first S)) (rest S)) (rest E)) 
                )
            ]
            ;[   else  null  ] ;(displayln "different") (set! I 1) ]
        )
    )



;----------------------------------------------------------- OUTCOME -----------------------------------------------------------
  
    (displayln (~a "String   = " SEQUENCE "            HumanEXPRESSION = " EXPRESSION)) 
    (displayln (~a "Sequence = " SEQUENCE_LIST  "    MachineEXPRESSION = " EXPRESSION_LIST ))
    (newline)  
    (cond 
        [   (= DONE 1)    (displayln "Sequence and Espression match!")   ]
        [   else   (displayln "Sequence and Espression do not match!")   ]
    )
    (newline) (newline)  
)




;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| TESTS ||||||||||||||||||||||||||||||||||||||||||||||||

 ;(FSM2 "aabbbc" "ab*|ab*ab*c")
 (FSM2 "stop right go 1sec 1sec"  "go* 1sec* stop (left | right) go 1sec+")
