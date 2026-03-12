CREATE DATABASE SHOP;
USE SHOP;

CREATE TABLE Product(
	PName VARCHAR(10)PRIMARY KEY,
	Price INT,
	Catagory VARCHAR(10),
	Manufacture VARCHAR(10)
);

CREATE TABLE Companies(
	CName VARCHAR(10)PRIMARY KEY,
	StockPrice INT,
	Country VARCHAR(5)
);

INSERT INTO Product (PName, Price, Catagory,Manufacture)
VALUES 
    ('Gizmo',19.99, 'Gadgets','GizmoWorks'),
    ('Powergizmo',29.99, 'Gadgets','GizmoWorks'),
	('SingleTouch',149.99, 'Photography','Canon'),
	('MultiTouch',203.99, 'Household','Hitachi')

INSERT INTO Companies (CName, StockPrice, Country)
VALUES 
    ('Gizmo',25.00, 'USA'),
    ('Powergizmo',65.00, 'Japan'),
	('Gizmo',15.00	, 'Japan')

--find all products under $200 manufacture in japan;
--print their names and prices.
SELECT PName,Price 
FROM Product,Companies 
WHERE Price<200 AND Country='Japan';

