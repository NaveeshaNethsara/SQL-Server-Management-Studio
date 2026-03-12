CREATE TABLE Product(
	PName VARCHAR(15),
	Price DECIMAL(10,2),
	Category VARCHAR(25),
	Manufacture VARCHAR(35)

	PRIMARY KEY(PName)
);

CREATE TABLE Company(
	CName VARCHAR(35),
	StockPrice INT,
	Country VARCHAR(20)

	PRIMARY KEY(CName)

);

INSERT INTO Product
VALUES
	('Gizmo',19.99,'Gedgets','GimzoWorks'),
	('Powergizmo',29.99,'Gedgets','GimzoWorks'),
	('Single Touch',149.99,'Photography','Canon'),
	('MultiTouch',203.99,'Household','Hitachi');

INSERT INTO Company
VALUES
	('GizmoWorks',25,'USA'),
	('Canon',65,'Japan'),
	('Hitachi',15,'Japan');

SELECT * FROM Company;

SELECT PName AS 'Product Name',
Company.Country AS 'Made in',
Product.Price AS Value

FROM Product,Company
WHERE Product.Manufacture=Company.CName 
AND Country='Japan'
AND Product.Price<200;

DROP TABLE Product;
DROP TABLE Company;