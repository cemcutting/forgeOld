#lang racket

(require "webserver/eval-model.rkt")

(define (check-ex-spec-backend instance gold-standard)
  (andmap (lambda (x) (eval-form x instance 7))))

