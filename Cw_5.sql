CREATE EXTENSION postgis;

CREATE TABLE obiekty(id INT PRIMARY KEY, nazwa VARCHAR(10), geom geometry);

DROP TABLE obiekty;

INSERT INTO obiekty VALUES
	(1, 'obiekt1', St_GeomFromEWKT('COMPOUNDCURVE(LINESTRING(0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), 
				       CIRCULARSTRING(3 1, 4 2, 5 1), LINESTRING(5 1, 6 1))')),
	(2, 'obiekt2', ST_GeomFromEWKT('CURVEPOLYGON(COMPOUNDCURVE(LINESTRING(10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2), 
				       CIRCULARSTRING(14 2, 12 0, 10 2), LINESTRING(10 2, 10 6)), CIRCULARSTRING(11 2, 13 2, 11 2))')), 
	(3, 'obiekt3', ST_GeomFromEWKT('COMPOUNDCURVE((10 17, 12 13), (12 13, 7 15), (7 15, 10 17))')),
	(4, 'obiekt4', ST_GeomFromEWKT('MULTILINESTRING((20 20, 25 25), (25 25, 27 24), (27 24, 25 22), 
								   (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))')),
	(5, 'obiekt5',  ST_GeomFromEWKT('MULTIPOINT(30 30 59, 38 32 234)')),
	(6, 'obiekt6', ST_GeomFromEWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))'));
	

-- 1. Wyznacz pole powierzchni bufora o wielkości 5 jednostek, któy został utworzony wokół najkrótszej linii łączącej
-- obiekt 3 i 4.

SELECT ST_Area(ST_Buffer(ST_ShortestLine(
	(SELECT geom FROM obiekty WHERE nazwa='obiekt3'), (SELECT geom FROM obiekty WHERE nazwa='obiekt4')),5)); 

-- 2. Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby możan było wykonać to zadanie? Zapewnij te warunki.

								   
UPDATE obiekty
SET geom = ST_MakePolygon(ST_LineMerge(ST_Collect(geom, 'LINESTRING(20.5 19.5,20 20)'))) WHERE nazwa='obiekt4';

-- 3. W tabeli obiekty jako obiekt7 zapisz obiekt złożony z obiekt3 i obiekt4. 

INSERT INTO obiekty VALUES (7, 'obiekt7', ST_Union((SELECT geom FROM obiekty WHERE nazwa = 'obiekt3'), (SELECT geom FROM obiekty WHERE nazwa = 'obiekt4')))
SELECT * FROM obiekty;
-- 4. Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów 
-- nie zawierających łuków.

SELECT SUM(ST_Area(ST_Buffer(geom, 5))) FROM obiekty WHERE NOT ST_HasArc(geom);
