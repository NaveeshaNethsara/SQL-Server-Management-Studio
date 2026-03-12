CREATE TABLE Person(
	ID int NOT NULL,
	LastName VARCHAR(255) NOT NULL,
	FirstName VARCHAR(255),
	age int CHECK(age>=18)
	
);

INSERT INTO Person
VALUES
	(1,'Naveesha','Nethsara',19),
	(2,'Chamashi','Dehenya',20),
	(3,'Inoka','Gangani',18);


CREATE TABLE Animal(
	AID VARCHAR(30) NOT NUll,
	LastName VARCHAR(255) NOT NULL,
	FirstName VARCHAR(255),
	age INT

	CONSTRAINT chk_age_18_plus CHECK(Age>=18),
	CONSTRAINT chk_ANI_ID CHECK(AID LIKE 'ANI%')
);

INSERT INTO Animal
VALUES
	('ANI1','Shepert',null,18),
	('ANI2','Tommy',null,19),
	('ANI3','Billy',null,20)
SELECT * FROM Animal;

--ADD Column to Existing Table
ALTER TABLE Animal
ADD good BIT;

--DROP Colmun FROM EXIXTING TABLE
ALTER TABLE Animal
DROP COLUMN good;

--Rename Column of a Existing Table
ALTER TABLE Animal
EXEC sp_rename 'Animal.GoodPet', 'FisrtName','COLUMN';

EXEC sp_rename 'Animal.GoodPet', 'FirstName', 'COLUMN';


UPDATE Animal
SET good=1
WHERE AID='ANI1';

UPDATE Animal
SET good=0
WHERE AID='ANI2';

UPDATE Animal
SET good=1
WHERE AID='ANI3';