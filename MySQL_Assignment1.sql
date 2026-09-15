-- ======================================================================
-- MySQL Assignment 1 - DDL Commands & Constraints
-- ======================================================================


-- ======================================================================
-- PART A: DDL COMMANDS
-- ======================================================================

-- ----------------------------------------------------------------------
-- 1. TABLE CREATION (CREATE)
-- ----------------------------------------------------------------------

CREATE DATABASE employee;
USE employee;

CREATE TABLE departments (
    department_id   INT,
    department_name VARCHAR(100)
);

CREATE TABLE location (
    location_id INT,
    location    VARCHAR(30)
);

CREATE TABLE employees (
    employee_id   INT,
    employee_name VARCHAR(50),
    gender        ENUM('M', 'F'),
    age           INT,
    hire_date     DATE,
    designation   VARCHAR(100),
    department_id INT,
    location_id   INT,
    salary        DECIMAL(10,2)
);


-- ----------------------------------------------------------------------
-- 2. TABLE ALTERATION (ALTER)
-- ----------------------------------------------------------------------

-- Add a new "email" column to Employees
ALTER TABLE employees
    ADD COLUMN email VARCHAR(100);

-- Widen the "designation" column
ALTER TABLE employees
    MODIFY COLUMN designation VARCHAR(200);

-- Drop the "age" column
ALTER TABLE employees
    DROP COLUMN age;

-- Rename "hire_date" to "date_of_joining"
ALTER TABLE employees
    RENAME COLUMN hire_date TO date_of_joining;


-- ----------------------------------------------------------------------
-- 3. TABLE RENAMING (RENAME)
-- ----------------------------------------------------------------------

RENAME TABLE departments TO departments_info;
RENAME TABLE location TO locations;


-- ----------------------------------------------------------------------
-- 4. TABLE TRUNCATION (TRUNCATE)
-- ----------------------------------------------------------------------

TRUNCATE TABLE employees;


-- ----------------------------------------------------------------------
-- 5. DATABASE & TABLE DROPPING (DROP)
-- ----------------------------------------------------------------------

DROP TABLE employees;
DROP DATABASE employee;


-- ======================================================================
-- PART B: CONSTRAINTS
-- ======================================================================

-- ----------------------------------------------------------------------
-- 1. Database Recreation
-- ----------------------------------------------------------------------

DROP DATABASE IF EXISTS employee;
CREATE DATABASE employee;
USE employee;

-- ----------------------------------------------------------------------
-- 2. Departments Table
--    - department_id uniquely identifies each row      -> PRIMARY KEY
--    - department_name has no duplicates / no nulls    -> UNIQUE + NOT NULL
-- ----------------------------------------------------------------------

CREATE TABLE departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- ----------------------------------------------------------------------
-- 3. Location Table
--    - location_id auto-generated, sequential, unique  -> AUTO_INCREMENT + PRIMARY KEY
--    - location has no nulls / no duplicates            -> NOT NULL + UNIQUE
-- ----------------------------------------------------------------------

CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location    VARCHAR(30) NOT NULL UNIQUE
);

-- ----------------------------------------------------------------------
-- 4. Employees Table
--    - employee_id distinct                              -> PRIMARY KEY
--    - employee_name always provided                      -> NOT NULL
--    - gender restricted to 'M' or 'F'                    -> ENUM('M','F')
--    - age must be 18 or above                             -> CHECK (age >= 18)
--    - hire_date defaults to current date                  -> DEFAULT (CURRENT_DATE)
--    - department_id / location_id link to their tables    -> FOREIGN KEY
-- ----------------------------------------------------------------------

CREATE TABLE employees (
    employee_id   INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    gender        ENUM('M', 'F') NOT NULL,
    age           INT NOT NULL CHECK (age >= 18),
    hire_date     DATE DEFAULT (CURRENT_DATE),
    designation   VARCHAR(100),
    department_id INT,
    location_id   INT,
    salary        DECIMAL(10,2),
    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_employees_location
        FOREIGN KEY (location_id) REFERENCES location(location_id)
);