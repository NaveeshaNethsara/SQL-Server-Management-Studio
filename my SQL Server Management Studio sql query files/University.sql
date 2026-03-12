

--DDL Commands--
--Creating a databse--
CREATE DATABASE University;


--select the databse--
USE University;

--creating table--
CREATE TABLE Student(
	stdid	CHAR(4) PRIMARY KEY,
	name_	VARCHAR(20),
	address_ CHAR(25),
	age		INTEGER,
	gpa		REAL
)

--Represent Candidate keys--
CREATE TABLE Student1(
	stdid	CHAR(4) PRIMARY KEY,
	NIC		CHAR(4) UNIQUE,
	name_	VARCHAR(20),
	address_ CHAR(25),
	age		INTEGER,
	gpa		REAL
)

--Represent Not null--
CREATE TABLE Student2(
	stdid	CHAR(4) PRIMARY KEY,
	NIC		CHAR(4) UNIQUE,
	name_	VARCHAR(20) NOT NULL,
	address_ CHAR(25),
	age		INTEGER,
	gpa		REAL
)

--Specifying default values--
CREATE TABLE Student3(
	stdid	CHAR(4) ,
	NIC		CHAR(4) ,
	name_	VARCHAR(20),
	address_ CHAR(25) DEFAULT'Matara',
	age		INTEGER,
	gpa		REAL
);

--Specifying valied values--
CREATE TABLE Emp(
	age int CHECK(age BETWEEN 0 AND 120),
	
);

--Referencial Intergrity Constraints--
--Foreign key.....References--
----

CREATE TABLE Grade
(
	subjectID CHAR(4),
	stdID		CHAR(4),
	grade		CHAR(2),
	PRIMARY KEY(subjectID,stdID),
	FOREIGN KEY(stdID) REFERENCES Student
	--why one above line is only mention table name--
	-- because of A foriegn key is one of primary key come another table's prime table--
);

CREATE TABLE Grade
(
	SubjectID CHAR(4)
	stdid
);

--removing a table--

--DROP TABLE Student;--i

--if we want drop the link of forieng key in future we can use bellow method--

CREATE TABLE Grade1
(
	subjectid CHAR(4),
	stdid		CHAR(10),
	grade		CHAR(2),
	PRIMARY KEY(subjectid,stdid),
	CONSTRAINT fk_Grade FOREIGN KEY(stdid) REFERENCES Student(stdid)

);
--add a new column--
ALTER TABLE Student ADD Email VARCHAR(12);

--Drop/remove a exixting column
ALTER TABLE Student DROP COLUMN Email;

--Changeing column Data size/range/definition--
ALTER TABLE Student ALTER COLUMN Email VARCHAR(30);--can't change data type can change the data range--

--Droping a Constraints--
ALTER TABLE Grade DROP fk_Grade;

--Adding a constraint--
ALTER TABLE Grade ADD CONSTRAINT fk_Grade FOREIGN KEY(stdid) REFERENCES Student(stdid);

--Add Cheack Constarint on GPA column of student table
ALTER TABLE Student ADD CONSTRAINT chk_Student CHECK(gpa BETWEEN 0 and 4);
