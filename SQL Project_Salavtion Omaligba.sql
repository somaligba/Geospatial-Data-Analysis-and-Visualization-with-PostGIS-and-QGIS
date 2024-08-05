-- Complete this file by adding queries below each comment to perform the evaluation

------------------------------------------------------------------------------------------------------------------------
-- load the airport.shp file into a postgis table named 'airport' with qgis or command line
-- (look at the .prj file to find the right SRID for this layer)
-- Using the airport table, compute the number of airports per country and type of airport,
-- and order the result by country and number of airports

Select * from airport;

Select count(*) as no_airport, iso_countr, type
From airport
Group by iso_countr, type
Order by iso_countr,no_airport;

-- load the countries_invalid.shp file into a postgis table named 'countries' with qgis or command line
-- (look at the .prj file to find the right SRID for this layer)
-- update the table to validate the invalid geometries
-- Create a table containing all France airports by joining the airport and countries table spatially (st_contains maybe)
-- -> be cautious about tables spatial reference systems
-- SRS are not the same between tables: one must reproject one table to be able to work with data
-- for instance, reproject countries into 3857 SRID (use st_transform to reproject.
-- you can create a second table with something like create table countries2 as select ... from countries
[insert SQL query answers here]

Select * from countries_invalid;

Select id, name, st_isvalidreason(geom)
From countries_invalid
Where not st_isvalid(geom);

Update countries_invalid set geom = st_collectionextract(st_makeValid(geom), 3)
Where not st_isvalid(geom);

Select id, name, st_isvalidreason(geom)
From countries_invalid
Where not st_isvalid(geom);

Create Table Countries2 as 
Select id,st_transform(geom, 3857) as geom,name,gmi_cntry,region from countries_invalid;

Select * from countries2;

Create table France_airports as (
SELECT a.name as name2
FROM airport a JOIN countries2 c
ON st_intersects(a.geom,c.geom)
WHERE c.name='France');

Select * from france_airports;

------------------------------------------------------------------------------------------------------------------------
-- load the communes-dile-de-france-au-01-janvier.shp file into a postgis table named 'commune' with qgis or command line
-- (look at the .prj file to find the right SRID for this layer)
-- compute the polygon for Paris (nomcom column values start with 'Paris ') by unioning the right polygons
-- from commune table
[insert SQL query answers here]

Create table paris as
Select st_union(geom) as singlegeom from communes
Where nomcom like 'Paris%';

------------------------------------------------------------------------------------------------------------------------
-- Display the Paris polygon in QGIS
-- [create a screenshot named img1.png to show qgis window with the polygon]

------------------------------------------------------------------------------------------------------------------------
-- load the wellbore.shp file into a postgis table named 'wellbore' with qgis or command line
-- (look at the .prj file to find the right SRID for this layer)
-- Using the wellbore and airport tables, find the closest large airport from each wellbore
-- -> Compute the distance in km between the airport and the wellbore
-- -> KNN query (as seen in slides)
-- -> One must filter airports based on its type (find the suitable column to filter on)
-- -> You can test parts of the final query in intermediate, smaller queries, then build the final query based on these steps
[insert SQL query answer here]

select w.id as id_well, a.id_airport, a.iso_countr, a.iata_code,
       round(a.dist::numeric / 1000.0, 2) as dist_km
from wellbore w CROSS JOIN LATERAL (
    select t.id as id_airport, t.name, t.iso_countr, t.iata_code,
           t.geom <-> w.geom as dist
    from airport t
    where t.type = 'large_airport'
    order by t.geom <-> w.geom
    LIMIT 1
    ) as a
where w.id='6828'
order by id_well, dist_km;


-- In QGIS, display wellbore with npdidwellbore = 6828, its closest large airport, and add an OSM base layer to check visually.
-- Use the distance tool to measure distance and compare with query result
-- [create screenshot img2.png to show qgis window with loaded tables, OSM background, and distance tool
-- measuring one airport <-> wellbore distance]



