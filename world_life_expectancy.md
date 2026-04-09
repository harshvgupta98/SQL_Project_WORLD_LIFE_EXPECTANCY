# 🌍 World Life Expectancy — SQL Project

A complete SQL project covering data cleaning and exploratory data analysis (EDA) on a real-world dataset containing life expectancy and health indicators for 193 countries across 16 years (2007–2022).

---

## 📁 Project Structure

```
world-life-expectancy/
│
├── WorldLifeExpectancy.csv                  # Raw dataset
├── world_life_expectancy_cleaning.sql       # Part 1: Data Cleaning
└── world_life_expectancy_eda.sql            # Part 2: Exploratory Data Analysis
```

---

## 📊 Dataset Overview

**File:** `WorldLifeExpectancy.csv`  
**Rows:** ~2,942  
**Countries:** 193  
**Years:** 2007–2022

| Column | Description |
|---|---|
| `Country` | Country name |
| `Year` | Year of record |
| `Status` | Developing / Developed |
| `Life expectancy` | Average life expectancy (years) |
| `Adult Mortality` | Deaths per 1,000 adults |
| `infant deaths` | Infant deaths per 1,000 population |
| `percentage expenditure` | Health expenditure as % of GDP |
| `Measles` | Reported measles cases |
| `BMI` | Average BMI |
| `under-five deaths` | Deaths of children under 5 |
| `Polio` | Polio immunisation coverage (%) |
| `Diphtheria` | Diphtheria immunisation coverage (%) |
| `HIV/AIDS` | Deaths per 1,000 from HIV/AIDS |
| `GDP` | GDP per capita (USD) |
| `thinness 1-19 years` | Prevalence of thinness in 10–19 year olds (%) |
| `thinness 5-9 years` | Prevalence of thinness in 5–9 year olds (%) |
| `Schooling` | Average years of schooling |
| `Row_ID` | Unique row identifier |

---

## 🧹 Part 1: Data Cleaning

**File:** `world_life_expectancy_cleaning.sql`

### Step 1 — Remove Duplicate Rows
Some `(Country, Year)` pairs appeared more than once (e.g. Zimbabwe 2019).  
Used `ROW_NUMBER()` window function partitioned by `CONCAT(Country, Year)` to identify and delete duplicates, keeping only the first occurrence.

### Step 2 — Fill Missing `Status` Values
Some rows had a blank `Status` field.  
Used a self-join on `Country` to propagate the correct `Developing` or `Developed` value from other rows of the same country.

### Step 3 — Interpolate Missing `Life Expectancy` Values
Some rows had a blank `Life expectancy` field.  
Used a three-way self-join (current year, previous year, next year) to calculate the average of adjacent years as an interpolated value.

---

## 🔍 Part 2: Exploratory Data Analysis

**File:** `world_life_expectancy_eda.sql`

### Step 1 — Life Expectancy Improvement Per Country
Calculated the min, max, and total improvement in life expectancy per country over 15 years. Identified the countries with the greatest and least improvement.

### Step 2 — Global Average Life Expectancy by Year
Tracked the worldwide average life expectancy year-by-year to identify the overall trend from 2007 to 2022.

### Step 3 — Life Expectancy vs GDP
Explored the correlation between a country's wealth (GDP) and its life expectancy. Also compared average life expectancy between high-GDP (≥ 1500) and low-GDP (≤ 1500) countries using conditional aggregation.

### Step 4 — Life Expectancy by Development Status
Compared average life expectancy between `Developing` and `Developed` countries, with country counts included for context.

### Step 5 — Life Expectancy vs BMI
Explored the relationship between average BMI and life expectancy across countries, ordered from highest to lowest BMI.

### Step 6 — Rolling Adult Mortality for "United" Countries
Used a `SUM() OVER()` window function to calculate a running total of adult mortality per year for countries with "United" in their name (e.g. United States, United Kingdom).

---

## 🛠️ How to Run

1. Import `WorldLifeExpectancy.csv` into your MySQL database as a table named `world_life_expectancy`
2. Run `world_life_expectancy_cleaning.sql` first to clean the data
3. Run `world_life_expectancy_eda.sql` to explore the cleaned data

> ⚠️ Always run the verification `SELECT` before each destructive operation (`DELETE` / `UPDATE`) in the cleaning script

---

## 💡 Key SQL Concepts Used

| Concept | Used In |
|---|---|
| `ROW_NUMBER()` window function | Data Cleaning — duplicate removal |
| Self-joins | Data Cleaning — filling blanks |
| Conditional `UPDATE` with `JOIN` | Data Cleaning — status & life expectancy fix |
| `GROUP BY` + `HAVING` | EDA — country-level aggregations |
| `CASE WHEN` conditional aggregation | EDA — GDP high/low comparison |
| `SUM() OVER (PARTITION BY ... ORDER BY ...)` | EDA — rolling adult mortality |
| Column aliasing | EDA — readable output headers |
