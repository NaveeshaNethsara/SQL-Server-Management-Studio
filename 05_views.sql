-- ============================================================
-- Views
-- SQL Server Management Studio Query File
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- Create a simple view
-- -----------------------------------------------------------
CREATE OR ALTER VIEW vw_ActiveEmployees
AS
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.Email,
        e.Phone,
        e.HireDate,
        e.Salary,
        d.DepartmentName,
        DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1;
GO

-- Query the view
SELECT * FROM vw_ActiveEmployees ORDER BY LastName, FirstName;
GO
SELECT FullName, Salary FROM vw_ActiveEmployees WHERE DepartmentName = 'Engineering';
GO

-- -----------------------------------------------------------
-- Create a view with aggregation
-- -----------------------------------------------------------
CREATE OR ALTER VIEW vw_DepartmentSummary
AS
    SELECT
        d.DepartmentID,
        d.DepartmentName,
        COUNT(e.EmployeeID)        AS EmployeeCount,
        ISNULL(AVG(e.Salary), 0)   AS AvgSalary,
        ISNULL(MIN(e.Salary), 0)   AS MinSalary,
        ISNULL(MAX(e.Salary), 0)   AS MaxSalary,
        ISNULL(SUM(e.Salary), 0)   AS TotalSalary
    FROM Departments d
    LEFT JOIN Employees e
        ON d.DepartmentID = e.DepartmentID AND e.IsActive = 1
    GROUP BY d.DepartmentID, d.DepartmentName;
GO

-- Query the view
SELECT * FROM vw_DepartmentSummary ORDER BY EmployeeCount DESC;
GO

-- -----------------------------------------------------------
-- Create an indexed (materialized) view
-- -----------------------------------------------------------
-- Note: Indexed views have strict requirements:
--   - Must use WITH SCHEMABINDING
--   - Cannot use non-deterministic functions (GETDATE, etc.)
--   - Aggregates must include COUNT_BIG(*)
--   - etc.
CREATE OR ALTER VIEW vw_EmployeeCountByDept
WITH SCHEMABINDING
AS
    SELECT
        e.DepartmentID,
        COUNT_BIG(*) AS EmployeeCount
    FROM dbo.Employees e
    WHERE e.IsActive = 1
    GROUP BY e.DepartmentID;
GO

-- Create the clustered index to materialize the view
CREATE UNIQUE CLUSTERED INDEX IX_vw_EmployeeCountByDept
ON vw_EmployeeCountByDept (DepartmentID);
GO

-- -----------------------------------------------------------
-- View with NOEXPAND hint (force indexed view usage in Standard Edition)
-- -----------------------------------------------------------
SELECT DepartmentID, EmployeeCount
FROM vw_EmployeeCountByDept WITH (NOEXPAND);
GO

-- -----------------------------------------------------------
-- List all views in the database
-- -----------------------------------------------------------
SELECT
    TABLE_SCHEMA AS ViewSchema,
    TABLE_NAME   AS ViewName,
    VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
ORDER BY TABLE_NAME;
GO

-- -----------------------------------------------------------
-- View definition using sys catalog
-- -----------------------------------------------------------
SELECT
    name        AS ViewName,
    create_date,
    modify_date,
    OBJECT_DEFINITION(object_id) AS ViewDefinition
FROM sys.views
ORDER BY name;
GO

-- -----------------------------------------------------------
-- Drop a view
-- -----------------------------------------------------------
DROP VIEW IF EXISTS vw_ActiveEmployees;
GO
DROP VIEW IF EXISTS vw_DepartmentSummary;
GO
DROP VIEW IF EXISTS vw_EmployeeCountByDept;
GO
