-- Load and Convert Data Type

CREATE DATABASE covid19;

USE covid19;

DROP TABLE IF EXISTS covid;

CREATE TABLE covid(
	code VARCHAR(40),
    continent VARCHAR(40),
    country VARCHAR(200),
    `date` DATE,
    population BIGINT,
    total_cases BIGINT,
    new_cases INT,
    new_cases_smoothed INT,
    total_deaths BIGINT,
    new_deaths INT,
    new_deaths_smoothed INT,
    total_vaccinations BIGINT,
    people_vaccinated BIGINT
);

SELECT *
FROM covid;

LOAD DATA LOCAL INFILE '/Users/hna/Documents/DA/SQL/Covid19/covid19_export.csv'
INTO TABLE covid
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
code,
continent,
country,
@`date`,
@population,
@total_cases,
@new_cases,
@new_cases_smoothed,
@total_deaths,
@new_deaths,
@new_deaths_smoothed,
@total_vaccinations,
@people_vaccinated
)
SET
`date` = IF(@`date` = '', NULL, STR_TO_DATE(trim(@`date`), '%Y-%m-%d')),
population = IF(@population = '', NULL, @population),
total_cases = IF(@total_cases = '', NULL, @total_cases),
new_cases = IF(@new_cases = '', NULL, @new_cases),
new_cases_smoothed = IF(@new_cases_smoothed = '', NULL, @new_cases_smoothed),
total_deaths = IF(@total_deaths = '', NULL, @total_deaths),
new_deaths = IF(@new_deaths = '', NULL, @new_deaths),
new_deaths_smoothed = IF(@new_deaths_smoothed = '', NULL, @new_deaths_smoothed),
total_vaccinations = IF(@total_vaccinations = '', NULL, @total_vaccinations),
people_vaccinated = IF(@people_vaccinated = '', NULL, @people_vaccinated)
;
