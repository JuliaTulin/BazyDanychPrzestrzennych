CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

-- 2
SELECT * FROM mosaic;

-- 3. Połącz te dane (wszystkie kafle) w mozaikę, a następnie wyeksportuj jako GeoTIFF

CREATE TABLE mosaic AS
SELECT lo_from_bytea(0,pos
       ST_AsGDALRaster(ST_Union(st_union), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
        ) AS loid
FROM uk_250k;

-- 5.
SELECT * FROM national_parks_boundries;

-- 6. 
CREATE TABLE uk_lake_district AS 
SELECT r.rid, ST_Clip(r.rast, p.geom, true) AS rast
FROM uk_250k AS r, national_parks_boundries AS p 
WHERE id=1 AND ST_Intersects(r.rast, p.geom);

drop table uk_lake_district

-- 7. 
CREATE TABLE lake_gtiff AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])) AS loid
FROM uk_lake_district;

-- 8. 9.
CREATE TABLE national_parks_3857 AS
SELECT ST_SetSRID(geom, 3857) FROM national_parks_boundries;

DROP TABLE national_parks_3857;

SELECT * FROM sentinel;

-- 10. 
CREATE TABLE red as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM s1_band4
                        UNION ALL
                         SELECT rast FROM s2_band4);

CREATE TABLE green as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM s1_band3
                        UNION ALL
                         SELECT rast FROM s2_band3);

CREATE TABLE nir as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM s1_band8
                        UNION ALL
                         SELECT rast FROM s2_band8);

WITH g1 AS (
(SELECT ST_Union(ST_Clip(g.rast, ST_Transform(np.geom, 32630), true)) as rast
            FROM public.green AS g, national_parks_boundries AS np
            WHERE ST_Intersects(g.rast, ST_Transform(np.geom, 32630)) AND np.id = 1)),
g2 AS (
(SELECT ST_Union(ST_Clip(n.rast, ST_Transform(np.geom, 32630), true)) as rast
    FROM public.nir AS n, national_parks_boundries AS np
    WHERE ST_Intersects(n.rast, ST_Transform(np.geom, 32630)) AND np.id = 1))

SELECT ST_MapAlgebra(g1.rast, g2.rast, '([rast1.val]-[rast2.val])/([rast1.val]+[rast2.val])::float', '32BF') AS rast
INTO lake_district_ndwi FROM g1, g2;

CREATE TABLE ndwi_gtiff AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])) AS loid
FROM lake_district_ndwi;

SELECT lo_export(loid, 'C:\Users\jtuli\Desktop\STUDIA\5_semestr\Bazy_danych_przestrzennych\cw7\ndwi.tiff') 
FROM ndwi_gtiff;

SELECT lo_unlink(loid)
FROM tmp_out;
