    
-- Inspect dataset time span and total layoffs in the world
SELECT MIN(`date`) AS start_date,
	MAX(`date`) AS last_date,
    sum(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE country = "United States";


-- Number of tech employees laid off in the U.S

SELECT country,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE country = 'United States'
GROUP BY country
ORDER BY total_laid_off DESC;


-- Number of layoff by year

SELECT DATE_FORMAT(`date`, '%Y') AS year,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE country = 'United States'
GROUP BY year
ORDER BY year;


-- Number of layoff by year and growth rate

WITH yearly AS (
	SELECT country,
			YEAR(`date`) AS yr,
			SUM(total_laid_off) AS total_laid_off
	FROM layoffs_staging
    WHERE country = 'United States'
    GROUP BY country, YEAR(`date`)
    ),
lagged AS (
	SELECT y.*, LAG(total_laid_off) OVER(ORDER BY yr) AS previous_total
    FROM yearly y
    )
SELECT country,
		yr,
        total_laid_off,
        previous_total,
        total_laid_off - previous_total AS yoy_change,
        ROUND(100 * (total_laid_off - previous_total) 
			/ NULLIF(previous_total, 0), 2) AS yoy_pct_change
FROM lagged
ORDER BY yr;


-- Number of layoff by month and year

SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY month
ORDER BY month;



-- Top 10 location with high number of layoff and pct contribution in the U.S

WITH USlocation AS (
	SELECT location, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging
    WHERE country = "United States"
    GROUP BY location),
    UStotal AS (
    SELECT sum(total_laid_off) AS total_US
    FROM USlocation),
    top10 AS (
    SELECT * 
    FROM USlocation
    ORDER BY total_laid_off DESC
    LIMIT 10)
SELECT t.location, t.total_laid_off AS location_total, 
	ROUND(100 * t.total_laid_off / u.total_US, 2) AS pct_of_US
FROM top10 t
CROSS JOIN UStotal u
ORDER BY location_total DESC;


-- Top 10 layoffs by industry

SELECT industry,
	SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE country = "United States"
GROUP BY industry
ORDER BY total_laid_off DESC
;


-- total laid off by year, company, ranked

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off)
FROM layoffs_staging
WHERE country = "United States"
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
WHERE country = "United States"
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

-- total laid off by year, location, ranked

WITH Location_Year (location, years, total_laid_off) AS
(
SELECT location, YEAR(`date`) AS years, sum(total_laid_off)
FROM layoffs_staging
WHERE country = "United States"
GROUP BY location, YEAR(`date`)
),
Location_Year_Ranked AS
(
SELECT *,
	DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Location_Year
WHERE location IS NOT NULL
)
SELECT *
FROM Location_Year_Ranked
WHERE ranking <=5;
