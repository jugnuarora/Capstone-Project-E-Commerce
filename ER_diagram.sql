 /*
Creation of ER Diagram for Brazilian e-commerce. 
Define the Primary Keys and Foreign Keys for all the tables.
While doing so, there was some redundant data found. For example in customers dataset, Sao Paulo was written in many different ways like Sau Palo, São Paulo and so on. So, we
removed the city and state from customer dataset as well as Sellers dataset as it can be picked from geolocation dataset. Also there were multiple combintations of latitudes
and longitudes for the same zip codes. So, we averaged the latitudes and longitudes for the same zip codes (like having the center point in the region).
In addition, there were English names as well as portugese names for the same zip codes. We kept only the English names for the ease of aggregation and report creation in Tableau
*/
SELECT count (DISTINCT order_id)
FROM orders_dataset;

ALTER TABLE orders_dataset
	ADD CONSTRAINT pk_order_id PRIMARY KEY (order_id);

ALTER TABLE customers_dataset
	ADD CONSTRAINT pk_customer_id PRIMARY KEY (customer_id);

ALTER TABLE orders_dataset
	ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id)
		REFERENCES customers_dataset(customer_id);

	
ALTER TABLE order_payments_dataset
	ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);

ALTER TABLE order_payments_dataset
	ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
	REFERENCES orders_dataset(order_id);

ALTER TABLE orders_reviews_dataset
	ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
	REFERENCES orders_dataset(order_id);

ALTER TABLE order_items_dataset
	ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
	REFERENCES orders_dataset(order_id);

ALTER TABLE order_items_dataset
	ADD CONSTRAINT pk_order_items_id PRIMARY KEY (order_id, product_id);

ALTER TABLE sellers_dataset
	ADD CONSTRAINT pk_seller_id PRIMARY KEY (seller_id);


ALTER TABLE products_dataset
	ADD CONSTRAINT pk_product_id PRIMARY KEY (product_id);

ALTER TABLE order_items_dataset
	ADD CONSTRAINT fk_seller_id FOREIGN KEY (seller_id)
	REFERENCES sellers_dataset(seller_id),
	ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id)
	REFERENCES products_dataset(product_id);

---Create dataset to have avg lat and lon for each zip code
CREATE TABLE geolocation_avg_dataset AS
	SELECT geolocation_zip_code_prefix, AVG(geolocation_lat) AS avg_geolocation_lat, AVG(geolocation_lng) AS avg_geolocation_lan, geolocation_city, geolocation_state
	FROM geolocation_dataset
	GROUP BY 1, 4, 5;
	

ALTER TABLE geolocation_avg_dataset
	DROP CONSTRAINT pk_geolocation_avg_location;

ALTER TABLE geolocation_dataset
	DROP CONSTRAINT pk_geolocation_location;

ALTER TABLE geolocation_dataset
	ADD CONSTRAINT pk_geolocation_location PRIMARY KEY (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng);

ALTER TABLE geolocation_avg_dataset
	ADD CONSTRAINT pk_geolocation_avg_location PRIMARY KEY (geolocation_zip_code_prefix, geolocation_city, geolocation_state);

	
ALTER TABLE sellers_dataset
	ADD CONSTRAINT fk_seller_location FOREIGN KEY (seller_zip_code_prefix, seller_city, seller_state)
	REFERENCES geolocation_avg_dataset(geolocation_zip_code_prefix, geolocation_city, geolocation_state);

--- Check for the zip codes, city and state in sellers dataset that are not matching in geolocation dataset

SELECT seller_zip_code_prefix, seller_city, seller_state
	FROM sellers_dataset
	WHERE (seller_zip_code_prefix, seller_city, seller_state) NOT IN 
	(SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state FROM geolocation_avg_dataset);

--- Check for the zip codes in sellers dataset which are not matching in geolocation dataset 

SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state 
	FROM sellers_dataset
	WHERE (seller_zip_code_prefix) NOT IN 
	(SELECT geolocation_zip_code_prefix FROM geolocation_avg_dataset);

--- Update the sellers zip code prefix based on the ones available in geolocation dataset

UPDATE sellers_dataset
SET seller_zip_code_prefix = 82840
WHERE seller_id = '5962468f885ea01a1b6a97a218797b0a';

UPDATE sellers_dataset
SET seller_zip_code_prefix = 91010
WHERE seller_id = '2aafae69bf4c41fbd94053d9413e87ee';

UPDATE sellers_dataset
SET seller_zip_code_prefix = 72592
WHERE seller_id = '2a50b7ee5aebecc6fd0ff9784a4747d6';

UPDATE sellers_dataset
SET seller_zip_code_prefix = 2286
WHERE seller_id = '2e90cb1677d35cfe24eef47d441b7c87';

UPDATE sellers_dataset
SET seller_zip_code_prefix = 7411
WHERE seller_id = '0b3f27369a4d8df98f7eb91077e438ac';

UPDATE sellers_dataset
SET seller_zip_code_prefix = 71540
WHERE seller_id = '42bde9fef835393bb8a8849cb6b7f245';

UPDATE sellers_dataset
SET seller_zip_code_prefix = 37709
WHERE seller_id = '870d0118f7a9d85960f29ad89d5d989a';

--- Update the sellers zip code prefix based on the ones available in geolocation dataset

SELECT geolocation_city, geolocation_state
	FROM geolocation_avg_dataset
	WHERE geolocation_zip_code_prefix = 55325;

--- Drop sellers_city and sellers_state from sellers_dataset

ALTER TABLE sellers_dataset
DROP COLUMN seller_city,
DROP COLUMN seller_state;

---Select first row of the data with duplicated zip codes
	
SELECT * FROM
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY geolocation_zip_code_prefix ORDER BY geolocation_city) AS row_id
FROM geolocation_avg_dataset
) AS a
WHERE row_id = 1;

SELECT count (DISTINCT geolocation_zip_code_prefix)
FROM geolocation_dataset;

--- Create new table with above view

DROP TABLE geolocation_final_dataset_eng;

CREATE TABLE geolocation_final_dataset_eng AS
SELECT * FROM
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY geolocation_zip_code_prefix ORDER BY geolocation_city) AS row_id
FROM geolocation_final_dataset
) AS a
WHERE row_id = 1;

ALTER TABLE geolocation_final_dataset_eng
DROP COLUMN row_id;

--- Add primary key to new geolocation dataset

ALTER TABLE geolocation_final_dataset_eng
	ADD CONSTRAINT pk_geo_location PRIMARY KEY (geolocation_zip_code_prefix);

--- Add foreign key to seller dataset
ALTER TABLE sellers_dataset
	ADD CONSTRAINT fk_seller_location FOREIGN KEY (seller_zip_code_prefix)
	REFERENCES geolocation_final_dataset_eng(geolocation_zip_code_prefix);

-----
SELECT count(DISTINCT seller_id)
FROM closed_deals_dataset cdd
WHERE seller_id NOT IN (SELECT seller_id FROM sellers_dataset sd);

SELECT count(DISTINCT seller_id)
FROM closed_deals_dataset cdd;

SELECT od.order_id, od.item_quantity, od.price, od.freight_value, opd.payment_sequential, opd.payment_installments, opd.payment_value
FROM order_items_dataset od 
INNER JOIN order_payments_dataset opd ON od.order_id = opd.order_id
WHERE od.item_quantity > 1
ORDER BY 1;

SELECT DISTINCT order_status
FROM orders_dataset od
WHERE od.order_id = '8272b63d03f5f79c56e9e4120aec44ef';

SELECT SUM(payment_value)
FROM order_payments_dataset
WHERE order_id = 'fa65dad1b0e818e3ccc5cb0e39231352';

SELECT order_id
FROM order_payments_dataset opd
GROUP BY order_id
HAVING COUNT(DISTINCT payment_type) > 1;

SELECT count(DISTINCT customer_id), count(DISTINCT order_id)
FROM orders_dataset od;

--- Delete foreign keys on order items dataset and drop the order_items_dataset

ALTER TABLE order_items_dataset
	DROP CONSTRAINT fk_order_id;

ALTER TABLE order_items_dataset
	DROP CONSTRAINT fk_product_id,
	DROP CONSTRAINT fk_seller_id;
	
DROP TABLE order_items_dataset;

--- create primary key and foreign keys for order_items_dataset

ALTER TABLE order_items_dataset
	ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);

ALTER TABLE order_items_dataset 
	ADD CONSTRAINT fk_order_id FOREIGN KEY (order_id)
	REFERENCES orders_dataset(order_id),
	ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id)
	REFERENCES products_dataset(product_id),
	ADD CONSTRAINT fk_seller_id FOREIGN KEY (seller_id)
	REFERENCES sellers_dataset(seller_id);

-----Customer dataset mapping with geolocation dataset

SELECT customer_zip_code_prefix, customer_city, customer_state
	FROM customers_dataset
	WHERE (customer_zip_code_prefix, customer_city, customer_state) NOT IN 
	(SELECT geolocation_zip_code_prefix, geolocation_city, geolocation_state FROM geolocation_avg_dataset_eng);



--- Merge the missing zip code table created to the geolocation avg dataset eng
CREATE TABLE geolocation_final_dataset AS
SELECT * 
FROM geolocation_avg_dataset_eng gade
UNION ALL
SELECT *
FROM zip_codes_dataset zcd;

INSERT INTO e_commerce.geolocation_final_dataset
(geolocation_zip_code_prefix, avg_geolocation_lat, avg_geolocation_lan, geolocation_city, geolocation_state)
VALUES(57254, -9.901, -36.2221, 'luziapolis', 'AL');


--- Check for the zip codes in customers dataset which are not matching in geolocation dataset 

SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state 
	FROM customers_dataset
	WHERE (customer_zip_code_prefix) NOT IN 
	(SELECT geolocation_zip_code_prefix FROM geolocation_final_dataset);

--- Update the zip code prefix in customer dataset with the maximum value in geolocation dataset
UPDATE customers_dataset
SET customer_zip_code_prefix = (SELECT max(geolocation_zip_code_prefix)
FROM geolocation_final_dataset
WHERE geolocation_city = customer_city)
WHERE customer_id IN (SELECT customer_id
	FROM customers_dataset
	WHERE (customer_zip_code_prefix) NOT IN 
	(SELECT geolocation_zip_code_prefix FROM geolocation_final_dataset));

--- Add foreign key to customer_dataset

ALTER TABLE customers_dataset
	ADD CONSTRAINT fk_customer_location FOREIGN KEY (customer_zip_code_prefix)
	REFERENCES geolocation_final_dataset_eng(geolocation_zip_code_prefix);

--- Drop customer city and state columns from customer dataset
ALTER TABLE customers_dataset
DROP COLUMN customer_city,
DROP COLUMN customer_state;

--- Add primary key to orders reviews dataset
ALTER TABLE orders_reviews_dataset
ADD CONSTRAINT pk_order_review PRIMARY KEY (order_id, review_id);

--- Add primary key to marketing qualified leads table
ALTER TABLE marketing_qualified_leads_dataset
ADD CONSTRAINT pk_marketing PRIMARY KEY (mql_id);

--- Add Primary key to closed deals dataset

ALTER TABLE closed_deals_dataset
ADD CONSTRAINT pk_closed PRIMARY KEY (mql_id);

ALTER TABLE closed_deals_dataset 
ADD CONSTRAINT fk_mql FOREIGN KEY (mql_id)
REFERENCES marketing_qualified_leads_dataset(mql_id);


--- Delete the extra created files
DROP TABLE customers_dataset_backup;
DROP TABLE customers_dataset_updated;
DROP TABLE geolocation_avg_dataset;
DROP TABLE geolocation_avg_dataset_eng;
DROP TABLE geolocation_dataset;
DROP TABLE zip_codes_dataset;

---check unique cities in geolocation dataset

SELECT DISTINCT geolocation_city 
FROM geolocation_final_dataset_eng
ORDER BY 1;


