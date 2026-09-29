


-- ---------------------------------------------------------------------
-- 1. DISTINCT VALUES
-- ---------------------------------------------------------------------
SELECT DISTINCT salary
FROM Employees;


-- ---------------------------------------------------------------------
-- 2. ALIAS (AS)
-- ---------------------------------------------------------------------
SELECT first_name,
       last_name,
       age    AS Employee_Age,
       salary AS Employee_Salary
FROM Employees;


-- ---------------------------------------------------------------------
-- 3. WHERE CLAUSE & OPERATORS
-- ---------------------------------------------------------------------
-- 3a. Salary > 50000 and hired before 2016-01-01
SELECT *
FROM Employees
WHERE salary > 50000
  AND hire_date < '2016-01-01';

-- 3b. Find the employee with a missing designation ...
SELECT *
FROM Employees
WHERE designation IS NULL OR designation = '';

-- ... and fill it with 'Data Scientist'
SET SQL_SAFE_UPDATES = 0;          -- needed in MySQL Workbench
UPDATE Employees
SET designation = 'Data Scientist'
WHERE designation IS NULL OR designation = '';
SET SQL_SAFE_UPDATES = 1;

-- verify
SELECT * FROM Employees WHERE designation = 'Data Scientist';


-- =====================================================================
-- SORTING AND GROUPING DATA
-- =====================================================================

-- 1. ORDER BY: department ID ascending, salary descending
SELECT *
FROM Employees
ORDER BY dept_id ASC, salary DESC;


-- 2. LIMIT: first 5 employees hired in 2018
SELECT *
FROM Employees
WHERE YEAR(hire_date) = 2018
ORDER BY hire_date ASC
LIMIT 5;


-- 3. AGGREGATE FUNCTIONS
-- 3a. Sum of all salaries in the Finance department
SELECT SUM(e.salary) AS Total_Finance_Salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Finance';

-- 3b. Minimum age among all employees
SELECT MIN(age) AS Minimum_Age
FROM Employees;


-- 4. GROUP BY
-- 4a. Maximum salary for each location
SELECT l.location,
       MAX(e.salary) AS Max_Salary
FROM Employees e
JOIN Locations l ON e.location_id = l.location_id
GROUP BY l.location;

-- 4b. Average salary for each designation containing 'Analyst'
SELECT designation,
       ROUND(AVG(salary), 2) AS Avg_Salary
FROM Employees
WHERE designation LIKE '%Analyst%'
GROUP BY designation;


-- 5. HAVING
-- 5a. Departments with less than 3 employees
--     (LEFT JOIN so departments with 0 employees are also included)
SELECT d.dept_id,
       d.dept_name,
       COUNT(e.emp_id) AS Employee_Count
FROM Departments d
LEFT JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) < 3;

-- 5b. Locations where female employees' average age is below 30
SELECT l.location,
       ROUND(AVG(e.age), 1) AS Avg_Female_Age
FROM Employees e
JOIN Locations l ON e.location_id = l.location_id
WHERE e.gender IN ('Female', 'F')
GROUP BY l.location
HAVING AVG(e.age) < 30;


-- =====================================================================
-- JOINS
-- =====================================================================

-- 1. INNER JOIN: employee names, designations and department names
SELECT CONCAT(e.first_name, ' ', e.last_name) AS Employee_Name,
       e.designation,
       d.dept_name
FROM Employees e
INNER JOIN Departments d ON e.dept_id = d.dept_id;


-- 2. LEFT JOIN: all departments with employee count (including zero)
SELECT d.dept_name,
       COUNT(e.emp_id) AS Total_Employees
FROM Departments d
LEFT JOIN Employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY Total_Employees DESC;


-- 3. RIGHT JOIN: all locations with assigned employee names (NULL if none)
SELECT l.location,
       CONCAT(e.first_name, ' ', e.last_name) AS Employee_Name
FROM Employees e
RIGHT JOIN Locations l ON e.location_id = l.location_id
ORDER BY l.location;
