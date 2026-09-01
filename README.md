# TTC Subway Delay 
> *This project focused on analyzing the TTC Subway Delay dataset dated between January 2014 and April 2025, to determine whether the main causes of delays are within TTC's operation control and can be prevented by prioritizing improvement initiatives*

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Objectives](#2-objectives)
3. [Project Scope & Tools](#3-project-scope--tools)
4. [Repository Structure](#4-repository-structure)
5. [Data Workflow](#5-data-workflow)
6. [Data Model & Schema](#6-data-model--schema)
7. [ERD - Entity Relationship Diagram](#7-erd--entity-relationship-diagram)
8. [Analysis & Metrics](#8-analysis--metrics)
9. [Key Insights](#9-key-insights)
10. [Recommendations](#10-recommendations)
11. [Assumptions & Limitations](#11-assumptions--limitations)
12. [Future Enhancements](#12-future-enhancements)
13. [Deliverables](#13-deliverables)
14. [Author](#14-author)

---

## 1. Project Overview

The TTC Subway system has been receiving an ongoing negative feedback through word of mouth and online forums, and I, myself, have experienced delays a few times whilst taking the TTC Subway transit. This begs the question — what are the root causes of these frequent delays, and can they be prevented? This project explored over 10 years of data across the TTC Subway system to determine whether underperformance was driven by factors that are within or outside the system's control. The analysis revealed that the highest delay count and total delay minutes across the system is caused by a delay reason that is not within TTC's control.

## 2. Objectives

- **Primary Objective:** Determine whether the frequent delays in TTC Subway system are caused by factors that are controllable (i.e. vehicle issues & crew availability)
- **Secondary Objective 1:** Identify the specific times or days when service reliability drops 
- **Secondary Objective 2:** Build improvement initiatives to lessen the occurrence of delays root causes and its operational impact
- **Secondary Objective 3:** [Remove if not applicable]

---

## 3. Project Scope & Tools

### Scope

| Dimension | Details |
|-----------|---------|
| **In Scope** | Delay data across all 4 TTC Subway Lines, January 2014-April 2025, & delay descriptions data. Analysis covers delay frequency, delay trends, delay times, and delay causes |
| **Out of Scope** | - Delay data from May 2025-December 2025 were excluded as the data sets were extracted and reviewed in June 2025. <br> - Three delay records with Line 3 as the TTC Line dated after July 24, 2023 were excluded from KPI calculation in Tableau as Line 3 was shut down permanently following a derailment on July 24, 2023. Note that these three records were included in other analyses as the error was seen after the MySQL queries and Tableau dashboard were created. |
| **Time Period** | January 2014-April 2025 |
| **Granularity** | Single delay incident per row, including timestamps, date, day, delay reason, TTC line, station, etc. |

### Tools & Technologies

| Category | Tool(s) Used |
|----------|-------------|
| Data Storage | CSV Files |
| Data Processing | MySQL, Excel (Power Query), Command Prompt |
| Analysis | MySQL Queries |
| Visualization | Tableau |
| Version Control | Git / GitHub |
| Documentation | Word / Excel |

---

## 4. Repository Structure

```
[project-root]/
│
├── data/
│   ├── raw/                  # Original, unmodified source data - never edited
│   ├── processed/            # Cleaned and transformed data
│   └── external/             # Reference data, lookup tables, third-party files
│
├── notebooks/                # Jupyter, R Markdown, or Colab notebooks
│
├── scripts/                  # Reusable .py, .R, or .sh processing files
│
├── queries/                  # SQL files (retain this folder for SQL-heavy projects)
│   ├── exploratory/          # Ad-hoc or investigative queries
│   ├── transformations/      # Cleaning and reshaping logic
│   └── final/                # Production-ready or presentation queries
│
├── reports/                  # Final outputs: PDFs, slide decks, Word docs
│
├── visuals/                  # Exported charts, dashboard screenshots, ERD diagrams
│
├── docs/                     # Data dictionaries, schema notes, reference material
│
├── project_metadata.yml      # Machine-readable metadata (optional)
└── README.md                 # You are here
```

> ⚠️ *Delete folders you didn't use. An empty folder is worse than no folder.*
> SQL-heavy projects: keep `queries/`. Analysis-only projects: keep `notebooks/`. Both? Keep both.

---

## 5. Data Workflow

```
[Data Source(s)]
      ↓
[Ingestion / Collection Method]
      ↓
[Cleaning & Transformation]
      ↓
[Analysis]
      ↓
[Output / Visualisation / Reporting]
```

1. **Source:**
   - Yearly CSV exports & Delay Code Description CSV exports pulled from the Open Data website (https://open.toronto.ca/dataset/ttc-subway-delay-data/).
     Ten files covering delay data from January 2014 to April 2025, and two files containing delays codes and descriptions.
2. **Ingestion:**
   - Consolidated the delay data CSV files and the delay codes CSV files into a single CSV file (230,841 rows and 340 rows, respectively) using Power Query in           Excel. These two consolidated CSV files were then loaded into MySQL using Command Prompt.
3. **Cleaning:**
   - ttc_subway table <br>
     - Removed trailing white space. <br>
     - Generated unique primary key values for each row. <br>
     - Removed 0.09% of duplicated rows. <br>
     - Converted the time column values into an hourly basis and excluded the minutes. <br>
     - Non-sensical station names in station column (5.66% rows) converted into NULL values (non-critical column). <br>
     - Resolved station name inconsistencies. <br>
     - Removed 0.08% of rows containing nonsensical values in code column (critical column). <br>
     - Converted the abbreviated values in bound column into the full direction description. <br>
     - Non-sensical values (blanks, random letter, none, numbers) in bound column (26.49% rows) converted into NULL values (non-critical column). <br>
     - Resolved line name inconsistencies. <br>
     - Non-sensical value in vehicle column (vehicle number is zero) (31.58% rows) converted into NULL values (non-critical column). <br>
     - Converted non-sensical values (numbers, address, none) in line column (0.35% rows) into NULL values (non-critical column). <br>
   - code_desc table. <br>
     - Removed trailing white space. <br>
     - Removed 0.06% of duplicated rows. <br>
4. **Transformation:**
   - Collected code description data from the open Toronto data website to decode the abbreviated delay reason on the TTC Subway delay data, and assigned operational control level classifications to each delay reasons — this dataset was created as a new table (code_desc).
   -  Created a reference look up table to map the code description to the cleaned subway delay dataset by creating a VIEW and using a LEFT JOIN, enriching records with delay reason descriptions and operational control level classifications.
   - Collected the subway line names and line numbers from external source and replaced the abbreviated values in line column in the data set by creating CASE WHEN queries.
   - Collected the subway station names from external source to validate the values in station column, resolve inconsistencies, and identify non-sensical names. CASE WHEN queries were created to resolve inconsistencies.
   - Converted the time column data from VARCHAR to TIME datatype to be able to analyze the data properly throughout MySQL queries.
5. **Analysis:** 
   - Yearly KPI and delay trends comparison.
   - Segmenting delay trends by time, station, TTC line, and vehicles.
   - Evaluating the operational impact of delays that are within control.
6. **Output / Visualization:** <br>
   - Developed 4 interactive dashboards in Tableau Public, targeting 4 distinct stakeholder audiences: Head of Transit Planning, Head of Operations, Senior              Management, and Head of Marketing. Included charts are listed below: <br>
     - Bar charts (most common cause of delay)
     - Barbell charts (delay frequency by train line and bound)
     - Bubble charts (delay frequency by station)
     - Pareto charts (delay cause contribution and vehicle impact)
     - Dual-axis bar and line charts (peak period analysis & disruptive delay cause analysis)
     - Year-over-year trend lines (avg delay comparison)
     - Scatter plots with quadrant annotations (downstream impact and improvement prioritization)
     - Bullet charts (on-time performance vs. 90% KPI target)
     - Heatmaps (service reliability by day and hour) <br>
   - Dashboard design decisions included: <br>
     - Dynamic parameters 
     - LOD expressions
     - Calculated fields 
     - Dual-axis configurations

---

## 6. Data Model & Schema

### Dataset / Table: `ttc_subway_cleaned`

| Field Name | Data Type | Description | Example Value | Nullable (yes/no) |
|------------|-----------|-------------|---------------|----------|
| `row_id` | int | Unique identifier per delay record | 33 | no |
| `date` | date | Date the delay occurred | 2022-01-01 | no |
| `day` | text | Day of week the delay occurred | Saturday | no |
| `cleaned_station` | varchar(27) | Standardized station name | Islington | yes |
| `code` | text | Abbreviated delay cause code | MUIRS | no |
| `min_delay` | int | Duration of delay in minutes | 5 | no |
| `min_gap` | int | Gap between successive vehicles in minutes | 12 | no |
| `cleaned_bound` | varchar(10) | Standardized direction of travel | Eastbound | yes |
| `cleaned_line` | varchar(23) | Standardized subway line name | Line 2 Bloor-Danforth | yes |
| `cleaned_vehicle` | bigint | Vehicle number of the train in operation | 5471 | yes |
| `time_military_hour` | time | Hour of delay in 24hr datetime format | 17:00:00 | no |

> **Row count:** 230,456 |
> **Date range:** January 2014–April 2025 |
> **Key join / relationship:** [`ttc_subway_cleaned.code` → `code_desc_clean_v2.code`]

### Dataset / Table: `code_desc_clean_v2`

| Field Name | Data Type | Description | Example Value | Nullable (yes/no) |
|------------|-----------|-------------|---------------|----------|
| `row_id` | int | Unique identifier per delay record | 3 | no |
| `code` | varchar(10) | Abbreviated delay cause code | ERAC | no |
| `description` | text | Full description of delay cause | work zone problems - signals | no |
| `control_level` | varchar(50) | Operational controllability classification | within_control | no |

> **Row count:** 212 |
> **Key join / relationship:** [`code_desc_clean_v2.code` → `ttc_subway_cleaned.code`]
---

## 7. ERD - Entity Relationship Diagram
### *(Primarily for SQL Projects - remove this section if not applicable)*

### Embedded Image
[ERD Diagram](TTC.Subway.Delay_ERD.pdf)
*[Two-table schema - ttc_subway_cleaned, and code_desc_cleaned_v2 joined on shared codes]*

---

**Table Relationships Summary:**

| Relationship | Join Key | Type |
|-------------|----------|------|
| `ttc_subway_cleaned` → `code_desc_cleaned_v2` | `code` | Many-to-One |

---

## 8. Analysis & Metrics

### Analytical Approach

In this project, I used an exploratory, stakeholder-driven approach to have a better understanding of the TTC subway delay patterns. The analysis was structured with 16 business questions that reflect how delay data would be consumed by key stakeholders across TTC — Head of Transit Planning, Head of Operations, Senior Management, and Head of Marketing.

Each question was treated as its own analytical unit: the appropriate grain, metric, and filtering logic were determined independently based on what each specific key stakeholder would need to make a decision. For example, the questions structured for the Head of Operations prioritize frequency and controllability of delay causes, while the questions structured for Head of Marketing prioritize disruption rate and rider-facing reliability — both using the same underlying dataset but through fundamentally different lenses.

There are two deliberate metric distinctions that shaped the entire analysis — min_delay & min_gap. min_delay captures how late a train was (service impact on riders), while min_gap captures the spacing between one train and the next arriving at a station (service impact on operations). These were applied selectively based on whether a question was about rider experience or downstream network impact. Using the wrong metric for a given question would produce a technically correct but analytically misleading result.

It is worth noting that using raw delay counts alone can be misleading since a higher number indicates a higher number of delay incidents. Where the question concerned reliability or risk, disruption rate (proportion of events that are beyond the on-time threshold) was used alongside raw delay counts to give a proportional view.

Further, a CREATE VIEW statement was built to capture the LEFT JOIN between the delay records and the code description reference table, avoiding repetition across queries and ensuring consistent mapping of delay reason and control level classifications throughout the analysis.

### Key Metrics Defined

| Metric | Plain-Language Definition | Why It Matters |
|--------|--------------------------|----------------|
| `min_delay` | Duration in minutes between a train's scheduled and actual arrival, as experienced by the rider | This is the primary rider-facing severity metric, and is used wherever the question concerns passenger impact rather than operational |
| `min_gap` | Time in minutes between one vehicle and the next arriving at a station | It measures service regularity from an operator perspective, and is used to assess whether a delay caused a wider service disruption |
| `disruption_rate` | Percentage of delay incidents where min_gap exceeded 8 minutes, indicating a service gap beyond the on-time threshold | Helps distinguish manageable delays from those that compound into system-wide problems |
| `avg_disruptive_gap` | 	Average min_gap value among incidents where min_gap > 8, calculated using conditional aggregation to exclude non-disruptive events from the average | Measures how severe the downstream service disruption is when it does occur — a high average indicates more severe downstream impact |
| `total_disruptive_gap` | 	Sum of all min_gap values exceeding 8 minutes | Measures the overall time lost to service gaps across all incidents — a cause that disrupts service moderately but frequently can have a more significant total impact than a rare but severe one |
| `on_time_service_pct` | Percentage of service events where min_gap ≤ 8 minutes | This is the system-wide KPI metric, and is compared against TTC's general standard target of 90% as claimed on their website |
| `pct_line_delays / pct_station_delays` | Each line or station's portion of total system delays, computed using SUM(COUNT(*)) OVER() as the denominator | Identifies disproportionate contributors to system-wide delay volume — used to prioritize stations and lines for marketing and operational attention |
| `severity_consistency_ratio` | 	Average delay severity divided by its standard deviation across weekdays (avg / NULLIF(stddev, 0)), computed via two-level CTE aggregation | Identifies time periods that are not just severe but reliably severe — a high ratio indicates that riders can predict poor service and may seek alternative transportation |
| `control_level` | Classification of each delay cause as within_control, partial_control, or outside_control, sourced from the code description reference table | Filters the improvement analysis to delay causes that TTC has the ability to address operationally |

### Methods Used

- Descriptive statistics — delay frequency, average delay duration, and total delay time calculated across multiple dimensions (station, line, bound direction, vehicle, time of day, day of week) to establish delay patterns across the TTC subway network.
- Top-N ranking per partition — RANK() and DENSE_RANK() window functions partitioned by station, time of day, and day of week in MySQL to surface the single most common delay cause per grouping.
- Trend analysis (2014–2025) — year-over-year comparison of average delay time using a dynamic current year vs. previous year parameter in Tableau, with monthly trends to identify seasonal patterns and shifts in delay severity.
- Segmentation by operational controllability — delay causes classified into within_control, partial_control, and outside_control tiers via a reference lookup table in MySQL, enabling analyses to be filtered by what TTC can realistically act on vs. can't act on due to external factors.
- Disruption analysis — conditional aggregation using CASE WHEN min_gap > 8 to distinguish delays that remained self-contained from those that caused downstream service gaps exceeding the 8-minute on-time threshold, analyzing disruption rate and total disruptive gap metrics per delay cause.
- Cumulative contribution analysis — running sum of total disruptive gap by delay cause visualized as a Pareto chart in Tableau to identify which causes account for the largest share of cumulative service gap, with an 80% threshold reference line.
- Weekday delay consistency analysis — identified which hours of the day experience consistently severe delays by using a two-level CTE to first calculate the average delay per hour per day, then measured how much of that varied across weekdays using standard deviation. Hours with high average severity and low variation indicates that riders would plausibly adjust their travel behaviour.
- On-time performance benchmarking — per train line, OTP is calculated in a yearly basis using min_gap ≤ 8 as the on-time threshold, benchmarked against TTC's published 90% KPI target from the 2025 Corporate Plan Mid-Year Progress Report. For the purpose of the project, I made an assumption that 90% is the KPI target for each year.
- Vehicle delay distribution analysis — Lorenz curve built in Tableau to show how unevenly delay is distributed across TTC vehicles — roughly a third of the trains accounts for 80% of all delay time, pointing to specific vehicles worth investigating further.
- Prioritization matrix — scatter plot in Tableau segmenting controllable delay causes into four quadrants (frequent & moderate, frequent & severe, rare but severe, monitor) using average delay time and delay count as axes to identify both high-volume and high-severity delay causes for improvement initiatives.
- Service reliability heatmap — disruption rate visualized across a day x hour grid in Tableau to identify specific day and time combinations where service reliability consistently drops.
- Relative delay share analysis — computed each station and line's percentage contribution to total system delays using partitioned window functions, enabling fair comparisons across locations with different delay volumes rather than relying on raw delay counts alone.

---

## 9. Key Insights

<!--
  Findings + implications. Not just what happened - what it means.

  WHAT GOOD LOOKS LIKE:
  ✅ "Return rates, not sales volume, explain Region A's underperformance.
      Region A's return rate on home goods was 34% - more than double the
      company average. Revenue was not lost at the point of sale; it was
      lost post-sale through refunds. This points to a fulfilment or
      product quality issue specific to that region, not a demand problem."

  WHAT TO AVOID:
  ❌ "Region A had lower revenue than other regions in Q4."
     (That's an observation. It describes what happened.
      An insight says what it means and where to look next.)

  Aim for 3–6 insights. Quality over quantity.
-->

**Insight 1: Disorderly patron explains TTC's frequent delays**

Disorderly patron ranks as the leading cause of delays across 60% of TTC subway stations and 75% of hourly intervals on a daily basis. This points to an issue that the main cause of delay is not within TTC's operation control, and initiating improvement initiatives towards this can be challenging.

**Insight 2: Roughly a third of TTC vehicles account for most delays**

34% of trains make up for 80% of total delay time. This points to specific trains that contribute disproportionately to system delays, which should be investigated further.

**Insight 3: Line 3 has the lowest OTP during the years it was running (2014 - 2023)**

The OTP for Line 3 ranges from 41%-59%, which is extremely low compared to the OTP range from other TTC lines (70%-93%), and is 31%-49% lower than the targeted KPI of 90%. This suggests that this TTC Line was experiencing significant delay issues on a year to year basis, heavily struggling to meet the KPI Target of 90%, which supports the company's decision to permanently shut down the line in July 2023.

**Insight 4: Disruption rate is significantly high on weekends and on times between 8pm and 1am on weekdays**

Disruption rate in these specific times and days range from 50% to 82%, which suggests that the riders are not able to rely on the service during these times, and they are likely to find a different method of transportation. This also suggests that there may be crew availability issues during these times, causing the delay issues to get resolved slower.


[pct_line_delays / pct_station_delays

severity_consistency_ratio

Weekday delay consistency analysis

OTP is being met from 2014 - 2019 for Lines 1 & 2, but struggles to meet it from 2020 onwards. This suggests that the COVID-19 affected the performance of TTC ??...
delays are more prominent during peak hour windows]

---

## 10. Recommendations

<!--
  Action-oriented. Addressed to a real audience.
  Tied explicitly to the insight that supports each one.

  WHAT GOOD LOOKS LIKE:
  Priority: High
  Recommendation: "Conduct a fulfilment audit for home goods deliveries
                   in Region A - specifically investigating whether returns
                   correlate with a particular warehouse, carrier, or SKU batch."
  Based On: Insight 1 - return rate anomaly in Region A
  Owner: Operations / Supply Chain team

  WHAT TO AVOID:
  ❌ "Improve the return rate."
     (Not actionable. Doesn't say who, how, or where to start.)
  ❌ "Further analysis is needed."
     (This is a placeholder, not a recommendation.)
-->

| Priority | Recommendation | Based On | Suggested Owner |
|----------|---------------|----------|-----------------|
| High | Conduct inspection and maintenance reviews on the top 34% of trains by total delay minutes - specifically investigate if they're causing significant delay issues on a year to year basis, and whether they need to be repaired or replaced | Insight 2: Roughly a third of TTC vehicles account for most delays | Head of Operations |
| Medium | Schedule more trains more frequently on weekends, and on weekdays between 8pm and 1am - specifically on lines and directions with highest disruption rates during these timeframes | Insight 4: Disruption rate is significantly high on weekends and on times between 8pm and 1am on weekdays | Head of Transit Planning |
| Low | Develop public-facing messaging and awareness campaigns regarding expected delays on a daily basis due to rider misconduct - include offering travel incentives or loyalty rewards for frequent riders affected by this delay cause | Insight 1: Disorderly patron explains TTC's frequent delays | Head of Marketing |

Note: Priority reflects both delay severity and operational controllability — outside-control causes are assigned lower priority because the improvement initiatives are limited to communication and mitigation rather than operational.

---

## 11. Assumptions & Limitations

<!--
  WHAT GOOD LOOKS LIKE:
  Assumption: "Transaction records were assumed to be complete for all five regions.
               No validation was performed against source system record counts."
  Limitation: "The analysis cannot distinguish between returns initiated by
               the customer vs. returns initiated by the business (e.g., recalls).
               If business-initiated returns are concentrated in Region A, the
               return rate finding may reflect a policy decision, not a quality issue."

  WHAT TO AVOID:
  ❌ Leaving this section blank or writing "None known."
     Every project has limitations. Documenting them is a sign of
     analytical maturity - not a confession of failure.
-->

### Assumptions
- [What did you treat as true without being able to verify?]
- [What simplifications did you make for scope or feasibility?]
- [What domain rules or definitions did you accept as given?]

- **`min_delay = 0` records were treated as non-events** — records where 
`min_delay = 0` were excluded from all delay analyses on the assumption 
that they do not represent delay incidents. These may reflect 
on-time arrivals logged in the system rather than actual delays.

- **The 8-minute service gap threshold was treated as the on-time benchmark** 
— based on TTC's published definition that a train is considered on time 
if it arrives within 1.5 times its scheduled headway. Assuming a standard 
5-minute headway, 1.5 × 5 = 7.5 minutes, rounded up to 8 minutes. This 
threshold was applied consistently across all disruption rate and OTP 
calculations.

- **`min_gap = 0` records were treated as evaluable service intervals** — 
after investigating the distribution of zero-gap records across hours of 
the day, their pattern mirrored overall delay volume rather than clustering 
at service start times, suggesting they represent normal service intervals 
rather than system resets or data artifacts. They were retained in OTP 
calculations accordingly.

- **Delay reason classifications were accepted as given from the TTC code 
description reference table** — the `control_level` classification 
(`within_control`, `partial_control`, `outside_control`) assigned to each 
delay code was treated as accurate without independent verification. These 
classifications directly influenced prioritization and improvement initiative 
analyses.

- **Weekday analysis excluded Saturday and Sunday throughout** — peak period 
and consistency analyses were scoped to Monday–Friday on the assumption that 
weekday commuter patterns are the primary planning concern. Weekend service 
patterns were analyzed separately where relevant.

- **The top-ranked delay cause per partition was treated as the dominant cause** 
— where `RANK() = 1` was used to identify the most common delay cause per 
station, hour, or day, ties were included (RANK rather than ROW_NUMBER). 
In practice, ties at rank 1 are rare but were not explicitly handled.

### Limitations
- [What gaps exist in the data?]
- [What analysis was out of scope but could affect interpretation?]
- [What would a more rigorous version of this project include?]
- [Are there known biases in the data source or collection method?]

- **No external validation of delay records against TTC operational logs** — 
the dataset was sourced from Open Toronto and accepted at face value. There 
was no way to verify whether all delay incidents were captured, whether 
records were complete, or whether reporting practices changed over the 
January 2014–April 2025 period in ways that could affect trend comparisons.

- **Line 3 Scarborough records post-July 24, 2023 were not excluded from 
all analyses** — Line 3 was permanently shut down following a derailment 
on July 24, 2023. Three records with Line 3 as the TTC line dated after 
this date were identified and excluded from KPI calculations in Tableau, 
but were retained in MySQL query results as the discrepancy was discovered 
after queries and dashboards were completed. This has minimal impact given 
the small record count but is noted for transparency.

- **Vehicle-level analysis cannot confirm whether the same physical vehicle 
is consistently problematic year over year** — the query identifies vehicles 
with the highest cumulative delay by vehicle number, but does not track 
whether those vehicle numbers recur across multiple years. A vehicle 
retired and replaced with the same number would appear as one continuous 
record.

- **`min_gap` as a service regularity proxy has known limitations** — 
the 8-minute gap threshold was derived from a standard headway assumption 
and may not accurately reflect scheduled headways for all lines, times, 
and service periods. Lines with longer scheduled headways (e.g. late night 
service) would be disproportionately flagged as disruptive under a fixed 
8-minute threshold.

- **Disruption rate calculations do not account for service frequency** — 
a route running every 3 minutes and a route running every 12 minutes are 
both assessed against the same 8-minute threshold, even though the 
operational impact of an 8-minute gap differs significantly between them.

- **The analysis cannot distinguish between delay causes that were accurately 
coded at the time vs. coded generically** — codes like "miscellaneous other" 
and "paa - no trouble found" suggest some incidents were logged without a 
confirmed cause. These records were included in frequency counts but may 
mask the true prevalence of more specific delay causes.

- **On-time performance comparisons to other transit authorities are 
approximate** — TTC's OTP methodology (headway adherence at end terminals) 
differs from methodologies used by other agencies such as NYC MTA (schedule 
adherence per stop). Direct percentage comparisons should be interpreted 
with caution rather than taken as precise benchmarks.

- **A more rigorous version of this project would include** — ridership 
volume data to weight delay impact by the number of passengers affected; 
weather data to isolate seasonal or weather-driven delay patterns; and 
real-time headway data at intermediate stations rather than end terminals 
only, which would give a more complete picture of service regularity 
experienced by riders mid-route.

> *The goal here is pre-emptive Q&A. What would a thoughtful skeptic push back on? Document the answer here, before they ask.*

---

## 12. Future Enhancements

<!--
  WHAT GOOD LOOKS LIKE:
  ✅ "Automate the monthly data pull from the POS export folder using
      a scheduled Python script, replacing the current manual process."
  ✅ "Expand the return rate analysis to include carrier-level data,
      which was unavailable in this dataset but exists in the logistics system."

  WHAT TO AVOID:
  ❌ "Add a machine learning model."
     (Vague, and disconnected from the actual findings of this project.)
  ❌ Listing aspirational features that don't follow logically from the work.
-->

- [ ] [Enhancement 1 - specific and traceable to a real gap in this project]
- [ ] [Enhancement 2]
- [ ] [Enhancement 3]
- [ ] [Enhancement 4]


- [ ] **Incorporate ridership volume data** — delay impact is currently 
measured by duration and frequency, but not by how many passengers were 
affected. Joining Open Toronto's TTC ridership data to the delay dataset 
would allow disruption rate and service gap metrics to be weighted by 
passenger volume, making prioritization recommendations significantly 
more precise. A 10-minute delay at Kennedy Station during AM Peak affects 
far more riders than the same delay at Ellesmere at midnight.

- [ ] **Add weather data as an explanatory variable** — several delay 
causes (track-level incidents, signal issues, door problems) may be 
seasonally driven but this cannot be confirmed from the current dataset 
alone. Joining historical weather data (temperature, precipitation, 
snowfall) from Environment Canada to the delay records by date would 
allow seasonal and weather-driven delay patterns to be isolated from 
structural ones, strengthening the root cause analysis.

- [ ] **Automate monthly data ingestion from Open Toronto** — the current 
workflow requires manually downloading updated delay CSV files from the 
Open Toronto data portal and re-running the Power Query consolidation 
and MySQL cleaning steps. This could be replaced with a scheduled Python 
script that pulls the latest monthly file from the Open Toronto API, 
appends it to the staging table, and triggers a refresh of the Tableau 
dashboard — removing the manual step entirely and keeping the analysis 
current without intervention.

- [ ] **Track vehicle-level delay patterns year over year** — the current 
vehicle analysis identifies which vehicles have the highest cumulative 
delay but cannot confirm whether the same vehicles are chronic offenders 
across multiple years. Adding a year dimension to the vehicle query and 
building a Tableau view that tracks each vehicle's ranking over time 
would allow the operational audit recommendation to be validated — 
confirming whether flagged vehicles are genuinely deteriorating or 
whether high totals reflect high utilization rather than poor condition.

- [ ] **Refine the on-time performance calculation using line-specific 
headway data** — the current OTP metric applies a fixed 8-minute gap 
threshold uniformly across all lines, times, and service periods. A more 
accurate calculation would apply each line's actual scheduled headway 
(which varies by time of day and day of week) as the threshold, rather 
than a single system-wide assumption. TTC publishes scheduled headways 
in their GTFS feed, which could be joined to the delay dataset to produce 
a headway-adjusted OTP metric that more accurately reflects the rider 
experience on each line.

- [ ] **Expand the analysis to include bus and streetcar delay data** — 
the current project is scoped to subway delays only. Open Toronto also 
publishes delay data for TTC bus and streetcar routes, which would allow 
cross-modal comparisons and a more complete picture of system-wide 
reliability. This would be particularly valuable for the marketing 
dashboard, where riders on surface routes connecting to affected subway 
stations may experience compounding delays not captured in the current 
analysis.

---

## 13. Deliverables

| Deliverable | Description | Location |
|-------------|-------------|----------|
| [Name] | [What it contains] | [`/path/to/file`] |
| [Name] | [What it contains] | [`/path/to/file`] |
| [Name] | [What it contains] | [`/path/to/file`] |

---

## 14. Author

**Francine Sangil** <br> current role: Team Leader, Fund Accounting at CIBC Mellon <br>target role: Data Analyst

- 🔗 www.linkedin.com/in/francinesangil
- 💼 https://github.com/fransan33
- 📧 sangilfrancine@gmail.com

---

*Last updated: [August 2026]*
