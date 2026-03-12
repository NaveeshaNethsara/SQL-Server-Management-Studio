--IN operator in SQL
`	--Set multiple values
	--Shorthand:Multiple OR conditions in SQL

	-- Creating the table
CREATE TABLE Employees (
    ID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    City VARCHAR(50),
    Salary INT
);

-- Inserting values
INSERT INTO Employees (ID, EmpName, City, Salary) VALUES
(1, 'Tom', 'ABC', 7000),
(2, 'Emma', 'PQR', 8000),
(3, 'Jeni', 'ZYW', 5000),
(4, 'David', 'FGH', 7500),
(5, 'Henry', 'PQR', 9500),
(6, 'Will', 'ABC', 6700);

SELECT * FROM Employees;

--Output will show us which values we give within parenthesis according to those City values DBMS is find who live in those cities and show all columns.
SELECT * FROM Employees
WHERE City IN('ZYW','FGH');

SELECT * FROM Employees
WHERE EmpName IN('Emma','Henry','Will');

--This will show the reverse process of IN keyword
SELECT * FROM Employees
WHERE EmpName NOT IN('Emma','Henry','Will');