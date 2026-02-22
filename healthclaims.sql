/*
================================================================================
PROJECT: Healthcare Claims Cost & Profitability Analysis
ROLE: Lead Data Analyst
BUSINESS PROBLEM: 
   The insurance company is experiencing significant financial losses. 
   This analysis identifies "cost leakage" by examining claim types, 
   high-cost procedures (CPT), diagnosis codes (ICD), and member utilization.

OBJECTIVES:
   1. Identify which claim types (Inpatient, ER, etc.) drive the highest spend.
   2. Pinpoint the top 10 most expensive CPT and ICD codes.
   3. Isolate high-cost members to understand their service consumption.
   4. Analyze the Paid-to-Billed ratio to identify pricing inefficiencies.

DATASET: Synthetic Claims Data (Demographics, Claims, ICD/CPT Codes, Financials)
TOOLS: SQL (Data Extraction), Tableau (Visualization)
================================================================================
*/

-- Step 1: Claim Type Cost Breakdown
-- Purpose: To see which broad categories of care are the most expensive.
select *
from claims;
-- -----------------------------------------------------------------------------
-- 1. CLAIM TYPE COST BREAKDOWN
-- Objective: Rank claim types by total paid amount to identify top cost drivers.
-- -----------------------------------------------------------------------------

SELECT 
    claim_type,
    COUNT(claim_id) AS total_claims,
    SUM(billed_amount) AS total_billed_amount,
    SUM(paid_amount) AS total_paid_amount,
    -- Calculating the average paid per claim for extra context
    ROUND(SUM(paid_amount) / COUNT(claim_id), 2) AS avg_paid_per_claim
FROM 
    claims 
GROUP BY 
    claim_type
ORDER BY 
    total_paid_amount DESC;

-- i included avg_paid_per_claim because a claim type might have a low total cost but very high per_visit cost,
-- which could indicate expensive specialty care that needs closer monitoring 


-- -----------------------------------------------------------------------------
-- 2. CPT & ICD COST DRIVERS
-- Objective: Identify the specific procedures (CPT) and diagnoses (ICD) 
-- that account for the highest total spending.
-- -----------------------------------------------------------------------------

-- Find the top 10 CPT codes by total paid amount
SELECT 
    icd_code,
    COUNT(claim_id) AS claim_count,
    SUM(paid_amount) AS total_paid_amount,
    -- Identifying high-cost procedures via average
    ROUND(SUM(paid_amount) / COUNT(claim_id), 2) AS avg_paid_per_claim
FROM 
    claims
GROUP BY 
    icd_code
ORDER BY 
    total_paid_amount DESC
LIMIT 10;

-- Find the top 10 ICD codes by total paid amount
SELECT 
    icd_code,
    COUNT(claim_id) AS claim_count,
    SUM(paid_amount) AS total_paid_amount
FROM 
    claims
GROUP BY 
    icd_code
ORDER BY 
    total_paid_amount DESC
LIMIT 10;

/* ================================================================================
PHASE 2 ANALYST INSIGHT: OPERATIONAL COST DRIVERS
================================================================================
While Phase 1 identified *where* we spend (Claim Type), Phase 2 identifies *what* we are paying for (Procedures & Diagnoses). 

KEY METRICS & STRATEGIC VALUE:
1. VOLUME VS. VALUE: 
   - High Total Paid + High Claim Count = "Routine High Costs" (e.g., standard labs). 
     Strategy: Renegotiate bulk contracts with high-volume labs.
   - High Total Paid + Low Claim Count = "Catastrophic Costs" (e.g., rare surgeries). 
     Strategy: Review medical necessity and prior authorization protocols.

2. PRICE VARIANCE:
   - By calculating 'avg_paid_per_claim', we can identify CPT codes that are 
     disproportionately expensive compared to industry benchmarks.

3. CLINICAL FOCUS:
   - Top ICD codes reveal the primary health conditions driving company losses 
     (e.g., Chronic Kidney Disease vs. Acute Trauma). This informs whether the 
     company should invest in specialized "Disease Management" programs.
================================================================================
*/

-- -----------------------------------------------------------------------------
-- 4. BILLED VS. PAID RATIO ANALYSIS
-- Objective: Identify pricing inefficiencies by comparing the amount 
-- charged vs. the amount actually paid.
-- -----------------------------------------------------------------------------

-- Analysis by Claim Type
SELECT 
    claim_type,
    ROUND(AVG(paid_amount / billed_amount), 4) AS avg_paid_ratio,
    SUM(billed_amount) AS total_billed,
    SUM(paid_amount) AS total_paid
FROM 
    claims
WHERE 
    billed_amount > 0 -- Avoid division by zero
GROUP BY 
    claim_type
ORDER BY 
    avg_paid_ratio DESC;

-- Analysis by Provider (Top 10 by Spend)
-- This identifies which doctors/hospitals we are paying the highest % to.
SELECT 
    provider_id,
    COUNT(claim_id) AS claim_count,
    ROUND(AVG(paid_amount / billed_amount), 4) AS avg_paid_ratio,
    SUM(paid_amount) AS total_paid
FROM 
    claims
WHERE 
    billed_amount > 0
GROUP BY 
    provider_id
HAVING 
    COUNT(claim_id) > 5 -- Focusing on providers with significant volume
ORDER BY 
    avg_paid_ratio DESC
LIMIT 10;
/* ================================================================================
PHASE 4 ANALYST INSIGHT: CONTRACTUAL LEVERAGE & RATIOS
================================================================================
This analysis measures the effectiveness of our provider network contracts. 

KEY METRICS & STRATEGIC VALUE:
1. THE "IDEAL" RATIO: 
   - Typically, insurance companies aim for a ratio between 0.30 and 0.60. 
   - A ratio of 1.0 (100%) suggests we are paying "Retail" prices, which is a 
     major reason for losing money. This often happens in Pharmacy or out-of-network ER visits.

2. PROVIDER NEGOTIATION:
   - If 'Provider_A' has a ratio of 0.80 and 'Provider_B' (doing the same work) 
     has a ratio of 0.40, the company is "bleeding money" by directing members 
     to Provider_A. 
   - Strategy: Steer members toward "High-Value" (low-ratio) providers.

3. OUTLIER DETECTION:
   - Claim types with a ratio of 0.00 indicate "Denied Claims." While this saves 
     money, high denial rates can lead to legal issues or member dissatisfaction.
================================================================================
*/
-- -----------------------------------------------------------------------------
-- 5. DEMOGRAPHIC & PLAN-TYPE ANALYSIS
-- Objective: Determine if specific member segments or plan types 
-- are contributing to the financial losses.
-- -----------------------------------------------------------------------------

-- Query 5A: Cost by Plan Type
-- Purpose: See if one plan (e.g., HMO) is significantly more expensive than others.
SELECT 
    m.plan_type,
    COUNT(DISTINCT m.member_id) AS total_members,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.paid_amount) AS total_paid,
    ROUND(SUM(c.paid_amount) / COUNT(DISTINCT m.member_id), 2) AS cost_per_member
FROM 
    members m
LEFT JOIN 
    claims c ON m.member_id = c.member_id
GROUP BY 
    m.plan_type
ORDER BY 
    cost_per_member DESC;

-- Query 5B: Cost by Age Group and Gender
-- Purpose: Identify high-risk demographic segments.
SELECT 
    m.member_gender,
    CASE 
        WHEN m.member_age < 30 THEN '18-29'
        WHEN m.member_age BETWEEN 30 AND 45 THEN '30-45'
        WHEN m.member_age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '61+' 
    END AS age_bucket,
    SUM(c.paid_amount) AS total_spend,
    ROUND(AVG(c.paid_amount), 2) AS avg_claim_cost
FROM 
    members m
JOIN 
    claims c ON m.member_id = c.member_id
GROUP BY 
    m.member_gender, age_bucket
ORDER BY 
    total_spend DESC;
    
    
/* ================================================================================
PHASE 5 ANALYST INSIGHT: DEMOGRAPHIC & PLAN PERFORMANCE
================================================================================
This analysis moves beyond 'what happened' to 'who is involved,' which is 
critical for setting next year's insurance premiums.

KEY METRICS & STRATEGIC VALUE:
1. PLAN TYPE PROFITABILITY: 
   - If the 'cost_per_member' for PPO plans is double that of HMO plans, the 
     company may need to adjust PPO premiums or increase co-pays to offset the 
     "bleeding."

2. AGE-BASED RISK:
   - High spending in the 61+ bucket is expected, but high spending in the 
     18-29 bucket is a red flag. It often indicates high Emergency Room (ER) 
     usage for non-emergencies, which is a massive cost-saving opportunity 
     through member education.

3. UNDER-UTILIZATION:
   - By using a LEFT JOIN from 'members' to 'claims', we can identify members 
     with ZERO claims. While they appear "profitable," they may be at risk of 
     churning (leaving the plan) because they aren't using the benefits they 
     pay for.
================================================================================
*/
