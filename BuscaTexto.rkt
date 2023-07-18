#lang racket

(define users (hash
               "20194079" "fAlejandra"
               "20170766" "jMaria"
               "20162536" "sDaniella"
               "20202308" "zRobert"
               "20202333" "zFernando"))

(define history '())

(define-struct ResultadoBusqueda (texto busqueda duracion apariciones tipoBusqueda))

(define (loadTextFromFile filePath)
  (define file (open-input-file filePath))
  (define text (read-string file))
  (close-input-port file)
  text)

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

;; Función principal
(define (main)
  (define scanner (open-input-string ""))
  (define history '())

  (display "Ingrese su usuario y contraseña para acceder al sistema.")
  (newline)
  (display "")
  (display "Usuario: ")
  (set! username (read-line))
  (display "Contraseña: ")
  (set! password (read-line))

  (if (and (hash-has-key? users username) (string=? (hash-ref users username) password))
      (begin
        (display " ")
        (display (string-append "Inicio de sesión exitoso. ¡Bienvenid@, " username "!"))
        (display " ")
        (newline)

        (define text "")
        (define currentPosition -1)
        (define searchHistory '())

        (let loop ()
          (display "-------- MENU --------")
          (newline)
          (display "1. Registrar un texto")
          (newline)
          (display "2. Buscar palabra / oración en un texto")
          (newline)
          (display "3. Ver historial de búsquedas")
          (newline)
          (display "4. Salir")
          (newline)
          (display "----------------------")
          (newline)
          (display "Ingrese el número de la opción deseada: ")
          (define option (read))
          (newline)

          (cond
            [(= option 1)
             (display " ")
             (display "Ingrese la ruta del archivo de texto a cargar: ")
             (set! filePath (read-line))
             (set! text (loadTextFromFile filePath))
             (if (not (string=? text ""))
                 (begin
                   (display "Texto cargado exitosamente.")
                   (newline))
                 (display "Error con archivo de texto."))]

            [(= option 2)
             (if (string=? text "")
                 (display "Aún no hay textos registrados.")
                 (begin
                   (display " ")
                   (display "Seleccione un tipo de búsqueda...")
                   (newline)
                   (display "1. Búsqueda por Fuerza Bruta")
                   (newline)
                   (display "2. Búsqueda Boyer-Moore")
                   (newline)
                   (display "3. Búsqueda KMP")
                   (newline)
                   (display "Ingrese el número de la opción deseada: ")
                   (define searchOption (read))
                   (newline)

                   (define tipoBusqueda
                     (cond
                       [(= searchOption 1) "por Fuerza Bruta"]
                       [(= searchOption 2) "por Boyer-Moore"]
                       [(= searchOption 3) "por KMP"]
                       [else
                        (begin
                          (display "Opción inválida. No se realizará ninguna acción adicional.")
                          (loop))]))))

               (display "Ingrese la palabra / oración a buscar: ")
               (define busqueda (read-line))
               (define duracion 0)
               (define posiciones '())

               (cond
                 [(= searchOption 1)
                  (define start-time (current-milliseconds))
                  (set! posiciones (fbSearch text busqueda))
                  (set! duracion (- (current-milliseconds) start-time))]

                 [(= searchOption 2)
                  (define start-time (current-milliseconds))
                  (set! posiciones (boyerMooreSearch busqueda text))
                  (set! duracion (- (current-milliseconds) start-time))]

                 [(= searchOption 3)
                  (define start-time (current-milliseconds))
                  (set! posiciones (searchByKMP text busqueda))
                  (set! duracion (- (current-milliseconds) start-time))]

                 [else
                  (display "Opción inválida. No se realizará ninguna acción adicional.")
                  (newline)
                  (loop)])

               (if (not (null? posiciones))
                   (begin
                     (display "Se encontraron coincidencias en las siguientes posiciones:")
                     (newline)
                     (for-each println posiciones)
                     (set! searchHistory posiciones)
                     (set! currentPosition 0))
                   (display "No se encontraron coincidencias."))

               (let ([resultado (ResultadoBusqueda text busqueda duracion (length posiciones) tipoBusqueda)])
                 (set! history (cons resultado history)))]

            [(= option 3)
             (display "Historial de búsquedas!")
             (newline)
             (for-each
               (λ (index resultado)
                 (display (string-append "Búsqueda " (number->string (+ index 1)) ", " (ResultadoBusqueda-tipoBusqueda resultado) ":"))
                 (newline)
                 (display (string-append "Texto elegido: " (ResultadoBusqueda-texto resultado)))
                 (newline)
                 (newline)
                 (display (string-append "Palabra/oración de búsqueda: " (ResultadoBusqueda-busqueda resultado)))
                 (newline)
                 (display (string-append "Tiempo de duración de la búsqueda: " (number->string (ResultadoBusqueda-duracion resultado)) " ms"))
                 (newline)
                 (display (string-append "Cantidad de apariciones: " (number->string (ResultadoBusqueda-apariciones resultado))))
                 (newline)
                 (newline))
               (reverse history) (in-naturals))]

            [(= option 4)
             (display "Hasta luego!")
             (newline)
             (return)]

            [else
             (display "Opción inválida. Por favor, ingrese un número válido.")]
          (newline)
          (loop))))))

(main)
