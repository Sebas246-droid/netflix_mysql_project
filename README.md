# Proyecto Análisis de Datos Netflix con MySQL
![Logo](https://github.com/Sebas246-droid/netflix_mysql_project/raw/main/logo.png)

## Descripción General

Este proyecto implica un análisis integral de los datos de películas y series de Netflix utilizando MYSQL. El objetivo es extraer información valiosa y responder diversas preguntas de negocio basadas en el conjunto de datos.

## Objetivos 
- Analizar la distribución de los tipos de contenido (películas vs. series de TV).
- Identificar las clasificaciones más comunes para películas y series de TV.
- Listar y analizar el contenido según los años de estreno, países y duraciones.
- Explorar y categorizar el contenido según criterios y palabras clave específicas.

## Dataset
Los datos para este proyecto provienen del conjunto de datos de Kaggle:
- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```sql
CREATE TABLE netflix
(
  show_id	VARCHAR(6),
  `type` VARCHAR(10),	
  title VARCHAR(150),	  
  director VARCHAR(210),	
  `cast`	VARCHAR(1000),
  country	VARCHAR(150),
  date_added	VARCHAR(210),
  release_year	INT,	
  rating VARCHAR(10),	
  duration	VARCHAR(15),	
  listed_in	VARCHAR(150),	
  description VARCHAR(250)
);
```
## Problemas de Negocio y Soluciones
### 1. Contar numero de peliculas vs TV shows

```sql
SELECT type, COUNT(*) AS TIPO
FROM netflix
GROUP BY type;
```
### 2. Encontrar la clasificacion (rating) mas comun para movies & TV shows
```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS `rank`
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating,
    rating_count
FROM RankedRatings
WHERE `rank` = 1;
```
### 3. Filtrar Peliculas por año en especifico considerando orden de lanzamiento en el año
```sql
SELECT 
	title,
    release_year
FROM netflix 
WHERE release_year = 2000
ORDER BY STR_TO_DATE(date_added, '%M %d, %Y') ASC;
```
### 4. Encuentra los 5 paises con mas contenido en netflix 
```sql
WITH CountryCount AS (
	SELECT 
        country,
        COUNT(*) AS count_country 
	FROM netflix 
    GROUP BY country
    ),
    RankedCountry AS (
    SELECT
        country,
        count_country,
        RANK() OVER (ORDER BY count_country DESC) AS rank_country
        FROM CountryCount 
	)
    SELECT 
    country,
    count_country
    FROM RankedCountry;
```
### 5. Identificar la Pelicula mas larga 
```sql
SELECT 
	title, 
    type,
    country,
    director,
    duration
FROM netflix
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) DESC;
```
### 6. Encontrar el contenido añadido en los ultimos 5 años
```sql
SELECT *
FROM netflix
WHERE release_year >= YEAR(CURDATE()) - 5
ORDER BY release_year DESC;
```
### 7. Encontral las peliculas o shows TV en donde el director es 'Rajiv Chilaka'!
```sql
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```
## 8. mostrar todos los shows de TV que tengan mas de 5 temporadas
```sql
SELECT * 
FROM netflix 
WHERE CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) > 5 
	AND type = 'TV Show'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) DESC;
```
### 9. Contenido para cada genero 
```sql
SELECT genre, COUNT(*) AS total_content
FROM netflix,
JSON_TABLE(
    CONCAT('["', REPLACE(listed_in, ', ', '","'), '"]'),
    "$[*]" COLUMNS(genre VARCHAR(255) PATH "$")
) AS genres_table
GROUP BY genre
ORDER BY total_content DESC;
```
### 10. Listar los contenidos que son documentales
```sql
SELECT * 
FROM netflix 
WHERE listed_in LIKE '%Documentaries';
```
### 11. Encontar peliculas donde director no tenga dato
```sql
SELECT *
FROM netflix
WHERE director IS NULL
   OR director = '';
```
### 12. Encontrar en cuantas peliculas aparece el actor 'Salman Khan' 
```sql
SELECT count(*) AS total
FROM netflix
WHERE `cast` LIKE '%Salman Khan%';
```
### 13. Categorizar como Malo las pelculias que en descripcion contengan la palabra clave 'Kill' o 'Violence'
```sql
SELECT 
    CASE 
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS total
FROM netflix
GROUP BY category;
```

## Hallazgos y Conclusión
- Distribución de Contenido: El conjunto de datos contiene una amplia variedad de películas y series de TV con diferentes calificaciones y géneros.
- Calificaciones Comunes: Los conocimientos sobre las calificaciones más comunes permiten comprender el público objetivo del contenido.
- Categoría de Contenido: Categorizar el contenido según palabras clave específicas ayuda a entender la naturaleza del contenido disponible en Netflix.
Este análisis proporciona una visión integral del contenido de Netflix y puede ayudar a orientar la estrategia de contenido y la toma de decisiones.

## Nota 

Este proyecto forma parte de mi portafolio y tiene como propósito demostrar mis habilidades en SQL, así como practicar mis consultas y análisis de datos.
¡Gracias por leerlo! Abajo encontrarás mis redes sociales.
<a href="https://www.linkedin.com/in/sebastian-alarcon-aguilar-0a42b8180/">
  <img src="https://img.shields.io/badge/linkedin-%230A66C2.svg?style=plastic&logo=linkedin&logoColor=white" alt="LinkedIn"/>
</a>
