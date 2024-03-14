;- Procedure: main-procedure
;- Input : Takes only one parameter named tripleList
;- Output : Returns list of triples according to the scenario
; described in section 3.
; Returns an error if the given parameter is not a tripleList.
(define main-procedure
    (lambda (tripleList)
        (if (or (null? tripleList) (not (list? tripleList)))
            (error "ERROR305: the input should be a list full of triples")
            (if (check-triple? tripleList)
                (sort-area (filter-pythagorean (filter-triangle
                (sort-all-triples tripleList))))
                (error "ERROR305: the input should be a list full of triples")
             )
         )
     )
 )

;- Procedure: positive?
;- Input : Takes only one parameter named num
;- Output : Returns true if the number is positive
; returns false if otherwise.
(define positive?
    (lambda (num)
     (and (number? num) (> num 0))
    )
 )

;- Procedure: check-triple?
;- Input : Takes only one parameter named tripleList
;- Output : Returns true if the given parameter consists of triples,
; returns false if otherwise.
;- Hint: You can assume that the given input to this procedure is
; a list and it is not null.
;- Examples :
; (check-triple? ’((1 2) (3 4 5))) ------> evaluates to false since ’(1 2)
;has only 2 elements
; (check-triple? ’((5 12 12) (6 6 6) ())) ----> evaluates to false since
; ’() is empty
; (check-triple? ’((5 3 9) (9 55 32) (’a 28 67))) -----> evaluates to false
; since ’a is not a number
; (check-triple? ’((5 12 13) (3 4 5) (16 63 65) (12 35 37))) --> evaluates to true
(define check-triple?
     (lambda (tripleList)
	(let loop ((ls tripleList))
           (cond
            ((null? ls) #t)
            ((check-single-triple? (car ls))
             (loop (cdr ls)))
            (else #f)
            )
	)
      )
)

;- Procedure: check-single-triple?
;- Input : Takes only one parameter named inTriple
;- Output : Returns true if the given parameter consists of triples,
; returns false if otherwise.
(define check-single-triple?
    (lambda (inTriple)
        (and (check-length? inTriple 3)
         (check-sides? inTriple))
     )
)

;- Procedure: check-length?
;- Input : Takes two parameters as inTriple and count
;- Output : Returns true if the length of the given list
; equals to count, returns false if otherwise.
;- Hint: You can assume that the given input (inTriple) to this procedure is
; a list.
;- Examples :
; (check-length? ’(’a ’bc) 2) --> evaluates to true
; (check-length? ’(3 4 5) 3) --> evaluates to true
; (check-length? ’(2 3 4 5) 3) --> evaluates to false since the length
; of the list is not 3
; (check-length? ’(3 4 5) 4) --> evaluates to false since the length of
; the list is not 4
(define check-length?
    (lambda (inTriple count)
        (= (length inTriple) count)
    )
)

;- Procedure: check-sides?
;- Input : Takes only one parameter named inTriple
;- Output : It returns true if all of the elements in the given
; list are numbers and each of the numbers is greater than zero.
; It returns false if otherwise.
;- Hint: You can assume that the given input to this procedure is
; a list and it has 3 elements.
;- Examples :
; (check-sides? ’(6 4 27)) --> evaluates to true
; (check-sides? ’(6 0 27)) --> evaluates to false since not all
;                              elements are greater than 0
; (check-sides? ’(() ’c 3)) -------> evaluates to false since
;                                  ’() and ’c are not numbers
; (check-sides? ’(#t 10 14)) -------> evaluates to false since #t is not a number
(define check-sides?
     (lambda (inTriple)
         (and (positive? (car inTriple))
          (positive? (cadr inTriple))
          (positive? (caddr inTriple))
          )
      )
)

;- Procedure: sort-all-triples
;- Input : Takes only one parameter named tripleList
;- Output : Returns the list of triples given as the parameter in which
; all triples are sorted internally in ascending order.
;- Hint: You can assume that the given input to this procedure is
; a list of triples (see section 4).
;- Examples :
; (sort-all-triples ’((4 3 5) (9 4 6) (13 12 1) (6 6 6))) --> evaluates to
;                                      ((3 4 5) (4 6 9) (1 12 13) (6 6 6))
; (sort-all-triples ’((4 7 9) (15 36 9))) --> evaluates to ((4 7 9) (9 15 36))
(define sort-all-triples
        (lambda (tripleList)
          (map sort-triple tripleList)
         )
)

;- Procedure: sort-triple
;- Input : Takes only one parameter named inTriple
;- Output : It returns the sorted inTriple in ascending order.
;- Hint: You can assume that the given input to this procedure is
; a triple (see section 3).
;- Examples :
; (sort-triple ’(4 3 5)) --> evaluates to (3 4 5)
; (sort-triple ’(8 8 8)) -------> evaluates to (8 8 8)
; (sort-triple ’(6 10 14)) -------> evaluates to (6 10 14)
(define sort-triple
    (lambda (inTriple)
      (cond ((<= (car inTriple) (cadr inTriple))
             (cond ((<= (cadr inTriple) (caddr inTriple)) inTriple)
                    ((<= (car inTriple) (caddr inTriple)) (list (car inTriple) (caddr inTriple) (cadr inTriple)))
                    (else (list (caddr inTriple) (car inTriple) (cadr inTriple))))
             )
            ((<= (car inTriple) (caddr inTriple))
             (list (cadr inTriple) (car inTriple) (caddr inTriple))
             )
            ((<= (cadr inTriple) (caddr inTriple))
             (list (cadr inTriple) (caddr inTriple) (car inTriple))
             )
            (else
             (list (caddr inTriple) (cadr inTriple) (car inTriple))
             )
       )
     )
)

;- Procedure: filter-triangle
;- Input : Takes only one parameter named tripleList
;- Output : It returns tripleList consists of triples that each triple represents
; a triangle. So, it filters triangles in intripleList and discards other triples.
; The Triangle rule is explained in section 3.
;- Hint: You can assume that the given input to this procedure is
; a list of triples that each of the triples is sorted internally in ascending order.
;- Examples :
; (filter-triangle ’((3 4 5) (4 6 9) (1 12 13))) --> evaluates to ((3 4 5) (4 6 9))
; (filter-triangle ’((8 10 21) (22 31 53))) --> evaluates to ()
(define filter-triangle
     (lambda (tripleList)
       (let loop ((ls tripleList) (res '()))
           (cond
            ((null? ls) (reverse res))
            ((triangle? (car ls))
             (loop (cdr ls) (cons (car ls) res)))
            (else (loop (cdr ls) res))
            )
        )
      )
)

;- Procedure: triangle?
;- Input : Takes only one parameter named triple
;- Output : It returns true if the given triple satisfies the triangle rule,
; returns false if otherwise.
; The Triangle rule is explained in section 3.
;- Hint: You can assume that the given input to this procedure is
; a triple (see section 3) in which all elements are sorted in ascending order.
;- Examples :
; (triangle? ’(4 6 8)) ---> evaluates to #t
; (triangle? ’(12 21 34)) ---> evaluates to #f
; (triangle? ’(9 10 18)) ---> evaluates to #t
(define triangle?
    (lambda (triple)
         (and
            (> (+ (car triple) (cadr triple)) (caddr triple))
            (> (+ (car triple) (caddr triple)) (cadr triple))
            (> (+ (cadr triple) (caddr triple)) (car triple))
          )
     )
)

;- Procedure: filter-pythagorean
;- Input : Takes only one parameter named tripleList
;- Output : It returns tripleList consists of triples that each triple represents
; a pythagorean triangle. So, it filters pythagorean triangles in intripleList
; and discards other triples.
; The Pythagorean theorem is explained in section 3.
;- Hint: You can assume that the given input to this procedure is
; a list of triples that each of the triples is sorted internally in ascending order,
; and satisfies the Triangle rule (see section 3).
;- Examples :
; (filter-pythagorean ’((3 4 5) (4 6 8))) ---> evaluates to ((3 4 5))
; (filter-pythagorean ’((3 4 5) (13 18 30) (5 12 13) (8 8 8))) ---> evaluates to
; ((3 4 5) (5 12 13))
; (filter-pythagorean ’((7 11 16) (9 11 12))) --------> evaluates to ()
(define filter-pythagorean
     (lambda (tripleList)
      (let loop ((ls tripleList) (res '()))
          (cond
           ((null? ls) (reverse res))
           ((pythagorean-triangle? (car ls))
            (loop (cdr ls) (cons (car ls) res)))
           (else (loop (cdr ls) res))
           )
       )
      )
)

;- Procedure: pythagorean-triangle?
;- Input : Takes only one parameter named triple
;- Output : It returns true if the given triple satisfies the Pythagorean theorem,
; returns false if otherwise.
; The Pythagorean theorem is explained in section 3.
;- Hint: You can assume that the given input to this procedure is
; a triple (see section 3) in which all elements are sorted in ascending order.
; Also, the triple itself satisfies the Triangle rule.
;- Examples :
; (pythagorean-triangle? ’(4 6 8)) ---> evaluates to #f
; (pythagorean-triangle? ’(5 12 13)) ---> evaluates to #t
; (pythagorean-triangle? ’(7 24 25)) ---> evaluates to #t
; (pythagorean-triangle? ’(9 10 18)) ---> evaluates to #f
(define pythagorean-triangle?
     (lambda (triple)
         (let (
               (a (car triple))
               (b (cadr triple))
               (c (caddr triple)))
          (= (+ (* a a) (* b b)) (* c c))
          )
      )
)

;- Procedure: sort-area
;- Input : Takes only one parameter named tripleList
;- Output : Returns the list of triples given as the parameter in which
; all triples are sorted according to the areas of the pythagorean triangles
; in ascending order.
;- Hint: You can assume that the given input to this procedure is
; a list of triples that each of the triples is sorted internally in ascending order,
; and satisties the Pythagorean theorem (see section 3).
; Examples :
; (sort-area ’((5 12 13) (3 4 5) (16 63 65) (12 35 37))) --> evaluates to
; ((3 4 5) (5 12 13) (12 35 37) (16 63 65))
; (sort-area ’((5 12 13) (16 63 65) (3 4 5))) ------>  evaluates to ((3 4 5) (5 12 13) (16 63 65))
(define sort-area
      (lambda (tripleList)
       (sort tripleList (lambda (a1 a2)
                         (< (get-area a1) (get-area a2)))
        )
       )
)

;- Procedure: get-area
;- Input : Takes only one parameter named triple
;- Output : It returns the area of the given pythagorean triangle.
;- Hint: You can assume that the given input to this procedure is
; a triple (see section 3) in which all elements are sorted in ascending order.
; Also, the triple itself satisfies the Pythagorean theorem (see section 3).
;- Examples :
; (get-area ’(3 4 5)) ---------> evaluates to 6
; (get-area ’(5 12 13)) -------> evaluates to 30
; (get-area ’(12 35 37)) ------> evaluates to 210
(define get-area
   (lambda (triple)
    (let (
          (a (car triple))
          (b (cadr triple))
          (c (caddr triple)))
     (/ (* a b) 2)
     )
    )
)
