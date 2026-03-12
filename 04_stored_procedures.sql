-- ============================================================
-- Stored Procedures
-- SQL Server Management Studio Query File
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- Basic stored procedure (no parameters)
-- -----------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_GetAllActiveEmployees
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.Email,
        e.Phone,
        e.HireDate,
        e.Salary,
        d.DepartmentName
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
    WHERE e.IsActive = 1
    ORDER BY e.LastName, e.FirstName;
END;
GO

-- Execute the procedure
EXEC usp_GetAllActiveEmployees;
GO

-- -----------------------------------------------------------
-- Stored procedure with input parameters
-- -----------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_GetEmployeesByDepartment
    @DepartmentID   INT,
    @ActiveOnly     BIT = 1   -- optional parameter with default value
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName AS FullName,
        e.Email,
        e.Salary,
        e.IsActive
    FROM Employees e
    WHERE e.DepartmentID = @DepartmentID
      AND (@ActiveOnly = 0 OR e.IsActive = 1)
    ORDER BY e.LastName, e.FirstName;
END;
GO

-- Execute with parameters
EXEC usp_GetEmployeesByDepartment @DepartmentID = 1;
EXEC usp_GetEmployeesByDepartment @DepartmentID = 1, @ActiveOnly = 0;
GO

-- -----------------------------------------------------------
-- Stored procedure with OUTPUT parameter
-- -----------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_AddEmployee
    @FirstName    NVARCHAR(50),
    @LastName     NVARCHAR(50),
    @Email        NVARCHAR(100),
    @Salary       DECIMAL(10,2),
    @DepartmentID INT,
    @NewEmployeeID INT OUTPUT    -- output parameter returns new ID
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate email is not already used
    IF EXISTS (SELECT 1 FROM Employees WHERE Email = @Email)
    BEGIN
        RAISERROR('An employee with email "%s" already exists.', 16, 1, @Email);
        RETURN;
    END;

    INSERT INTO Employees (FirstName, LastName, Email, Salary, DepartmentID)
    VALUES (@FirstName, @LastName, @Email, @Salary, @DepartmentID);

    SET @NewEmployeeID = SCOPE_IDENTITY();
END;
GO

-- Execute and capture OUTPUT parameter
DECLARE @NewID INT;
EXEC usp_AddEmployee
    @FirstName    = 'Frank',
    @LastName     = 'Miller',
    @Email        = 'frank.miller@example.com',
    @Salary       = 72000.00,
    @DepartmentID = 2,
    @NewEmployeeID = @NewID OUTPUT;
PRINT 'New Employee ID: ' + CAST(@NewID AS VARCHAR(10));
GO

-- -----------------------------------------------------------
-- Stored procedure with error handling
-- -----------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_UpdateEmployeeSalary
    @EmployeeID INT,
    @NewSalary  DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
            RAISERROR('Employee with ID %d not found.', 16, 1, @EmployeeID);

        IF @NewSalary < 0
            RAISERROR('Salary cannot be negative.', 16, 1);

        UPDATE Employees
        SET Salary    = @NewSalary,
            UpdatedAt = SYSDATETIME()
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;
        PRINT 'Salary updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT            = ERROR_SEVERITY();
        DECLARE @ErrorState    INT            = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- -----------------------------------------------------------
-- Stored procedure returning multiple result sets
-- -----------------------------------------------------------
CREATE OR ALTER PROCEDURE usp_GetDepartmentSummary
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: Department info
    SELECT
        DepartmentID,
        DepartmentName
    FROM Departments
    WHERE DepartmentID = @DepartmentID;

    -- Result set 2: Employee list
    SELECT
        EmployeeID,
        FirstName + ' ' + LastName AS FullName,
        Email,
        Salary,
        HireDate
    FROM Employees
    WHERE DepartmentID = @DepartmentID
      AND IsActive = 1
    ORDER BY LastName, FirstName;

    -- Result set 3: Salary statistics
    SELECT
        COUNT(*)        AS TotalEmployees,
        AVG(Salary)     AS AvgSalary,
        MIN(Salary)     AS MinSalary,
        MAX(Salary)     AS MaxSalary,
        SUM(Salary)     AS TotalSalary
    FROM Employees
    WHERE DepartmentID = @DepartmentID
      AND IsActive = 1;
END;
GO

-- -----------------------------------------------------------
-- List all stored procedures in the database
-- -----------------------------------------------------------
SELECT
    ROUTINE_SCHEMA,
    ROUTINE_NAME,
    CREATED,
    LAST_ALTERED
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
GO

-- -----------------------------------------------------------
-- View stored procedure definition
-- -----------------------------------------------------------
EXEC sp_helptext 'usp_GetAllActiveEmployees';
GO

-- Alternative
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_GetAllActiveEmployees'));
GO

-- -----------------------------------------------------------
-- Drop a stored procedure
-- -----------------------------------------------------------
DROP PROCEDURE IF EXISTS usp_GetAllActiveEmployees;
GO
