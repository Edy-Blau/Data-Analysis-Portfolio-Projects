--Project: Worldwide Layoffs - Data-Cleaning
--Source: SQL Course (AlexTheAnalyst)
--Modified/Edited by: EdyBlau
--Date: 01/13/2025

-- DATA CLEANING

SELECT *
FROM layoffs;

# Steps to perform
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Look at Null Values or Blank Values
-- 4. Remove Any Columns and Rows that are unnecesary

# A staging table
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

# To insert the data in the new table
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
# Identify duplicates
# Using a Window function.
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
    `date`, stage, country,unds_raised_millions) AS row_num
FROM layoffs_staging;

# And then with a CTE
WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
    `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT *
# DELETE
FROM duplicate_cte
WHERE row_num > 1;

# Creating a copy of previous table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

# Copying the data into new table
INSERT INTO layoffs_staging2
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
    `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging;

# To identify the duplicates
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

# To delete them
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- 2. STANDARDIZE THE DATA
# To delete extra spaces in company names
SELECT DISTINCT(company)
FROM layoffs_staging2;

SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

# To unify industry terms
SELECT DISTINCT(Industry)
FROM layoffs_staging2
ORDER BY 1;

# Fixing Crypto terms
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# To check the Countries
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

# Fix the date datatype
SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); # Now it shows the date format, but it's still text datatype

# Now, this column is actually date datatype
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. LOOK AT NULL VALUES OR BLANK VALUES
# Identify nulls and blanks
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'AirBnb';

# A self-join to populate the null and blank values in industries where we know their type
SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL);

# First update blanks to Nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND (t2.industry IS NOT NULL);


-- 4. REMOVE ANY COLUMNS AND ROWS THAT ARE UNNECESARY
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Removing the row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;
# DATA CLEANING COMPLETED!
