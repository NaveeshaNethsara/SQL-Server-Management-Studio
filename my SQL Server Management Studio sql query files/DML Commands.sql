--Search operation--
--Keyword is SELECT--
CREATE DATABASE Company;

USE Company;
CREATE TABLE Department1(
	dno	CHAR(6) PRIMARY KEY,
	dname	VARCHAR(20),
	dlocation VARCHAR(20) 
)
CREATE TABLE Employee(
	e_id	CHAR(6) PRIMARY KEY,
	e_name_	VARCHAR(20),
	salary INT,
	depNo char(6),
	FOREIGN KEY(depNo) REFERENCES Department1(dno)
	
);
INSERT  INTO Employee VALUES('E1101','Kamal',15000,'A0001'),
							('E1102','Nimal',16000,'A0001'),
							('E1103','Kusum',17000,'A0002'),
							('E1104','Gayan',18000,'A0002'),
							('E1105','Lakmal',19000,'A0003');

INSERT  INTO Department1 VALUES('A0001','Kamal','colombo'),
							('A0002','Nimal','colombo'),
							('A0003','Kusum','Galle'),
							('A0004','Gayan','Kandy');
							--('A0001','Lakmal','colombo');

SELECT e_name_ FROM Employee;

SELECT e_id AS'Employee id',e_name_ AS 'Employee Name' FROM Employee;

--1)select name of employees which works in dept A0001--

SELECT e_name_ FROM Employee
WHERE depNo='A0001';

--2)display the all the details of all employee--
--Way1--
SELECT * from Employee;
--use of Asterisk(*) is means all columns
--Way2--
SELECT ALL depNo FROM Employee;--ALl key word is default--

---Display all department numbers in  employee Table--
SELECT depNo FROM Employee;

SELECT DISTINCT depNo
FROM Employee;

UPDATE Department1
SET dlocation='Galle'
WHERE dno='A0003';

UPDATE Department1
SET dlocation='Kandy'
WHERE dno='A0004';


--List all the department names which are in colombo--
SELECT dname 
FROM Department1 
WHERE dlocation='colombo';

--List all the deparmentswhich are in colombo or kandy
SELECT dname 
FROM Department1 
WHERE dlocation='colombo' OR dlocation='kandy';

--List all the employee names who are in deparment A0001 and salary greter than 10,000 LKR)
SELECT e_name_ FROM Employee where depNo='A0001' AND salary>10000;