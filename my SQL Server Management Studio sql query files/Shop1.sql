use Company;
--List the employeee information with their department details who are working in the deparments
SELECT * FROM Employee,Department1
WHERE depNo=dno;

--print the name of the employees and the name of the names of their working departments

SELECT e_name_ AS 'Employee Name',dlocation AS 'Departmrnt Name' from Employee,Department1
WHERE depNo=dno;

--Aliasing--
--Example--
SELECT Employee.e_name_,Department1.dname 
FROM Employee,Department1
WHERE Employee.depNo=Department1.dno;

SELECT e.e_name_ AS 'Employee Name',d.dname AS 'Department name'
FROM Employee e,Department1 d
WHERE e.depNo=d.dno;