USE amithDB;
--For Login
CREATE LOGIN afftan WITH PASSWORD='1122';
--For user
CREATE USER afftan FOR LOGIN afftan;

--DCL Commands GRANT and REVOKE

GRANT SELECT,UPDATE,INSERT
ON Employees
TO afftan;

SELECT * FROM Employees;

UPDATE Employee
SET EmpName='Shiran',City='Monaragala'
WHERE ID=3;

INSERT INTO Employee
VALUES

(7,'Sadira','Agulana',50000);

DELETE FROM Employees WHERE ID=1;

DROP TABLE Employee;