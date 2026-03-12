CREATE DATABASE amithDB;
CREATE TABLE Employee(
	ID INT,
	EmpName VARCHAR(15),
	City VARCHAR(25),
	Salary INT
);

INSERT INTO Employee
VALUES
	(1,'Tom','ABC',7000),
	(2,'Emma','PQR',8000),
	(3,'Jeni','ZYW',5000),
	(4,'Devid','FHG',7500),
	(5,'Henry','PQR',9500),
	(6,'Will','ABC',6700);
USE amithDB;
DROP TABLE Employee;

SELECT * FROM Employee;

SELECT COUNT(DISTINCT City) FROM Employee;

SELECT EmpName,salary
FROM Employee
WHERE ID=1 or ID=2;

SELECT EmpName 
FROM Employee
WHERE Salary BETWEEN 5000 AND 7000;

SELECT *
FROM Employee
WHERE EmpName LIKE 'E%';

SELECT *
FROM Employee
WHERE EmpName LIKE '__e%';

SELECT *
FROM Employee
WHERE EmpName LIKE '[^ET]%'

SELECT * 
FROM Employee
ORDER BY EmpName,City;

SELECT *
FROM Employee
WHERE City='ABC' AND EmpName LIKE 'w_l%';

SELECT *
FROM Employee
WHERE City='ABC'
AND EmpName='Will'
AND Salary<67001;

SELECT *
FROM Employee
WHERE City='ABC' AND (EmpName LIKE 'W%' OR EmpName LIKE 'H%');

SELECT *
FROM Employee
WHERE City='ABC' OR City='PQR'
ORDER BY EmpName DESC;

UPDATE Employee
SET EmpName='Eve Hanah'
WHERE ID=2;


UPDATE Employee
SET EmpName='William'
WHERE ID=1;
