-- ============================================================
-- Data Manipulation (SELECT, INSERT, UPDATE, DELETE)
-- SQL Server Management Studio Query File
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- INSERT: Add single row
-- -----------------------------------------------------------
INSERT INTO Departments (DepartmentName)
VALUES ('Engineering');

INSERT INTO Departments (DepartmentName)
VALUES ('Human Resources');

INSERT INTO Departments (DepartmentName)
VALUES ('Finance');
GO

-- INSERT with explicit column list (recommended)
INSERT INTO Employees (FirstName, LastName, Email, Phone, HireDate, Salary, DepartmentID)
VALUES ('Alice', 'Smith', 'alice.smith@example.com', '555-1001', '2020-01-15', 75000.00, 1);
GO

-- -----------------------------------------------------------
-- INSERT: Add multiple rows at once
-- -----------------------------------------------------------
INSERT INTO Employees (FirstName, LastName, Email, Phone, HireDate, Salary, DepartmentID)
VALUES
    ('Bob',     'Jones',    'bob.jones@example.com',    '555-1002', '2019-06-01', 68000.00, 1),
    ('Carol',   'Williams', 'carol.w@example.com',      '555-1003', '2021-03-20', 82000.00, 2),
    ('David',   'Brown',    'david.brown@example.com',  '555-1004', '2018-11-05', 91000.00, 3),
    ('Eve',     'Taylor',   'eve.taylor@example.com',   NULL,       '2022-07-10', 60000.00, 1);
GO

-- -----------------------------------------------------------
-- INSERT from another table
-- -----------------------------------------------------------
INSERT INTO Employees (FirstName, LastName, Email, HireDate, Salary, DepartmentID)
SELECT FirstName, LastName, Email, HireDate, Salary, DepartmentID
FROM StagingEmployees
WHERE IsValid = 1;
GO

-- -----------------------------------------------------------
-- SELECT: Basic queries
-- -----------------------------------------------------------

-- Select all columns (avoid in production code)
SELECT * FROM Employees;
GO

-- Select specific columns
SELECT EmployeeID, FirstName, LastName, Email, Salary
FROM Employees;
GO

-- Select with alias
SELECT
    EmployeeID                        AS ID,
    FirstName + ' ' + LastName        AS FullName,
    Email,
    ISNULL(Phone, 'N/A')              AS Phone,
    FORMAT(Salary, 'C', 'en-US')      AS FormattedSalary,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService
FROM Employees
WHERE IsActive = 1
ORDER BY LastName, FirstName;
GO

-- -----------------------------------------------------------
-- SELECT: Filtering with WHERE
-- -----------------------------------------------------------

-- Comparison operators
SELECT * FROM Employees WHERE Salary > 70000;
SELECT * FROM Employees WHERE Salary BETWEEN 60000 AND 90000;
SELECT * FROM Employees WHERE DepartmentID IN (1, 2);
SELECT * FROM Employees WHERE Phone IS NULL;
SELECT * FROM Employees WHERE Phone IS NOT NULL;

-- Pattern matching with LIKE
SELECT * FROM Employees WHERE Email LIKE '%@example.com';
SELECT * FROM Employees WHERE LastName LIKE 'S%';       -- starts with S
SELECT * FROM Employees WHERE FirstName LIKE '_ob';     -- 3 chars ending in ob

-- Combining conditions
SELECT * FROM Employees
WHERE IsActive = 1
  AND (Salary > 75000 OR DepartmentID = 2)
  AND HireDate >= '2019-01-01';
GO

-- -----------------------------------------------------------
-- SELECT: Aggregation and GROUP BY
-- -----------------------------------------------------------
SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID)     AS EmployeeCount,
    AVG(e.Salary)           AS AvgSalary,
    MIN(e.Salary)           AS MinSalary,
    MAX(e.Salary)           AS MaxSalary,
    SUM(e.Salary)           AS TotalSalary
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName
HAVING COUNT(e.EmployeeID) > 0
ORDER BY TotalSalary DESC;
GO

-- -----------------------------------------------------------
-- SELECT: JOINs
-- -----------------------------------------------------------

-- INNER JOIN: only matching rows from both tables
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.IsActive = 1;
GO

-- LEFT JOIN: all rows from left table, matching from right
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    d.DepartmentName
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID;
GO

-- Self JOIN: find manager info
SELECT
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName          AS EmployeeName,
    mgr.FirstName + ' ' + mgr.LastName      AS ManagerName
FROM Employees e
LEFT JOIN Employees mgr ON e.DepartmentID = mgr.EmployeeID; -- simplified example
GO

-- -----------------------------------------------------------
-- SELECT: Subqueries
-- -----------------------------------------------------------

-- Subquery in WHERE
SELECT EmployeeID, FirstName, LastName, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees)
ORDER BY Salary DESC;
GO

-- Subquery in FROM (derived table)
SELECT DeptSummary.DepartmentID, DeptSummary.AvgSalary
FROM (
    SELECT DepartmentID, AVG(Salary) AS AvgSalary
    FROM Employees
    WHERE IsActive = 1
    GROUP BY DepartmentID
) AS DeptSummary
WHERE DeptSummary.AvgSalary > 70000;
GO

-- -----------------------------------------------------------
-- SELECT: Common Table Expressions (CTE)
-- -----------------------------------------------------------
WITH ActiveEmployees AS
(
    SELECT
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.Salary,
        d.DepartmentName
    FROM Employees e
    INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1
),
DeptStats AS
(
    SELECT
        DepartmentName,
        AVG(Salary) AS AvgSalary
    FROM ActiveEmployees
    GROUP BY DepartmentName
)
SELECT
    ae.FullName,
    ae.DepartmentName,
    ae.Salary,
    ds.AvgSalary,
    ae.Salary - ds.AvgSalary AS DiffFromAvg
FROM ActiveEmployees ae
INNER JOIN DeptStats ds ON ae.DepartmentName = ds.DepartmentName
ORDER BY ae.DepartmentName, ae.Salary DESC;
GO

-- -----------------------------------------------------------
-- SELECT: Window Functions
-- -----------------------------------------------------------
SELECT
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    DepartmentID,
    Salary,
    RANK()        OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank,
    DENSE_RANK()  OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS DenseSalaryRank,
    ROW_NUMBER()  OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS RowNum,
    AVG(Salary)   OVER (PARTITION BY DepartmentID)                      AS DeptAvgSalary,
    SUM(Salary)   OVER (ORDER BY HireDate ROWS UNBOUNDED PRECEDING)     AS RunningTotal
FROM Employees
WHERE IsActive = 1;
GO

-- -----------------------------------------------------------
-- SELECT: TOP and pagination
-- -----------------------------------------------------------

-- Top N rows
SELECT TOP 10 * FROM Employees ORDER BY Salary DESC;
GO

-- Top N percent
SELECT TOP 10 PERCENT * FROM Employees ORDER BY HireDate ASC;
GO

-- Pagination with OFFSET/FETCH
DECLARE @PageNumber INT = 1;
DECLARE @PageSize   INT = 10;

SELECT
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Salary
FROM Employees
ORDER BY EmployeeID
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;
GO

-- -----------------------------------------------------------
-- UPDATE: Modify rows
-- -----------------------------------------------------------

-- Update a single row
UPDATE Employees
SET Salary    = 80000.00,
    UpdatedAt = SYSDATETIME()
WHERE EmployeeID = 1;
GO

-- Update multiple rows based on condition
UPDATE Employees
SET Salary    = Salary * 1.05,  -- 5% raise
    UpdatedAt = SYSDATETIME()
WHERE DepartmentID = 1
  AND IsActive = 1;
GO

-- Update with JOIN
UPDATE e
SET e.Salary    = e.Salary * 1.10,
    e.UpdatedAt = SYSDATETIME()
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Engineering'
  AND e.IsActive = 1;
GO

-- -----------------------------------------------------------
-- DELETE: Remove rows
-- -----------------------------------------------------------

-- Delete specific rows
DELETE FROM Employees
WHERE EmployeeID = 5;
GO

-- Delete with JOIN
DELETE e
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Finance'
  AND e.HireDate < '2015-01-01';
GO

-- -----------------------------------------------------------
-- MERGE: Upsert (Insert or Update)
-- -----------------------------------------------------------
MERGE INTO Employees AS target
USING (
    SELECT 1 AS EmployeeID, 'Alice' AS FirstName, 'Smith' AS LastName,
           'alice.smith@example.com' AS Email, 78000.00 AS Salary
) AS source
ON target.EmployeeID = source.EmployeeID
WHEN MATCHED THEN
    UPDATE SET
        target.FirstName = source.FirstName,
        target.LastName  = source.LastName,
        target.Salary    = source.Salary,
        target.UpdatedAt = SYSDATETIME()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (FirstName, LastName, Email, Salary)
    VALUES (source.FirstName, source.LastName, source.Email, source.Salary);
GO

-- -----------------------------------------------------------
-- Transactions
-- -----------------------------------------------------------
BEGIN TRANSACTION;

BEGIN TRY
    UPDATE Employees SET Salary = Salary * 1.10 WHERE DepartmentID = 1;
    UPDATE Departments SET DepartmentName = 'Software Engineering' WHERE DepartmentID = 1;
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back due to error: ' + ERROR_MESSAGE();
END CATCH;
GO
