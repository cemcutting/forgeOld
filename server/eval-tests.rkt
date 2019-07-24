#lang racket

(require "eval-model.rkt")

(require rackunit)
(require (only-in test-engine/racket-tests check-error))

(define binding #hash([r . ((a b) (b c))] [b . ((b) (q) (z) (c))] [a . ((a))] [c . ((c))]))

;(check-equal? (eval-exp '(plus 1 2) binding 7) '((3)))


; Normal case binary-op tests
(check-equal? (eval-exp '(+ a c) binding 7) '((a) (c)))
(check-equal? (eval-exp '(+ a a) binding 7) '((a)))
(check-equal? (eval-exp '(+ b c) binding 7) '((b) (q) (z) (c)))
(check-equal? (eval-exp '(+ a r) binding 7) '((a) (a b) (b c)))
(check-equal? (eval-exp '(+ a 9) binding 7) '((a) (2)))
(check-equal? (eval-exp '(+ a (- b b)) binding 7) '((a)))

(check-equal? (eval-exp '(- a c) binding 7) '((a)))
(check-equal? (eval-exp '(- a a) binding 7) '())
(check-equal? (eval-exp '(- b a) binding 7) '((c) (z) (q) (b)))
(check-equal? (eval-exp '(- b c) binding 7) '((z) (q) (b)))
(check-equal? (eval-exp '(- r a) binding 7) '((a b) (b c)))
(check-equal? (eval-exp '(- c a) binding 7) '((c)))
(check-equal? (eval-exp '(- c b) binding 7) '())

(check-equal? (eval-exp '(& a a) binding 7) '((a)))
(check-equal? (eval-exp '(& a b) binding 7) '())
(check-equal? (eval-exp '(& b a) binding 7) '())
(check-equal? (eval-exp '(& b c) binding 7) '((c)))
(check-equal? (eval-exp '(& a 3) binding 7) '())

(check-equal? (eval-exp '(-> a a) binding 7) '((a a)))
(check-equal? (eval-exp '(-> a b) binding 7) '((a b) (a q) (a z) (a c)))
(check-equal? (list->set (eval-exp '(-> b b) binding 7)) (list->set '((b b) (b q) (b z) (b c) (q b) (q q) (q z) (q c) (z b) (z q) (z z) (z c) (c b) (c q) (c z) (c c))))
(check-equal? (eval-exp '(-> a r) binding 7) '((a a b) (a b c)))
(check-equal? (eval-exp '(-> a (-> a (-> a (-> a a)))) binding 7) '((a a a a a)))
(check-equal? (eval-exp '(-> a (-> a (-> a (-> a c)))) binding 7) '((a a a a c)))
(check-equal? (eval-exp '(-> a (-> a (-> a (-> a r)))) binding 7) '((a a a a a b) (a a a a b c)))

(check-equal? (eval-exp '(join a r) binding 7) '((b)))
(check-equal? (eval-exp '(join (-> a a) r) binding 7) '((a b)))
(check-equal? (eval-exp '(join (-> b b) r) binding 7) '((b c) (q c) (z c) (c c)))

(check-error (eval-exp '((a a) (a c)) binding 7) "Implicit set comprehension is disallowed - use \"set\"")
(check-error (eval-exp '((a c) (a c)) binding 7) "Implicit set comprehension is disallowed - use \"set\"")
(check-error (eval-exp '((a r)) binding 7) "Implicit set comprehension is disallowed - use \"set\"")

; Cardinality tests:
(check-equal? (eval-exp '(card r) binding 7) '((2)))
(check-equal? (eval-exp '(card (+ r (-> a c))) binding 7) '((3)))
(check-equal? (eval-exp '(card (+ r 2)) binding 7) '((3)))
(check-equal? (eval-exp '(card (+ r r)) binding 7) '((2)))

(check-equal? (eval-exp 'b binding 7) '((b) (q) (z) (c)))


(check-true (eval-form '(some b) binding 7))
(check-false (eval-form '(one b) binding 7))
(check-false (eval-form '(in a b) binding 7))

(check-true (eval-form '(in a a) binding 7))

(check-true (eval-form '(all x b (in x b)) binding 7))
(check-false (eval-form '(all x b (in x a)) binding 7))

(check-equal? (eval-exp '(set x b (in x b)) binding 7) '((b) (q) (z) (c)))
(check-equal? (eval-exp '(set x b (in x c)) binding 7) '((c)))