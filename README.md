# Geospatial-Data-Analysis-and-Visualization-with-PostGIS-and-QGIS
The project demonstrates the use of PostGIS for advanced geospatial data analysis. The tasks include:  Analyzing airport data. Validating and analyzing country geometries. Creating a polygon for Paris by unioning relevant polygons. Finding the closest large airport to wellbores and calculating distances.
Here is the content of the `README.md` file for you to download manually:

```markdown
# Geospatial Data Analysis and Visualization with PostGIS and QGIS

This project involves a series of geospatial data analysis tasks using PostGIS and QGIS. The tasks range from loading shapefiles into PostGIS tables, performing spatial queries, validating geometries, and visualizing the results in QGIS.

## Table of Contents
- [Project Overview](#project-overview)
- [Setup Instructions](#setup-instructions)
- [Tasks and Queries](#tasks-and-queries)
  - [Airport Data Analysis](#airport-data-analysis)
  - [Country Data Validation and Analysis](#country-data-validation-and-analysis)
  - [Paris Polygon Creation](#paris-polygon-creation)
  - [Wellbore and Airport Proximity Analysis](#wellbore-and-airport-proximity-analysis)
- [Visualization](#visualization)
- [Conclusion](#conclusion)

## Project Overview

The project demonstrates the use of PostGIS for advanced geospatial data analysis. The tasks include:
1. Analyzing airport data.
2. Validating and analyzing country geometries.
3. Creating a polygon for Paris by unioning relevant polygons.
4. Finding the closest large airport to wellbores and calculating distances.

## Setup Instructions

1. **Install PostGIS and QGIS:**
   - Ensure PostGIS is installed and configured in your PostgreSQL database.
   - Install QGIS for data visualization.

2. **Load Shapefiles into PostGIS:**
   - Use QGIS or command line tools to load shapefiles into PostGIS tables.

3. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/geospatial-data-analysis.git
   cd geospatial-data-analysis
   ```

## Tasks and Queries

### Airport Data Analysis
1. Load the `airport.shp` file into a PostGIS table named `airport`.
2. Compute the number of airports per country and type, ordered by country and number of airports:
   ```sql
   SELECT COUNT(*) AS no_airport, iso_countr, type
   FROM airport
   GROUP BY iso_countr, type
   ORDER BY iso_countr, no_airport;
   ```

### Country Data Validation and Analysis
1. Load the `countries_invalid.shp` file into a PostGIS table named `countries_invalid`.
2. Validate the geometries and update the table:
   ```sql
   SELECT id, name, ST_IsValidReason(geom)
   FROM countries_invalid
   WHERE NOT ST_IsValid(geom);

   UPDATE countries_invalid SET geom = ST_CollectionExtract(ST_MakeValid(geom), 3)
   WHERE NOT ST_IsValid(geom);

   SELECT id, name, ST_IsValidReason(geom)
   FROM countries_invalid
   WHERE NOT ST_IsValid(geom);
   ```
3. Reproject `countries_invalid` into SRID 3857 and create a new table `countries2`:
   ```sql
   CREATE TABLE countries2 AS 
   SELECT id, ST_Transform(geom, 3857) AS geom, name, gmi_cntry, region 
   FROM countries_invalid;
   ```
4. Create a table containing all France airports:
   ```sql
   CREATE TABLE france_airports AS 
   SELECT a.name AS name2
   FROM airport a 
   JOIN countries2 c ON ST_Intersects(a.geom, c.geom)
   WHERE c.name = 'France';
   ```

### Paris Polygon Creation
1. Load the `communes-dile-de-france-au-01-janvier.shp` file into a PostGIS table named `communes`.
2. Create a polygon for Paris by unioning the relevant polygons:
   ```sql
   CREATE TABLE paris AS
   SELECT ST_Union(geom) AS singlegeom 
   FROM communes
   WHERE nomcom LIKE 'Paris%';
   ```

### Wellbore and Airport Proximity Analysis
1. Load the `wellbore.shp` file into a PostGIS table named `wellbore`.
2. Find the closest large airport to each wellbore:
   ```sql
   SELECT w.id AS id_well, a.id_airport, a.iso_countr, a.iata_code,
          ROUND(a.dist::numeric / 1000.0, 2) AS dist_km
   FROM wellbore w 
   CROSS JOIN LATERAL (
       SELECT t.id AS id_airport, t.name, t.iso_countr, t.iata_code,
              t.geom <-> w.geom AS dist
       FROM airport t
       WHERE t.type = 'large_airport'
       ORDER BY t.geom <-> w.geom
       LIMIT 1
   ) AS a
   ORDER BY id_well, dist_km;
   ```

## Visualization
- **Paris Polygon:** Display the Paris polygon in QGIS and take a screenshot (`img1.png`).
- **Wellbore and Airport Proximity:** Display the wellbore with `npdidwellbore = 6828`, its closest large airport, and add an OSM base layer in QGIS. Measure and compare distances, then take a screenshot (`img2.png`).

## Conclusion
This project showcases advanced geospatial data analysis using PostGIS and QGIS, demonstrating the ability to handle real-world geospatial data tasks effectively.
```

Copy the above content and save it in a file named `README.md` in your project directory.
