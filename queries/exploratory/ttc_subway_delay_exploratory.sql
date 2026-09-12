#Exploratory Queries
Ad-hoc SQL queries used during initial data exploration.
 
/* count the total number of rows */

SELECT 
COUNT(*)
FROM ttc_subway; 

-- --------------------------------------------------------------------------------------------------------------

/* review the whole dataset */

SELECT *
FROM ttc_subway_staging;

SELECT *
FROM code_desc;

SELECT *
FROM code_desc_staging;

SELECT *
FROM code_desc_clean;

SELECT *
FROM code_desc_clean_v2;

SELECT *
FROM ttc_subway_cleaned;

-- --------------------------------------------------------------------------------------------------------------

 /* review the special characters in the dataset */
 
SELECT *
FROM code_desc_clean
WHERE description LIKE '%Â%';

SELECT description, HEX(description)
FROM code_desc_clean
WHERE description REGEXP '[^ -~]'
LIMIT 10;

SELECT COUNT(*) AS remaining_bad_chars
FROM code_desc_clean
WHERE description REGEXP '[^ -~]';

-- --------------------------------------------------------------------------------------------------------------------------------
