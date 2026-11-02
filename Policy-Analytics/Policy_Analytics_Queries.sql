
-- ============================================================
-- INSURANCE ANALYTICS PROJECT
-- POLICY PERFORMANCE ANALYSIS
-- Database: insurance
-- Tool: MySQL
-- ============================================================


-- ============================================================
-- 1. DATABASE CREATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS insurance;

USE insurance;


-- ============================================================
-- 2. DATA CLEANING AND COLUMN RENAMING
-- ============================================================

-- Customer Information

ALTER TABLE policy_customers
RENAME COLUMN `ï»¿Customer ID` TO customer_id;


-- Policy Details

ALTER TABLE policy_details
RENAME COLUMN `ï»¿Policy ID` TO Policy_id;


-- Claims

ALTER TABLE policy_claims
RENAME COLUMN `ï»¿Claim ID` TO Claim_id;


-- Payment History

RENAME TABLE policy_payment_history TO payment_history;

ALTER TABLE payment_history
RENAME COLUMN `ï»¿Payment ID` TO Payment_id;


-- Additional Fields

RENAME TABLE policy_additional_fields TO additional_fields;

ALTER TABLE additional_fields
RENAME COLUMN `ï»¿Agent ID` TO Agent_id;


-- ============================================================
-- 3. CHECK TABLES AFTER DATA CLEANING
-- ============================================================

SELECT * FROM policy_customers;

SELECT * FROM policy_details;

SELECT * FROM policy_claims;

SELECT * FROM payment_history;

SELECT * FROM additional_fields;


-- ============================================================
-- 4. KPI CARDS
-- TOTAL POLICIES / TOTAL CUSTOMERS / TOTAL CLAIM AMOUNT
-- ============================================================

SELECT
    (SELECT COUNT(Policy_id)
     FROM policy_details) AS Total_Policies,

    (SELECT COUNT(DISTINCT customer_id)
     FROM policy_customers) AS Total_Customers,

    (SELECT ROUND(SUM(`Claim Amount`), 2)
     FROM policy_claims) AS Total_Claim_Amount;


-- ============================================================
-- KPI: TOTAL PREMIUM AMOUNT
-- ============================================================

SELECT
    ROUND(SUM(`Premium Amount`), 2) AS Total_Premium
FROM policy_details;


-- ============================================================
-- KPI: TOTAL COVERAGE AMOUNT
-- ============================================================

SELECT
    ROUND(SUM(`Coverage Amount`), 2) AS Total_Coverage
FROM policy_details;


-- ============================================================
-- 5. KPI 1: AGE BUCKET-WISE POLICY COUNT
-- ============================================================

SELECT
    CASE
        WHEN c.Age IS NULL THEN 'Unknown'
        WHEN c.Age < 18 THEN 'Below 18'
        WHEN c.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.Age BETWEEN 46 AND 64 THEN '46-64'
        ELSE '65+'
    END AS Age_Bucket,

    COUNT(p.Policy_id) AS Policy_Count

FROM policy_customers c

JOIN policy_details p
    ON c.customer_id = p.`Customer ID`

GROUP BY Age_Bucket

ORDER BY Policy_Count DESC;


-- ============================================================
-- 6. KPI 2: GENDER-WISE POLICY COUNT
-- ============================================================

SELECT
    c.Gender,
    COUNT(p.Policy_id) AS Policy_Count

FROM policy_customers c

JOIN policy_details p
    ON c.customer_id = p.`Customer ID`

GROUP BY c.Gender

ORDER BY Policy_Count DESC;


-- ============================================================
-- 7. KPI 3: POLICIES EXPIRING IN 2026
-- ============================================================

-- Convert Policy End Date into DATE format

ALTER TABLE policy_details
ADD COLUMN policy_end_date_new DATE;

UPDATE policy_details

SET policy_end_date_new =
    STR_TO_DATE(`policy end date`, '%d-%m-%Y');


-- Count policies expiring in 2026

SELECT
    COUNT(Policy_id) AS Policies_Expiring_2026

FROM policy_details

WHERE policy_end_date_new >= '2026-01-01'
  AND policy_end_date_new < '2027-01-01';


-- ============================================================
-- 8. KPI 4: POLICY TYPE-WISE POLICY COUNT
-- ============================================================

SELECT
    `Policy Type`,
    COUNT(Policy_id) AS Policy_Count

FROM policy_details

GROUP BY `Policy Type`

ORDER BY Policy_Count DESC;


-- ============================================================
-- 9. KPI 5: CLAIM STATUS-WISE CLAIM COUNT
-- ============================================================

SELECT
    `Claim Status`,
    COUNT(Claim_id) AS Claim_Count

FROM policy_claims

GROUP BY `Claim Status`

ORDER BY Claim_Count DESC;


-- ============================================================
-- 10. KPI 6: PAYMENT STATUS-WISE PAYMENT COUNT
-- ============================================================

SELECT
    `Payment Status`,
    COUNT(Payment_id) AS Payment_Count

FROM payment_history

GROUP BY `Payment Status`

ORDER BY Payment_Count DESC;


-- ============================================================
-- 11. ADDITIONAL KPI: POLICY STATUS DISTRIBUTION
-- ============================================================

SELECT
    Status,
    COUNT(Policy_id) AS Policy_Count

FROM policy_details

GROUP BY Status

ORDER BY Policy_Count DESC;


-- ============================================================
-- 12. ADDITIONAL KPI: PAYMENT METHOD-WISE DISTRIBUTION
-- ============================================================

SELECT
    `Payment Method`,
    COUNT(Payment_id) AS Payment_Count

FROM payment_history

GROUP BY `Payment Method`

ORDER BY Payment_Count DESC;


-- ============================================================
-- 13. ADDITIONAL KPI: PAYMENT FREQUENCY-WISE POLICY COUNT
-- ============================================================

SELECT
    `Payment Frequency`,
    COUNT(Policy_id) AS Policy_Count

FROM policy_details

GROUP BY `Payment Frequency`

ORDER BY Policy_Count DESC;


-- ============================================================
-- 14. ADDITIONAL KPI: CLAIM AMOUNT BY CLAIM STATUS
-- ============================================================

SELECT
    `Claim Status`,
    ROUND(SUM(`Claim Amount`), 2) AS Total_Claim_Amount

FROM policy_claims

GROUP BY `Claim Status`

ORDER BY Total_Claim_Amount DESC;


-- ============================================================
-- 15. ADDITIONAL KPI: AVERAGE POLICY DISCOUNT
-- ============================================================

SELECT
    ROUND(AVG(`Policy Discounts`), 2) AS Average_Policy_Discount

FROM additional_fields;


-- ============================================================
-- 16. ADDITIONAL KPI: AVERAGE RISK SCORE
-- ============================================================

SELECT
    ROUND(AVG(`Risk Score`), 2) AS Average_Risk_Score

FROM additional_fields;


-- ============================================================
-- 17. DATA VALIDATION QUERIES
-- ============================================================

-- Check total records in all tables

SELECT 'Policy Details' AS Table_Name, COUNT(*) AS Total_Rows
FROM policy_details

UNION ALL

SELECT 'Policy Customers', COUNT(*)
FROM policy_customers

UNION ALL

SELECT 'Policy Claims', COUNT(*)
FROM policy_claims

UNION ALL

SELECT 'Payment History', COUNT(*)
FROM payment_history

UNION ALL

SELECT 'Additional Fields', COUNT(*)
FROM additional_fields;


-- Check duplicate Policy IDs

SELECT
    Policy_id,
    COUNT(*) AS Duplicate_Count

FROM policy_details

GROUP BY Policy_id

HAVING COUNT(*) > 1;


-- Check missing Customer IDs

SELECT *
FROM policy_customers

WHERE customer_id IS NULL;


-- Check missing Policy IDs

SELECT *
FROM policy_details

WHERE Policy_id IS NULL;


-- Check policy status distribution

SELECT
    Status,
    COUNT(*) AS Total_Policies

FROM policy_details

GROUP BY Status;


-- ============================================================
-- END OF POLICY ANALYTICS SQL QUERIES
-- ============================================================
