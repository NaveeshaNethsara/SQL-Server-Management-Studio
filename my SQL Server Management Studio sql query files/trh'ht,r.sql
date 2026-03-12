--SP with no Perameter
CREATE PROCEDURE DisplayDetails
AS
BEGIN
	SELECT * FROM Student;
END;

--Run a strored SQL Procedures
EXECUTE DisplayDetails;

--Write a stored procedures to Display Details of students Whos is GPA is greater than USER Inputs
CREATE PROCEDURE StudentGPADetails(@gpa FLOAT)
AS
BEGIN
	SELECT *
	FROM Student
	WHERE gpa>@gpa
END;

--Runs stored procedures with arguements
EXECUTE StudentGPADetails @gpa=3.2;

--Write a stored procedures to Display Details of student which city user 
CREATE PROCEDURE StudentAddresssADetails(@address VARCHAR(50))
AS
BEGIN
	SELECT *
	FROM Student
	WHERE address_=@address
END;

EXECUTE StudentAddresssADetails @address='Mathara';

--create Stored procedure to display Whose gpa is greater than the user given gpa and Adrress is eaual to user specified adress
--Stored Procedure
CREATE PROCEDURE DisplayStudentGpaANDAddress(@gpa FLOAT ,@address VARCHAR(50))
AS
BEGIN
	SELECT *
	FROM Student
	WHERE gpa>@gpa AND address_=@address
END;

EXECUTE DisplayStudentGpaANDAddress @gpa=2.5,@address='Mathara';