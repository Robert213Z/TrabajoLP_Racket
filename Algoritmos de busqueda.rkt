;; Algoritmo de Fuerza Bruta
(define (fbSearch textoFB patron)
  (define posiciones '())
  (define count 0)
  (define n (string-length textoFB))
  (define m (string-length patron))

  (define (match? i j)
    (and (< j m) (char=? (string-ref textoFB (+ i j)) (string-ref patron j))))

  (for ([i (- n m)])
    (define j 0)
    (while (and (< j m) (match? i j))
      (set! j (+ j 1)))
    (when (= j m)
      (set! count (+ count 1))
      (set! posiciones (cons i posiciones))))

  (if (= count 0)
      (println "No se encontraron coincidencias.")
      (begin
        (println (string-append "Se encontraron " (number->string count) " ocurrencias en las siguientes posiciones:"))
        (for-each println posiciones)))
  posiciones)
;; Algoritmo de Boyer Moore
(define (boyerMooreSearch pattern text)
  (define badCharacterTable (make-vector 256 (string-length pattern))) ; Corrección: tamaño 256 en lugar de 999999
  (define (createBadCharacterTable)
    (for ([i (in-range (string-length pattern) -1 -1)])
      (vector-set! badCharacterTable (char->integer (string-ref pattern i)) (- (string-length pattern) 1 i))))
  (createBadCharacterTable)

  (define (createGoodSuffixTable)
    (define table (make-vector (string-length pattern) 0))
    (define suffixes (make-vector (string-length pattern) 0))
    (define lastPrefixIndex (string-length pattern))
    (for ([i (in-range (- (string-length pattern) 1) -1 -1)])
      (if (isPrefix? pattern (+ i 1))
          (set! lastPrefixIndex (+ i 1)))
      (vector-set! suffixes i lastPrefixIndex))

    (for ([i (in-range (string-length pattern) -1 -1)])
      (define suffixLength (getSuffixLength i))
      (vector-set! table suffixLength (- (string-length pattern) 1 i suffixLength)))

    (for ([i (in-range (string-length pattern) -1 -1)])
      (define suffixLength (getSuffixLength i))
      (when (= suffixLength (+ i 1))
        (for ([j (in-range (- (string-length pattern) 1 suffixLength) -1 -1)])
          (when (= (vector-ref table j) (string-length pattern))
            (vector-set! table j (- (string-length pattern) 1 suffixLength))))))

    table)

  (define table (createGoodSuffixTable))

  (define indices '())
  (define i 0)

  (while (<= i (- (string-length text) (string-length pattern)))
    (define j (- (string-length pattern) 1))

    (while (and (>= j 0) (char=? (string-ref pattern j) (string-ref text (+ i j))))
      (set! j (- j 1)))

    (if (< j 0)
        (begin
          (set! indices (cons i indices))
          (set! i (+ i (string-length pattern))))
        (set! i (+ i (max (vector-ref badCharacterTable (char->integer (string-ref text (+ i j))))
                          (- j (vector-ref table j)))))))

  indices)

;; Algoritmo de Knuth-Morris-Pratt (KMP)
(define (searchByKMP text pattern)
  (define positions '())
  (define prefixSuffixTable (buildPrefixSuffixTable pattern))
  (define i 0)
  (define j 0)

  (define (buildPrefixSuffixTable pattern)
    (define table (make-vector (string-length pattern) 0))
    (define length 0)
    (define i 1)

    (while (< i (string-length pattern))
      (if (char=? (string-ref pattern i) (string-ref pattern length))
          (begin
            (set! length (+ length 1))
            (vector-set! table i length)
            (set! i (+ i 1)))
          (if (> length 0)
              (set! length (vector-ref table (- length 1)))
              (set! i (+ i 1)))))

    table)

  (while (< i (string-length text))
    (if (char=? (string-ref pattern j) (string-ref text i))
        (begin
          (set! i (+ i 1))
          (set! j (+ j 1))))
    (if (= j (string-length pattern))
        (begin
          (set! positions (cons (- i j) positions))
          (set! j (vector-ref prefixSuffixTable (- j 1))))
        (when (and (< i (string-length text))
                   (not (char=? (string-ref pattern j) (string-ref text i))))
          (if (> j 0)
              (set! j (vector-ref prefixSuffixTable (- j 1)))
              (set! i (+ i 1))))))

  positions)
