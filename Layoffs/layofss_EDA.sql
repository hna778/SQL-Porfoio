-- Inspect dataset time span and total layoffs in the world
SELECT MIN(`date`) AS start_date,
	MAX(`date`) AS last_date,
    sum(total_laid_off) AS total_laid_off
FROM layoffs_staging;

-- 1. BY COMPANY
-- Fully closed companies ranked by total laid off

SELECT company,
	MAX(percentage_laid_off) AS pct_laid_off,
	SUM(total_laid_off) AS total_laid_off
    -- country
FROM layoffs_staging
WHERE percentage_laid_off = 100
GROUP BY company, country
ORDER BY total_laid_off DESC;


-- Fully closed companies ranked by fund raised

SELECT company,
	MAX(percentage_laid_off) AS pct_laid_off,
	SUM(funds_raised) AS funds_raised
	, country
FROM layoffs_staging
WHERE percentage_laid_off = 100
GROUP BY company, country
ORDER BY funds_raised DESC;


-- Top layoffs by company

SELECT company,
	SUM(total_laid_off) AS total_laid_off
    ,country
FROM layoffs_staging
GROUP BY company, country
ORDER BY total_laid_off DESC;


-- Layoffs by specific company

SELECT *
FROM layoffs_staging
WHERE company = 'Amazon';


-- Total layoffs by specific company

SELECT company,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE company = 'Amazon'
GROUP BY company;

-- 2. BY INDUSTRY
-- Top layoffs by industry

SELECT industry,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY industry
ORDER BY total_laid_off DESC;


-- Layoffs by specific industry

SELECT *
FROM layoffs_staging
WHERE industry = 'Finance'
ORDER BY total_laid_off DESC;


-- Total layoffs by specific industry

SELECT industry,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE industry = 'Healthcare'
GROUP BY industry;


-- 3. BY COUNTRY
-- Top layoffs by country

SELECT country,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY country
ORDER BY total_laid_off DESC;


-- Layoffs by specific country

SELECT *
FROM layoffs_staging
WHERE country = 'United States'
ORDER BY total_laid_off DESC;


-- Total layoffs by specific country

SELECT country,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE country = 'United States'
GROUP BY country
ORDER BY total_laid_off DESC;


-- 4. BY LOCATION
-- Total layoffs by specific location

SELECT location,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE location = 'Chicago'
GROUP BY location
ORDER BY total_laid_off DESC;


-- Total layoffs by location

SELECT location,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE country = 'United States'
GROUP BY location
ORDER BY total_laid_off DESC;


-- 5. BY TIME
-- Number of layoff by year

SELECT DATE_FORMAT(`date`, '%Y') AS year,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY year
ORDER BY year;


-- Number of layoff by month and year

SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY month
ORDER BY month;


-- Number of layoff by month, year and country

SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
	country,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY month, country
ORDER BY month, total_laid_off DESC;


-- Number of layoff by month, year and industry

SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
	industry,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY month, industry
ORDER BY month, total_laid_off DESC;


-- Number of layoff by year and industry

SELECT YEAR(`date`) AS `year`,
	industry,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY `year`, industry
ORDER BY `year` DESC, total_laid_off DESC;


-- total laid off by year, and by industry add specific industry

SELECT YEAR(`date`) AS `year`,
		industry,
        SUM(total_laid_off)
FROM layoffs_staging
WHERE industry LIKE 'Crypto'
GROUP BY Year(`date`), industry
ORDER BY `year`;

-- total laid off by year, and by specific company

SELECT YEAR(`date`) AS `year`,
		company,
        SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE company = 'Amazon'
GROUP BY company, `year`
ORDER BY `year`;

-- total laid off by year & month & specific company, with rolling total
-- Use DATE_FORMAT
WITH Rolling_total AS 
(
SELECT DATE_FORMAT(`date`,'%Y-%m') AS `month`,
		company,
		SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE company LIKE 'Amazon'
GROUP BY `month`, company
ORDER BY `month` DESC
)
SELECT `month`, company, total_laid_off,
		SUM(total_laid_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_total;
        
-- Use SUBSTRING
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, company, SUM(total_laid_off) AS total_off
FROM layoffs_staging
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
AND company LIKE 'Amazon'
GROUP BY `month`, company
ORDER BY 1
)
SELECT `month`, company, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;


-- total laid off by year & specific company, with rolling total

WITH Rolling_total AS 
(
SELECT YEAR(`date`) AS `year`,
		company,
		SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE company LIKE 'Amazon'
GROUP BY `year`, company
ORDER BY `year` DESC
)
SELECT `year`, company, total_laid_off,
		SUM(total_laid_off) OVER(ORDER BY `year`) AS rolling_total
FROM Rolling_total;


-- total laid off by year, company, ranked

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY company, years
), 
Company_Year_Ranked AS
(
SELECT *,
	DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Ranked
WHERE Ranking <=5;

-- total laid off by year, industry, ranked

WITH Industry_Year (industry, years, total_laid_off) AS
(
SELECT industry, YEAR(`date`) AS years, sum(total_laid_off)
FROM layoffs_staging
GROUP BY industry, years
),
Industry_Year_Ranked AS
(
SELECT *,
	DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
WHERE industry IS NOT NULL
)
SELECT *
FROM Industry_Year_Ranked
WHERE ranking <=5;


-- 6. BY STAGE
-- Number layoffs by stage

SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY stage
ORDER BY total_laid_off DESC;
