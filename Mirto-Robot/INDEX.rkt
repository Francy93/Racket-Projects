#lang racket
 (require web-server/servlet web-server/servlet-env racket/path file/convertible)
 (require "AsipMain.rkt" "MirtoBlack.rkt" "MirtoVacum.rkt" "LangRun.rkt")
 ;(require racket/gui/base);racket/draw mred)



(define WARNING "Nothing entered so far")

(define (HTML)  
	`(html
	    (head  (title "Mirto Project")
	           (link ([rel "icon"] [href "/LOGO.png"] [type "image/png"] [sizes "16x16"]))
	    )
	    (style
		    "div {font-family: -apple-system, system-ui, BlinkMacSystemFont, Roboto, Ubuntu;}
			"
		    "h1 {   margin-top: 3%;
			        margin-bottom: 6%;
			    }
			"
		    ".wrap {	border-style: solid;
			        	border-width: 1px;
						border-color: white;
						width: 70%;
						padding: 5px;
					}
			"
			"#warning   {   justify-content:space-betweeny;
				            margin: 10px;
					    }
			"
			"#warning h5    {	display: inline-block;
				            	margin: 5px; 
					        }
			"
			"#warning h3    {   display: inline-block;
				                margin: 5px; 
					        }
			"
			".box   {   display: inline-block;
						width: 30%;
						margin: 10px;
					}
			"
			".box input {   width: 90%;
			                margin: 10px; 
					    }
			"
			".modes {   width: 20%;
						margin: 6%; 
					}
			"
			".modes div {
				            display: flex;
				            justify-content:space-around;
					    }
			"
		)

		(body
			([bgcolor "red"])
			(div ([align "center"])
				(font ([color "white"]  [face "Helvetica"]) (h1 "Welcome to Mirto Control Settings"))
			)
			(div ([align "center"])
			   ;(img ([src "LOGO.png"]))
				(font ([color "black"] [face "San Francisco"])
					(form
						(div ([id "warning"])
							    (h3 "Language set:  (go stop wait right left back)")
								(h5 "The language entered is: (" ,WARNING ")")
						)
						(div ([class "wrap"]);([align "center"])
							(div ([class "box"])
								(p "Enter here below your language")
								(input ( [name "lang"] [placeholder "e.g:  go wait wait left wait go wait stop"] ))
									
							)
							(div ([class "box"])
								(p "Enter here below your expression")
								(input ( [name "expr"] [placeholder "e.g:  ((go|left|right)* wait)+ stop"] ))
							)
							(input ( [name "fsm"  ] [type "submit"] [value "FSM"] ))
						)
						(div ([class "modes"] [align "center"])
							(p "AUTOMATIC")
							(div
								(input ( [name "vacum"] [type "submit"] [value "Vacum Cleaner"]))
								(input ( [name "black"] [type "submit"] [value "Black Line"]))
							)
						)
					)
				)
			)
		)
	)
)


(define (myresponse request)
;; We extract the key/value pairs (if present):
    (define bindings (request-bindings request))

    
;; If there is a "name" key, we print "Hi (name)"
    (cond 
        [   (exists-binding? 'vacum bindings)
            (displayln "Vacum selected") (Vacum) (displayln "Vacum exited") 
	        
            (response/xexpr
                (HTML)
			)
        ]

        [   (exists-binding? 'black bindings)
            (displayln "Black selected") (BlackLine) (displayln "Black exited")
            (response/xexpr
                (HTML)
			)
        ]

        [   (exists-binding? 'fsm bindings)
		    (displayln "Fsm selected")
			(cond 
			    [   (or (equal? "" (first(extract-bindings 'lang bindings)))   (equal? "" (first(extract-bindings 'expr bindings)))   )
				    (set! WARNING "Warning! You didn't enter any language or expression")
				]
				[   else    (set! WARNING (first (extract-bindings 'lang bindings)) )
				            (displayln "Start SX_CHECK")
							(define SX_CHECK (SYNTAX_CHECK (extract-bindings 'lang bindings) (extract-bindings 'expr bindings) ))
							(displayln "End SX_CHECK")
						    (cond 
							    [	(= 0 SX_CHECK)  (FUN_LANG)   ]
								[	(= 1 SX_CHECK)  (set! WARNING "Language set expected does not match the one entered")    ]
								[	(= 2 SX_CHECK)  (set! WARNING "Language and expression do not match")    ]
							)
				]
			)
			(displayln "Fsm exited")
            (response/xexpr
			   (HTML)
			)
        ]

        [   else   ;; If there is no "name", we generate a form: 
		    (displayln "Else, first page")
            (response/xexpr
			   (HTML)
			)
			
        ]
    )
)

 (serve/servlet myresponse
	#:listen-ip #f 
    #:port 8080
    #:servlet-path "/MEFProject"
	#:launch-browser? #t
 )