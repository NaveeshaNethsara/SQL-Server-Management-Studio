CREATE DATABASE DB1;
USE DB1;

CREATE TABLE Author(
	Login_ VARCHAR(12),
	Name_ VARCHAR(50)
);

CREATE TABLE Document(
	URL_ VARCHAR(50),
	Title VARCHAR(50),
);

CREATE TABLE Wrote(
	Login__ VARCHAR(50),
	Url__ VARCHAR(50),
);
--Find all athours who wrote at least 10 Documents
