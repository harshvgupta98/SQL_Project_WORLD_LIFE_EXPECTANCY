-- ============================================================
-- World Life Expectancy Project — Exploratory Data Analysis
-- Dataset : WorldLifeExpectancy.csv
-- Rows    : ~2,942 | Countries: 193 | Years: 2007–2022
-- Author  : (Your Name)
-- ============================================================


-- ============================================================
-- STEP 0: Preview the cleaned data
-- ============================================================

SELECT * 
FROM world_life_expectancy;


-- ============================================================
-- STEP 1: Life Expectancy Improvement Per Country (2007–2022)
-- Shows how much each country's life expectancy changed
-- over the 15-year period.
-- ============================================================

-- Countries with the GREATEST improvement (DESC)
SELECT 
    Country, 
    MIN(`Life expectancy`)                                      AS Min_Life_Exp,
    MAX(`Life expectancy`)                                      AS Max_Life_Exp,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1)  AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING Min_Life_Exp != 0
   AND Max_Life_Exp != 0
ORDER BY Life_Increase_15_Years DESC;


-- Countries with the LEAST improvement (ASC)
SELECT 
    Country, 
    MIN(`Life expectancy`)                                      AS Min_Life_Exp,
    MAX(`Life expectancy`)                                      AS Max_Life_Exp,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1)  AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING Min_Life_Exp != 0
   AND Max_Life_Exp != 0
ORDER BY Life_Increase_15_Years ASC;


-- ============================================================
-- STEP 2: Global Average Life Expectancy by Year
-- Tracks the worldwide trend in life expectancy over time.
-- ============================================================

SELECT 
    Year, 
    ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Exp
FROM world_life_expectancy
WHERE `Life expectancy` != 0
GROUP BY Year
ORDER BY Year;


-- ============================================================
-- STEP 3: Life Expectancy vs GDP by Country
-- Explores the relationship between wealth and longevity.
-- ============================================================

-- 3a. Average Life Expectancy and GDP per country (ordered low to high GDP)
SELECT 
    Country, 
    ROUND(AVG(`Life expectancy`), 1) AS Life_Exp, 
    ROUND(AVG(GDP), 1)               AS Avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
   AND Avg_GDP > 0
ORDER BY Avg_GDP ASC;


-- 3b. Compare Life Expectancy between High GDP and Low GDP countries
--     Threshold: GDP >= 1500 = High, GDP <= 1500 = Low
SELECT 
    SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END)                        AS High_GDP_Count,
    ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END), 1) AS High_GDP_Life_Exp,
    SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END)                        AS Low_GDP_Count,
    ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END), 1)  AS Low_GDP_Life_Exp
FROM world_life_expectancy;


-- ============================================================
-- STEP 4: Life Expectancy by Development Status
-- Compares Developing vs Developed countries.
-- ============================================================

-- 4a. Average life expectancy per status
SELECT 
    Status, 
    ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Exp
FROM world_life_expectancy
GROUP BY Status;


-- 4b. Add country count to give context to the averages
SELECT 
    Status, 
    COUNT(DISTINCT Country)          AS Country_Count,
    ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Exp
FROM world_life_expectancy
GROUP BY Status;


-- ============================================================
-- STEP 5: Life Expectancy vs BMI by Country
-- Explores the relationship between BMI and longevity.
-- ============================================================

-- Countries with the HIGHEST average BMI
SELECT 
    Country, 
    ROUND(AVG(`Life expectancy`), 1) AS Life_Exp, 
    ROUND(AVG(BMI), 1)               AS Avg_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
   AND Avg_BMI > 0
ORDER BY Avg_BMI DESC;


-- Countries with the LOWEST average BMI
SELECT 
    Country, 
    ROUND(AVG(`Life expectancy`), 1) AS Life_Exp, 
    ROUND(AVG(BMI), 1)               AS Avg_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
   AND Avg_BMI > 0
ORDER BY Avg_BMI ASC;


-- ============================================================
-- STEP 6: Rolling Adult Mortality — "United" Countries
-- Calculates a running total of Adult Mortality per year
-- for countries with "United" in their name.
-- ============================================================

SELECT 
    Country, 
    Year,
    `Life expectancy`,
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER (
        PARTITION BY Country 
        ORDER BY Year
    ) AS Rolling_Mortality_Total
FROM world_life_expectancy
WHERE Country LIKE '%United%';
