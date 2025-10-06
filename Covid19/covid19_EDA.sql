-- EDA
SELECT DISTINCT continent, country
FROM covid_staging;

SELECT DISTINCT country, continent
FROM covid_staging;

SELECT *
FROM covid_staging
WHERE continent = '';

SELECT DISTINCT country, continent
FROM covid_staging
WHERE continent IS NOT NULL;



-- By World
-- 1. Number of Cases, Infection Rate, Case Fatality Rate

-- Create a View of World Population
CREATE OR REPLACE VIEW continent_pop AS
SELECT country AS continent, max(population) AS population
FROM covid_staging
WHERE continent = ''
	AND country IN ('Africa', 'Europe', 'North America', 'South America', 'Oceania', 'Asia')
GROUP BY country;

SELECT sum(population) AS world_population
FROM continent_pop;

-- Calculate number of Cases, Infection Rate, Case Fatality Rate
SELECT 	w.world_pop AS world_population,
		w.world_cases AS world_cases,
        w.world_deaths AS world_deaths,
		round(w.world_cases / w.world_pop,4) AS infection_rate_pct,
		round(w.world_deaths / w.world_cases,4) AS case_fatality_rate_pct
FROM ( 
	SELECT 
		(SELECT sum(population) FROM continent_pop) AS world_pop,
        (SELECT max(total_deaths) FROM covid_staging
			WHERE continent IS NOT NULL
				AND country NOT IN (
                'world', 'european union (27)', 'Africa', 'Europe', 'North America', 'South America', 'Oceania', 
                'Asia', 'Asia excl. China', 'England', 'England and Wales', 'Equatorial Guinea', 'High-income countries',
                'Low-income countries', 'Lower-middle-income countries', 'Northern Ireland', 'Scotland', 'Summer Olympics 2020', 
                'Winter Olympics 2022', 'Upper-middle-income countries', 'Wales', 'World excl. China', 'World excl. China and South Korea',
                'World excl. China, South Korea, Japan and Singapore')
                ) 
                AS world_deaths,
		(SELECT max(total_cases) FROM covid_staging
			WHERE continent IS NOT NULL
				AND country NOT IN (
                  'world', 'european union (27)', 'Africa', 'Europe', 'North America', 'South America', 'Oceania', 
                'Asia', 'Asia excl. China', 'England', 'England and Wales', 'Equatorial Guinea', 'High-income countries',
                'Low-income countries', 'Lower-middle-income countries', 'Northern Ireland', 'Scotland', 'Summer Olympics 2020', 
                'Winter Olympics 2022', 'Upper-middle-income countries', 'Wales', 'World excl. China', 'World excl. China and South Korea',
                'World excl. China, South Korea, Japan and Singapore')
                ) 
                AS world_cases
	) w;
    
-- By Continents
-- 2. Number of infected, vaccinated and deaths by Continent
SELECT 	country AS continent, 
		max(population) AS population,
		max(total_cases) AS total_cases,
        max(people_vaccinated) AS total_vaccinations,
        max(total_deaths) AS total_deaths,
		round(max(total_cases) / max(population), 4) AS infection_rate,
        round(max(total_deaths) / max(population), 4) AS case_fatality_rate,
        round(max(people_vaccinated) / max(population), 4) AS vaccination_rate
FROM covid_staging
WHERE continent = ''
	AND country IN ('Africa', 'Europe', 'North America', 'South America', 'Oceania', 'Asia')
GROUP BY country;


-- By Countries
-- 3. Number of infected, vaccinated and deaths by Country (label)
SELECT 	continent,
		country, 
		max(population) AS population,
		max(total_cases) AS total_cases,
        max(people_vaccinated) AS total_vaccinations,
        max(total_deaths) AS total_deaths,
		round(max(total_cases) / max(population), 4) AS infection_rate,
        round(max(total_deaths) / max(population), 4) AS case_fatality_rate,
        round(max(people_vaccinated) / max(population), 4) AS vaccination_rate
FROM covid_staging
WHERE continent IS NOT NULL
	AND country NOT IN (
		'world', 'european union (27)', 'Africa', 'Europe', 'North America', 'South America', 'Oceania', 
		'Asia', 'Asia excl. China', 'England', 'England and Wales', 'Equatorial Guinea', 'High-income countries',
		'Low-income countries', 'Lower-middle-income countries', 'Northern Ireland', 'Scotland', 'Summer Olympics 2020', 
		'Winter Olympics 2022', 'Upper-middle-income countries', 'Wales', 'World excl. China', 'World excl. China and South Korea',
		'World excl. China, South Korea, Japan and Singapore')
GROUP BY country, continent
ORDER BY country;

-- 4. Daily Confirmed Deaths 
SELECT 	continent,
		country,
        `date`,
        new_deaths_smoothed
FROM covid_staging
WHERE continent IS NOT NULL
	AND country NOT IN ('world', 'european union (27)', 'Africa', 'Europe', 'North America', 'South America', 'Oceania', 
		'Asia', 'Asia excl. China', 'England', 'England and Wales', 'Equatorial Guinea', 'High-income countries',
		'Low-income countries', 'Lower-middle-income countries', 'Northern Ireland', 'Scotland', 'Summer Olympics 2020', 
		'Winter Olympics 2022', 'Upper-middle-income countries', 'Wales', 'World excl. China', 'World excl. China and South Korea',
		'World excl. China, South Korea, Japan and Singapore')
ORDER BY country, `date`;











