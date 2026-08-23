# TTC Subway Delay 
> *This project focused on analyzing the TTC Subway Delay dataset dated between January 2014 and April 2025, to determine whether the main causes of delays are within TTC's operation control and can be prevented by prioritizing improvement initiatives*

---

## ⚙️ Project Type Flags
> *Check what applies. This helps reviewers and collaborators understand the nature of the work at a glance. Delete this block before publishing.*

- [x] SQL Analysis / Querying
- [x] Dashboard / Data Visualization
- [x] Data Pipeline / ETL
- [ ] Predictive Modelling / Machine Learning
- [x] Data Cleaning / Wrangling
- [ ] End-to-End (multiple of the above)

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Objectives](#2-objectives)
3. [Project Scope & Tools](#3-project-scope--tools)
4. [Repository Structure](#4-repository-structure)
5. [Data Workflow](#5-data-workflow)
6. [Data Model & Schema](#6-data-model--schema)
7. [ERD - Entity Relationship Diagram](#7-erd--entity-relationship-diagram) *(SQL projects)*
8. [Analysis & Metrics](#8-analysis--metrics)
9. [Key Insights](#9-key-insights)
10. [Recommendations](#10-recommendations)
11. [Assumptions & Limitations](#11-assumptions--limitations)
12. [Future Enhancements](#12-future-enhancements)
13. [Deliverables](#13-deliverables)
14. [Author](#14-author)

---

## 1. Project Overview

The TTC Subway System has been receiving an ongoing negative feedback through word of mouth and online forums, and I, myself, have experienced delays a few times whilst taking the TTC Subway transit. This begs the question - what are the root causes of these frequent delays, and can they be prevented? This project explored over 10 years of delays data across the TTC Subway to determine whether underperformance was driven by factors that are within the system's control or outside the system's control. The analysis revealed that the highest delay count and total delay minutes across the system is caused by a delay reason that is not within TTC's control.

## 2. Objectives

- **Primary Objective:** Determine whether the frequent delays in TTC Subway System correlates with reasons that are controllable (i.e. vehicle issues, crew availability)
- **Secondary Objective 1:** Identify the specific times or days when service reliability drops 
- **Secondary Objective 2:** Build improvement initiatives to lessen the occurrence of delays root causes and its operational impact
- **Secondary Objective 3:** [Remove if not applicable]

> 💡 *Every analysis decision in this project traces back to one of these objectives.*

---

## 3. Project Scope & Tools

### Scope

<!--
  WHAT GOOD LOOKS LIKE:
  In Scope: "Transaction-level data for Regions A–E, Jan 2023–Jun 2024.
             Analysis covers revenue, return rates, and product category performance."
  Out of Scope: "Customer demographics and marketing spend data were excluded -
                 demographic data was incomplete for two regions, and marketing
                 data sits in a separate system outside this engagement."

  WHAT TO AVOID:
  ❌ Leaving Out of Scope blank. This is the section that protects your credibility.
     If you don't define the fence, reviewers assume you missed things.
-->

| Dimension | Details |
|-----------|---------|
| **In Scope** | Delay data across all 4 TTC Subway Lines, Jan 2014 - Apr 2025, & delay codes. Analysis covers delay frequency, delay trends, delay times, and delay causes  |
| **Out of Scope** | Delay data from May 2025 - Dec 2025 were excluded - the data sets were extracted and reviewed in Jun 2025 |
| **Time Period** | January 2014 - April 2025 |
| **Granularity** | single delay incident per row, including timestamps, date, day, delay reason, TTC line, station, etc. |

### Tools & Technologies

<!--
  List only what you actually used on this project.
  This is not your skills section - it's the project's technical context.
-->

| Category | Tool(s) Used |
|----------|-------------|
| Data Storage | CSV files |
| Data Processing | MySQL, Excel (Power Query), Command Prompt |
| Analysis | custom MySQL queries |
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

<!--
  Show how data moved through your project - from source to output.
  Every transformation decision should be traceable here.

  WHAT GOOD LOOKS LIKE:
  1. Source: "Monthly CSV exports pulled from the internal POS system.
              Five files, one per region, covering Jan 2023–Jun 2024."
  2. Ingestion: "Loaded into Python using pandas. Files concatenated into
                 a single dataframe (approx. 340,000 rows)."
  3. Cleaning: "Removed 1.2% of rows with null transaction IDs.
                Standardised date formats across regional files.
                Resolved product category naming inconsistencies (3 variants → 1)."
  4. Transformation: "Created a returns_rate field at product-category level.
                      Aggregated to weekly and regional grain for trend analysis."
  5. Analysis: "Descriptive statistics, regional comparison, return rate
                segmentation by product category."
  6. Output: "Summary report (PDF), annotated notebook, processed CSV."

  WHAT TO AVOID:
  ❌ "Data was cleaned and analysed." (No chain. No decisions. No trust.)
-->

```
[Data Source(s)]
      ↓
[Ingestion / Collection Method]
      ↓
[Cleaning & Transformation]
      ↓
[Analysis / Modelling / Querying]
      ↓
[Output / Visualisation / Reporting]
```

1. **Source:** Yearly CSV exports & Delay Code Description CSV exports pulled from the Open Data website (https://open.toronto.ca/dataset/ttc-subway-delay-data/).
               Ten files covering Jan 2014 – Apr 2025, and two files containing delays codes, and                   code descriptions.
2. **Ingestion:** Consolidated multiple delay data CSV files (230,841 rows)and the delay codes CSV files into a                      single CSV using Power Query in Excel, and loaded into MySQL using Command Prompt. 
3. **Cleaning:** - subway delay table -
                 Removed trailing white space.
                 Generated unique primary key values.
                 Removed 0.09% of duplicated rows.
                 Converted the time column values into an hourly basis and excluded the minutes.
                 Non-sensical station names in station column (5.66% rows) converted into NULL values as it is a non-critical column.
                 Resolved station name inconsistencies.
                 Removed 0.08% of rows containing nonsensical values in code column.
                 Converted the abbreviated values in bound column into the full name of bounds.
                 Non-sensical values (blanks, random letter, none, numbers) in bound column (26.49% rows) converted into NULL values as it is a non-critical column.
                 Resolved line name inconsistencies.
                 Non-sensical value in vehicle column (vehicle number is zero) (31.58% rows) converted into NULL values as it is a non-critical column
                 Converted non-sensical values (numbers, address, none) in line column (0.35% rows) into NULL values.
                 - code desc table -
                 Removed trailing white space.
                 Removed 0.06% of duplicated rows.   
                 
5. **Transformation:** [What new fields, aggregations, or structures did you create?]
                       Collected code description data from the open toronto data website to decode the abbreviated delay reason on the ttc delay data. Created a reference look up table and mapped it to the cleaned dataset subway delay dataset by creating a VIEW and using a LEFT JOIN, enriching records with delay reason descriptions and operational control level classifications.
                       Collected the subway line names and line numbers from external source and replaced the abbreviated line column in the data set.
                       Collected the subway station names from external source to validate the values in station column and resolve inconsistencies and identify                           non-sensical names.
                       Converted the time column data from VARCHAR -> TIME datatype to be able to analyze the data properly throughout the MySQL queries, as well as through Tableau dashboards.
7. **Analysis:** [What methods - statistical, visual, query-based, model-based?]
                 Yearly KPI, delay trends comparison.
                 Segmenting delay trends by time, station, ttc line, vehicles.
                 Evaluating the operational impact of delays that are within control.
9. **Output/ Visualization:** [What form do the results take?] Tableau Public
                               Developed 4 interactive dashboards targeting 4 distinct stakeholder audiences: Head of Transit Planning, Head of Operations, Senior Management, and Head of Marketing. Included charts are listed below:

Bar charts (most common cause of delay)
Barbell charts (delay frequency by train line and bound)
Bubble charts (delay frequency by station)
Pareto charts (delay cause contribution and vehicle impact)
Dual-axis bar and line charts (peak period analysis & disruptive delay cause analysis)
Year-over-year trend lines (avg delay comparison)
Scatter plots with quadrant annotations (downstream impact and improvement prioritization)
Bullet charts (on-time performance vs. 90% KPI target)
Heatmaps (service reliability by day and hour)


Dashboard design decisions included dynamic parameters for station, hour of day, day of week, & year selection, LOD expressions for consistency metrics, calculated fields for disruption rate and KPI, and dual-axis configurations for layered storytelling.

---

## 6. Data Model & Schema

<!--
  Define your fields so that someone reading your analysis can follow along
  without digging through your code.

  WHAT GOOD LOOKS LIKE (one row example):
  | transaction_id | string | Unique identifier per sales transaction | TXN-00482 |
  | return_flag    | boolean | Whether the transaction included a return | TRUE |
  | region_code    | string | Two-letter identifier for store region | "NE" |

  WHAT TO AVOID:
  ❌ Skipping this section because "the field names are self-explanatory."
     They're not. Not to a reviewer. Not to you in six months.

  📌 FOR SQL PROJECTS: If you have multiple tables, create one block per table.
     Describe join keys and relationships here. Your ERD (Section 7) will
     visualise what this section describes in text.

  📌 FOR NON-SQL PROJECTS: Describe the shape of your dataset informally
     if a formal schema doesn't apply. Even one paragraph is more helpful than nothing.
-->

### Dataset / Table: `ttc_subway_cleaned`

| Field Name | Data Type | Description | Example Value | Nullable (yes/no) |
|------------|-----------|-------------|---------------|----------|
| `row_id` | int | Unique identifier per delay record | 33 | no |
| `date` | date | Date the delay occurred | 2022-01-01 | no |
| `day` | text | Day of week the delay occurred | Saturday | no |
| `cleaned_station` | varchar(27) | Standardized station name after cleaning | Islington | yes |
| `code` | text | Abbreviated delay cause code from TTC | MUIRS | no |
| `min_delay` | int | Duration of delay in minutes (rider-facing) | 0 | no |
| `min_gap` | int | Gap between successive vehicles in minutes | 0 | no |
| `cleaned_bound` | varchar(10) | Standardized direction of travel | Eastbound | yes |
| `cleaned_line` | varchar(23) | Standardized subway line name | Line 2 Bloor-Danforth | yes |
| `cleaned_vehicle` | bigint | 	Vehicle number of the train in operation | 5471 | yes |
| `time_military_hour` | time | Hour of delay in 24hr datetime format | 17:00:00 | no |

> **Row count:** 230,456
> **Date range:** Jan 2014 – Apr 2025
> **Key join / relationship:** [`ttc_subway_cleaned.code` → `code_desc_clean_v2.code`]

### Dataset / Table: `code_desc_clean_v2`

| Field Name | Data Type | Description | Example Value | Nullable (yes/no) |
|------------|-----------|-------------|---------------|----------|
| `row_id` | int | Unique identifier per delay record | 33 | no |
| `code` | varchar(10) | Abbreviated delay cause code from TTC | ERAC | no |
| `description` | text | 	Full description of delay cause | work zone problems - signals | no |
| `control_level` | varchar(50) | Operational controllability classification | within_control | no |

> **Row count:** 212
> **Key join / relationship:** [ `code_desc_clean_v2.code` → `ttc_subway_cleaned.code`]
---

## 7. ERD - Entity Relationship Diagram
### *(Primarily for SQL Projects - remove this section if not applicable)*

<!--
  An ERD shows how your tables connect to each other visually.
  It is the fastest way for a reviewer to understand the data structure
  of a SQL project without reading every query.

  HOW TO INCLUDE YOUR ERD:
  Option A - Image embed (most common):
    Export your ERD from dbdiagram.io, DBeaver, Lucidchart, or similar.
    Save to /visuals/erd.png and reference it below.

  Option B - dbdiagram.io code block (version-controllable):
    Paste your schema definition code directly in the fenced block below.
    Anyone can paste it into dbdiagram.io to regenerate the visual.

  Option C - Mermaid diagram (renders natively in GitHub):
    Use the mermaid code block syntax below.
    GitHub will render this as a diagram automatically.

  PICK ONE. Don't use all three. Delete the options you don't use.
-->

### Embedded Image
[ERD Diagram](TTC.Subway.Delay_ERD.pdf)
*[Brief caption: e.g., "Two-table schema - ttc_subway_cleaned, and code_desc_cleaned_v2 joined on shared codes."]*

---

**Table Relationships Summary:**

| Relationship | Join Key | Type |
|-------------|----------|------|
| `ttc_subway_cleaned` → `code_desc_cleaned_v2` | `code` | Many-to-One |

---

## 8. Analysis & Metrics

<!--
  Explain what you measured and how - before you share what you found.

  WHAT GOOD LOOKS LIKE:
  Metric: "Customer Return Rate"
  Definition: "Number of transactions flagged as returns divided by total
               transactions, calculated at product-category and regional grain."
  Why It Matters: "Return rate - not sales volume - was hypothesised to
                  explain regional revenue gaps. This metric tests that hypothesis."

  WHAT TO AVOID:
  ❌ Defining a metric only in code: SUM(returns) / COUNT(transaction_id)
     That's an implementation. Write the plain-language definition here.
     Both belong in your project - the definition in the README,
     the implementation in the code.
-->

### Analytical Approach

[Describe how you approached the analysis. Were you exploring patterns? Testing a hypothesis? Building and validating a pipeline? Be honest about your method - exploratory work is valid, just call it that.]

In this project, I used an exploratory, stakeholder-driven approach to have a better understanding of the TTC subway delay patterns. The analysis was structured with 16 business questions that reflect how delay data would be consumed across different 'audiences' within 'a transit industry' - Head of Transit Planning, Head of Operations, Senior Management, and Head of Marketing.

Each question was treated as its own analytical unit: the appropriate grain, metric, and filtering logic were determined independently based on what that specific audience would need to make a decision. For example, the questions under Head of Operations prioritize frequency and controllability of delay causes, while the questions under Head of Marketing prioritize disruption rate and rider-facing reliability — both using the same underlying dataset but through fundamentally different lenses.

There are two 'deliberate' metric distinctions that shaped the entire analysis — min_delay & min_gap. min_delay captures how late a train was (service impact on riders), while min_gap captures the spacing between one train and the next arriving at a station (service impact on operations). These were applied selectively based on whether a question was about rider experience or downstream network impact. Using the wrong metric for a given question would produce a technically correct but analytically misleading result.

It is worth noting that using raw delay counts (delay frequency counts) alone can be misleading since a higher number indicates a higher number of delay incidents. Where the question concerned reliability or risk, disruption rate (proportion of events that are beyond the on-time threshold) was used alongside raw delay counts to give a proportional view.

Lastly, a CREATE VIEW statement was built to capture the LEFT JOIN between the delay records and the code description reference table, avoiding repetition across queries and ensuring consistent mapping of delay reason and control level classifications throughout the analysis.

### Key Metrics Defined

| Metric | Plain-Language Definition | Why It Matters |
|--------|--------------------------|----------------|
| `min_delay` | 	Duration in minutes between a train's scheduled and actual arrival, as experienced by the rider | This is the primary rider-facing severity metric, and is used wherever the question concerns passenger impact rather than operational |
| `min_gap` | Time in minutes between one vehicle and the next arriving at a station | It measures service regularity from an operator perspective, and is used to assess whether a delay caused a wider service disruption |
| `disruption_rate` | Percentage of delay incidents where min_gap exceeded 8 minutes, indicating a service gap beyond the on-time threshold | Helps distinguish manageable delays from those that compound into system-wide problems |
| `avg_disruptive_gap` | 	Average min_gap value among incidents where min_gap > 8, calculated using conditional aggregation to exclude non-disruptive events from the average | Measures how severe the downstream service disruption is when it does occur — a high average indicates more severe downstream impact |
| `total_disruptive_gap` | 	Sum of all min_gap values exceeding 8 minutes | Measures the overall time lost to service gaps across all incidents — a cause that disrupts service moderately but frequently can have a more significant total impact than a rare but severe one |
| `on_time_service_pct` | Percentage of service events where min_gap ≤ 8 minutes | This is the system-wide OTP metric, and is compared against TTC's general standard target of 90% as claimed on their website |
| `pct_line_delays / pct_station_delays` | Each line or station's portion of total system delays, computed using SUM(COUNT(*)) OVER() as the denominator | Identifies disproportionate contributors to system-wide delay volume — used to prioritize stations and lines for marketing and operational attention |
| `severity_consistency_ratio` | 	Average delay severity divided by its standard deviation across weekdays (avg / NULLIF(stddev, 0)), computed via two-level CTE aggregation | Identifies time periods that are not just severe but reliably severe — a high ratio indicates that riders can predict poor service and may seek alternative transportation |
| `control_level` | Classification of each delay cause as within_control, partial_control, or outside_control, sourced from the code description reference table | Filters the improvement analysis to delay causes that TTC has the ability to address operationally |

### Methods Used

- [e.g., Descriptive statistics - distribution, central tendency, outlier detection]
- [e.g., Trend analysis across [time period]]
- [e.g., Segmentation / group comparison by [dimension]]
- [e.g., Correlation analysis between [variable A] and [variable B]]
- [e.g., SQL window functions for [specific aggregation]]
- [e.g., Custom aggregation or transformation logic in [tool]]

Descriptive statistics — delay frequency, average delay duration, and total delay time calculated across multiple dimensions (station, line, bound direction, vehicle, time of day, day of week) to establish delay patterns across the TTC subway network

Top-N ranking per partition in MySQL — RANK() and DENSE_RANK() window functions partitioned by station, time of day, and day of week to surface the single most common delay cause per grouping

Trend analysis (2014–2025) — year-over-year comparison of average delay time using a dynamic current year vs. previous year parameter in Tableau, with monthly trends to identify seasonal patterns and shifts in delay severity

Segmentation by operational controllability — delay causes classified into within_control, partial_control, and outside_control tiers via a reference lookup table, enabling analyses to be filtered by what TTC can realistically act on vs. can't act on due to external factors

Disruption analysis — conditional aggregation using CASE WHEN min_gap > 8 to distinguish delays that remained self-contained from those that caused downstream service gaps exceeding the 8-minute on-time threshold, 'analyzing' disruption rate and total disruptive gap metrics per delay cause

Cumulative contribution analysis in Tableau — running sum of total disruptive gap by delay cause visualized as a Pareto chart in Tableau to identify which causes account for the largest share of cumulative service gap, with an 80% threshold reference line

Weekday delay consistency analysis — identified which hours of the day experience consistently severe delays by using a two-level CTE to first calculate the average delay per hour per day, then measured how much that varied across weekdays using standard deviation. Hours with high average severity and low variation indicates that riders would plausibly adjust their travel behaviour

On-time performance benchmarking — per train line OTP calculated using min_gap ≤ 8 as the on-time threshold, benchmarked against TTC's published 90% KPI target from the 2025 Corporate Plan Mid-Year Progress Report

Vehicle delay distribution analysis — Lorenz curve built in Tableau to show how unevenly delay is distributed across TTC vehicles — roughly a third of the trains accounts for 80% of all delay time, pointing to specific vehicles worth investigating further

Prioritization matrix — scatter plot in Tableau segmenting controllable delay causes into four quadrants (frequent & moderate, frequent & severe, rare but severe, monitor) using average delay time and delay count as axes, to surface both high-volume and high-severity delay causes for improvement initiatives

Service reliability heatmap — disruption rate visualized across a day x hour grid in Tableau to identify specific day and time combinations where service reliability consistently drops, directly addressing to customers

Relative delay share analysis — computed each station and line's percentage contribution to total system delays using partitioned window functions, enabling fair comparisons across locations with different overall volumes rather than relying on raw counts alone


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

**Insight 1: [Short descriptive headline]**
[What you found + what it suggests. One short paragraph.]
Disorderly patron explains TTC's frequent delays.
The overall disruption rate of disorderly patron delay cause is 53.85% - 
Disorderly patron has the highest delay count overall - being the top delay cause in over 60% of ttc stations, 75% of the time throughout the day, and on a daily basis. This points to a delay issue that is not within our control.  

**Insight 2: [Short descriptive headline]**
[What you found + what it suggests.]
KPI?

**Insight 3: [Short descriptive headline]**
[What you found + what it suggests.]
delays are more prominent during peak hour windows

**Insight 4 (if applicable): [Short descriptive headline]**
[What you found + what it suggests.]

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
| High | [Specific, actionable step] | [Insight it comes from] | [Who should act] |
| Medium | [Specific, actionable step] | [Insight it comes from] | [Who should act] |
| Low | [Exploratory or longer-term suggestion] | [Insight it comes from] | [Who should act] |

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

### Limitations
- [What gaps exist in the data?]
- [What analysis was out of scope but could affect interpretation?]
- [What would a more rigorous version of this project include?]
- [Are there known biases in the data source or collection method?]

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

---

## 13. Deliverables

| Deliverable | Description | Location |
|-------------|-------------|----------|
| [Name] | [What it contains] | [`/path/to/file`] |
| [Name] | [What it contains] | [`/path/to/file`] |
| [Name] | [What it contains] | [`/path/to/file`] |

---

## 14. Author

**[Your Name]**
[Your role or title - current or target]

- 🔗 [LinkedIn URL]
- 💼 [Portfolio or GitHub profile URL]
- 📧 [Email - optional]

---

*Last updated: [Month YYYY]*
*If this template helped you, consider starring the repository.*
