/* =====================================================================
   Module End Assignment 2 (MySQL): E-Commerce Customer Churn Analysis
   Database : ecomm      Table : customer_churn
   Run E-Commerce_Customer_churn_db.sql first, then this script top to bottom.
   ===================================================================== */

USE ecomm;
SET SQL_SAFE_UPDATES = 0;   -- allow UPDATE/DELETE without a key in WHERE

/* =====================================================================
   1. DATA CLEANING  (5 marks)
   ===================================================================== */

-- 1.1 Impute MEAN (rounded to nearest integer)
--     Mean is captured into a variable first, because MySQL does not allow
--     a subquery on the same table inside an UPDATE.
SET @avg_wh   = (SELECT ROUND(AVG(WarehouseToHome))             FROM customer_churn);
SET @avg_hrs  = (SELECT ROUND(AVG(HourSpendOnApp))              FROM customer_churn);
SET @avg_hike = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn);
SET @avg_day  = (SELECT ROUND(AVG(DaySinceLastOrder))           FROM customer_churn);

UPDATE customer_churn SET WarehouseToHome             = @avg_wh   WHERE WarehouseToHome             IS NULL;
UPDATE customer_churn SET HourSpendOnApp              = @avg_hrs  WHERE HourSpendOnApp              IS NULL;
UPDATE customer_churn SET OrderAmountHikeFromlastYear = @avg_hike WHERE OrderAmountHikeFromlastYear IS NULL;
UPDATE customer_churn SET DaySinceLastOrder           = @avg_day  WHERE DaySinceLastOrder           IS NULL;

-- 1.2 Impute MODE
SET @mode_tenure = (SELECT Tenure     FROM customer_churn WHERE Tenure     IS NOT NULL
                    GROUP BY Tenure     ORDER BY COUNT(*) DESC LIMIT 1);
SET @mode_coupon = (SELECT CouponUsed FROM customer_churn WHERE CouponUsed IS NOT NULL
                    GROUP BY CouponUsed ORDER BY COUNT(*) DESC LIMIT 1);
SET @mode_order  = (SELECT OrderCount FROM customer_churn WHERE OrderCount IS NOT NULL
                    GROUP BY OrderCount ORDER BY COUNT(*) DESC LIMIT 1);

UPDATE customer_churn SET Tenure     = @mode_tenure WHERE Tenure     IS NULL;
UPDATE customer_churn SET CouponUsed = @mode_coupon WHERE CouponUsed IS NULL;
UPDATE customer_churn SET OrderCount = @mode_order  WHERE OrderCount IS NULL;

-- 1.3 Outliers: delete rows where WarehouseToHome > 100
DELETE FROM customer_churn WHERE WarehouseToHome > 100;

-- 1.4 Inconsistencies
UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'Phone';
UPDATE customer_churn SET PreferedOrderCat     = 'Mobile Phone' WHERE PreferedOrderCat     = 'Mobile';

-- 1.5 Standardise payment modes
UPDATE customer_churn SET PreferredPaymentMode = 'Cash on Delivery' WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn SET PreferredPaymentMode = 'Credit Card'      WHERE PreferredPaymentMode = 'CC';

-- Verification: no NULLs should remain in the cleaned columns
SELECT SUM(WarehouseToHome IS NULL)             AS wh_nulls,
       SUM(HourSpendOnApp IS NULL)              AS hrs_nulls,
       SUM(OrderAmountHikeFromlastYear IS NULL) AS hike_nulls,
       SUM(DaySinceLastOrder IS NULL)           AS day_nulls,
       SUM(Tenure IS NULL)                      AS tenure_nulls,
       SUM(CouponUsed IS NULL)                  AS coupon_nulls,
       SUM(OrderCount IS NULL)                  AS order_nulls,
       COUNT(*)                                 AS total_rows
FROM customer_churn;


/* =====================================================================
   2. DATA TRANSFORMATION  (3 marks)
   ===================================================================== */

-- 2.1 Rename columns
ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp   TO HoursSpentOnApp;

-- 2.2 New columns
ALTER TABLE customer_churn
    ADD COLUMN ComplaintReceived VARCHAR(3),
    ADD COLUMN ChurnStatus       VARCHAR(10);

UPDATE customer_churn
SET ComplaintReceived = IF(Complain = 1, 'Yes', 'No'),
    ChurnStatus       = IF(Churn    = 1, 'Churned', 'Active');

-- 2.3 Drop original columns
ALTER TABLE customer_churn
    DROP COLUMN Churn,
    DROP COLUMN Complain;

DESCRIBE customer_churn;


/* =====================================================================
   3. DATA EXPLORATION AND ANALYSIS  (17 marks)
   ===================================================================== */

-- Q1. Count of churned and active customers
SELECT ChurnStatus, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;

-- Q2. Average tenure and total cashback of churned customers
SELECT ROUND(AVG(Tenure), 2) AS AvgTenure,
       SUM(CashbackAmount)   AS TotalCashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- Q3. Percentage of churned customers who complained
SELECT ROUND(100 * SUM(ComplaintReceived = 'Yes') / COUNT(*), 2) AS PctChurnedWhoComplained
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- Q4. City tier with the most churned customers preferring Laptop & Accessory
SELECT CityTier, COUNT(*) AS ChurnedCustomers
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCustomers DESC
LIMIT 1;

-- Q5. Most preferred payment mode among active customers
SELECT PreferredPaymentMode, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY CustomerCount DESC
LIMIT 1;

-- Q6. Total order amount hike for single customers who order via mobile phone
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredOrderCat = 'Mobile Phone';

-- Q7. Average number of devices registered among UPI users
SELECT ROUND(AVG(NumberOfDeviceRegistered), 2) AS AvgDevicesRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- Q8. City tier with the highest number of customers
SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

-- Q9. Gender that used the most coupons
SELECT Gender, SUM(CouponUsed) AS TotalCouponsUsed
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCouponsUsed DESC
LIMIT 1;

-- Q10. Customers and max hours spent on app per preferred order category
SELECT PreferredOrderCat,
       COUNT(*)             AS CustomerCount,
       MAX(HoursSpentOnApp) AS MaxHoursSpentOnApp
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC;

-- Q11. Total order count for credit-card customers with the maximum satisfaction score
SELECT SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

-- Q12. Average satisfaction score of customers who complained
SELECT ROUND(AVG(SatisfactionScore), 2) AS AvgSatisfactionScore
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- Q13. Preferred order categories among customers who used more than 5 coupons
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC;

-- Q14. Top 3 preferred order categories by average cashback
SELECT PreferredOrderCat, ROUND(AVG(CashbackAmount), 2) AS AvgCashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AvgCashback DESC
LIMIT 3;

-- Q15. Payment modes whose customers average 10 months tenure and placed > 500 orders
SELECT PreferredPaymentMode,
       ROUND(AVG(Tenure)) AS AvgTenure,
       SUM(OrderCount)    AS TotalOrders
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING ROUND(AVG(Tenure)) = 10
   AND SUM(OrderCount) > 500;

-- Q16. Distance categories with churn status breakdown
SELECT CASE
           WHEN WarehouseToHome <= 5  THEN 'Very Close Distance'
           WHEN WarehouseToHome <= 10 THEN 'Close Distance'
           WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
           ELSE 'Far Distance'
       END AS DistanceCategory,
       ChurnStatus,
       COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY FIELD(DistanceCategory, 'Very Close Distance', 'Close Distance',
                                 'Moderate Distance', 'Far Distance'),
         ChurnStatus;

-- Q17. Married, City Tier 1, order count above the overall average
SELECT CustomerID, MaritalStatus, CityTier, PreferredOrderCat,
       PreferredPaymentMode, OrderCount, OrderAmountHikeFromlastYear,
       CouponUsed, DaySinceLastOrder, CashbackAmount
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn)
ORDER BY OrderCount DESC;

-- Q18 a) Create and populate customer_returns
DROP TABLE IF EXISTS customer_returns;
CREATE TABLE customer_returns (
    ReturnID     INT PRIMARY KEY,
    CustomerID   INT,
    ReturnDate   DATE,
    RefundAmount INT,
    FOREIGN KEY (CustomerID) REFERENCES customer_churn(CustomerID)
);

INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
    (1001, 50022, '2023-01-01', 2130),
    (1002, 50316, '2023-01-23', 2000),
    (1003, 51099, '2023-02-14', 2290),
    (1004, 52321, '2023-03-08', 2510),
    (1005, 52928, '2023-03-20', 3000),
    (1006, 53749, '2023-04-17', 1740),
    (1007, 54206, '2023-04-21', 3250),
    (1008, 54838, '2023-04-30', 1990);

SELECT * FROM customer_returns;

-- Q18 b) Return details with customer details for churned customers who complained
SELECT r.ReturnID, r.ReturnDate, r.RefundAmount, c.*
FROM customer_returns r
JOIN customer_churn  c ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes'
ORDER BY r.ReturnID;

SET SQL_SAFE_UPDATES = 1;
