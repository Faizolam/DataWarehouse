CREATE TABLE dimDate
(	
	date_key integer NOT NULL PRIMARY KEY,
	date date NOT NULL,
	year smallint NOT NULL,
	quarter smallint NOT NULL,
	month smallint NOT NULL,
	day smallint NOT NULL,
	week smallint NOT NULL,
	is_weekend boolean
);

CREATE TABLE dimCustomer
(
customer_key 	SERIAL PRIMARY KEY,
coustomer_id 	SMALLINT NOT NULL,
first_name 		VARCHAR(45) NOT NULL,
last_name  		VARCHAR(45) NOT NULL,
email 			VARCHAR(45),
address 		VARCHAR(50) NOT NULL,
address2 		VARCHAR(45),
district 		VARCHAR(45) NOT NULL,
city 			VARCHAR(45) NOT NULL,
country 		VARCHAR(45) NOT NULL,
postal_code 	VARCHAR(45),
phone			VARCHAR(20) NOT NULL,	
active			SMALLINT NOT NULL,	
create_date 	TIMESTAMP NOT NULL,
start_date 		DATE NOT NULL,
end_date 		DATE NOT NULL
);

CREATE TABLE dimStore
(
store_key			SERIAL PRIMARY KEY,							
store_id			SMALLINT NOT NULL,			
address				VARCHAR(50) NOT NULL,
address2			VARCHAR(50),	
district			VARCHAR(45) NOT NULL,	
city				VARCHAR(50) NOT NULL,
country				VARCHAR(50) NOT NULL,
postal_code			VARCHAR(10),	
manager_first_name	VARCHAR(45) NOT NULL,			
manager_last_name	VARCHAR(45) NOT NULL,			
start_date			date NOT NULL,	
end_date			date NOT NULL		
);

CREATE TABLE dimMovie
(
movie_key 			SERIAL PRIMARY KEY,
film_id				SMALLINT NOT NULL,
title 				VARCHAR(255) NOT NULL,
description 		TEXT,
release_year 		YEAR,
language 			VARCHAR(20) NOT NULL,
original_language	VARCHAR(20),
rental_duration     SMALLINT NOT NULL,	
length				SMALLINT NOT NULL,
ratings				VARCHAR(5) NOT NULL,
special_features	VARCHAR(60) NOT NULL
);


CREATE TABLE factSales(
		sales_key 	 SERIAL PRIMARY KEY,
		date_key	 INTEGER REFERENCES dimDate(date_key),
		customer_key INTEGER REFERENCES dimCustomer(customer_key),
		sales_amount NUMERIC,
		store_key	 INTEGER REFERENCES dimStore(store_key),
		movie_key	 INTEGER REFERENCES dimMovie(movie_key)
);


--Insert data dimDate TABLE
INSERT INTO dimDate
(date_key,date,year,quarter,month,day,week,is_weekend)
SELECT
	
	DISTINCT(TO_CHAR(payment_date :: DATE, 'yyyyMMDD') ::INTEGER) AS date_key,
	date(payment_date) 					as date,
	EXTRACT(year from payment_date)		as year,
	EXTRACT(quarter from payment_date)	as quarter,
	EXTRACT(month from payment_date)	as month,
	EXTRACT(day from payment_date)		as day,
	EXTRACT(week from payment_date)		as week,
	CASE WHEN EXTRACT(ISODOW from payment_date) IN (6,7) THEN TRUE ELSE FALSE END as week
FROM payment;


--Insert data dimCustomer TABLE
INSERT INTO dimCustomer(customer_key,coustomer_id,first_name,last_name,email,
						address,address2,district,city,country,postal_code,phone,
						active,create_date,start_date,end_date)
SELECT C.customer_id AS customer_key,
	   C.customer_id,
	   C.first_name,
	   C.last_name,
	   C.email,
	   A.address,
	   A.address2,
	   A.district,
	   CI.city,
	   CO.country,
	   A.postal_code,
	   A.phone,
	   C.active,
	   C.create_date,
	   NOW()          AS start_date,
	   NOW()		  AS end_date
FROM customer C
JOIN address A ON (C.address_id = A.address_id)
JOIN city CI   ON (A.city_id = CI.city_id)
JOIN country CO ON (CI.country_id = CO.country_id);

--SELECT * FROM dimCustomer WHERE address2 = 'NULL'

--Insert data dimStore TABLE
INSERT INTO dimStore(store_key, store_id, address, address2,district, city, country,
					 postal_code, manager_first_name, manager_last_name, start_date, end_date)

SELECT S.store_id AS store_key,
	   S.store_id,
	   A.address,
	   A.address2,
	   A.district,
	   CI.city,
	   CU.country,
	   A.postal_code,
	   ST.first_name AS manager_first_name,
	   ST.last_name AS manager_last_name,
	   NOW()          AS start_date,
	   NOW()		  AS end_date
FROM store S
JOIN address A ON (S.address_id = A.address_id)
JOIN city CI ON (A.city_id = CI.city_id)
JOIN country CU ON (CI.country_id = CU.country_id)
JOIN staff ST ON (S.store_id = ST.store_id);


--Insert data dimMovie TABLE
INSERT INTO dimMovie(movie_key, film_id, title, description, release_year, language,
					 rental_duration, length, ratings, special_features)
SELECT 
		F.film_id AS movie_key,
		F.film_id,
		F.title,
		F.description,
		F.release_year,
		L.name AS language,
		F.rental_duration,
		F.length,
		F.rating,
		F.special_features
FROM film F 
JOIN language L ON (F.language_id = L.language_id);



--Insert data factSales TABLE
INSERT INTO factSales(date_key, customer_key, sales_amount, store_key, movie_key)
SELECT 
		TO_CHAR(payment_date :: DATE, 'yyyyMMDD')::INTEGER AS date_key,
		P.customer_id AS customer_key,
		P.amount AS sales_amount,
		I.store_id AS store_key,
		I.film_id AS movie_key
FROM payment P
JOIN rental R ON (R.rental_id = P.rental_id)
JOIN inventory I ON (R.inventory_id = I.inventory_id);

--VIEW TABLES DATA
select * from dimMovie;
select * from dimDate;
select * from factsales;
select * from dimStore;
select * from dimCustomer;



--garbage
Truncate table factsales
Truncate table dimDate RESTART IDENTITY CASCADE; 
TRUNCATE sch.mytable RESTART IDENTITY CASCADE;


select * from payment limit 10;
select DISTINCT(payment_date :: DATE, 'yyyyMMDD') from payment limit 10;




SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'dimdate'
SELECT COUNT(payment_date) FROM payment WHERE RTRIM(TO_CHAR(payment_date, 'day')) = 'monday'

SELECT
  payment_date::DATE,
  EXTRACT(ISODOW FROM payment_date),
  to_char(payment_date, 'DAY')
FROM
  payment
WHERE
  to_char(payment_date, 'DAY') = 'WEDNESDAY';












