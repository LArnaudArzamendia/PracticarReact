# Entrega 1.1 - Diseño de interfaz web móvil y desarrollo inicial

## Objetivos

El objetivo de esta entrega es documentar el diseño de la interfaz de usuario de la aplicación móvil, utilizando preferentemente la herramienta Figma.

## Diseño de Interfaz de Usuario

Para un conjunto de requisitos del [enunciado general del proyecto](../../README.md) (verlos a continuación), se debe presentar un diseño de interfaz móvil de mediana fidelidad, es decir, mostrar todas las pantallas asemejándose a la interfaz real, pero sin implementar funcionalidad real, sino _sólo navegación básica mediante enlaces entre las distintas pantallas_.

El diseño de interfaz debe realizarse considerando que el toolkit de interfaz de usuario móvil preferido será Material UI de Google, en su versión 3, y la implementación a usar será la biblioteca MUI de componentes para React ([https://mui.com/material-ui/](https://mui.com/material-ui/)), versión 7.

Para el diseño de la interfaz, usaremos Figma, con UI kits [Material 3 Design Kit](https://www.figma.com/community/file/1035203688168086460), y [Material UI for Figma (and MUI X)](https://www.figma.com/community/file/912837788133317724/material-ui-for-figma-and-mui-x). Para usar un mockup de un dispositivo móvi, es recomendable el uso del UI kit [Minimal Mockups](https://www.figma.com/design/3uoWgyChDi0RDQGsfTa7G6?fuid=1404551889925454225). También estará permitido usar Axure RP, sin embargo, para prototipar con MUI se requieren bibliotecas de componentes que generalmente son comerciales, y para las cuales no tenemos licencia en el curso.

Como ya se ha visto en el laboratorio 1, es factible obtener una licencia de Figma educacional.

## Evaluación del Diseño

El diseño debe contener las pantallas de interfaz que cumplan con la siguiente funcionalidad:

1. [.5] Los usuarios (ver modelo `User` y tabla correspondiente) pueden registrarse ingresando nombre, correo electrónico, un *handle* (similar a X o Instagram, p. ej., `@nomadclimber`), y su nacionalidad (ver modelo `Country`).
2. [.5] Los usuarios pueden crear nuevos viajes (`Trip`), dándoles un título y descripción, además de una fecha de inicio y término opcional.
3. [.5] Los usuarios pueden buscar ubicaciones (`Location`) por nombre o seleccionarlas desde un mapa interactivo, y agregarlas a algún viaje en el orden en que las visitarán.
4. [.5] Los usuarios pueden hacer *check-in* en una `Location` de un `Trip` en curso, registrando la fecha de la visita. Esto crea una entrada en `TripLocation`.
5. [1.0] Desde una `Location` donde han hecho *check-in*, los usuarios pueden crear publicaciones (`Post`) que incluyan texto, imágenes (`Picture`) y/o vídeos (`Video`).
6. [1.0] Los usuarios pueden ver la cronología de publicaciones de un viaje, ordenadas por fecha y agrupadas por ubicación visitada.
7. [1.0] Los usuarios pueden buscar a otros usuarios por *handle* y agregarlos como *travel buddies* (`TravelBuddy`), registrando la `Location` y la fecha en que se conocieron.
8. [1.0] Los usuarios pueden invitar a sus *travel buddies* a un viaje específico (`TravelBuddy`), permitiéndoles contribuir con sus propias publicaciones.

## Evaluación

Cada requisito será evaluado en escala 1-5. Estos puntos se traducen a ponderadores:

* 1 -> 0.0: No entregado
* 2 -> 0.25: Esbozo de solucion
* 3 -> 0.5: Logro intermedio
* 4 -> 0.75: Alto logro con deficiencias o errores menores
* 5 -> 1.00: Implementación completa y correcta

Los ponderadores aplican al puntaje máximo del ítem. La nota en escala 1-7 se calcula como la suma de puntajes parciales ponderados más el punto base.

## Forma y fecha de entrega

Con respecto al diseño de interfaz de usuario, deben invitar al ayudante que tengan asignado a su grupo al proyecto Figma. Además, es conveniente exportar el diseño completo a PDF para facilitar la evaluación si invitar al ayudante por cualquier razón no fuera factible. Los archivos de diseño deben ser entregados en la misma carpeta en donde está _este documento_, con nombre 'grupoxx.fig', o 'grupoxx.rp' si se usa Axure RP. 

El código con la implementación de los controladores debe ser entregado en este repositorio. Para la evaluación, se debe realizar un pull request que incluya al ayudante de proyecto asignado.

La fecha límite para la entrega 1.1 es viernes 22/8 a las 23:59 hrs.