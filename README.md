# TrabajoLP_Racket
Sistema de Búsqueda de Textos en Kotlin
Sistema con menú de acceso y búsqueda de textos mediante 3 algoritmos posibles
Proyecto elaborado para el curso de Lenguajes de Programación de la Universidad de Lima
Ingreso al Sistema
Se accede al programa mediante una serie de usuarios y contraseñas previamente registrados. Si se tiene éxito, se muestra el menú de opciones:

texto del registrador
Buscar palabra/oración en texto registrado
Ver historial de busquedas
salir
registro de texto
Los textos son registrados mediante la ruta de ubicación de los mismos. Es importante que el archivo esté en la misma unidad de memoria para evitar errores.

Búsqueda de palabra/oración
Se dan 3 opciones de algoritmos de búsqueda de cadenas al usuario:

fuerza bruta
Boyer-Moore
KMP (Knuth-Morris-Pratt) (Los algoritmos ya están implementados para su uso directo con este sistema).
Una vez elegido, el usuario debe ingresar la cadena a buscar. Se mostrarán las posiciones del texto en que se encontraron coincidencias, además de otro menú con las siguientes opciones:

Mostrar cantidad de apariciones
Ver apariciones
Ir a la siguiente ocurrencia
Ir a la ocurrencia anterior
Cancelar operación (Opción 5 devuelve a menú de selección de algoritmos).
Historial de busquedas
Se muestra:

Número de orden de búsqueda
texto elegido
Palabra/oracion de busqueda
Tiempo de duracion de busqueda (del sistema, no interaccion con el usuario).
Cantidad de apariciones
