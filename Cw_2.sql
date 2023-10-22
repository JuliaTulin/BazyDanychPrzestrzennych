CREATE EXTENSION postgis;

-- 4. Wyznacz liczbe budynków położonych w odległości mniejszej niz 1000 jednostek od głównych rzek.
-- Budynki spełniające to kryterium zapisz do osobnej tabeli tableB.
CREATE TABLE TableB AS
SELECT p.* FROM popp AS p, majrivers AS m
WHERE p.f_codedesc='Building' AND ST_Distance(p.geom, m.geom) > 1000; -- bufor????

SELECT COUNT(*) FROM TableB;

-- 5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports zaimportuj do niej nazwy lotnisk, 
-- ich geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.
CREATE TABLE airportsNew AS
SELECT a.name, a.geom, a.elev FROM airports AS a;

-- a) Znajdź lotnisko, ktróe położone jest najbardziej na zachód i najbardziej na wschod
SELECT * FROM airportsNew AS a ORDER BY ST_X(a.geom) DESC LIMIT 1; --zachód
SELECT * FROM airportsNew AS a ORDER BY ST_X(a.geom) LIMIT 1; --wschód

-- b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które połozone jest w punkcie środkowym 
-- drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB. 
-- Wysokosc n.p.m. przyjmij dowolną.
INSERT INTO airportsNew 
VALUES ('airportB', (SELECT ST_Centroid(ST_ShortestLine((
	SELECT geom FROM airportsNew ORDER BY ST_X(geom) DESC LIMIT 1), 
	(SELECT geom FROM airportsNew ORDER BY ST_X(geom) LIMIT 1)))), 350);

-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niz 1000 jednostek od najkrószej
-- linii łączącej jezioro o nazwie 'lliamna Lake' i lotnisko o nazwie "AMBLER".
SELECT ST_Area(ST_Buffer(ST_ShortestLine(l.geom, a.geom), 1000)) 
	FROM airportsnew AS a, lakes AS l WHERE l.names = 'Iliamna Lake' AND a.name = 'AMBLER';
	
-- 6. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących 
-- poszczególne typy drzew znajdujących się na obszarze tundry i bagien.
SELECT SUM(ST_Area(ST_Intersection(tr.geom, t.geom)))+
		   SUM(ST_Area(ST_Intersection(tr.geom, s.geom))), tr.vegdesc 
		   FROM trees AS tr, tundra AS t, swamp AS s
		   GROUP BY tr.vegdesc;
