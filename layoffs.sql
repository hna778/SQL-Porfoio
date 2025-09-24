-- 1) Load Raw Data
CREATE DATABASE dblayoffs;

USE dblayoffs;

DROP TABLE IF EXISTS layoffs;
CREATE TABLE layoffs (
	company VARCHAR(255) DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    total_laid_off VARCHAR(10) DEFAULT NULL,
    `date` VARCHAR(50) DEFAULT NULL,
    percentage_laid_off VARCHAR(10) DEFAULT NULL,
    industry VARCHAR(255) DEFAULT NULL,
    source TEXT DEFAULT NULL,
    stage VARCHAR(255) DEFAULT NULL,
    funds_raised VARCHAR(50) DEFAULT NULL,
    country VARCHAR(255) DEFAULT NULL,
    date_added VARCHAR(50) DEFAULT NULL
);

LOAD DATA LOCAL INFILE '/Users/hna/Documents/DA/SQL/Layoffs/layoffs.csv'
INTO TABLE layoffs
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company,
location,
total_laid_off,
`date`,
percentage_laid_off,
industry,
`source`,
stage,
funds_raised,
country,
date_added)
;
    
SELECT *
FROM layoffs;


-- 2) Create Staging Table

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- 3) Data Cleansing
-- Remove Duplicates

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, `source`, stage, funds_raised, country, date_added) AS row_num
FROM layoffs_staging;

WITH cte_duplicate AS (
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, `source`, stage, funds_raised, country, date_added) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM cte_duplicate
WHERE row_num > 1;

-- Validate Duplicates

SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, `source`, stage, funds_raised, country, date_added) AS row_num
	FROM layoffs_staging
	WHERE company = '100 Thieves';

WITH cte_duplicate AS (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, `source`, stage, funds_raised, country, date_added) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM cte_duplicate
WHERE company = '100 Thieves'
	AND row_num > 1;
    
    
-- 4) Data Normalization
-- a) Trim Whitespace

SELECT CONCAT(
	'SELECT ''', COLUMN_NAME, ''' AS col, COUNT(*) AS bad_rows ',
    'FROM layoffs_staging WHERE `', COLUMN_NAME, '` <> TRIM(`', COLUMN_NAME, '`);'
) AS query_to_run
FROM information_schema.columns
WHERE table_schema = 'dblayoffs'
	AND table_name = 'layoffs_staging'
    AND data_type IN ('varchar', 'text');

SELECT 'company' AS col, COUNT(*) AS inconsist_rows FROM layoffs_staging WHERE `company` <> TRIM(`company`);    

UPDATE  layoffs_staging
SET company = trim(company);
    
-- Validate for Leading or Trailling Whitespace

SELECT company, trim(company)
FROM layoffs_staging
WHERE company <> trim(company);


-- b) Standardize Formats
-- Turn date Column into DATE Datatype

SELECT `date`
FROM layoffs_staging;

UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;

-- Validate sensical ranges
SELECT MIN(`date`) AS earliest,
	MAX(`date`) AS latest
FROM layoffs_staging;


-- Turn total_laid_off Column into INT Datatype

SELECT total_laid_off
FROM layoffs_staging;

UPDATE layoffs_staging
SET total_laid_off = NULLIF(total_laid_off, '');

ALTER TABLE layoffs_staging
MODIFY COLUMN total_laid_off INT;

-- Validate no non-numeric remnants

SELECT SUM(total_laid_off)
FROM layoffs_staging
WHERE company = '100 Thieves';


-- Turn percentage_laid_off Column into FLOAT Datatype

SELECT percentage_laid_off
FROM layoffs_staging;

UPDATE layoffs_staging
SET percentage_laid_off = NULLIF(REPLACE(percentage_laid_off, '%', ''),'');

ALTER TABLE layoffs_staging
MODIFY COLUMN percentage_laid_off FLOAT;

-- Validate no non-numeric remnants

SELECT SUM(percentage_laid_off)
FROM layoffs_staging
WHERE company = 'Vimeo';


-- Turn funds_raised column into INT Datatype

SELECT funds_raised
FROM layoffs_staging
ORDER BY funds_raised DESC;

UPDATE layoffs_staging
SET funds_raised = NULLIF(REPLACE(funds_raised, '$',''), '');

ALTER TABLE layoffs_staging
MODIFY COLUMN funds_raised INT;

-- Validate no non-numeric remnants

SELECT SUM(funds_raised IS NULL) AS nulls,
		SUM(funds_raised = 0) AS zero
FROM layoffs_staging;


-- Turn date_added column into DATE Datatype

SELECT date_added
FROM layoffs_staging;

UPDATE layoffs_staging
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY COLUMN date_added DATE;

-- Validate the Update

DESCRIBE layoffs_staging;


-- c) Unify Values
-- Check the Distinct Value 

SELECT DISTINCT country
FROM layoffs_staging;

-- Check the similarity between distinct values

SELECT a.industry AS val1, b.industry AS val2
FROM (
    SELECT DISTINCT industry FROM layoffs_staging
) a
JOIN (
    SELECT DISTINCT industry FROM layoffs_staging
) b
  ON a.industry < b.industry   -- avoid duplicates/self-matches
WHERE a.industry LIKE CONCAT('%', b.industry, '%')
   OR b.industry LIKE CONCAT('%', a.industry, '%')
ORDER BY val1, val2;

-- Populating NULL/Blank values with known data

SELECT count(industry) AS blank_value
FROM layoffs_staging
WHERE industry = ''
	OR industry = NULL;

UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging t1
JOIN layoffs_staging t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
	AND t2.industry IS NOT NULL;
    
SELECT a.industry, b.industry
FROM layoffs_staging a
JOIN layoffs_staging b
	ON a.company = b.company
WHERE a.industry IS NULL OR a.industry = ''
AND b.industry IS NOT NULL;

-- Remove Rows with Relevant Values are NULL

SELECT *,
	COUNT(*) AS to_delete
FROM layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging;

-- Verify how many rows remain
SELECT COUNT(*) AS remaining
FROM layoffs_staging;


-- Remove Unused Columns 

ALTER TABLE layoffs_staging
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging;










