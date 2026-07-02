-- ============================================
-- Churn Analysis — SQL Server ETL
-- ============================================

-- 1. Create database
CREATE DATABASE db_Churn;

-- 2. Explore data quality (run after importing CSV into stg_Churn via Import Wizard)

-- Distinct value check example (repeat per categorical column)
SELECT Gender, COUNT(Gender) AS TotalCount,
       COUNT(Gender) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY Gender;

SELECT Contract, COUNT(Contract) AS TotalCount,
       COUNT(Contract) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY Contract;

SELECT Customer_Status, COUNT(Customer_Status) AS TotalCount,
       SUM(Total_Revenue) AS TotalRev,
       SUM(Total_Revenue) / (SELECT SUM(Total_Revenue) FROM stg_Churn) * 100 AS RevPercentage
FROM stg_Churn
GROUP BY Customer_Status;

SELECT State, COUNT(State) AS TotalCount,
       COUNT(State) * 1.0 / (SELECT COUNT(*) FROM stg_Churn) AS Percentage
FROM stg_Churn
GROUP BY State
ORDER BY Percentage DESC;

-- Null check across all columns
SELECT
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Customer_ID_Null_Count,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Gender_Null_Count,
    SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END) AS Value_Deal_Null_Count,
    SUM(CASE WHEN Internet_Type IS NULL THEN 1 ELSE 0 END) AS Internet_Type_Null_Count,
    SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END) AS Churn_Category_Null_Count,
    SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason_Null_Count
    -- ... extend to remaining columns as needed
FROM stg_Churn;

-- 3. Clean nulls and load into production table
SELECT
    Customer_ID, Gender, Age, Married, State, Number_of_Referrals, Tenure_in_Months,
    ISNULL(Value_Deal, 'None') AS Value_Deal,
    Phone_Service,
    ISNULL(Multiple_Lines, 'No') AS Multiple_Lines,
    Internet_Service,
    ISNULL(Internet_Type, 'None') AS Internet_Type,
    ISNULL(Online_Security, 'No') AS Online_Security,
    ISNULL(Online_Backup, 'No') AS Online_Backup,
    ISNULL(Device_Protection_Plan, 'No') AS Device_Protection_Plan,
    ISNULL(Premium_Support, 'No') AS Premium_Support,
    ISNULL(Streaming_TV, 'No') AS Streaming_TV,
    ISNULL(Streaming_Movies, 'No') AS Streaming_Movies,
    ISNULL(Streaming_Music, 'No') AS Streaming_Music,
    ISNULL(Unlimited_Data, 'No') AS Unlimited_Data,
    Contract, Paperless_Billing, Payment_Method,
    Monthly_Charge, Total_Charges, Total_Refunds,
    Total_Extra_Data_Charges, Total_Long_Distance_Charges, Total_Revenue,
    Customer_Status,
    ISNULL(Churn_Category, 'Others') AS Churn_Category,
    ISNULL(Churn_Reason, 'Others') AS Churn_Reason
INTO [db_Churn].[dbo].[prod_Churn]
FROM [db_Churn].[dbo].[stg_Churn];

-- 4. Views for Power BI / Python model consumption
CREATE VIEW vw_ChurnData AS
    SELECT * FROM prod_Churn WHERE Customer_Status IN ('Churned', 'Stayed');
GO

CREATE VIEW vw_JoinData AS
    SELECT * FROM prod_Churn WHERE Customer_Status = 'Joined';
GO
