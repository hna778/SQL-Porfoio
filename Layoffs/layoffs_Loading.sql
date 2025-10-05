-- 1) Load Data Into A Database
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
DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;