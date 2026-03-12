CREATE TABLE customers (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

INSERT INTO customers (customer_id, first_name, last_name) VALUES
(1, 'Fred', 'Fish'),
(2, 'Larry', 'Lobster'),
(3, 'Bubble', 'Bass'),
(4, 'Poppy', 'Puff');


CREATE TABLE transactions (
    transaction_id INT,
    amount DECIMAL(5, 2),
    customer_id INT,
    
);

INSERT INTO transactions (transaction_id, amount, customer_id) VALUES
(1000, 4.99, 3),
(1001, 2.89, 2),
(1002, 3.38, 3),
(1003, 4.99, 1),
(1004, 1.00, 4);

INSERT INTO transactions(amount,customer_id)
VALUES(1.00,NULL);

INSERT INTO customers(first_name,last_name)
VALUES('Poppy','Puff');

SELECT * FROM customers;

SELECT * FROM transactions;

--INNEER JOIN
SELECT transaction_id,amount,first_name,last_name FROM transactions INNER JOIN customers
ON transactions.customer_id=customers.customer_id;

--Left Join
SELECT * 
FROM transactions LEFT JOIN customers
ON transactions.customer_id=customers.customer_id;

--Right Join
SELECT * 
FROM transactions RIGHT JOIN customers
ON transactions.transaction_id=customers.customer_id;




DROP TABLE customers;
DROP TABLE transactions;