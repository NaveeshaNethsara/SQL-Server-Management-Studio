CREATE DATABASE Demo1;
USE Demo1;
CREATE TABLE Employee(
	eid VARCHAR(10),
	eName VARCHAR(30),
	salary DECIMAL(20,4),
	depNo VARCHAR(10),

	FOREIGN KEY(depNo) REFERENCES Deparment(dno)
	ON DELETE CASCADE
	ON UPDATE CASCADE

);

CREATE TABLE Deparment(
	dno VARCHAR(10),
	dName VARCHAR(30),
	location VARCHAR(15)

	PRIMARY KEY(dno)
);

INSERT INTO Employee
VALUES
	('E1101','Kamal',15000.0,'A0001'),
	('E1102','Nimal',16000.0,'A0001'),
	('E1103','Kasun',17000.0,'A0002'),
	('E1104','Gayan',18000.0,'A0002'),
	('E1105','Lakmal',19000.0,'A0003');

INSERT INTO Deparment
VALUES
	('A0001','aaaa','Colombo'),
	('A0002','bbbb','Kandy'),
	('A0003','cccc','Kurunagala'),
	('A0004','dddd','Kasbewa');

SELECT ename 
FROM Employee
WHERE depNo='A0001';

SELECT *
FROM Employee;

SELECT DISTINCT depno 
FROM Employee;

SELECT dname 
FROM Deparment
WHERE location='Colombo';

SELECT dname
FROM Deparment
WHERE location='Colombo' OR location='Kandy';

SELECT ename 
FROM Employee
WHERE depNo='A0001'
AND salary>10000;

SELECT * 
FROM Employee,Deparment
WHERE depNo=dno;

SELECT ename,dname
FROM Employee,Deparment
WHERE depNo=dno;

SELECT Employee.eName,Deparment.dName
FROM Employee,Deparment
WHERE Employee.depNo=Deparment.dno;

SELECT e.ename AS 'Employee Name',
	   d.dname AS 'Deparment Name'
FROM Employee e,Deparment d
WHERE e.depNo=d.dno;

DROP TABLE Deparment;