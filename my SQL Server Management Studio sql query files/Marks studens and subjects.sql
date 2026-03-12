--Having Clause

--This cluase used to filter data
	--It is like where Clause but there little bit difference
	--Where is used for give condition to normal rows 
	--Having is used to give condition to Group of rows(Which we gatting using GROUP BY)
	--HAVING is always or most of time used with GROUP BY Caluse
	--But we can use HAVING without GROUP BY but is act like same as WHERE clause in that situation

--Synatx
	--SELECT columnList FROM table_Name
	--WHERE search_Condition
	--GROUP BY group by expressions
	--Having group_conditions

CREATE TABLE Marks(
	StudentID INT,
	SubjectID VARCHAR(20),
	Marks INT,
	
	PRIMARY KEY(StudentID,SubjectID),
	FOREIGN KEY(StudentID) REFERENCES Student(Student_ID),
	FOREIGN KEY(SubjectID) REFERENCES Subject(SubjectID)
);

CREATE TABLE Student(
	Student_ID INT,
	Student_Name VARCHAR(20),
	Mobile_No VARCHAR(30)

	PRIMARY KEY(Student_ID)
);

CREATE TABLE Subject(
	SubjectID VARCHAR(20),
	Subject VARCHAR(30)

	PRIMARY KEY(SubjectID)
);

INSERT INTO Marks (StudentID, SubjectID, Marks) VALUES
(2, 'SUB001', 76),
(2, 'SUB002', 50),
(2, 'SUB003', 64),
(2, 'SUB004', 48),
(2, 'SUB005', 52),
(3, 'SUB001', 67),
(3, 'SUB003', 72),
(3, 'SUB004', 75),
(3, 'SUB005', 87),
(4, 'SUB001', 69),
(4, 'SUB003', 37),
(4, 'SUB004', 75),
(4, 'SUB005', 36);


INSERT INTO Student(Student_ID, Student_Name,Mobile_No) VALUES
(1, 'Kamal', '0713337773'),
(2, 'Sunil', '0711234333'),
(3, 'Mala', NULL),
(4, 'Nimal', NULL),
(5, 'Amal', NULL);

INSERT INTO Subject(SubjectID, Subject) VALUES
('SUB001', 'Sinhala'),
('SUB002', 'Maths'),
('SUB003', 'Science'),
('SUB004', 'Tamil'),
('SUB005', 'English');


DROP TABLE Marks;
DROP TABLE Student;
DROP TABLE Subject;

SELECT SubjectID,AVG(Marks) 'Average Marks'
FROM Marks GROUP BY SubjectID
HAVING AVG(Marks)>60;

SELECT SubjectID,MIN(Marks) 
FROM Marks GROUP BY SubjectID Having MIN(Marks)<40;

