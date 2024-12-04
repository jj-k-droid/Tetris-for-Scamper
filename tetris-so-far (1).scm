(import image)
(import canvas)
(import html)

(struct tetromino
  (x y rotations))

(define shadow 
  (lambda (color)
    (let* ([c (rgb->hsv color)]
           [h (hsv-hue c)]
           [s (hsv-saturation c)]
           [v (hsv-value c)]) 
       (hsv h s (* v 0.7)))))

(define highlight 
  (lambda (color)
    (let* ([c (rgb->hsv color)]
           [h (hsv-hue c)]
           [s (hsv-saturation c)]
           [v (hsv-value c)]) 
       (hsv h (* s 0.5) v))))

(define tetris-square 
  (lambda (size color)
    (let* ([shadow (shadow color)]
           [highlight (highlight color)])
    (overlay (solid-square (* size 0.75) color)
             (path size size (list (pair 0 0) (pair 0 size) (pair size 0)) "solid" highlight)
             (solid-square size shadow)))))

(define I
  (let* ([size 20]
         [color (rgb 1 230 254)]
         [flat (beside (tetris-square size color) (tetris-square size color) (tetris-square size color) (tetris-square size color))]
         [i (above (tetris-square size color) (tetris-square size color) (tetris-square size color) (tetris-square size color))])
  (tetromino 0 0 (vector flat i flat i))))

(tetromino-rotations I)

(define J
  (let* ([size 20]
         [color (rgb 24 1 255)]
         [flat (above/align "left" (tetris-square size color)
                            (beside (tetris-square size color) (tetris-square size color) (tetris-square size color)))]
         [filpped-j (beside/align "top" 
                                      (above (tetris-square size color) (tetris-square size color) (tetris-square size color))
                                      (tetris-square size color))]
         [filpped-flat (above/align "right" (beside (tetris-square size color) (tetris-square size color) (tetris-square size color))
                                        (tetris-square size color))]
         [j (beside/align "bottom" (tetris-square size color)
                          (above (tetris-square size color) (tetris-square size color) (tetris-square size color)))])
  (tetromino 0 0 (vector flat filpped-j filpped-flat j))))

(tetromino-rotations J)

(define L
  (let* ([size 20]
         [color (rgb 255 115 9)]
         [flat (above/align "right" (tetris-square size color)
                            (beside (tetris-square size color) (tetris-square size color) (tetris-square size color)))]
         [l (beside/align "bottom" 
                          (above (tetris-square size color) (tetris-square size color) (tetris-square size color))
                          (tetris-square size color))]
         [filpped-flat (above/align "left" (beside (tetris-square size color) (tetris-square size color) (tetris-square size color))
                                        (tetris-square size color))]
         [filpped-l (beside/align "top" (tetris-square size color)
                                       (above (tetris-square size color) (tetris-square size color) (tetris-square size color)))])
  (tetromino 0 0 (vector flat l filpped-flat filpped-l))))

(tetromino-rotations L)

(define O
  (let* ([size 20]
         [color (rgb 255 222 2)]
         [o (above (beside (tetris-square size color) (tetris-square size color))
                   (beside (tetris-square size color) (tetris-square size color)))])
        (tetromino 0 0 (vector o o o o))))

(tetromino-rotations O)

(define S
  (let* ([size 20]
         [color (rgb 102 253 3)]
         [s (overlay/offset size (- size (* size 2))
                            (beside (tetris-square size color) (tetris-square size color))
                            (beside (tetris-square size color) (tetris-square size color)))]
         [vertical-s (overlay/offset size size
                                     (above (tetris-square size color) (tetris-square size color))
                                     (above (tetris-square size color) (tetris-square size color)))])
        (tetromino 0 0 (vector s vertical-s s vertical-s))))

(tetromino-rotations S)

(define Z
  (let* ([size 20]
         [color (rgb 254 17 60)]
         [z (overlay/offset size size
                            (beside (tetris-square size color) (tetris-square size color))
                            (beside (tetris-square size color) (tetris-square size color)))]
         [vertical-z (overlay/offset (- size (* size 2)) size
                                     (above (tetris-square size color) (tetris-square size color))
                                     (above (tetris-square size color) (tetris-square size color)))])
        (tetromino 0 0 (vector z vertical-z z vertical-z))))

(tetromino-rotations Z)

(define T
  (let* ([size 20]
         [color (rgb 184 3 253)]
         [flat (above/align "middle" (tetris-square size color)
                            (beside (tetris-square size color) (tetris-square size color) (tetris-square size color)))]
         [vertical-1 (beside/align "center" (above (tetris-square size color) (tetris-square size color) (tetris-square size color))
                                   (tetris-square size color))]
         [flipped-flat (above/align "middle" 
                                    (beside (tetris-square size color) (tetris-square size color) (tetris-square size color))
                                    (tetris-square size color))]
         [vertical-2 (beside/align "center" (tetris-square size color)
                                   (above (tetris-square size color) (tetris-square size color) (tetris-square size color)))])
         (tetromino 0 0 (vector flat vertical-1 flipped-flat vertical-2))))

(tetromino-rotations T)


; tetris grid
(import image)
(import canvas)
(import lab)
(define colors (list
                (rgb 0 0 0)
                 (rgb 255 0 0)
                 (rgb 255 127 0)
                 (rgb 255 255 0)
                 (rgb 0 255 0)
                 (rgb 0 255 255)
                 (rgb 0 0 255)
                 (rgb 255 0 255)))

;Grid Functions
(struct grid (width height contents))

(define create-grid
  (lambda (width height)
    (grid width height (make-vector (* width height) 0))))

(define grid-ref 
  (lambda (grid x y)
    (vector-ref (grid-contents grid) (+ x (* y (grid-width grid))))))

(define grid-set!
  (lambda (grid x y value)
    (vector-set! (grid-contents grid) (+ x (* y (grid-width grid))) value )))

(define get-row-helper 
  (lambda (grid y i)
    (if (>= i (grid-width grid))
        null
        (cons (grid-ref grid i y) (get-row-helper grid y (+ i 1))))))

(define get-row
  (lambda (grid y)
    (get-row-helper grid y 0)))

;functions to convert grid to a drawing
(define grid-value->tetris-square
  (lambda (value size)
    (if (equal? value 0)
        (solid-square size (rgb 0 0 0 0))
        (tetris-square size (list-ref colors value)))))

(define row->drawing
  (lambda (row size)
    (apply beside
      (map (section grid-value->tetris-square _ size) row ))))

(define grid->drawing-helper
  (lambda (grid size i so-far)
    (if (>= i (grid-height grid))
        (apply above so-far)
        (grid->drawing-helper grid size (+ i 1) (cons (row->drawing (get-row grid i) size) so-far)))))

(define grid->drawing 
  (lambda (grid pixel-size)
    (grid->drawing-helper grid pixel-size 0 null)))

;canvas
(define canv (make-canvas 280 100))

; 14 x 5 grid
(define test-grid (grid 14 5 (vector 7 7 7 7 0 4 4 4 4 0 0 2 2 0
                                     7 0 0 0 0 4 0 0 0 0 2 0 0 2
                                     7 0 0 0 0 4 4 4 0 0 2 0 0 2
                                     7 0 0 0 0 4 0 0 0 0 2 0 0 2
                                     7 0 0 0 0 4 4 4 4 0 0 2 2 0)))
; put the grid on the canvas
(begin (canvas-rectangle! canv 0 0 280 100 "solid" "black")
       (canvas-drawing! canv 0 0 (grid->drawing test-grid 20)))

;change pixels color and redraw the grid on click
(canvas-onclick! canv
  (lambda (x y)
    (let* ([grid-x (floor (/ x 20))]
           [grid-y (- (grid-height test-grid) (floor (/ y 20)) 1)]
           [current-value (grid-ref test-grid grid-x grid-y)]
           [new-value (remainder (+ current-value 1) 8)])
          (begin (grid-set! test-grid grid-x grid-y new-value)
                 (canvas-rectangle! canv 0 0 280 100 "solid" "black")
                 (canvas-drawing! canv 0 0 (grid->drawing test-grid 20))))))


;10 x 20 tetris grid
(define tetris-grid (create-grid 10 20))

;fill the grid with random colors
(ignore (vector-map! (section random 8) (grid-contents tetris-grid)))

;display the random color grid
(grid->drawing tetris-grid 20)

;display the canvas
(problem "click the canvas to edit the pixels \n    |\n   v")
canv


; falling animation
(define test-canvas
  (make-canvas 500 500))

(display test-canvas)


(define rotation
  (ref "none"))

(define shape-index
  (ref 0))

(define current-shape
  (ref T))

(define shape-position
  (pair 0 0))

(define rotate-shape
  (lambda (key canvas x-pos y-pos)
    (let* ([i (+ (deref shape-index) 4)]
           [shape (deref current-shape)]
           [current (vector-ref (tetromino-rotations shape) i)]
           [next (vector-ref (tetromino-rotations shape) 
                             (remainder (+ i 1) 4))]
           [prev (vector-ref (tetromino-rotations shape) 
                             (remainder (- i 1) 4))])
         (begin
            (canvas-rectangle! canvas 0 0 200 400 "solid" "black")
            (if (equal? key "x")
                (begin
                  (canvas-drawing! canvas x-pos y-pos next)
                  (ref-set! shape-index (remainder (+ i 1) 4)))
                (begin
                  (canvas-drawing! canvas x-pos y-pos prev)
                  (ref-set! shape-index (remainder (- i 1) 4))))
            (ref-set! rotation "none")))))

(on-keydown!
        (lambda (key)
            (cond
              [(and (or (equal? key "x") (equal? key "z")) (equal? (deref rotation) "none"))
                  (begin 
                    (ref-set! rotation "rotating")
                    (rotate-shape key test-canvas (deref x-position) (deref y-position)))]
              [(or (equal? key "ArrowRight") (equal? key "ArrowLeft") (equal? key "ArrowDown"))
                (move key test-canvas)]
              [else void])))              

(define move
  (lambda (key canvas)
    (let
      ([x-pos (deref x-position)]
       [y-pos (deref y-position)]
       [current-shape (vector-ref (tetromino-rotations (deref current-shape)) (deref shape-index))])
      (begin
          (canvas-rectangle! test-canvas 0 0 200 400 "solid" "black")
          (cond 
            [(equal? key "ArrowRight")
              (begin
                  (canvas-drawing! canvas x-pos y-pos current-shape)
                  (ref-set! x-position (+ x-pos 20)))]
            [(equal? key "ArrowLeft")
              (begin
                (canvas-drawing! canvas x-pos y-pos current-shape)
                (ref-set! x-position (- x-pos 20)))]
            [else 
              (begin
                (canvas-drawing! canvas x-pos y-pos current-shape)
                (ref-set! y-position (+ y-pos 100)))])))))
              
              

(define x-position
  (ref 220))

(define y-position
  (ref 500))

(define shape-spawn-time
  (ref 0))

(ignore
  (animate-with
    (lambda (time)
           (begin
             (ref-set! y-position (remainder (* (quotient (round (- time (deref shape-spawn-time))) 1000) 20) 500))
             (canvas-rectangle! test-canvas 0 0 500 500 "solid" "black")
             (canvas-drawing! test-canvas (deref x-position) (deref y-position) (vector-ref (tetromino-rotations (deref current-shape)) (deref shape-index)))
             #t))))