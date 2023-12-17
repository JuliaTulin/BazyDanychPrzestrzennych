CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

SELECT * FROM Exports;

CREATE TABLE SouthWales AS 
SELECT ST_Union(rast) AS rast FROM "Exports";

SELECT * FROM SouthWales;