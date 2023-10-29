CREATE EXTENSION postgis;

-- 1.  Znajdz budynki wybudowane lub wyremontowane na przestrezbni roku.
SELECT COUNT(*) FROM T2018_KAR_BUILDINGS;

CREATE VIEW budynki AS (
SELECT b19.* FROM T2018_KAR_BUILDINGS AS b18 RIGHT JOIN T2019_KAR_BUILDINGS AS b19
ON b18.polygon_id = b19.polygon_id
WHERE ST_Equals(b18.geom, b19.geom) != TRUE OR b18.polygon_id = NULL);

SELECT * FROM budynki;

-- 2. Znajdz ile nowych POI pojawiło się w promieniu 500m od wyremontowanych lub wybudowanych budynków.
-- Policz je według ich kategorii.
CREATE TABLE new_poi AS
SELECT poi19.* FROM t2018_kar_poi_table AS poi18 RIGHT JOIN t2019_kar_poi_table AS poi19
ON poi18.poi_id = poi19.poi_id
WHERE poi18.poi_id IS NULL;

SELECT COUNT(DISTINCT(n.*)) FROM new_poi AS n, budynki AS b
WHERE ST_DWithin(b.geom, n.geom, 500)
GROUP BY n.type;


-- 3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli 
-- T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.

CREATE TABLE streets_reprojected AS
SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel,
ST_Transform(geom, 3068) AS reprojected_geometry
FROM T2019_KAR_STREETS;

-- 4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej. 

CREATE TABLE input_points(
	id INT NOT NULL,
	geom geometry)

INSERT INTO input_points VALUES
	(1, 'POINT(8.36093 49.03174)'),
	(2, 'POINT(8.39876 49.00644)')
	

-- 5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych 
-- DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().

UPDATE input_points SET geom = ST_SetSRID(geom, 3068);
SELECT ST_AsText(geom) FROM input_points;


-- 6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej ??????????????
-- z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj 
-- reprojekcji geometrii, aby była zgodna z resztą tabel.

SELECT * FROM t2019_kar_street_node AS node19
WHERE ST_Contains(ST_Buffer(ST_Shortestline((SELECT geom FROM input_points WHERE id=1), 
											   (SELECT geom FROM input_points WHERE id=2)), 2), node19.geom)
											   AND node19.intersect = 'Y';


-- 7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się 
-- w odległości 300 m od parków (LAND_USE_A)
SELECT COUNT(*) FROM (SELECT DISTINCT p.* FROM t2019_kar_poi_table AS p, t2019_kar_land_use_a AS l
WHERE p.type = 'Sporting Goods Store' AND ST_Intersects(St_Buffer(l.geom, 300), p.geom))


-- 8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz 
-- znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES'.
CREATE TABLE t2019_kar_bridges AS
SELECT Distinct ST_Intersection(rail.geom, water.geom) AS bridges
FROM t2019_kar_railways AS rail, t2019_kar_water_lines AS water
    
SELECT * FROM t2019_kar_bridges