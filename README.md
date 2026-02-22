# Healthcare Claims Cost & Profitability Analysis

## Project Overview

This project addresses a critical business challenge for a health insurance company experiencing significant financial losses. As a Data Analyst, the objective was to perform a deep dive into synthetic healthcare claims data to identify "cost leakage"—areas where spending is disproportionately high or inefficient.

The analysis provides a data-driven roadmap for C-Level Executives to pinpoint high-cost procedures, diagnosis-driven spend, and high-utilizer member segments, ultimately aiming to steer the company back toward profitability.

## The Dataset

The analysis is based on two primary relational tables:

### 1. Claims Table (`claims.csv`)

* `claim_id`: Unique identifier for each claim.
* `member_id`: Link to the member demographics.
* `claim_type`: Category of service (Inpatient, Outpatient, ER, Pharmacy, Lab).
* `cpt_code`: Current Procedural Terminology (The "What" was done).
* `icd_code`: International Classification of Diseases (The "Why" it was done).
* `billed_amount`: The sticker price charged by the provider.
* `paid_amount`: The actual amount reimbursed by the insurer.

### 2. Members Table (`members.csv`)

* `member_id`: Unique identifier for each insured individual.
* `member_age` / `member_gender`: Demographic context.
* `plan_type`: The insurance product (HMO, PPO, EPO, POS).
* `enrollment_dates`: Member tenure information.

---

## Technical Workflow & Thought Process

### Phase 1: Macro Cost Breakdown

**Goal:** Identify the most expensive claim categories.

* **Thought Process:** I started with the "big picture" to see if losses were concentrated in specific service types. By ranking `total_paid_amount`, we identified whether high-volume services (like Pharmacy) or high-cost services (Inpatient) were the primary drivers.

### Phase 2: Operational Drivers (CPT & ICD)

**Goal:** Identify specific medical procedures and diagnoses driving costs.

* **Thought Process:** I analyzed the Top 10 codes by total spend and average cost per claim. This distinguishes between "Frequent/Routine" costs and "Catastrophic/Rare" costs, allowing for targeted medical management strategies.

### Phase 3: High-Utilizer Analysis

**Goal:** Identify "Power Users" within the membership.

* **Thought Process:** Healthcare costs often follow the Pareto Principle (80/20 rule). I isolated the top 5-10 highest-cost members to see if their spending was driven by chronic illness (high volume of pharmacy/outpatient) or acute events (large inpatient stays).

### Phase 4: Financial Efficiency (Billed vs. Paid)

**Goal:** Evaluate the effectiveness of provider contracts.

* **Thought Process:** I calculated the `Paid Ratio` (Paid / Billed). A ratio close to 1.0 indicates a lack of negotiated discounts, which is a major contributor to financial "bleeding." This identifies specific providers or CPT codes that require contract renegotiation.

### Phase 5: Demographic & Plan Performance

**Goal:** Evaluate profitability by age group and insurance plan.

* **Thought Process:** By joining demographic data, we determined if certain plan types (e.g., PPO) or age groups (e.g., 56+) were underpriced relative to their medical consumption.

---

## Key Findings & Strategic Recommendations

* **Contract Inefficiency:** Specific high-acuity Inpatient procedures showed a `Paid Ratio` exceeding 0.90, suggesting the company is paying near "retail" prices. **Recommendation:** Target these specific hospital contracts for renegotiation.
* **High-Utilizer Concentration:** A small segment of the 45-60 age group accounts for a disproportionate share of the total spend. **Recommendation:** Implement proactive Disease Management programs for these members to reduce ER and Inpatient visits.
* **Service Leakage:** Outpatient and Pharmacy costs are high in volume but show better negotiated discounts than Lab services. **Recommendation:** Direct members toward preferred Lab providers with lower negotiated rates.

---

## Tech Stack

* **SQL:** Used for all data cleaning, complex joins, feature engineering (age binning), and financial metric calculations.
* **Tableau:** Used to create an executive-level dashboard featuring KPI BANs (Big Angry Numbers), Billed vs. Paid bullet graphs, and member utilization scatter plots.
* **Data Preparation:** Python was utilized to generate a consolidated "Master Analytics Table" for seamless BI integration.

---

## How to Use This Repository

1. **SQL Analysis:** Navigate to `/sql_scripts` to view the full query logic and analyst annotations.
2. **Data Source:** The master dataset used for visualization is available in `tableau_healthcare_analysis.csv`.
