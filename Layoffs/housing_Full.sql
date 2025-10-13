-- Load Data Into Database
-- 1. Create Raw Data Table

USE housing;

DROP TABLE IF EXISTS nashville;

CREATE TABLE nashville (
		UniqueID VARCHAR(20),
		ParcelID VARCHAR(30),
        LandUse VARCHAR(250),
        PropertyAddress VARCHAR(250),
        SaleDate VARCHAR(50),
        SalePrice VARCHAR(50),
        LegalReference VARCHAR(250),
        SoldAsVacant VARCHAR(250),
        OwnerName VARCHAR(250),
        OwnerAddress VARCHAR(250),
        Acreage VARCHAR(50),
        TaxDistrict VARCHAR(250),
        LandValue VARCHAR(50),
        BuildingValue VARCHAR(250),
        TotalValue VARCHAR(50),
        YearBuilt VARCHAR(10),
        Bedrooms VARCHAR(10),
        FullBath VARCHAR(10),
        HalfBath VARCHAR(10)
);

LOAD DATA LOCAL INFILE '/Users/hna/Documents/DA/SQL/Housing/Nashville Housing.csv'
INTO TABLE nashville
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
UniqueID,
ParcelID,
LandUse,
@PropertyAddress,
@SaleDate,
SalePrice,
LegalReference,
SoldAsVacant,
@OwnerName,
@OwnerAddress,
@Acreage,
@TaxDistrict,
@LandValue,
@Buildingvalue,
@TotalValue,
@YearBuilt,
@Bedrooms,
@FullBath,
@HalfBath
)
SET
PropertyAddress = NULLIF(@PropertyAddress, ''),
SaleDate = NULLIF(@SaleDate, ''),
OwnerName = NULLIF(@OwnerName, ''),
OwnerAddress = NULLIF(@OwnerAddress, ''),
Acreage = NULLIF(@Acreage, ''),
TaxDistrict = NULLIF(@TaxDistrict, ''),
LandValue = NULLIF(@LandValue, ''),
BuildingValue = NULLIF(@BuildingValue, ''),
TotalValue = NULLIF(@TotalValue, ''),
YearBuilt = NULLIF(@YearBuilt, ''),
Bedrooms = NULLIF(@Bedrooms, ''),
FullBath = NULLIF(@FullBath, ''),
HalfBath = NULLIF(@HalfBath, '')
;

SELECT *
FROM nashville;

-- 2. Create Staging Table

DROP TABLE IF EXISTS nashville_staging;

CREATE TABLE nashville_staging 
LIKE nashville;

INSERT nashville_staging 
SELECT *
FROM nashville;

SELECT * 
FROM nashville_staging;

-- 3. Initial check

SELECT count(DISTINCT UniqueID), count(UniqueID)
FROM nashville_staging;

SELECT count(DISTINCT ParcelID), count(ParcelID)
FROM nashville_staging;

SELECT
  SUM(UniqueID      IS NULL) AS null_UniqueID,
  SUM(ParcelID      IS NULL) AS null_ParcelID,
  SUM(LandUse       IS NULL) AS null_LandUse,
  SUM(PropertyAddress IS NULL) AS null_PropertyAddress,
  SUM(SaleDate      IS NULL) AS null_SaleDate,
  SUM(SalePrice     IS NULL) AS null_SalePrice,
  SUM(SoldAsVacant  IS NULL) AS null_SoldAsVacant,
  SUM(OwnerAddress  IS NULL) AS null_OwnerAddress,
  SUM(Acreage       IS NULL) AS null_Acreage,
  SUM(LandValue     IS NULL) AS null_LandValue,
  SUM(BuildingValue IS NULL) AS null_BuildingValue,
  SUM(TotalValue    IS NULL) AS null_TotalValue,
  SUM(YearBuilt     IS NULL) AS null_YearBuilt,
  SUM(Bedrooms      IS NULL) AS null_Bedrooms,
  SUM(FullBath      IS NULL) AS null_FullBath,
  SUM(HalfBath      IS NULL) AS null_HalfBath
FROM nashville_staging;


-- Data Cleaning
-- Populate the NULL/Blank Values with Known Data in PropertyAddress Column

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM nashville_staging AS a
JOIN nashville_staging AS b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_staging a
JOIN nashville_staging b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


-- Breakdown PropertyAddress Column Into PropertyAddress and PropertyCity

SELECT	SUBSTRING_INDEX(PropertyAddress, ',', 1) AS PropertyAddressSplit,	
		SUBSTRING_INDEX(PropertyAddress, ',', -1) AS PropertyCitySplit
FROM nashville_staging;

ALTER TABLE nashville_staging
ADD PropertyAddressSplit VARCHAR(240);

UPDATE nashville_staging
SET PropertyAddressSplit = SUBSTRING_INDEX(PropertyAddress,',', 1);


ALTER TABLE nashville_staging
ADD PropertyCitySplit VARCHAR(50);

UPDATE nashville_staging
SET PropertyCitySplit = SUBSTRING_INDEX(PropertyAddress,',', -1);


-- Convert Datatype of SaleDate Column

SELECT SaleDate, STR_TO_DATE(NULLIF(SaleDate,''),'%M %e, %Y') AS SaleDate_Upd
FROM nashville_staging;

UPDATE nashville_staging
SET SaleDate = STR_TO_DATE(NULLIF(SaleDate,''),'%M %e, %Y');

ALTER TABLE nashville_staging
MODIFY COLUMN SaleDate DATE NOT NULL;

SELECT min(SaleDate) as earliest, max(SaleDate) as latest
FROM nashville_staging;


-- Convert Datatype and Standardize SalePrice Column

SELECT SalePrice
FROM nashville_staging
WHERE SalePrice LIKE '%$%';

SELECT SalePrice, REGEXP_REPLACE(TRIM(SalePrice),'[$,]','')
FROM nashville_staging
WHERE SalePrice LIKE '%$%';

UPDATE nashville_staging
SET SalePrice = REGEXP_REPLACE(TRIM(SalePrice),'[$,]','');

ALTER TABLE nashville_staging
MODIFY COLUMN SalePrice DECIMAL(12,2) NULL;


-- Convert Datatype of Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath

SELECT LandValue, BuildingValue, TotalValue
FROM nashville_staging
WHERE LandValue LIKE '%$%'
	OR BuildingValue LIKE '%$%'
    OR TotalValue LIKE '%$%';

UPDATE nashville_staging
SET 	LandValue = REPLACE(TRIM(LandValue),',',''),
		BuildingValue = REPLACE(TRIM(BuildingValue), ',',''),
		TotalValue = REPLACE(TRIM(TotalValue),',', ''),
		YearBuilt = TRIM(YearBuilt),
        Bedrooms = TRIM(Bedrooms),
        FullBath = TRIM(FullBath),
        HalfBath = TRIM(HalfBath),
        Acreage = TRIM(Acreage);
        
ALTER TABLE nashville_staging
MODIFY COLUMN Acreage DECIMAL(10,2) UNSIGNED NULL,
MODIFY COLUMN LandValue INT UNSIGNED NULL,
MODIFY COLUMN BuildingValue INT UNSIGNED NULL,
MODIFY COLUMN YearBuilt SMALLINT UNSIGNED NULL,
MODIFY COLUMN Bedrooms TINYINT UNSIGNED NULL,
MODIFY COLUMN FullBath TINYINT UNSIGNED NULL,
MODIFY COLUMN HalfBath TINYINT UNSIGNED NULL;
        
DESCRIBE nashville_staging;

-- Standardize SoldAsVacant

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM nashville_staging
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
	CASE 	WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
	END
FROM nashville_staging;
		

UPDATE nashville_staging
SET SoldAsVacant =	CASE 	WHEN SoldAsVacant = 'N' THEN 'No'
							WHEN SoldAsVacant = 'Y' THEN 'Yes'
							ELSE SoldAsVacant
	END;


-- Breakdown OwnerAddress Column Into OwnerAddress, OwnerCity and OwnerState

SELECT	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerAddressSplit,	
		SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',-2), ',',1) AS OwnerCitySplit,
		SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerStateSplit
FROM nashville_staging;

ALTER TABLE nashville_staging
ADD OwnerAddressSplit VARCHAR(240);

UPDATE nashville_staging
SET OwnerAddressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALTER TABLE nashville_staging
ADD OwnerCitySplit VARCHAR(50);

UPDATE nashville_staging
SET OwnerCitySplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',-2), ',',1);


ALTER TABLE nashville_staging
ADD OwnerStateSplit VARCHAR(50);

UPDATE nashville_staging
SET OwnerStateSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);


SELECT *
FROM nashville_staging;

-- Remove Duplicates

WITH RowNumCTE AS (
	SELECT 	*,
			ROW_NUMBER() OVER (
				PARTITION BY 
					ParcelID,
					LandUse,
					PropertyAddress,
					SaleDate,
					SalePrice
	ORDER BY UniqueID) AS row_num
	FROM nashville_staging
	ORDER BY UniqueID)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS (
	SELECT *,
			ROW_NUMBER() OVER (
				PARTITION BY
					ParcelID,
					LandUse,
					PropertyAddress,
					SaleDate,
					SalePrice
	ORDER BY UniqueID) AS row_num
	FROM nashville_staging
	ORDER BY UniqueID)
DELETE h
FROM nashville_staging h
JOIN RowNumCTE r
	ON h.UniqueID = r.UniqueID
WHERE r.row_num > 1;


-- Drop Unnecessary Columns

ALTER TABLE nashville_staging
DROP COLUMN PropertyAddress,
DROP COLUMN LegalReference,
DROP COLUMN OwnerAddress;

SELECT * 
FROM nashville_staging;


-- EDA
-- City with the Most Property Sales
SELECT 	PropertyCitySplit AS city,
		COUNT(*) AS sale_count
FROM nashville_staging
GROUP BY city
ORDER BY sale_count DESC;


-- LandUse Distribution O the Top City
WITH top_city AS (
	SELECT TRIM(PropertyCitySplit) AS city
	FROM nashville_staging
    WHERE TRIM(PropertyCitySplit) <> ''
    GROUP BY city
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT LandUse, COUNT(*) AS sales
FROM nashville_staging, top_city
WHERE TRIM(PropertyCitySplit) = top_city.city
GROUP BY LandUse
ORDER BY sales DESC
LIMIT 10;


-- Number of sales and sale price range of top 2 distributions
WITH top_city AS (
  SELECT TRIM(PropertyCitySplit) AS city
  FROM nashville_staging
  WHERE TRIM(PropertyCitySplit) <> ''
  GROUP BY city
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
base AS (
  SELECT
    TRIM(PropertyCitySplit) AS city,
    TRIM(LandUse)           AS landuse,
    SalePrice				AS price
  FROM nashville_staging
  WHERE TRIM(LandUse) IN ('RESIDENTIAL CONDO','SINGLE FAMILY')
)
SELECT
  b.city,
  b.landuse,
  COUNT(*)        AS total_sales,
  COUNT(b.price)  AS price_rows,
  ROUND(AVG(b.price), 2) AS avg_price,
  MIN(b.price)    AS min_price,
  MAX(b.price)    AS max_price
FROM base b
JOIN top_city t ON b.city = t.city
GROUP BY b.city, b.landuse
ORDER BY b.landuse;


-- Median SalePrice for 'RESIDENTIAL CONDO' and 'SINGLE FAMILY' within the top city that has the highest number of sales

WITH top_city AS (
  SELECT TRIM(PropertyCitySplit) AS city
  FROM nashville_staging
  WHERE TRIM(PropertyCitySplit) <> ''
  GROUP BY city
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
prices AS (
  SELECT
    TRIM(LandUse) AS landuse,
    SalePrice AS price
  FROM nashville_staging, top_city
  WHERE TRIM(PropertyCitySplit) = top_city.city
    AND SalePrice <> ''
    AND TRIM(LandUse) IN ('RESIDENTIAL CONDO','SINGLE FAMILY')
),
ranked AS (
  SELECT
    landuse, price,
    ROW_NUMBER() OVER (PARTITION BY landuse ORDER BY price) AS rn,
    COUNT(*)    OVER (PARTITION BY landuse)                 AS n
  FROM prices
),
med AS (
  -- for even counts, this averages the two middle prices
  SELECT landuse, AVG(price) AS median_price
  FROM ranked
  WHERE rn IN (FLOOR((n+1)/2), CEIL((n+1)/2))
  GROUP BY landuse
)
SELECT
  MAX(CASE WHEN landuse = 'RESIDENTIAL CONDO' THEN median_price END) AS median_residential_condo,
  MAX(CASE WHEN landuse = 'SINGLE FAMILY'     THEN median_price END) AS median_single_family
FROM med;


-- Target Questions
-- What is the distribution of sale prices for the properties?
-- Price range (Average, Min, Max Price)
WITH top_city AS (
  SELECT TRIM(PropertyCitySplit) AS city
  FROM nashville_staging
  WHERE TRIM(PropertyCitySplit) <> ''
  GROUP BY city
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
base AS (
  SELECT
    TRIM(PropertyCitySplit) AS city,
    TRIM(LandUse)           AS landuse,
    SalePrice				AS price
  FROM nashville_staging
)
SELECT
  b.city,
  b.landuse,
  COUNT(*)        AS total_sales,
  COUNT(b.price)  AS price_rows,
  ROUND(AVG(b.price), 2) AS avg_price,
  MIN(b.price)    AS min_price,
  MAX(b.price)    AS max_price
FROM base b
JOIN top_city t ON b.city = t.city
GROUP BY b.city, b.landuse
ORDER BY b.landuse;


-- Median Price
WITH top_city AS (
  SELECT TRIM(PropertyCitySplit) AS city
  FROM nashville_staging
  WHERE TRIM(PropertyCitySplit) <> ''
  GROUP BY city
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
prices AS (
  SELECT
    TRIM(LandUse) AS landuse,
    SalePrice AS price
  FROM nashville_staging, top_city
  WHERE TRIM(PropertyCitySplit) = top_city.city
    AND SalePrice IS NOT NULL
    AND TRIM(LandUse) <> ''
),
ranked AS (
  SELECT
    landuse, price,
    ROW_NUMBER() OVER (PARTITION BY landuse ORDER BY price) AS rn,
    COUNT(*)    OVER (PARTITION BY landuse)                 AS n
  FROM prices
)
SELECT
  landuse,
  MAX(n)            AS rows_in_group,
  AVG(price)        AS median_price   -- avg of the middle 1–2 rows
FROM ranked
WHERE rn IN (FLOOR((n+1)/2), CEIL((n+1)/2))
GROUP BY landuse
ORDER BY rows_in_group DESC, landuse;

-- Integrate both the price range and median price

WITH top_city AS (
  SELECT UPPER(TRIM(PropertyCitySplit)) AS city
  FROM nashville_staging
  WHERE TRIM(PropertyCitySplit) <> ''
  GROUP BY city
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
base AS (
  SELECT
    UPPER(TRIM(PropertyCitySplit)) AS city,
    UPPER(TRIM(LandUse))           AS landuse,
    SalePrice                      AS price          -- DECIMAL(12,2)
  FROM nashville_staging, top_city
  WHERE UPPER(TRIM(PropertyCitySplit)) = top_city.city
    AND SalePrice IS NOT NULL
    AND TRIM(LandUse) <> ''
),
-- your usual aggregates
stats AS (
  SELECT
    city, landuse,
    COUNT(*)       AS total_sales,
    COUNT(price)   AS price_rows,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price)     AS min_price,
    MAX(price)     AS max_price
  FROM base
  GROUP BY city, landuse
),
-- compute median per (city, landuse)
ranked AS (
  SELECT
    city, landuse, price,
    ROW_NUMBER() OVER (PARTITION BY city, landuse ORDER BY price) AS rn,
    COUNT(*)    OVER (PARTITION BY city, landuse)                 AS n
  FROM base
),
med AS (
  -- for even counts, average the two middle prices
  SELECT city, landuse, AVG(price) AS median_price
  FROM ranked
  WHERE rn IN (FLOOR((n+1)/2), CEIL((n+1)/2))
  GROUP BY city, landuse
)
SELECT
  s.city, s.landuse,
  s.total_sales, s.price_rows, s.avg_price, s.min_price, s.max_price,
  m.median_price
FROM stats s
LEFT JOIN med m USING (city, landuse)
ORDER BY s.total_sales DESC;


-- Is there a trend in sale prices over time?

SELECT
  DATE_FORMAT(SaleDate, '%Y-%m') AS month,
  ROUND(AVG(CASE WHEN TRIM(LandUse) = 'RESIDENTIAL CONDO' THEN SalePrice END), 2) AS avg_price_condo,
  ROUND(AVG(CASE WHEN TRIM(LandUse) = 'SINGLE FAMILY'     THEN SalePrice END), 2) AS avg_price_single_family
FROM nashville_staging
WHERE SaleDate IS NOT NULL
  AND TRIM(LandUse) IN ('RESIDENTIAL CONDO','SINGLE FAMILY')
GROUP BY month
ORDER BY month;


-- How does property size impact sale prices?
-- quick signal: correlation & slope (linear trend)
WITH base AS (
  SELECT
    LandUse,
    Acreage   AS x,   -- DECIMAL
    SalePrice AS y    -- DECIMAL
  FROM nashville_staging
  WHERE UPPER(TRIM(REPLACE(PropertyCitySplit, '\r',''))) = 'NASHVILLE'
    AND Acreage  IS NOT NULL AND Acreage  > 0
    AND SalePrice IS NOT NULL AND SalePrice > 0
),
s AS (
  SELECT
    COUNT(*) AS n,
    SUM(x)   AS sx,   SUM(y)   AS sy,
    SUM(x*y) AS sxy,  SUM(x*x) AS sx2,
    SUM(y*y) AS sy2
  FROM base
),
stats AS (
  SELECT
    n, sx, sy, sxy, sx2, sy2,
    (n*sxy - sx*sy) AS cov_n,
    (n*sx2 - sx*sx) AS varx_n,
    (n*sy2 - sy*sy) AS vary_n
  FROM s
)
SELECT
  n,
  -- Pearson correlation r in [-1,1]
  cov_n / NULLIF(SQRT(varx_n * vary_n), 0)              AS r,
  -- Best-fit slope: Δprice per +1 acre
  cov_n / NULLIF(varx_n, 0)                             AS slope_per_acre,
  -- Intercept for y = a + b*x
  (sy/n) - (cov_n / NULLIF(varx_n, 0)) * (sx/n)         AS intercept
FROM stats
WHERE n > 1;

-- by LandUse
WITH base AS (
  SELECT
    LandUse,
    Acreage   AS x,   -- DECIMAL
    SalePrice AS y    -- DECIMAL
  FROM nashville_staging
  WHERE UPPER(TRIM(REPLACE(PropertyCitySplit, '\r',''))) = 'NASHVILLE'
    AND Acreage  IS NOT NULL AND Acreage  > 0
    AND SalePrice IS NOT NULL AND SalePrice > 0
),
s AS (
  SELECT
    COUNT(*) AS n,
    SUM(x)   AS sx,   SUM(y)   AS sy,
    SUM(x*y) AS sxy,  SUM(x*x) AS sx2,
    SUM(y*y) AS sy2
  FROM base
),
agg AS (
  SELECT LandUse,
         COUNT(*) n, SUM(x) sx, SUM(y) sy, SUM(x*y) sxy, SUM(x*x) sx2, SUM(y*y) sy2
  FROM base
  GROUP BY LandUse
)
SELECT
  LandUse, n,
  (n*sxy - sx*sy) / SQRT((n*sx2 - sx*sx)*(n*sy2 - sy*sy)) AS r,
  (n*sxy - sx*sy) / (n*sx2 - sx*sx)                       AS slope_per_acre
FROM agg
HAVING n >= 20
ORDER BY r DESC;

-- Size bins (trend shape without scatterplot)
WITH base AS (
  SELECT
    LandUse,
    Acreage   AS x,   -- DECIMAL
    SalePrice AS y    -- DECIMAL
  FROM nashville_staging
  WHERE UPPER(TRIM(REPLACE(PropertyCitySplit, '\r',''))) = 'NASHVILLE'
    AND Acreage  IS NOT NULL AND Acreage  > 0
    AND SalePrice IS NOT NULL AND SalePrice > 0
),
binned AS (
  SELECT
    NTILE(10) OVER (ORDER BY x) AS size_decile,  -- 10 bins by acreage
    x, y
  FROM base
)
SELECT
  size_decile,
  ROUND(AVG(x), 4)   AS avg_acreage,
  ROUND(AVG(y), 2)   AS avg_price,
  AVG(y/x)           AS avg_price_per_acre
FROM binned
GROUP BY size_decile
ORDER BY size_decile;

-- price per acre
WITH base AS (
  SELECT
    LandUse,
    Acreage   AS x,   -- DECIMAL
    SalePrice AS y    -- DECIMAL
  FROM nashville_staging
  WHERE UPPER(TRIM(REPLACE(PropertyCitySplit, '\r',''))) = 'NASHVILLE'
    AND Acreage  IS NOT NULL AND Acreage  > 0
    AND SalePrice IS NOT NULL AND SalePrice > 0
)
SELECT
  LandUse,
  COUNT(*) AS n,
  ROUND(AVG(y/x), 2)        AS avg_price_per_acre,
  ROUND(MIN(y/x), 2)        AS min_price_per_acre,
  ROUND(MAX(y/x), 2)        AS max_price_per_acre
FROM base
GROUP BY LandUse
ORDER BY avg_price_per_acre DESC;

-- handle skew: use log transform (elasticity)
WITH base AS (
  SELECT
    LandUse,
    Acreage   AS x,   -- DECIMAL
    SalePrice AS y    -- DECIMAL
  FROM nashville_staging
  WHERE UPPER(TRIM(REPLACE(PropertyCitySplit, '\r',''))) = 'NASHVILLE'
    AND Acreage  IS NOT NULL AND Acreage  > 0
    AND SalePrice IS NOT NULL AND SalePrice > 0
),
logbase AS (
  SELECT LandUse, LOG(x) AS lx, LOG(y) AS ly FROM base
  WHERE x > 0 AND y > 0
),
s AS (
  SELECT
    COUNT(*) n, SUM(lx) sx, SUM(ly) sy,
    SUM(lx*ly) sxy, SUM(lx*lx) sx2, SUM(ly*ly) sy2
  FROM logbase
)
SELECT
  (n*sxy - sx*sy) / SQRT((n*sx2 - sx*sx)*(n*sy2 - sy*sy)) AS r_log,
  (n*sxy - sx*sy) / (n*sx2 - sx*sx)                       AS elasticity_size_to_price
FROM s;
-- elasticity_size_to_price ≈ % price change for 1% more acreage.

-- Are there correlations between the year of construction and sale prices?
-- Trend by year
SELECT 	PropertyCitySplit, YearBuilt,
		COUNT(*) AS number_of_construction,
		ROUND(AVG(SalePrice), 2) AS avg_price,
		LandUse, Acreage
FROM nashville_staging
WHERE 	TRIM(PropertyCitySplit) = 'NASHVILLE'
	AND TRIM(LandUse)= 'SINGLE FAMILY'
GROUP BY YearBuilt, PropertyCitySplit, LandUse, Acreage
ORDER BY YearBuilt;

SELECT 	PropertyCitySplit, YearBuilt
	-- 	COUNT(*) AS number_of_construction,
		-- ROUND(AVG(SalePrice), 2) AS avg_price
FROM nashville_staging
WHERE 	TRIM(PropertyCitySplit) = 'NASHVILLE' AND TRIM(LandUse)= 'RESIDENTIAL CONDO'
GROUP BY YearBuilt, PropertyCitySplit
ORDER BY YearBuilt;


SELECT
  YEAR(SaleDate) AS sale_year,
  COUNT(*) AS n,
  ROUND(AVG(CAST(REPLACE(REPLACE(TRIM(SalePrice), ',', ''), '$', '') AS DECIMAL(12,2))), 2) AS avg_price
FROM nashville_staging
WHERE UPPER(LandUse) LIKE '%CONDO%'
  AND SaleDate IS NOT NULL
GROUP BY sale_year
ORDER BY sale_year;

SELECT PropertyCitySplit, LandUse, SalePrice, YearBuilt
FROM nashville_staging
WHERE TRIM(PropertyCitySplit) = 'NASHVILLE'
	AND TRIM(LandUse) = 'RESIDENTIAL CONDO'
ORDER BY YearBuilt;

SELECT PropertyCitySplit, ROUND(AVG(SalePrice),2), YearBuilt, LandUse
FROM nashville_staging
WHERE TRIM(PropertyCitySplit) = 'NASHVILLE'
	AND TRIM(LandUse) = 'SINGLE FAMILY'
GROUP BY PropertyCitySplit, YearBuilt, LandUse
ORDER BY YearBuilt;


WITH base AS (
  SELECT
    YearBuilt AS x,
    CAST(REPLACE(TRIM(SalePrice), ',', '') AS DECIMAL(12,2)) AS y
  FROM nashville_staging
  WHERE YearBuilt IS NOT NULL
    AND TRIM(SalePrice) <> ''
)
, s AS (
  SELECT
    COUNT(*)        AS n,
    SUM(x)          AS sx,
    SUM(y)          AS sy,
    SUM(x*y)        AS sxy,
    SUM(x*x)        AS sx2,
    SUM(y*y)        AS sy2
  FROM base
)
SELECT
  n,
  -- Pearson r
  (n*sxy - sx*sy) /
    SQRT( (n*sx2 - sx*sx) * (n*sy2 - sy*sy) ) AS r,
  -- optional: slope/intercept of best-fit line y = a + b*x
  (n*sxy - sx*sy) / (n*sx2 - sx*sx)           AS slope_b,
  (sy/n) - ((n*sxy - sx*sy)/(n*sx2 - sx*sx))*(sx/n) AS intercept_a,
  POW( (n*sxy - sx*sy) /
       SQRT( (n*sx2 - sx*sx) * (n*sy2 - sy*sy) ), 2 ) AS r_squared
FROM s;

WITH base AS (
  SELECT YearBuilt AS x, LOG( CAST(REPLACE(TRIM(SalePrice), ',', '') AS DECIMAL(12,2)) ) AS y
  FROM nashville_staging
  WHERE YearBuilt IS NOT NULL AND TRIM(SalePrice) <> '' AND
        CAST(REPLACE(TRIM(SalePrice), ',', '') AS DECIMAL(12,2)) > 0
), s AS (
  SELECT
    COUNT(*)        AS n,
    SUM(x)          AS sx,
    SUM(y)          AS sy,
    SUM(x*y)        AS sxy,
    SUM(x*x)        AS sx2,
    SUM(y*y)        AS sy2
  FROM base
)
SELECT
  n,
  -- Pearson r
  (n*sxy - sx*sy) /
    SQRT( (n*sx2 - sx*sx) * (n*sy2 - sy*sy) ) AS r,
  -- optional: slope/intercept of best-fit line y = a + b*x
  (n*sxy - sx*sy) / (n*sx2 - sx*sx)           AS slope_b,
  (sy/n) - ((n*sxy - sx*sy)/(n*sx2 - sx*sx))*(sx/n) AS intercept_a,
  POW( (n*sxy - sx*sy) /
       SQRT( (n*sx2 - sx*sx) * (n*sy2 - sy*sy) ), 2 ) AS r_squared
FROM s;

WITH base AS (
  SELECT
    LandUse,
    YearBuilt AS x,
    CAST(REPLACE(TRIM(SalePrice), ',', '') AS DECIMAL(12,2)) AS y
  FROM nashville_staging
  WHERE YearBuilt IS NOT NULL AND TRIM(SalePrice) <> ''
),
agg AS (
  SELECT
    LandUse,
    COUNT(*) AS n, SUM(x) AS sx, SUM(y) AS sy,
    SUM(x*y) AS sxy, SUM(x*x) AS sx2, SUM(y*y) AS sy2
  FROM base
  GROUP BY LandUse
)
SELECT
  LandUse, n,
  (n*sxy - sx*sy) /
    SQRT( (n*sx2 - sx*sx) * (n*sy2 - sy*sy) ) AS r
FROM agg
HAVING n >= 20                 -- avoid tiny groups
ORDER BY r DESC;




-- How many properties were sold as vacant?

SELECT 	LandUse,
		COUNT(*) AS total_in_landuse,
        SUM(TRIM(SoldAsVacant) = 'Yes') AS yes_count
FROM nashville_staging
WHERE TRIM(PropertyCitySplit) = 'NASHVILLE'
GROUP BY LandUse
ORDER BY yes_count DESC;



