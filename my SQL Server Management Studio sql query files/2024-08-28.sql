
USE SHOP;
CREATE TABLE Purchase(
	Product VARCHAR(50),
	Date DATE,
	Price DECIMAL(10,4),
	Quantity INT
);

INSERT INTO Purchase
VALUES
	('Apple','2024-10-21',35,15),
	('Banana','2024-10-21',10.50,7),
	('Apple','2024-10-20',40,20),
	('Banana','2024-10-19',11,17);

--Find total sales for the entire database

SELECT SUM(Price*Quantity) AS TotalSales
FROM Purchase;


--Find total sale for each product*
SELECT Product,SUM(Price*Quantity) AS TotalSales
FROM Purchase
GROUP BY Product;

SELECT Product,SUM(Price*Quantity) AS 'TotalSales' 
FROM Purchase
WHERE Date>'2023-10-20'
GROUP BY 