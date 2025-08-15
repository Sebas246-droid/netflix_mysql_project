-- Analisis de datos Netflix con MySQL 

-- 1. Contar numero de movies vs TV shows
SELECT type, COUNT(*) AS TIPO
FROM netflix
GROUP BY type;

-- 2. Encontrar la clasificacion (rating) mas comun para movies & TV shows
-- Se podria resolver como subquery, CTE da una mejor legibilidad
-- CTE (Common Table expression) Tabla temporal 
-- CTE 1 Conteo de clasificacion COUNT de la combinacion de type y rating 
-- CTE 2 Fucion de ventana RANK OVER
-- PARTITION BY numeracion de rank para cada type es como un GROUP BY no colapsa las filas en una sola 
-- ORDER BY asigna el numero mas bajo al rating con mas registros 

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

    
-- 3. Filtrar Peliculas por año en especifico considerando orden de lanzamiento en el año

SELECT 
	title,
    release_year
FROM netflix 
WHERE release_year = 2000
ORDER BY STR_TO_DATE(date_added, '%M %d, %Y') ASC;

-- 4. Encuentra los 5 paises con mas contenido en netflix 
-- CTE 1 conteo de pais agrupado por pais 
-- CTE 2 rankeo de los pais ordenado por cantidad de contenido 
-- la Consulta muestra los paises con su recuento de cantidad de contenido 

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

-- 5. Identificar la Pelicula mas larga 
-- necesitamos extraer el numero entero de duracion
-- CAST funcion de conversion de tipo de dato 
-- CAST Necesita el tipo de dato al que quieres convertr UNSIGNED entero positivo
-- SUBSTRING_INDEX extraer parte de un texto usando delimitador y se declara el numero de partes a extraer 

SELECT 
	title, 
    type,
    country,
    director,
    duration
FROM netflix
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) DESC;

-- 6 encontrar el contenido añadido en los ultimos 5 años
-- YEAR(CURDATE()) - 5 obtiene el año actual -5 caltula el año minimo a incluir 
-- Tambien podria ser entre dos fechas BETWEEN 2016 AND 2021 

SELECT *
FROM netflix
WHERE release_year >= YEAR(CURDATE()) - 5
ORDER BY release_year DESC;


-- 7 Encontral las peliculas o shows TV en donde el director es 'Rajiv Chilaka'!
-- Una manera de mejorar la consulta seria normaxlizar la tabla y separar los directores 
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8 mostrar todos los shows de TV que tengan mas de 5 temporadas
-- CAST convercion tipo de dato UNSIGNED int positivo, SUBSTRING_INDEX extrae el valor de la tenporada y se convierte numerico
SELECT * 
FROM netflix 
WHERE CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) > 5 
	AND type = 'TV Show'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) DESC;

-- Solucion con CTE 

WITH ShowSeason AS(
	SELECT
		*,
         CAST(SUBSTRING_INDEX(duration, ' ',1) AS  UNSIGNED) AS num_seasons 
    FROM netflix 
    WHERE type = 'TV Show'
    )
SELECT *
FROM ShowSeason
WHERE num_seasons > 5 
ORDER BY num_seasons DESC;
        
-- 9 Contenido para cada genero 
-- JSON_TABLE crea una tabla virtual llamada genres_table con una columna llamada genere 
-- JSON trabaja con arrays o con diccionarios 
-- CONCAT(valor1, valor2, ...) concatena muchos valores es una sola cadena
-- REPLACE(cadena, búsqueda, reemplazo) busca aparciciones de un str y lo remplaza 
-- " " en JSON cada string debe de ir entre comillas dobles
-- toma el valor de listed_in y lo transforma en un JSON válido.
-- ruta del JSON parte que se quiere leer porpiedades de JSON 
-- "$[*]" recorre cada elemento del array JSON
-- COLUMNS(... PATH "$") → crea la columna virtual y asigna a cada fila el valor del elemento actual del array.

SELECT genre, COUNT(*) AS total_content
FROM netflix,
JSON_TABLE(
    CONCAT('["', REPLACE(listed_in, ', ', '","'), '"]'),
    "$[*]" COLUMNS(genre VARCHAR(255) PATH "$")
) AS genres_table
GROUP BY genre
ORDER BY total_content DESC;

-- 10. listar los contenidos que son documentale s
SELECT * 
FROM netflix 
WHERE listed_in LIKE '%Documentaries';

-- 11. Encontrar los registros donde el director no tiene dato 
-- En mysql mcuhas veces las columnas de texto quedan como cadenas vacias

SELECT *
FROM netflix
WHERE director IS NULL
   OR director = '';

-- 12 Encontrar en cuantas peliculas aparece el actor 'Salman Khan' 

SELECT count(*) AS total
FROM netflix
WHERE `cast` LIKE '%Salman Khan%';

-- 13 Categorizar como Malo las pelculias que en descripcion contengan la palabra clave Kill o Violence
-- CASE estructura condicional 

SELECT 
    CASE 
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS total
FROM netflix
GROUP BY category;


