-- ============================================================
-- Table Operations
-- SQL Server Management Studio Query File
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- Create a simple table
-- -----------------------------------------------------------
CREATE TABLE Employees
(
    EmployeeID   INT           NOT NULL IDENTITY(1,1),
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Email        NVARCHAR(100) NOT NULL,
    Phone        NVARCHAR(20)      NULL,
    HireDate     DATE          NOT NULL DEFAULT GETDATE(),
    Salary       DECIMAL(10,2)     NULL,
    DepartmentID INT               NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt    DATETIME2         NULL,
    CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID),
    CONSTRAINT UQ_Employees_Email UNIQUE (Email),
    CONSTRAINT CHK_Employees_Salary CHECK (Salary >= 0)
);
GO

-- Create a related Departments table
CREATE TABLE Departments
(
    DepartmentID   INT          NOT NULL IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    ManagerID      INT               NULL,
    CreatedAt      DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Departments PRIMARY KEY (DepartmentID),
    CONSTRAINT UQ_Departments_Name UNIQUE (DepartmentName)
);
GO

-- Add foreign key after both tables exist
ALTER TABLE Employees
ADD CONSTRAINT FK_Employees_Departments
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID);
GO

ALTER TABLE Departments
ADD CONSTRAINT FK_Departments_Manager
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);
GO

-- -----------------------------------------------------------
-- Add a column to an existing table
-- -----------------------------------------------------------
ALTER TABLE Employees
ADD MiddleName NVARCHAR(50) NULL;
GO

-- -----------------------------------------------------------
-- Modify a column (change data type or nullability)
-- -----------------------------------------------------------
ALTER TABLE Employees
ALTER COLUMN Phone NVARCHAR(30) NULL;
GO

-- -----------------------------------------------------------
-- Drop a column
-- -----------------------------------------------------------
-- Drop constraint first if one exists on the column
-- Then drop the column
ALTER TABLE Employees
DROP COLUMN MiddleName;
GO

-- -----------------------------------------------------------
-- Add a default constraint
-- -----------------------------------------------------------
ALTER TABLE Employees
ADD CONSTRAINT DF_Employees_IsActive DEFAULT 1 FOR IsActive;
GO

-- -----------------------------------------------------------
-- Drop a constraint
-- -----------------------------------------------------------
ALTER TABLE Employees
DROP CONSTRAINT DF_Employees_IsActive;
GO

-- -----------------------------------------------------------
-- Rename a table (using sp_rename)
-- -----------------------------------------------------------
EXEC sp_rename 'Employees', 'Staff';
GO
-- Rename back
EXEC sp_rename 'Staff', 'Employees';
GO

-- -----------------------------------------------------------
-- Rename a column
-- -----------------------------------------------------------
EXEC sp_rename 'Employees.Phone', 'PhoneNumber', 'COLUMN';
GO

-- -----------------------------------------------------------
-- View table structure / columns
-- -----------------------------------------------------------
EXEC sp_help 'Employees';
GO

-- Alternative: query information_schema
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employees'
ORDER BY ORDINAL_POSITION;
GO

-- -----------------------------------------------------------
-- View all tables in the current database
-- -----------------------------------------------------------
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

-- -----------------------------------------------------------
-- Check table row count
-- -----------------------------------------------------------
SELECT
    t.name AS TableName,
    p.rows AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)  -- heap or clustered index
ORDER BY p.rows DESC;
GO

-- -----------------------------------------------------------
-- Truncate a table (remove all rows, reset identity)
-- -----------------------------------------------------------
TRUNCATE TABLE Employees;
GO

-- -----------------------------------------------------------
-- Drop tables (order matters for foreign keys)
-- -----------------------------------------------------------
ALTER TABLE Employees DROP CONSTRAINT FK_Employees_Departments;
GO
ALTER TABLE Departments DROP CONSTRAINT FK_Departments_Manager;
GO
DROP TABLE IF EXISTS Employees;
GO
DROP TABLE IF EXISTS Departments;
GO

-- -----------------------------------------------------------
-- Create a temporary table
-- -----------------------------------------------------------
CREATE TABLE #TempEmployees
(
    EmployeeID INT,
    FullName   NVARCHAR(101),
    Salary     DECIMAL(10,2)
);
GO

-- Create a global temporary table (visible to all sessions)
CREATE TABLE ##GlobalTempEmployees
(
    EmployeeID INT,
    FullName   NVARCHAR(101)
);
GO

-- -----------------------------------------------------------
-- Create table from SELECT (SELECT INTO)
-- -----------------------------------------------------------
SELECT
    EmployeeID,
    FirstName + ' ' + LastName AS FullName,
    Salary
INTO EmployeesSummary
FROM Employees
WHERE IsActive = 1;
GO
