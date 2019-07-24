#lang web-server
  
(require  web-server/servlet-env
          xml
          web-server/http/xexpr)

(define my-xml-response
  (response/xexpr `(xml "victory!")
                  #:mime-type #"text/xml charset=utf-8"
                  #:headers (list (make-header #"Set-Cookie" #"name=mikey"))))
  
(define (start request)
  (letrec ((response-generator (λ (make-url)
                                 (response/xexpr `(html (head 
                                                         (script ((type "text/javascript")) ,(format StartXMLHttpRequest (make-url receive-ajax-signal)))
                                                         (script ((type "text/javascript")) ,processChange)
                                                         )
                                                        (body (div ((onclick "alert('things are working');"))  "Hello jay")
                                                                     (div ((onclick "StartXMLHttpRequest('some data');"))  "click for AJAX-type Request")
                                                                     (a ((href ,(make-url receive-signal)))"click for browser-window-type Request"))))))
           (receive-ajax-signal   (λ (request)
                                    my-xml-response))
           (receive-signal (λ (request)
                              (send/suspend/dispatch response-generator))))
    (send/suspend/dispatch response-generator)))


(define StartXMLHttpRequest (string-append "function StartXMLHttpRequest(post_data){ "
                                           "obj = new XMLHttpRequest(); "
                                           "obj.onreadystatechange = processChange;"
                                           "obj.open('POST','~A',false); "
                                           "obj.setRequestHeader('Content-Type','application/x-www-form-urlencoded'); "
                                           "obj.send(post_data); "
                                           "processChange();"
                                            "} "))

                 
(define processChange "function processChange(){alert('in processChange!');}")
                                           

(serve/servlet start
               #:stateless? #t        
               #:launch-browser? #t
               #:connection-close? #t
               #:quit? #f 
               #:listen-ip #f 
               #:port 8000
               #:servlet-path "/")