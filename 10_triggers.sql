-- ============================================================
-- Triggers
-- SQL Server Management Studio Query File
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- AFTER trigger: log changes to an audit table
-- -----------------------------------------------------------

-- First create the audit table
CREATE TABLE EmployeeAudit
(
    AuditID      INT           NOT NULL IDENTITY(1,1),
    EmployeeID   INT           NOT NULL,
    Action       NVARCHAR(10)  NOT NULL,  -- INSERT, UPDATE, DELETE
    OldFirstName NVARCHAR(50)      NULL,
    NewFirstName NVARCHAR(50)      NULL,
    OldLastName  NVARCHAR(50)      NULL,
    NewLastName  NVARCHAR(50)      NULL,
    OldSalary    DECIMAL(10,2)     NULL,
    NewSalary    DECIMAL(10,2)     NULL,
    ChangedBy    NVARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
    ChangedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_EmployeeAudit PRIMARY KEY (AuditID)
);
GO

-- Create an AFTER INSERT, UPDATE, DELETE trigger
CREATE OR ALTER TRIGGER trg_Employees_Audit
ON Employees
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle INSERT
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO EmployeeAudit (EmployeeID, Action, NewFirstName, NewLastName, NewSalary)
        SELECT EmployeeID, 'INSERT', FirstName, LastName, Salary
        FROM inserted;
    END;

    -- Handle DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO EmployeeAudit (EmployeeID, Action, OldFirstName, OldLastName, OldSalary)
        SELECT EmployeeID, 'DELETE', FirstName, LastName, Salary
        FROM deleted;
    END;

    -- Handle UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO EmployeeAudit
            (EmployeeID, Action, OldFirstName, NewFirstName, OldLastName, NewLastName, OldSalary, NewSalary)
        SELECT
            i.EmployeeID,
            'UPDATE',
            d.FirstName, i.FirstName,
            d.LastName,  i.LastName,
            d.Salary,    i.Salary
        FROM inserted i
        INNER JOIN deleted d ON i.EmployeeID = d.EmployeeID;
    END;
END;
GO

-- -----------------------------------------------------------
-- INSTEAD OF trigger: prevent deletion, soft-delete instead
-- -----------------------------------------------------------
CREATE OR ALTER TRIGGER trg_Employees_SoftDelete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE e
    SET e.IsActive  = 0,
        e.UpdatedAt = SYSDATETIME()
    FROM Employees e
    INNER JOIN deleted d ON e.EmployeeID = d.EmployeeID;

    PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' employee(s) soft-deleted.';
END;
GO

-- -----------------------------------------------------------
-- DDL trigger: prevent table drops in production
-- -----------------------------------------------------------
CREATE OR ALTER TRIGGER trg_PreventTableDrop
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'Dropping tables is not allowed in this database!';
    ROLLBACK;
END;
GO

-- Disable a DDL trigger
DISABLE TRIGGER trg_PreventTableDrop ON DATABASE;
GO

-- Enable a DDL trigger
ENABLE TRIGGER trg_PreventTableDrop ON DATABASE;
GO

-- -----------------------------------------------------------
-- Server-level DDL trigger (requires sysadmin)
-- -----------------------------------------------------------
-- CREATE OR ALTER TRIGGER trg_ServerAuditLogin
-- ON ALL SERVER
-- FOR CREATE_LOGIN, DROP_LOGIN, ALTER_LOGIN
-- AS
-- BEGIN
--     PRINT 'Login change detected by: ' + SUSER_SNAME();
--     -- INSERT INTO AuditLog ...
-- END;
-- GO

-- -----------------------------------------------------------
-- AFTER trigger: enforce business rule
-- -----------------------------------------------------------
CREATE OR ALTER TRIGGER trg_Employees_SalaryCheck
ON Employees
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE Salary > 500000
    )
    BEGIN
        RAISERROR('Salary cannot exceed $500,000.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- -----------------------------------------------------------
-- View all triggers in the database
-- -----------------------------------------------------------
SELECT
    t.name                          AS TriggerName,
    OBJECT_NAME(t.parent_id)        AS TableName,
    t.type_desc,
    t.is_disabled,
    t.is_instead_of_trigger,
    te.type_desc                    AS EventType
FROM sys.triggers t
INNER JOIN sys.trigger_events te ON t.object_id = te.object_id
WHERE t.parent_class = 1   -- DML triggers (parent_class = 0 for DDL)
ORDER BY TableName, TriggerName;
GO

-- View DDL triggers
SELECT
    name        AS TriggerName,
    type_desc,
    is_disabled,
    parent_class_desc,
    create_date,
    modify_date
FROM sys.triggers
WHERE parent_class = 0  -- database-level DDL triggers
ORDER BY name;
GO

-- -----------------------------------------------------------
-- Disable and enable a DML trigger
-- -----------------------------------------------------------
DISABLE TRIGGER trg_Employees_Audit ON Employees;
GO
ENABLE TRIGGER trg_Employees_Audit ON Employees;
GO

-- Disable all triggers on a table
DISABLE TRIGGER ALL ON Employees;
GO
ENABLE TRIGGER ALL ON Employees;
GO

-- -----------------------------------------------------------
-- Drop triggers
-- -----------------------------------------------------------
DROP TRIGGER IF EXISTS trg_Employees_Audit;
GO
DROP TRIGGER IF EXISTS trg_Employees_SoftDelete;
GO
DROP TRIGGER IF EXISTS trg_Employees_SalaryCheck;
GO
DROP TRIGGER IF EXISTS trg_PreventTableDrop ON DATABASE;
GO
