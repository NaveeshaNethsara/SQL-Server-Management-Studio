SELECT * FROM Employees;
--ADD column to Existing table
ALTER TABLE Employees
ADD Email VARCHAR(60);

--Delete a column from a table
ALTER TABLE Employees
DROP COLUMN Telephone;

--Rename a column name
EXEC sp_rename 'Employees.Email','Telephone','COLUMN';

--Modify data type
ALTER TABLE Employees
ALTER COLUMN Telephone INT;



INSERT INTO Employees
VALUES(1,'Naveesha','Aluthagama',30000,0766151125);