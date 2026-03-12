CREATE DATABASE Demo2;
USE Demo2;
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,            -- Unique identifier for each employee
    FirstName NVARCHAR(50),                -- Employee's first name
    LastName NVARCHAR(50),                 -- Employee's last name
    Email NVARCHAR(100) UNIQUE,            -- Employee's email (must be unique)
    HireDate DATE,                         -- Date when the employee was hired
    Salary DECIMAL(10, 2),                 -- Employee's salary with 2 decimal places
    Department NVARCHAR(50)                -- Department where the employee works
);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, HireDate, Salary, Department)
VALUES (1, 'John', 'Doe', 'john.doe@example.com', '2021-05-15', 55000.00, 'IT');

INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, HireDate, Salary, Department)
VALUES (2, 'Jane', 'Smith', 'jane.smith@example.com', '2022-03-10', 62000.00, 'HR');

INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, HireDate, Salary, Department)
VALUES (3, 'Michael', 'Johnson', 'michael.johnson@example.com', '2020-11-22', 58000.00, 'Finance');

INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, HireDate, Salary, Department)
VALUES (4, 'Emily', 'Clark', 'emily.clark@example.com', '2021-09-01', 60000.00, 'Marketing');

SELECT * FROM Employees;

--Create Login
CREATE LOGIN Naveesha WITH PASSWORD='navee2006';

--Creating a user
CREATE USER naveebro FOR LOGIN Naveesha;

--Give permission to user only SELECT permission
GRANT SELECT,UPDATE ON Employees TO naveebro;


--Remove SELECT permission from Naveesha
REVOKE SELECT ON Employees FROM naveeebro;

SELECT * FROM sys.objects WHERE principal_id=USER_ID('naveeebro');

DROP USER naveebro;
DROP LOGIN Naveesha;

