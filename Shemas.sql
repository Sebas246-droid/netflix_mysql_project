-- Base de datos 
CREATE DATABASE mi_empresa;
-- Crear tabla 

CREATE TABLE netflix (
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

SELECT * FROM netflix;


