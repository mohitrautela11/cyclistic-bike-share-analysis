# Cyclistic Bike-Share Usage Analysis: Converting Casual Riders into Annual Members

**End-to-End Data Analytics Case Study** | **Tools:** SQL Server (T-SQL), Microsoft Excel, Tableau Desktop, Executive Presentation

**Dataset:** 12 Months of Chicago Bike-Share Trip Data (`202511-divvy-tripdata.csv` to `202610-divvy-tripdata.csv`) | **6,130,248 Verified Rides**

---

## 1. Executive Summary & Business Problem

**Cyclistic** is a Chicago-based bike-share company operating a fleet of over 5,800 bicycles across 692 docking stations. While the company offers single-ride passes, full-day passes (**Casual riders**), and **Annual memberships**, internal financial analysis shows that **annual members are significantly more profitable** than casual riders.

### The Core Business Question

> *"How do annual members and casual riders use Cyclistic bikes differently, and how can marketing convert high-intent casual riders into recurring annual members?"*

### Key Project Outcome

By consolidating and cleaning **6,294,451 raw trip records** across 12 monthly CSV files down to **6,130,248 verified rides**, I identified clear behavioral differences between **commuter-driven annual members (64.73%)** and **leisure-driven casual riders (35.27%)**. These findings led to **three targeted conversion initiatives** designed to convert high-intent weekend, summer, and classic-bike casual riders into recurring annual members.

---

## 2. Repository Structure

This repository contains every stage of the project, organized into clean folders from raw data files to the final executive briefing:

```text
cyclistic-bike-share-analysis/
├── README.md                                  # Complete project documentation
├── raw_data/                                  # 12 monthly source CSV files (Nov 2025 – Oct 2026)
│   ├── 202511-divvy-tripdata.csv
│   ├── 202512-divvy-tripdata.csv
│   ├── 202601-divvy-tripdata.csv
│   ├── 202602-divvy-tripdata.csv
│   ├── 202603-divvy-tripdata.csv
│   ├── 202604-divvy-tripdata.csv
│   ├── 202605-divvy-tripdata.csv
│   ├── 202606-divvy-tripdata.csv
│   ├── 202607-divvy-tripdata.csv
│   ├── 202608-divvy-tripdata.csv
│   ├── 202609-divvy-tripdata.csv
│   └── 202610-divvy-tripdata.csv
├── sql/                                       # SQL Server (T-SQL) ETL & analytical queries
│   ├── 01_create_database_and_raw_table.sql   # Creates CyclisticDB and dbo.trips_raw staging schema
│   ├── 02_bulk_insert_12_months.sql           # Cursor-based BULK INSERT across all 12 CSV files
│   ├── 03_data_quality_audit.sql              # Checks duplicates, null timestamps, and duration outliers
│   ├── 04_data_cleaning_and_transform.sql     # Builds dbo.trips_clean with engineered time features
│   ├── 05_exploratory_analysis_queries.sql    # Queries volume, duration, weekday, hourly & bike trends
│   └── 06_tableau_summary_aggregation.sql     # Generates 8,063-row dbo.tableau_summary table
├── processed_data/
│   └── cyclistic_tableau_summary.csv          # Exported 8,063-row aggregated dataset feeding Tableau
├── tableau/
│   └── CyclisticBikeAnalysis.twbx             # Interactive Tableau dashboard workbook
├── presentation/
│   └── Cyclistic_Stakeholder_Briefing.html    # 10-slide executive presentation for leadership
└── assets/
    └── dashboard_preview.png                  # Full Tableau dashboard screenshot
```

---

## 3. Data Pipeline & Methodology (SQL Server + Excel)

Because combining 12 monthly Divvy files produces **6,294,451 raw rows**, processing everything directly in Excel causes severe performance limits. I built a 6-step **SQL Server (`CyclisticDB`)** pipeline to ingest, audit, clean, and aggregate the data before validating summary metrics in Excel and visualizing in Tableau.

### Step 1: Database Setup & Automated Ingestion (`01` & `02`)

* Created `CyclisticDB` and the staging table `dbo.trips_raw` with 13 raw columns (`ride_id`, `rideable_type`, `started_at`, `ended_at`, station names/IDs, coordinates, and `member_casual`).
* Automated ingestion of all 12 CSV files (`202511-divvy-tripdata.csv` through `202610-divvy-tripdata.csv`) using a T-SQL `CURSOR` and `BULK INSERT`.

### Step 2: Data Quality Audit & Cleaning (`03` & `04`)

* **Deduplication:** Used `ROW_NUMBER() OVER (PARTITION BY ride_id ...)` to remove **35 duplicate `ride_id` entries** and enforce a primary key constraint.
* **String & Null Handling:** Stripped enclosing quotes and replaced blank station names with `'On-Street / No Station'` so valid dockless e-bike trips were preserved.
* **Duration Filtering:** Engineered `ride_length_sec` and `ride_length_min`, removing invalid records (`<= 0` seconds), false starts under 1 minute (`< 60` seconds), and extreme outliers over 24 hours (`> 86,400` seconds).
* **Feature Engineering:** Extracted `day_of_week` (1 = Sunday to 7 = Saturday), `day_name`, `month_num`, `month_name`, and `start_hour` (0–23).
* **Clean Production Table (`dbo.trips_clean`):** **6,130,248 verified trips** (**3,967,964 Member** | **2,162,176 Casual**).

### Step 3: Exploratory Analysis & BI Aggregation (`05` & `06`)

* Ran segmented T-SQL queries across user type, weekday, month, start hour, and bike type to establish core behavioral benchmarks.
* Built `dbo.tableau_summary`—excluding minor October 31 spillover rows—and exported the **8,063-row** `cyclistic_tableau_summary.csv` file, cross-checking totals and weighted average durations in Excel before connecting Tableau.

---

## 4. Key Analytical Findings

| Behavioral Dimension | Annual Members (`64.73%` / `3,967,964`) | Casual Riders (`35.27%` / `2,162,176`) | Strategic Takeaway |
| :--- | :--- | :--- | :--- |
| **Weekly Ride Volume** | Peaks **Tue–Thu** (`614K–647K` daily) | Surges **Sat–Sun** (`464K` Sat, `350K` Sun) | Members ride for weekday work commutes; Casuals ride for weekend leisure. |
| **Average Trip Duration** | Consistent **`12.1 min`** (`11.6 min` Wed) | **50% longer at `18.0 min`** (`20.7 min` Sun) | Casual riders incur higher per-minute and single-pass fees on extended rides. |
| **Hourly Demand Curve** | Sharp spikes at **8:00 AM** & **5:00 PM (`426K`)** | Gradual afternoon build peaking at **5:00 PM (`204K`)** | The **8:00 AM – 5:00 PM** workday window clearly defines annual member commuting. |
| **Monthly Seasonality** | Steady year-round (`109K` Jan to `511K` Aug) | **14x seasonal surge** (`24K` Jan to `346K` Jul) | **May – September** is the highest-leverage window for conversion campaigns. |
| **Bike Type Split** | E-bikes lead volume (`11.4 min` avg) | Classic bikes average **`28.6 min`** (vs. `13.8 min` member) | Classic bikes are strongly preferred for longer recreational rides. |

---

## 5. Tableau Dashboard & Executive Presentation

### Interactive Tableau Workbook (`tableau/CyclisticBikeAnalysis.twbx`)

Connected to `cyclistic_tableau_summary.csv` using a weighted average duration calculation (`SUM([total_ride_minutes]) / SUM([total_rides])`) and interactive cross-filtering across all worksheets:

* **Unified Color Palette:** **Cobalt Blue (`#0077B6`)** for Annual Members and **Coral Red (`#E63946`)** for Casual riders across every visual.
* **KPI Summary Cards (`KPI Sheet 1–3`):** Total Annual Rides, Casual vs. Member Share, and Weighted Avg Trip Duration.
* **Five Core Visuals:** `Weekly Ride Volume`, `Weekly Avg Duration`, `Hourly Commute vs. Leisure Curve`, `12-Month Seasonality`, and `Bike Type Preference & Duration`, plus a collapsible month filter on `Dashboard 1`.

### Stakeholder Presentation (`presentation/Cyclistic_Stakeholder_Briefing.html`)

A 10-slide executive decision briefing tailored for Marketing Director **Lily Moreno** and the Cyclistic leadership team, highlighting key focus windows directly on the charts and outlining **three actionable conversion initiatives**:

1. **Weekend-to-Annual Pass Upgrade:** Credit Sunday pass spend toward an annual membership after a rider's second weekend trip (`814K` weekend casual rides).
2. **May–September Digital Blitz:** Concentrate Q2/Q3 geo-fenced ads around Lakefront Trail, Millennium Park, and Navy Pier during the `14x` summer surge.
3. **45-Minute Classic Bike Member Perk:** Emphasize unlimited 45-minute classic bike rides in membership onboarding to convert casual classic riders averaging `28.6 minutes` per trip.

---

## Author

* **Mohit Rautela**
* **Tools Used:** SQL Server (T-SQL) | Microsoft Excel | Tableau Desktop | Executive Stakeholder Presentation
