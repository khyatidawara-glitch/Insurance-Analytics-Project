
-- ============================================================
-- INSURANCE ANALYTICS PROJECT
-- BRANCH REVENUE & EXECUTIVE PERFORMANCE ANALYSIS
-- Database: Insurance_Branch_Project
-- Tool: MySQL
-- ============================================================

CREATE DATABASE Insurance_Branch_Project;

USE Insurance_Branch_Project;


-- ============================================================
-- KPI 1: RENEWAL ACHIEVEMENT PERCENTAGE
-- Objective: Calculate renewal revenue against renewal budget
-- ============================================================

WITH renewal_revenue AS (
    SELECT
        `Account Exe ID`,
        SUM(Amount) AS Total_Renewal_Revenue
    FROM (
        SELECT `Account Exe ID`, Amount
        FROM brokerage
        WHERE income_class = 'Renewal'

        UNION ALL

        SELECT `Account Exe ID`, Amount
        FROM fees
        WHERE income_class = 'Renewal'
    ) AS revenue
    GROUP BY `Account Exe ID`
),
renewal_budget AS (
    SELECT
        `Account Exe ID`,
        SUM(`Renewal Budget`) AS Total_Renewal_Budget
    FROM individual_budget
    GROUP BY `Account Exe ID`
)
SELECT
    r.`Account Exe ID`,
    r.Total_Renewal_Revenue,
    b.Total_Renewal_Budget,
    ROUND(
        r.Total_Renewal_Revenue /
        NULLIF(b.Total_Renewal_Budget, 0) * 100,
        2
    ) AS Renewal_Achievement_Percentage
FROM renewal_revenue r
JOIN renewal_budget b
    ON r.`Account Exe ID` = b.`Account Exe ID`;


-- ============================================================
-- KPI 2: BRANCH REVENUE COMPARISON
-- Objective: Compare total revenue across branches
-- ============================================================

SELECT
    branch_name,
    ROUND(SUM(Amount), 2) AS Total_Revenue
FROM (
    SELECT branch_name, Amount
    FROM brokerage

    UNION ALL

    SELECT branch_name, Amount
    FROM fees
) AS branch_revenue
GROUP BY branch_name
ORDER BY Total_Revenue DESC;


-- ============================================================
-- KPI 3: BRANCH-WISE OPEN OPPORTUNITY COUNT
-- Objective: Count opportunities in open stages by branch
-- ============================================================

SELECT
    branch,
    COUNT(*) AS Open_Opportunity_Count
FROM opportunity
WHERE stage IN (
    'Qualify Opportunity',
    'Propose Solution',
    'Negotiate'
)
GROUP BY branch
ORDER BY Open_Opportunity_Count DESC;


-- ============================================================
-- KPI 4: TOP 10 WON OPPORTUNITIES
-- Objective: Identify the highest-value won opportunities
-- ============================================================

SELECT
    revenue_amount,
    branch,
    specialty,
    product_group,
    product_sub_group,
    closing_date
FROM opportunity
WHERE stage = 'Won'
ORDER BY revenue_amount DESC
LIMIT 10;


-- ============================================================
-- KPI 5: AVERAGE INVOICE VALUE
-- Objective: Calculate average invoice value by executive
-- and income class
-- ============================================================

SELECT
    `Account Exe ID`,
    income_class,
    ROUND(
        SUM(Amount) /
        NULLIF(COUNT(DISTINCT invoice_number), 0),
        2
    ) AS Average_Invoice_Value
FROM invoice
GROUP BY
    `Account Exe ID`,
    income_class
ORDER BY
    `Account Exe ID`,
    income_class;


-- ============================================================
-- KPI 6: REVENUE PER CLIENT
-- Objective: Calculate total revenue generated per client
-- ============================================================

SELECT
    client_name,
    ROUND(SUM(Amount), 2) AS Revenue_Per_Client
FROM (
    SELECT client_name, Amount
    FROM brokerage

    UNION ALL

    SELECT client_name, Amount
    FROM fees
) AS client_revenue
GROUP BY client_name
ORDER BY Revenue_Per_Client DESC;


-- ============================================================
-- DATA VALIDATION QUERIES
-- ============================================================

-- 1. Check total records in each table

SELECT 'Brokerage' AS Table_Name, COUNT(*) AS Total_Rows
FROM brokerage

UNION ALL

SELECT 'Fees', COUNT(*) FROM fees

UNION ALL

SELECT 'Invoice', COUNT(*) FROM invoice

UNION ALL

SELECT 'Opportunity', COUNT(*) FROM opportunity

UNION ALL

SELECT 'Meeting', COUNT(*) FROM meeting

UNION ALL

SELECT 'Individual Budget', COUNT(*) FROM individual_budget;


-- 2. Check missing Account Executive IDs

SELECT *
FROM individual_budget
WHERE `Account Exe ID` IS NULL;

SELECT *
FROM brokerage
WHERE `Account Exe ID` IS NULL;

SELECT *
FROM fees
WHERE `Account Exe ID` IS NULL;


-- 3. Check opportunity stage distribution

SELECT
    stage,
    COUNT(*) AS Total_Opportunities
FROM opportunity
GROUP BY stage
ORDER BY Total_Opportunities DESC;


-- ============================================================
-- END OF BRANCH ANALYTICS SQL QUERIES
-- ============================================================
