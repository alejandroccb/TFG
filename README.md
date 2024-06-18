# Códigos Convolucionales Cíclicos Sesgados. Algoritmo de Sugiyama

>  Doble Grado Ingeniería Informática y Matemáticas

> Autor: Alejandro Cárdenas Barranco

> Tutor: Gabriel Navarro Garulo

>  Departamento de Álgebra

## 📄 Descripción

El objetivo de este trabajo es explorar los códigos convolucionales cíclicos sesgados, una clase de códigos convolucionales que facilita el diseño de algoritmos de decodificación eficientes. Para ello, presentaremos el algoritmo de Sugiyama y lo implementaremos utilizando el software SageMath. Comenzaremos con nociones básicas de álgebra, incluyendo teoría de anillos, cuerpos y módulos, y luego estudiaremos los códigos lineales y cíclicos. Finalmente, examinaremos los códigos convolucionales y los anillos de polinomios sesgados para implementar el algoritmo de Sugiyama.

## 🎯 Objetivos

### Matemáticas

En cuanto al ámbito de las Matemáticas, los objetivos de este trabajo son:

- Estudiar las nociones básicas de la teoría de códigos lineales.
- Explorar los códigos convolucionales y su estructura algebraica, así como algunas de sus propiedades fundamentales.
- Investigar la noción de ciclicidad para los códigos convolucionales mediante los polinomios de Ore.
- Estudiar los códigos convolucionales sesgados Reed-Solomon.
- Exponer el algoritmo de Sugiyama para códigos convolucionales sesgados Reed-Solomon.

### Ingeniería Informática

En cuanto a la Ingeniería Informática, observemos que los objetivos anteriores se enmarcan en el campo de la Computación teórica. Además, otros objetivos más específicos son:

- Implementar el algoritmo de Sugiyama para la decodificación de códigos BCH.
- Implementar un sistema de construcción de códigos convolucionales sesgados Reed-Solomon.
- Implementar un sistema de codificación de códigos convolucionales sesgados Reed-Solomon.
- Implementar el algoritmo de Sugiyama para la decodificación de códigos convolucionales sesgados Reed-Solomon.

## ⚙️ Instrucciones para Ejecutar el Código

Para ejecutar el código desarrollado en este proyecto:

1. **Instalar SageMath**: Se debe tener SageMath instalado, se puede descargar e instalar desde [aquí](https://www.sagemath.org/download.html).

2. **Clonar el Repositorio**: Clona el repositorio de GitHub en tu máquina local utilizando el siguiente comando:

   ```sh
   git clone https://github.com/alejandroccb/TFG.git
   ```

   Navegar al directorio del repositorio clonado:

   ```sh
   cd TFG
   ```

3. **Cargar los Ficheros .sage**: Abrir SageMath y cargar cada fichero `.sage` usando la función `load()`. Por ejemplo, si se quiere cargar el fichero `sccc_sugiyama.sage` se debe cargar de la siguiente forma:

   ```sage
   load('ruta/al/fichero/sccc_sugiyama.sage')
   ```

4. **Ejecutar el Código**: Una vez cargados todos los ficheros `.sage`, se pueden ejecutar las funciones y algoritmos definidos en ellos.

Se pueden probar los cuadernillos que se encuentran en la carpeta `jupyter`, donde se encuentran ejemplos del uso de los métodos de las clases implementadas.

## ✅ Instrucciones para Ejecutar los Tests

Para ejecutar los tests desarrollados en este proyecto, se deben seguir estos pasos:

1. **Navegar al Directorio de Tests**: Desde el directorio principal del proyecto, navegar al directorio de tests:

   ```sh
   cd src/test
   ```

2. **Ejecutar los Tests**: Ejecutar los siguientes comandos para correr los tests usando `pytest`:

   ```sh
   sage -python -m pytest -vv -p no:warnings test_bch_sugiyama.py
   sage -python -m pytest -vv -p no:warnings test_sccc_sugiyama.py
   ```

Se debe instalar `PyTest` previamente.
