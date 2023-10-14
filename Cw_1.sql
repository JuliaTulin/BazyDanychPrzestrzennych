-- 3. 
CREATE EXTENSION postgis;

CREATE SCHEMA plan;

CREATE TABLE plan.budynki(
	id int PRIMARY KEY not null,
	geometria geometry,
	nazwa varchar (20)
);
--DROP TABLE plan.budynki;

CREATE TABLE plan.drogi(
	id int PRIMARY KEY not null,
	geometria geometry,
	nazwa varchar (20)
);
--DROP TABLE plan.drogi;

CREATE TABLE plan.punkty_informacyjne(
	id int PRIMARY KEY not null,
	geometria geometry,
	nazwa varchar (20)
);
--DROP TABLE plan.punkty_informacyjne;

INSERT INTO plan.budynki VALUES 
	(1, ST_GeomFromText('polygon((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))'), 'BuildingA'), 
	(2, ST_GeomFromText('polygon((4 7, 6 7, 6 5, 4 5, 4 7))'), 'BuildingB'),
	(3, ST_GeomFromText('polygon((3 8, 5 8, 5 6, 3 6, 3 8))'), 'BuildingC'),
	(4, ST_GeomFromText('polygon((9 9, 10 9, 10 8, 9 8, 9 9))'), 'BuildingD'),
	(5, ST_GeomFromText('polygon((1 2, 2 2, 2 1, 1 1, 1 2))'), 'BuildingE');
	
INSERT INTO plan.drogi VALUES 
	(1, ST_GeomFromText('linestring(0 4.5, 12 4.5)'), 'RoadX'), 
	(2, ST_GeomFromText('linestring(7.5 10.5, 7.5 0)'), 'RoadY');
	
INSERT INTO plan.punkty_informacyjne VALUES 
	(1, ST_GeomFromText('point(1 3.5)'), 'G'), 
	(2, ST_GeomFromText('point(5.5 1.5)'), 'H'),
	(3, ST_GeomFromText('point(9.5 6)'), 'I'),
	(4, ST_GeomFromText('point(6.5 6)'), 'J'),
	(5, ST_GeomFromText('point(6 9.5)'), 'K');
	
--6
--a. wyznacz całkowitą długość dróg w analizowanym mieście
SELECT SUM(ST_Length(geometria)) FROM plan.drogi;

--b. Wypisz geometrie (WKT), pole powierzchni oraz obwód poligonu reprezentującego 
-- budynek o nazwie BuildingA
SELECT ST_AsText(geometria) AS WKT, ST_Area(geometria) AS Pole_powierzchni, ST_Perimeter(geometria) 
AS Obwod FROM plan.budynki 
WHERE nazwa='BuildingA';

--c. Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki.
--Wyniki posortuj alfabetycznie
SELECT nazwa, ST_Area(geometria) FROM plan.budynki ORDER BY nazwa ASC;

--d. Wypisz nazwy i obwody 2 budynków o największej powierzchni
SELECT nazwa, ST_Perimeter(geometria) FROM plan.budynki 
ORDER BY ST_Area(geometria) DESC LIMIT 2;

--e. Wyznacz najkrószą odległość między budynkiem BuildingC a punktem G
SELECT ST_Distance(budynki.geometria, punkty_informacyjne.geometria) 
FROM (plan.budynki CROSS JOIN plan.punkty_informacyjne)
WHERE plan.budynki.nazwa = 'BuildingC' AND plan.punkty_informacyjne.nazwa = 'G';


--f. Wypisz pole powierzchni tej częsci budynku BuildingC, która znajduje się w 
-- odległości większej niż 0.5 od budynku BuildingB.
SELECT ST_Area(ST_Difference((SELECT budynki.geometria FROM plan.budynki WHERE nazwa = 'BuildingC'), 
			   ST_Buffer((SELECT budynki.geometria FROM plan.budynki WHERE nazwa = 'BuildingB'), 0.5)))

--g. Wybierz te budynki, któych centroid znajduje się powyżej drogi o nazwie RoadX.
SELECT budynki.nazwa FROM (plan.budynki CROSS JOIN plan.drogi)
WHERE (ST_Y(ST_Centroid(budynki.geometria))) > (ST_Y(ST_Centroid(drogi.geometria))) AND drogi.nazwa='RoadX'

--8. Oblicz pole powierzchni tych cześci budynku BuildingC i poligonu o 
-- współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów
SELECT ST_Area(ST_SymDifference('polygon((4 7, 6 7, 6 8, 4 8, 4 7))', 
						   (SELECT budynki.geometria FROM plan.budynki WHERE nazwa='BuildingC')))