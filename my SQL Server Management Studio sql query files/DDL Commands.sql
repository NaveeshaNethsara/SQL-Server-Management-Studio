--DML Commands--
--INSERT STATEMENT--
--type of INSERT-- 
	--1)inserting a single row--
INSERT INTO Student VALUES('S001','Amal','Mathara',20,3.9,'naveesha@gmail.com');
	--Inserting to user-specified columns--
INSERT INTO Student(stdid,name_,address_) VALUES ('S002','Nimal','Kaluthara');

--inserting multiple-rows--
INSERT  INTO Student VALUES('S003','Wimla','Colombo',21,2.8,'naveesha1@gmail.com'),
							('S004','Sunil','kandy',19,2.8,'naveesha2@gmail.com'),
							('S005','Wimla','Monaragala',21,2.8,'naveesha3@gmail.com'), 
							('S006','Rahal','Mathara',21,2.8,'naveesha4@gmail.com');

--Delete statement--
--Deleting all records
DELETE FROM Student;

--deleting only specified records--
DELETE FROM Student
WHERE address_='kandy';

--update statement--
--Upadate all records--
UPDATE Student
SET gpa=3.5;

--Upadet only specified records--
UPDATE Student 
SET gpa=3.9
WHERE stdid='S005';

Select * from Student;

