--BETWEEN Operator
	--select values in a range i.e.BETWEEN
	--Values:numbers like 1,2,3
		   --text:Tom,Jack,........
		   --Dates:2021-07-14,2021-07-16, etc.
USE amithDB;
SELECT * FROM Employees;

--This will give which records are with in that beween 7000 and 9000 range 
SELECT * 
FROM Employees
WHERE Salary BETWEEN 7000 AND 9000;

--This will give records which is not in range between 7000 and 9000 range
SELECT * 
FROM Employees
WHERE Salary NOT BETWEEN 7000 AND 9000;

SELECT * FROM Employees;
SELECT * 
FROM Employees
WHERE EmpName BETWEEN 'David' AND 'Jeni'
ORDER BY EmpName;
