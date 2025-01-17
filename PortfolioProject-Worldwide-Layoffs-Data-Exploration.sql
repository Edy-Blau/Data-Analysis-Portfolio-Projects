--Project: Worldwide Layoffs - Exploratory Data Analysis
--Source: SQL Course (AlexTheAnalyst)
--Modified/Edited by: EdyBlau
--Date: 01/13/2025

-- EDA: EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

# Maximum number of layoffs
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

# The companies that laid off all their personnel
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

# Grouping by companies
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

# Data time range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; # Basicallly all the pandemic

# Grouping by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# Grouping by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# Grouping by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

# Grouping by Stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

# The Progression of layoffs
# A rolling sum

SELECT  SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

# Using a CTE
With Rolling_Total AS
(
	SELECT  SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total_sum
FROM Rolling_Total;

# Grouping by companies and year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

# Using CTEs to Rank
WITH Company_Year (company, years, total_laid_off) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS
(
	SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
	FROM Company_Year
	WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
