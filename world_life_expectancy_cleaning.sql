-- ============================================================
-- World Life Expectancy Project — Data Cleaning
-- Dataset : WorldLifeExpectancy.csv
-- Rows    : ~2,942 | Countries: 193 | Years: 2007–2022
-- Author  : (Your Name)
-- ============================================================


-- ============================================================
-- STEP 0: Preview the raw data
-- ============================================================

SELECT * 
FROM world_life_expectancy;


-- ============================================================
-- STEP 1: Remove Duplicate Rows
-- Each (Country, Year) pair should appear only once.
-- ============================================================

-- 1a. Identify duplicates
SELECT 
    Country, 
    Year, 
    COUNT(CONCAT(Country, Year)) AS occurrences
FROM world_life_expectancy
GROUP BY Country, Year
HAVING occurrences > 1;


-- 1b. Find the Row_IDs of the duplicate records (keep the first, remove the rest)
SELECT *
FROM (
    SELECT 
        Row_ID, 
        CONCAT(Country, Year) AS country_year,
        ROW_NUMBER() OVER (
            PARTITION BY CONCAT(Country, Year) 
            ORDER BY CONCAT(Country, Year)
        ) AS row_num
    FROM world_life_expectancy
) AS row_table
WHERE row_num > 1;


-- 1c. ⚠️ Run the SELECT above first to verify rows, THEN run this DELETE
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT 
            Row_ID,
            ROW_NUMBER() OVER (
                PARTITION BY CONCAT(Country, Year) 
                ORDER BY CONCAT(Country, Year)
            ) AS row_num
        FROM world_life_expectancy
    ) AS row_table
    WHERE row_num > 1
);


-- ============================================================
-- STEP 2: Fill in Missing 'Status' Values
-- Some rows have blank Status; fill using other rows for the
-- same country that already have a Status value.
-- ============================================================

-- 2a. Check which rows have a blank Status
SELECT * 
FROM world_life_expectancy
WHERE Status = '';

-- 2b. View the distinct Status values that exist
SELECT DISTINCT Status
FROM world_life_expectancy
WHERE Status != '';


-- 2c. Fill blank Status with 'Developing' where applicable
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
  AND t2.Status != ''
  AND t2.Status = 'Developing';


-- 2d. Fill blank Status with 'Developed' where applicable
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
  AND t2.Status != ''
  AND t2.Status = 'Developed';


-- 2e. Verify no blank Status values remain
SELECT * 
FROM world_life_expectancy
WHERE Status = '';


-- ============================================================
-- STEP 3: Fill in Missing 'Life Expectancy' Values
-- Interpolate using the average of the previous and next year
-- for the same country.
-- ============================================================

-- 3a. Check which rows have a blank Life Expectancy
SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = '';


-- 3b. Preview the interpolated values before applying
SELECT 
    t1.Country,
    t1.Year,
    t1.`Life expectancy`                                        AS current_value,
    t2.`Life expectancy`                                        AS prev_year_value,
    t3.`Life expectancy`                                        AS next_year_value,
    ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1) AS interpolated_value
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';


-- 3c. ⚠️ Run the SELECT above first to verify values, THEN run this UPDATE
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = '';


-- ============================================================
-- STEP 4: Final Check — Verify cleaned data
-- ============================================================

SELECT * 
FROM world_life_expectancy;
