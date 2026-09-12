/* TTC Subway Delay */
/* Skills used: Creating VIEWs, JOINs and CTEs; Aggregate and Window Functions */

-- --------------------------------------------------------------------------------------------------------------------------------

/* HEAD OF TRANSIT PLANNING */

/* 1. What are the most common causes of train delays by station, time of day, or day of week? */

-- BY STATION

WITH code_station_count AS (
	SELECT 
        delay_reason,
		cleaned_station AS station_name, 
		COUNT(*) AS delay_count
	FROM ttc_delay_tagged
	WHERE 
		cleaned_station IS NOT NULL
		AND min_delay > 0
	GROUP BY delay_reason, station_name
),
code_station_ranked AS (
	SELECT 
		*,
		RANK() OVER (
			PARTITION BY station_name
			ORDER BY delay_count DESC) AS rank_num
	FROM code_station_count
),
top_per_station AS (
	SELECT 
		delay_reason,
        station_name
	FROM code_station_ranked
	WHERE rank_num = 1
),
station_counts AS (
	SELECT 
		delay_reason,
		COUNT(DISTINCT station_name) AS num_stations_affected
	FROM top_per_station
	GROUP BY delay_reason
)
SELECT
	delay_reason,
    num_stations_affected,
    ROUND(num_stations_affected * 100.0 / 75, 2) AS pct_stations_affected
FROM station_counts
ORDER BY num_stations_affected DESC;

-- TIME OF DAY

WITH code_time_count AS (
	SELECT 
        delay_reason,
		time_military_hour AS time_of_event,
		COUNT(*) AS delay_count
	FROM ttc_delay_tagged
    WHERE min_delay > 0
	GROUP BY delay_reason, time_of_event
),
code_time_ranked AS (
	SELECT 
		*,
		RANK() OVER (
			PARTITION BY time_of_event
			ORDER BY delay_count DESC) AS rank_num
	FROM code_time_count
),
top_per_hour AS (
	SELECT 
		delay_reason,
		time_of_event
	FROM code_time_ranked
	WHERE rank_num = 1
),
hour_counts AS (
    SELECT 
        delay_reason,
        COUNT(DISTINCT time_of_event) AS num_hours_affected
    FROM top_per_hour
    GROUP BY delay_reason
)
SELECT
	delay_reason,
    num_hours_affected,
    ROUND(num_hours_affected * 100.0 / 24, 2) AS pct_hours_affected
FROM hour_counts
ORDER BY num_hours_affected DESC;

-- DAY OF THE WEEK

WITH code_day_count AS (
	SELECT 
        delay_reason,
		day,
		COUNT(*) AS delay_count
	FROM ttc_delay_tagged
    WHERE min_delay > 0
	GROUP BY delay_reason, day
),
code_day_ranked AS (
	SELECT 
		*,
		RANK() OVER (
			PARTITION BY day
			ORDER BY delay_count DESC) AS rank_num
	FROM code_day_count
),
top_per_day AS (
	SELECT
		delay_reason,
		day
	FROM code_day_ranked
	WHERE rank_num = 1
),
day_counts AS (
SELECT 
delay_reason,
COUNT(DISTINCT day) AS num_days_affected
FROM top_per_day
GROUP BY delay_reason
)
SELECT
	delay_reason,
    num_days_affected,
    ROUND(num_days_affected * 100.0 / 7, 2) AS pct_days_affected
FROM day_counts
ORDER BY num_days_affected DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 2. Which stations or routes experience the highest average delay times, and how can scheduling be adjusted to reduce them? */

-- STATION

SELECT 
	cleaned_station,
    AVG(min_delay) AS avg_delay_time
FROM ttc_subway_cleaned
WHERE min_delay > 0 
GROUP BY cleaned_station
ORDER BY avg_delay_time DESC; 

-- LINE

SELECT 
	cleaned_line,
    AVG(min_delay) AS avg_delay_time
FROM ttc_subway_cleaned
WHERE 
	min_delay > 0
	AND cleaned_line IS NOT NULL
GROUP BY cleaned_line
ORDER BY avg_delay_time DESC; 

-- --------------------------------------------------------------------------------------------------------------------------------

/* 3. Is there a correlation between delay frequency and specific train lines or directions (e.g., northbound vs. southbound)? */

SELECT 
	cleaned_line AS train_line,
    cleaned_bound AS train_bound,
	COUNT(*) AS num_delay,
    ROUND (
		COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY cleaned_line), 
        2) AS pct_line_delays
FROM ttc_subway_cleaned
WHERE 
	min_delay > 0 
	AND cleaned_line IS NOT NULL
	AND cleaned_bound IS NOT NULL
GROUP BY cleaned_line, cleaned_bound
ORDER BY cleaned_line, pct_line_delays DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 4. Can we identify operational bottlenecks that occur consistently across specific days or time periods? */

-- DAY

WITH delay_days AS (
	SELECT 
        delay_reason,
		day,
		COUNT(row_id) AS num_delays
	FROM ttc_delay_tagged
	WHERE min_delay > 0
	GROUP BY delay_reason, day
),
delay_days_ranking AS (
	SELECT 
		*,
        DENSE_RANK() OVER(PARTITION BY day ORDER BY num_delays DESC) rank_num 
    FROM delay_days
),
top_delay_days AS (
	SELECT *
    FROM delay_days_ranking
    WHERE rank_num = 1
),
consistency_delay_days AS (
	SELECT 
		delay_reason,
        COUNT(DISTINCT day) AS days_affected
    FROM top_delay_days
    GROUP BY delay_reason
)

SELECT *
FROM consistency_delay_days;

-- TIME

WITH delay_time AS (
	SELECT 
        delay_reason,
		time_military_hour AS time_of_event,
		COUNT(row_id) AS num_delays
	FROM ttc_delay_tagged
	WHERE min_delay > 0
	GROUP BY delay_reason, time_of_event
),
delay_time_ranking AS (
	SELECT 
		*,
        DENSE_RANK() OVER(PARTITION BY time_of_event ORDER BY num_delays DESC) rank_num
    FROM delay_time
),
top_delay_time AS (
	SELECT *
    FROM delay_time_ranking
    WHERE rank_num = 1
),
consistency_delay_time AS (
	SELECT 
		delay_reason,
        COUNT(DISTINCT time_of_event) AS hours_affected,
        SUM(num_delays) AS total_delays
    FROM top_delay_time
    GROUP BY delay_reason
    ORDER BY total_delays DESC
)
SELECT *
FROM consistency_delay_time;

-- --------------------------------------------------------------------------------------------------------------------------------

/* HEAD OF OPERATIONS */

/* 1. Which reasons for delays are within our operational control (e.g., vehicle issues, crew availability), and how often do they occur? */

SELECT 
    delay_reason,
    COUNT(row_id) AS num_occurence
FROM ttc_delay_tagged
WHERE control_level = 'within_control'
	OR control_level = 'partial_control'
	AND min_delay > 0 
GROUP BY delay_reason
ORDER BY num_occurence DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 2. How does delay time vary by vehicle number — are there specific trains that contribute disproportionately to system delays? */

SELECT 
	    cleaned_vehicle AS vehicle_num,
        AVG(min_delay) AS avg_delay_time, 
        COUNT(row_id) AS num_of_delays, 
        SUM(min_delay) AS total_delay_min 
FROM ttc_subway_cleaned
WHERE min_delay > 0
	AND cleaned_vehicle IS NOT NULL
GROUP BY cleaned_vehicle
ORDER BY total_delay_min DESC; 

-- --------------------------------------------------------------------------------------------------------------------------------

/* 3. Are there peak periods or specific combinations of line and bound direction where delays spike, requiring contingency planning? */

-- LINE & BOUND COMBO

SELECT 
	cleaned_line AS line,
    cleaned_bound AS bound_direction,
    SUM(min_delay) AS min_delay, 
    AVG(min_delay) AS avg_delay_min, 
    COUNT(row_id) AS num_delays 
FROM ttc_subway_cleaned
WHERE min_delay > 0
	AND cleaned_bound IS NOT NULL
    AND cleaned_line IS NOT NULL
GROUP BY line, bound_direction
ORDER BY min_delay DESC;

-- PEAK HOURS 

SELECT 
    time_military_hour AS time_of_event,
    CASE
        WHEN HOUR(time_military_hour) BETWEEN 6 AND 9 THEN 'AM Peak'
        WHEN HOUR(time_military_hour) BETWEEN 15 AND 19 THEN 'PM Peak'
        ELSE 'Off Peak'
    END AS peak_period,
    SUM(min_delay)  AS total_delay_min,
    AVG(min_delay)  AS avg_delay_min,
    COUNT(row_id)   AS num_delays
FROM ttc_subway_cleaned
WHERE min_delay > 0
  AND day NOT IN ('Saturday', 'Sunday')
GROUP BY time_of_event
ORDER BY total_delay_min DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 4. What impact do frequent delays have on downstream operations and overall network reliability? */

SELECT 
    delay_reason,
    control_level,
    CASE
        WHEN HOUR(time_military_hour) BETWEEN 6 AND 9 THEN 'AM Peak'
        WHEN HOUR(time_military_hour) BETWEEN 15 AND 19 THEN 'PM Peak'
        ELSE 'Off Peak'
    END AS peak_period,
    COUNT(*) AS num_delays,
    AVG(min_delay) AS avg_initial_delay,
    AVG(CASE WHEN min_gap > 8 THEN min_gap END) AS avg_disruptive_gap,
    SUM(CASE WHEN min_gap > 8 THEN min_gap ELSE 0 END) AS total_disruptive_gap,
    ROUND(SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS disruption_rate
FROM ttc_delay_tagged
WHERE min_delay > 0
	AND min_gap > 0
GROUP BY delay_reason, control_level, peak_period
ORDER BY num_delays DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* SENIOR MANAGEMENT */

/* 1. How have average delay times trended over the current year and the past year? What are the key drivers? */

/* analyzed the year 2023-2024 */

-- TREND

SELECT 
	DATE_FORMAT(date, '%Y-%m') AS Month_Year,
    AVG(min_delay) AS avg_min_delay,
    COUNT(row_id) AS total_delays
FROM ttc_subway_cleaned
WHERE min_delay > 0
	AND date BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY Month_Year
ORDER BY Month_Year ASC; 

-- KEY DRIVERS
   
WITH delay_trend AS (
	SELECT 
		DATE_FORMAT(date, '%Y-%m') AS Month_Year,
		delay_reason,
		control_level,
		SUM(min_delay) AS total_min_delay, 
		AVG(min_delay) AS avg_min_delay,
		COUNT(row_id) AS num_delays 
	FROM ttc_delay_tagged
	WHERE min_delay > 0
		AND date BETWEEN '2023-01-01' AND '2024-12-31'
	GROUP BY Month_Year, delay_reason, control_level
	ORDER BY Month_Year ASC
),
key_driver AS (
SELECT 
	*,
    DENSE_RANK() OVER(PARTITION BY Month_Year ORDER BY num_delays DESC) AS ranked_delays
FROM delay_trend
)
SELECT *
FROM key_driver
WHERE ranked_delays <=2;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 2. Which delay causes result in the largest cumulative service gaps and therefore pose the greatest risk to passenger experience and reliability? */

SELECT 
    delay_reason,
    COUNT(*) AS num_delays,
    SUM(CASE WHEN min_gap > 8 THEN min_gap ELSE 0 END) AS total_disruptive_gap,
    AVG(CASE WHEN min_gap > 8 THEN min_gap END) AS avg_disruptive_gap
FROM ttc_delay_tagged
WHERE min_delay > 0 
GROUP BY delay_reason
ORDER BY total_disruptive_gap DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 3. What is our system-wide on-time performance, and how does it compare to strategic KPIs? */

SELECT 
	cleaned_line AS ttc_line,
	COUNT(*) AS total_evaluable_events,
    SUM(CASE  
			WHEN min_gap <= 8 THEN 1 ELSE 0 END) AS on_time_service,
	SUM(CASE 
			WHEN min_gap <= 8 THEN 1 ELSE 0 END) * 100 / COUNT(*) AS on_time_service_pct
FROM ttc_subway_cleaned
WHERE cleaned_line IS NOT NULL
	AND day NOT IN('Saturday', 'Sunday')
    AND date BETWEEN '2025-01-01' AND '2025-04-30'
GROUP BY cleaned_line
ORDER BY on_time_service_pct DESC; 

-- --------------------------------------------------------------------------------------------------------------------------------

/* 4. Which improvement initiatives should be prioritized based on delay root causes and operational impact? */

SELECT 
    delay_reason,
    control_level,
    COUNT(*) AS total_incidents,
    AVG(min_delay) AS avg_delay_min,
    SUM(min_delay) AS total_delay_min,
    SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) AS disruptive_incidents,
    ROUND(SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS disruption_rate
FROM ttc_delay_tagged
WHERE min_delay > 0
	AND control_level IN ('within_control', 'partial_control')
GROUP BY delay_reason, control_level
ORDER BY total_delay_min DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* HEAD OF MARKETING */

/* 1. Which stations or lines experience frequent delays that may be impacting customer satisfaction or brand perception? */

-- STATION

SELECT 
	cleaned_station AS station,
    COUNT(*) AS num_delay, 
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS pct_station_delays 
FROM ttc_subway_cleaned
WHERE min_delay > 0
	AND cleaned_station IS NOT NULL
    AND cleaned_bound IS NOT NULL
GROUP BY cleaned_station
ORDER  BY pct_station_delays DESC;

-- LINE

SELECT 
	cleaned_line AS ttc_line,
    COUNT(*) AS num_delay, 
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS pct_line_delays
FROM ttc_subway_cleaned
WHERE min_delay > 0
	AND cleaned_line IS NOT NULL
GROUP BY cleaned_line
ORDER  BY pct_line_delays DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 2. Are there specific times or days when service reliability drops and should be addressed in customer communication or loyalty campaigns? */

SELECT 
    day AS day_of_delay,
    time_military_hour AS time_of_delay,
    COUNT(*) AS total_events,
    SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) AS disruptive_incidents,
    ROUND(SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS disruption_rate,
    SUM(CASE WHEN min_gap > 8 THEN min_gap ELSE 0 END) AS total_disruptive_service_gap,
    AVG(CASE WHEN min_gap > 8 THEN min_gap END) AS avg_disruptive_gap
FROM ttc_subway_cleaned
WHERE min_delay > 0 
GROUP BY day_of_delay, time_of_delay
HAVING COUNT(*) >= 100
ORDER BY disruption_rate DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 3. Can we develop targeted messaging for routes or time slots most affected by delays to manage rider expectations? */

WITH affected_routes AS (
    SELECT 
        cleaned_line AS ttc_line,
        cleaned_bound AS ttc_bound,
        day,
        time_military_hour AS time_of_delay,
        CASE
            WHEN time_military_hour BETWEEN 6 AND 9 THEN 'AM Peak'
            WHEN time_military_hour BETWEEN 15 AND 19 THEN 'PM Peak'
            ELSE 'Off Peak'
        END AS peak_period,
        COUNT(*) AS total_events,
        SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) AS disruptive_incidents,
        ROUND(SUM(CASE WHEN min_gap > 8 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS disruption_rate,
        AVG(CASE WHEN min_gap > 8 THEN min_gap END) AS avg_disruptive_gap
    FROM ttc_delay_tagged
    WHERE min_delay > 0
        AND cleaned_line IS NOT NULL
        AND cleaned_bound IS NOT NULL
    GROUP BY cleaned_line, cleaned_bound, day, time_military_hour
    HAVING COUNT(*) >= 100
),
affected_routes_rank AS (
    SELECT 
        *,
        DENSE_RANK() OVER(
            PARTITION BY time_of_delay, day 
            ORDER BY disruption_rate DESC
        ) AS delay_ranking
    FROM affected_routes
)
SELECT *
FROM affected_routes_rank
WHERE delay_ranking = 1
ORDER BY disruption_rate DESC;

-- --------------------------------------------------------------------------------------------------------------------------------

/* 4. Which weekday time periods experience consistent delay severity that could plausibly influence riders to adjust travel times or seek alternative modes? */

WITH daily_trends AS (
    SELECT
        day AS day_of_delay,
        time_military_hour AS time_of_delay,
        COUNT(*) AS num_delays,
        AVG(min_delay) AS avg_delay_min    
    FROM ttc_delay_tagged
    WHERE min_delay > 8                           
      AND day NOT IN ('Saturday', 'Sunday')
    GROUP BY day, time_military_hour
),
hourly_summary AS (
    SELECT
        time_of_delay,
        AVG(avg_delay_min) AS avg_severity,
        STDDEV(avg_delay_min) AS severity_stddev,
        SUM(num_delays) AS total_delays,
        COUNT(DISTINCT day_of_delay) AS days_observed
    FROM daily_trends
    GROUP BY time_of_delay
)
SELECT
    time_of_delay,
    ROUND(avg_severity, 2) AS avg_delay_minutes,
    ROUND(severity_stddev, 2) AS consistency_stddev,
    total_delays,
    ROUND(avg_severity / NULLIF(severity_stddev, 0), 2) AS severity_consistency_ratio
FROM hourly_summary
WHERE total_delays >= 20 
  AND days_observed >= 3
ORDER BY severity_consistency_ratio DESC, avg_severity DESC;

-- --------------------------------------------------------------------------------------------------------------------------------
