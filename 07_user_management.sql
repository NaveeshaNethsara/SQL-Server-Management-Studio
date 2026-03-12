-- ============================================================
-- User and Security Management
-- SQL Server Management Studio Query File
-- ============================================================

-- Switch to master to manage logins
USE master;
GO

-- -----------------------------------------------------------
-- Create a SQL Server login (SQL Authentication)
-- -----------------------------------------------------------
CREATE LOGIN AppLogin
WITH PASSWORD = 'StrongP@ssw0rd!',
     DEFAULT_DATABASE = MyDatabase,
     CHECK_EXPIRATION = ON,
     CHECK_POLICY = ON;
GO

-- -----------------------------------------------------------
-- Create a Windows login (Windows Authentication)
-- -----------------------------------------------------------
-- CREATE LOGIN [DOMAIN\UserName] FROM WINDOWS;
-- GO

-- -----------------------------------------------------------
-- View all logins
-- -----------------------------------------------------------
SELECT
    name            AS LoginName,
    type_desc       AS LoginType,
    is_disabled     AS IsDisabled,
    default_database_name,
    create_date,
    modify_date
FROM sys.server_principals
WHERE type IN ('S', 'U', 'G')  -- SQL login, Windows user, Windows group
ORDER BY name;
GO

-- -----------------------------------------------------------
-- Disable / enable a login
-- -----------------------------------------------------------
ALTER LOGIN AppLogin DISABLE;
GO
ALTER LOGIN AppLogin ENABLE;
GO

-- -----------------------------------------------------------
-- Change login password
-- -----------------------------------------------------------
ALTER LOGIN AppLogin WITH PASSWORD = 'NewStrongP@ssw0rd!';
GO

-- -----------------------------------------------------------
-- Drop a login
-- -----------------------------------------------------------
DROP LOGIN AppLogin;
GO

-- ============================================================
-- Database-level user management
-- ============================================================

USE MyDatabase;
GO

-- -----------------------------------------------------------
-- Create a database user mapped to a login
-- -----------------------------------------------------------
CREATE USER AppUser FOR LOGIN AppLogin;
GO

-- -----------------------------------------------------------
-- Create a database user without a login (contained database)
-- -----------------------------------------------------------
-- CREATE USER ContainedUser WITH PASSWORD = 'StrongP@ssw0rd!';
-- GO

-- -----------------------------------------------------------
-- View all users in the current database
-- -----------------------------------------------------------
SELECT
    name            AS UserName,
    type_desc       AS UserType,
    default_schema_name,
    create_date,
    modify_date
FROM sys.database_principals
WHERE type IN ('S', 'U', 'G')
ORDER BY name;
GO

-- -----------------------------------------------------------
-- Grant permissions to a user
-- -----------------------------------------------------------

-- Grant SELECT on a specific table
GRANT SELECT ON Employees TO AppUser;
GO

-- Grant multiple permissions on a table
GRANT SELECT, INSERT, UPDATE ON Employees TO AppUser;
GO

-- Grant execute on a stored procedure
GRANT EXECUTE ON usp_GetAllActiveEmployees TO AppUser;
GO

-- Grant schema-level permissions (all objects in schema)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO AppUser;
GO

-- Grant database-level permissions
GRANT CREATE TABLE TO AppUser;
GO

-- -----------------------------------------------------------
-- Revoke permissions
-- -----------------------------------------------------------
REVOKE INSERT ON Employees FROM AppUser;
GO
REVOKE CREATE TABLE FROM AppUser;
GO

-- -----------------------------------------------------------
-- Deny permissions (takes precedence over GRANT)
-- -----------------------------------------------------------
DENY DELETE ON Employees TO AppUser;
GO

-- -----------------------------------------------------------
-- Add user to a built-in database role
-- -----------------------------------------------------------

-- db_datareader: read all tables and views
ALTER ROLE db_datareader ADD MEMBER AppUser;
GO

-- db_datawriter: insert, update, delete all tables
ALTER ROLE db_datawriter ADD MEMBER AppUser;
GO

-- db_owner: full control of the database
-- ALTER ROLE db_owner ADD MEMBER AppUser;
-- GO

-- -----------------------------------------------------------
-- Remove user from a database role
-- -----------------------------------------------------------
ALTER ROLE db_datareader DROP MEMBER AppUser;
GO

-- -----------------------------------------------------------
-- Create a custom database role
-- -----------------------------------------------------------
CREATE ROLE ReportingRole;
GO

GRANT SELECT ON vw_ActiveEmployees    TO ReportingRole;
GRANT SELECT ON vw_DepartmentSummary  TO ReportingRole;
GRANT EXECUTE ON usp_GetAllActiveEmployees TO ReportingRole;
GO

ALTER ROLE ReportingRole ADD MEMBER AppUser;
GO

-- -----------------------------------------------------------
-- View user permissions
-- -----------------------------------------------------------
SELECT
    dp.class_desc,
    OBJECT_NAME(dp.major_id) AS ObjectName,
    dp.permission_name,
    dp.state_desc
FROM sys.database_permissions dp
WHERE dp.grantee_principal_id = USER_ID('AppUser')
ORDER BY dp.class_desc, ObjectName, dp.permission_name;
GO

-- View role membership
SELECT
    r.name  AS RoleName,
    m.name  AS MemberName
FROM sys.database_role_members rm
INNER JOIN sys.database_principals r ON rm.role_principal_id   = r.principal_id
INNER JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
ORDER BY r.name, m.name;
GO

-- -----------------------------------------------------------
-- Drop a database user and role
-- -----------------------------------------------------------
ALTER ROLE ReportingRole DROP MEMBER AppUser;
GO
DROP ROLE IF EXISTS ReportingRole;
GO
DROP USER IF EXISTS AppUser;
GO
