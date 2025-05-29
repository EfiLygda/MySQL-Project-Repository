
-- 1.  Simple SQL questions per table (total 165)

--  Includes:
--  no joins, no subqueries, just single-table queries using 
--  SELECT, WHERE, GROUP BY, HAVING, ORDER BY, and also CASE
--  MIN, MAX, COUNT, AVG, SUM, MOD, DIV, LENGTH, INSTR, SUBSTR, UPPER, LOWER
--  with conditions including AND, OR, BETWEEN, IN and null handling.

USE e_commerce;

-------------------------------------------------------------------------------------------------------------------------------
-- Table: customers
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all customers from Goiás state.
SELECT	* 
FROM 	customers
WHERE	customer_state = 'GO';


-- Q2. Count how many customers are from each city.
SELECT		customer_city, COUNT(DISTINCT customer_id) AS customer_count
FROM 		customers
GROUP BY	customer_city
ORDER BY	customer_count	DESC;


-- Q3. Find the minimum and maximum zip code prefix values.
SELECT		MIN(customer_zip_code_prefix) AS min_prefix, MAX(customer_zip_code_prefix) AS max_prefix
FROM 		customers;


-- Q4. Calculate the average zip code prefix for customers in Goiás state.
SELECT		customer_state, AVG(customer_zip_code_prefix) AS avg_prefix
FROM 		customers
WHERE		customer_state = 'GO';


-- Q5. List customers where the city is not null.
SELECT		customer_id, customer_city
FROM 		customers
WHERE		customer_city IS NOT NULL
ORDER BY	customer_city;


-- Q6. Find the total number of distinct customer unique ids.
SELECT		COUNT(DISTINCT customer_unique_id) AS distinct_customer_id
FROM 		customers;


-- Q7. Count customers where the zip code prefix is between 9000 and 10000.
SELECT		customer_zip_code_prefix, COUNT(DISTINCT customer_id) AS customer_id_count
FROM 		customers
WHERE		customer_zip_code_prefix BETWEEN 9000 AND 10000
GROUP BY	customer_zip_code_prefix
ORDER BY	customer_zip_code_prefix;


-- Q8. Retrieve customers from Sao Paolo or Goiás state.
SELECT		customer_id, customer_state
FROM 		customers
WHERE		customer_state IN ('SP', 'GO') 
ORDER BY	customer_state;


-- Q9. List customers that don't have customer unique ids.
SELECT		customer_id, customer_unique_id
FROM 		customers
WHERE		customer_unique_id IS NULL 
ORDER BY	customer_id;


-- Q10. Show only those states with more than 100 customers.
SELECT		customer_state, COUNT(DISTINCT customer_unique_id) AS customer_count
FROM 		customers
GROUP BY	customer_state
HAVING		customer_count > 100
ORDER BY	customer_count DESC;


-- Q11. Order customers by ascending customer zip code prefixes.
SELECT		customer_unique_id, customer_zip_code_prefix
FROM 		customers
ORDER BY	customer_zip_code_prefix;


-- Q12. Count customers for each city where zip code prefix is not null.
SELECT		customer_city, COUNT(DISTINCT customer_unique_id) AS customer_count 
FROM 		customers
WHERE		customer_zip_code_prefix IS NOT NULL
GROUP BY	customer_city
ORDER BY	customer_count DESC;


-- Q13. List customers where customer state is not null and customer city is Rio de Janeiro.
SELECT		customer_unique_id, customer_city, customer_state
FROM 		customers
WHERE		customer_state IS NOT NULL AND customer_city = 'rio de janeiro'
ORDER BY	customer_state DESC;


-- Q14. Find the number of customers in states starting with letter 'S'.
SELECT		customer_state, COUNT(DISTINCT customer_unique_id) AS customer_count
FROM 		customers
GROUP BY	customer_state
HAVING		customer_state LIKE 'S%'
ORDER BY	customer_count DESC;


-- Q15. Show the top 5 cities with the most customers.
SELECT		customer_state, COUNT(DISTINCT customer_unique_id) AS customer_count
FROM 		customers
GROUP BY	customer_state
ORDER BY	customer_count DESC
LIMIT		5;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: geolocation
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all records where their geolocation state is Goiás.
SELECT		*
FROM		geolocation
WHERE		geolocation_state = 'GO';


-- Q2. Count how many geolocation entries exist for each city.
SELECT		geolocation_city, COUNT(geolocation_zip_code_prefix) AS geolocation_count
FROM		geolocation
GROUP BY	geolocation_city
ORDER BY	geolocation_count DESC;


-- Q3. Find the minimum and maximum latitude values.
SELECT		MIN(geolocation_lat) AS min_lat, MAX(geolocation_lat) AS max_lat
FROM		geolocation;


-- Q4. Calculate the average longitude for a given state.
SELECT		geolocation_state, AVG(geolocation_lng) AS avg_lat
FROM		geolocation
WHERE		geolocation_state = 'RJ';


-- Q5. List all entries where geolocation city is null.
SELECT		*
FROM		geolocation
WHERE		geolocation_city IS NULL;


-- Q6. Count distinct zip code prefixes.
SELECT		COUNT(DISTINCT geolocation_zip_code_prefix) AS zip_count
FROM		geolocation;


-- Q7. List geolocation entries where latitude is in [-1,1].
SELECT		geolocation_zip_code_prefix, geolocation_lat
FROM		geolocation
WHERE		geolocation_lat BETWEEN -1 AND 1
ORDER BY	geolocation_zip_code_prefix;


-- Q8. Find all entries with geolocation state in Rio de Janeiro or São Paulo.
SELECT		geolocation_zip_code_prefix, geolocation_state
FROM		geolocation
WHERE		geolocation_state IN ('RJ', 'SP')
ORDER BY	geolocation_state;


-- Q9. Count entries where longitude is null.
SELECT		COUNT(geolocation_zip_code_prefix) AS null_lat_count
FROM		geolocation
WHERE		geolocation_lng IS NULL;


-- Q10. Show states with more than 50 entries.
SELECT		geolocation_state, COUNT(geolocation_zip_code_prefix) AS entry_count
FROM		geolocation
GROUP BY	geolocation_state
HAVING		entry_count > 50
ORDER BY	entry_count DESC;


-- Q11. Order by geolocation zip code prefix descending.
SELECT		*
FROM		geolocation
ORDER BY	geolocation_zip_code_prefix DESC;


-- Q12. Count entries per city where zip code prefix is not null.
SELECT		geolocation_city, COUNT(geolocation_zip_code_prefix) AS entry_count
FROM		geolocation
WHERE		geolocation_zip_code_prefix IS NOT NULL
GROUP BY	geolocation_city
ORDER BY	entry_count DESC;


-- Q13. List entries where state is not null and city is Rio de Janeiro
SELECT		COUNT(geolocation_zip_code_prefix) AS entry_count
FROM		geolocation
WHERE		geolocation_state IS NOT NULL AND geolocation_city = 'rio de janeiro';


-- Q14. Count entries for states starting with 'M'.
SELECT		geolocation_state, COUNT(geolocation_zip_code_prefix) AS entry_count
FROM		geolocation
WHERE		geolocation_state LIKE 'M%'
GROUP BY	geolocation_state
ORDER BY	entry_count DESC;


-- Q15. Show the top 10 cities with the most geolocation entries.
SELECT		geolocation_city, COUNT(geolocation_zip_code_prefix) AS entry_count
FROM		geolocation
GROUP BY	geolocation_city
ORDER BY	entry_count DESC
LIMIT		10;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: leads_closed
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all leads that are from resellers.
SELECT		*
FROM		leads_closed
WHERE		business_type = 'reseller';


-- Q2. Count leads by lead type.
SELECT		lead_type, COUNT(*) AS lead_count
FROM		leads_closed
GROUP BY	lead_type
ORDER BY	lead_count DESC;


-- Q3. Find minimum and maximum declared monthly revenue.
SELECT		MIN(declared_monthly_revenue) AS min_revenue, MAX(declared_monthly_revenue) AS max_revenue
FROM		leads_closed;


-- Q4. Calculate average declared product catalog size by business type.
SELECT		business_type, AVG(declared_product_catalog_size) AS avg_product_size
FROM		leads_closed
GROUP BY	business_type
ORDER BY	avg_product_size DESC;


-- Q5. List leads where has_company is null.
SELECT		business_type, AVG(declared_product_catalog_size) AS avg_product_size
FROM		leads_closed
WHERE		declared_product_catalog_size IS NOT NULL
GROUP BY	business_type
ORDER BY	avg_product_size DESC;


-- Q6. Count leads that have a global trade item number
SELECT		COUNT(*) AS lead_count
FROM		leads_closed
WHERE		has_gtin = 1;


-- Q7. Find leads where declared monthly revenue is between 10000 and 30000.
SELECT		COUNT(*) AS lead_count
FROM		leads_closed
WHERE		declared_monthly_revenue BETWEEN 10000 AND 30000;


-- Q8. Retrieve leads where lead behaviour profile is either cat, eagle or wolf.
SELECT		*
FROM		leads_closed
WHERE		lead_behaviour_profile IN ('cat', 'eagle', 'wolf');


-- Q9. Count leads where the date when the lead was successfully closed or converted is null.
SELECT		COUNT(*) AS lead_count
FROM		leads_closed
WHERE		won_date IS NULL;


-- Q10. Show sellers with more than 5 leads.
SELECT		seller_id, COUNT(*) AS lead_count
FROM		leads_closed
GROUP BY	seller_id
HAVING		lead_count > 5;


-- Q11. Order leads by declared monthly revenue descending.
SELECT		*
FROM		leads_closed
ORDER BY	declared_monthly_revenue DESC;


-- Q12. Count leads for each business segment that have a company.
SELECT		business_type, COUNT(*) AS lead_count
FROM		leads_closed
WHERE		has_company = 1
GROUP BY	business_type
ORDER BY	lead_count DESC;


-- Q13. Count leads where their average stock in to null.
SELECT		COUNT(average_stock) AS average_stock_not_null
FROM		leads_closed
WHERE		average_stock IS NOT NULL;


-- Q14. Count leads by lead type with declared monthly revenue greater than 10000.
SELECT		lead_type, COUNT(*) AS lead_count
FROM		leads_closed
WHERE		declared_monthly_revenue > 10000
GROUP BY	lead_type
ORDER BY	lead_count DESC;


-- Q15. Show top 10 sellers with most leads closed in the reseller sector of business.
SELECT		seller_id, COUNT(*) AS lead_count
FROM		leads_closed
WHERE		business_type = 'reseller'
GROUP BY	seller_id
ORDER BY	lead_count DESC
LIMIT		10;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: leads_qualified
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select leads qualified from social media.
SELECT		*
FROM		leads_qualified
WHERE		origin = 'social';


-- Q2. Count leads by landing page id.
SELECT		landing_page_id, COUNT(*) AS lead_count
FROM		leads_qualified
GROUP BY	landing_page_id
ORDER BY	lead_count DESC;


-- Q3. Find earliest and latest first contact date.
SELECT		MIN(first_contact_date) AS earliest_date, MAX(first_contact_date) AS latest_date
FROM		leads_qualified;


-- Q4. List leads where landing page id is null.
SELECT		*
FROM		leads_qualified
WHERE		landing_page_id IS NULL;


-- Q5. Count distinct marketing qualified lead ids.
SELECT		COUNT(DISTINCT mql_id) as distinct_ids
FROM		leads_qualified;


-- Q6. Retrieve leads where first_contact_date is between 2018 and 2020.
SELECT		*
FROM		leads_qualified
WHERE		year(first_contact_date) BETWEEN 2018 AND 2020;


-- Q7. Count leads where their origin is known.
SELECT		COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		origin <> 'unknown' AND origin IS NOT NULL;


-- Q8. Find leads where first contact date is null.
SELECT		COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		first_contact_date IS NULL;


-- Q9. Show lead origins with more than 10 leads.
SELECT		origin, COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		origin IS NOT NULL
GROUP BY	origin
HAVING		lead_count > 10
ORDER BY	lead_count	DESC;


-- Q10. Order leads by first contact date ascending.
SELECT		*
FROM		leads_qualified
ORDER BY	first_contact_date;


-- Q11. Count leads where origin is not null.
SELECT		COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		origin IS NOT NULL;


-- Q12. List leads where their first contact date happeded in February 2018.
SELECT		COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		month(first_contact_date) = 2 AND year(first_contact_date) = 2018;


-- Q13. Count leads by origin where their first contact date happened after March 2018.
SELECT		origin, COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		month(first_contact_date) > 3 AND
			year(first_contact_date) >= 2018 AND 
			origin IS NOT NULL
GROUP BY	origin
ORDER BY	lead_count DESC;


-- Q14. Show number of leads per landing page id where origin is not null.
SELECT		landing_page_id, COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		origin IS NOT NULL
GROUP BY	landing_page_id
ORDER BY	lead_count DESC;


-- Q15. List the top 5 origins by lead count.
SELECT		origin, COUNT(*) AS lead_count
FROM		leads_qualified
WHERE		origin IS NOT NULL
GROUP BY	origin
ORDER BY	lead_count DESC
LIMIT		5;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: order_items
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all order items with price greater than 200.
SELECT		*
FROM		order_items
WHERE		price > 200;


-- Q2. Count order items per product id.
SELECT		product_id, COUNT(*) AS order_item_count
FROM		order_items
GROUP BY	product_id
ORDER BY	order_item_count DESC;


-- Q3. Find minimum and maximum freight value.
SELECT		MIN(freight_value) AS min_freight_value, MAX(freight_value) AS max_freight_value
FROM		order_items;


-- Q4. Calculate average price by seller.
SELECT		seller_id, AVG(price) AS avg_price
FROM		order_items
GROUP BY	seller_id
ORDER BY	avg_price	DESC;


-- Q5. List order items where shipping limit date is null.
SELECT		*
FROM		order_items
WHERE		shipping_limit_date IS NULL;


-- Q6. Count order items where freight value equals zero.
SELECT		COUNT(*) AS order_item_count
FROM		order_items
WHERE		freight_value = 0;


-- Q7. Find order items where price is in [10,20] or greater than 40.
SELECT		*
FROM		order_items
WHERE		(price BETWEEN 10 AND 20) OR (price > 40);


-- Q8. Retrieve order items where seller id ends in 4.
SELECT		*
FROM		order_items
WHERE		seller_id LIKE '%4';


-- Q9. Count order items where shipping limit date is not null.
SELECT		COUNT(*) AS order_item_count
FROM		order_items
WHERE		shipping_limit_date IS NOT NULL;


-- Q10. Show products with more than 50 order items.
SELECT		product_id, COUNT(*) AS order_item_count
FROM		order_items
GROUP BY	product_id
HAVING		order_item_count > 50
ORDER BY	order_item_count DESC;


-- Q11. Order order items by price descending.
SELECT		*
FROM		order_items
ORDER BY	price DESC;


-- Q12. Count order items for each seller id with freight value greater than 200.
SELECT		seller_id, COUNT(*) AS order_item_count
FROM		order_items
WHERE		freight_value > 200
GROUP BY	seller_id
ORDER BY	order_item_count DESC;


-- Q13. List order items with order_item_id greater than 5
SELECT		*
FROM		order_items
WHERE		order_item_id > 5;


-- Q14. Count order items per shipping limit date where price greater than 500.
SELECT		shipping_limit_date, COUNT(*) AS order_item_count
FROM		order_items
WHERE		price > 500
GROUP BY	shipping_limit_date
ORDER BY	shipping_limit_date;


-- Q15. Show top 10 products with highest average price.
SELECT		product_id, AVG(price) AS avg_price
FROM		order_items
GROUP BY	product_id
ORDER BY	avg_price DESC
LIMIT 		10;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: order_payments
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all payments where payment type is via credit_card or voucher.
SELECT		* 
FROM		order_payments
WHERE		payment_type IN ('credit_card', 'voucher');


-- Q2. Count payments by payment sequential number.
SELECT		payment_sequential, COUNT(*) AS order_count
FROM		order_payments
GROUP BY	payment_sequential
ORDER BY	payment_sequential;


-- Q3. Find minimum and maximum payment value.
SELECT		MIN(payment_value) AS min_payment, MAX(payment_value) AS max_payment
FROM		order_payments;


-- Q4. Calculate average payment_value by payment_type.
SELECT		payment_type, AVG(payment_value) AS avg_payment
FROM		order_payments
GROUP BY	payment_type
ORDER BY	avg_payment	DESC;


-- Q5. List payment type with the biggest average payment installments.
SELECT		payment_type, AVG(payment_installments) AS avg_pay_installments
FROM		order_payments
GROUP BY	payment_type
ORDER BY	avg_pay_installments DESC
LIMIT		1;


-- Q6. Count payments with payment value less than 500 or greater than 1000.
SELECT		COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_value < 500 OR payment_value > 1000;


-- Q7. Count credit card payments where payment installments is greater than 3 and the value less than 50
SELECT		COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_installments >  3 AND payment_value < 50;


-- Q8. Retrieve credit card payments with the most payment installments
SELECT		payment_installments, COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_type = 'credit_card'
GROUP BY	payment_installments
ORDER BY	payment_installments DESC
LIMIT		1;


-- Q9. Count boleto payments where payment_sequential is greater than 1.
SELECT		COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_type = 'boleto' AND payment_sequential > 1;


-- Q10. Show payment types with more than 1000 payments.
SELECT		payment_type, COUNT(*) AS order_payments_count
FROM		order_payments
GROUP BY	payment_type
HAVING		order_payments_count > 1000;


-- Q11. Order payments by payment type and then payment value descending.
SELECT		*
FROM		order_payments
ORDER BY	payment_type, payment_value DESC;


-- Q12. Count payments for each payment installments count where payment value is over 3000.
SELECT		payment_installments, COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_value > 3000
GROUP BY	payment_installments
ORDER BY	payment_installments;


-- Q13. List the highest payment value's payment type for payments with payment sequential greater than 1.
SELECT		payment_type
FROM		order_payments
WHERE		payment_sequential > 1
ORDER BY	payment_value DESC
LIMIT		1;


-- Q14. Count payments by payment type where payment value is greater than 500.
SELECT		payment_type, COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_value > 500
GROUP BY	payment_type
ORDER BY	order_payments_count DESC;


-- Q15. Show the top 2 payment types by number of payments that have payment sequential greater than 1.
SELECT		payment_type, COUNT(*) AS order_payments_count
FROM		order_payments
WHERE		payment_sequential > 1
GROUP BY	payment_type
ORDER BY	order_payments_count DESC
LIMIT		2;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: order_reviews
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all reviews with review score greater than 3 stars.
SELECT		*
FROM		order_reviews
WHERE		review_score > 3;


-- Q2. Count reviews by review score.
SELECT		review_score, COUNT(*) AS review_count
FROM		order_reviews
GROUP BY	review_score
ORDER BY	review_score DESC;


-- Q3. Find minimum and maximum review_creation_date of 1 star reviews.
SELECT		MIN(review_creation_date) AS min_review_creation_date, MAX(review_creation_date) AS max_review_creation_date 
FROM		order_reviews
WHERE		review_score = 1;


-- Q4. List reviews that don't have a review comment message.
SELECT		*
FROM		order_reviews
WHERE		review_comment_message IS NULL;


-- Q5. Count reviews by each year that they were created.
SELECT		year(review_creation_date) AS creation_year,  COUNT(*) AS review_count
FROM		order_reviews
GROUP BY	creation_year
ORDER BY	creation_year;


-- Q6. Find average review score of reviews without a review comment title created in March of 2018.
SELECT		AVG(review_score) AS avg_review_score
FROM		order_reviews
WHERE		review_comment_title IS NULL AND
			review_creation_date LIKE '2018-03%';


-- Q7. Count reviews where with no review comment title and no review comment message that were answered between 9AM and 9PM.
SELECT		COUNT(*) AS review_count
FROM		order_reviews
WHERE		review_comment_title IS NULL AND
			review_comment_message IS NULL AND
            hour(review_answer_timestamp) BETWEEN 9 AND 21;
            
            
-- Q8. Count reviews that were answered within 6 hours.
SELECT		COUNT(*) AS review_count
FROM		order_reviews
WHERE		TIMESTAMPDIFF(HOUR, review_creation_date, review_answer_timestamp) < 6;
            
            
-- Q9. Show review scores with more than 10000 reviews.
SELECT		review_score, COUNT(*) AS review_count
FROM		order_reviews
GROUP BY	review_score
HAVING		review_count > 10000
ORDER BY	review_score DESC;


-- Q10. Find the second to last review comment message created.
SELECT		review_comment_message
FROM		order_reviews
ORDER BY	review_creation_date DESC
LIMIT		1 OFFSET 1;


-- Q11. Count reviews that don't have a review comment title and have 2 or 4 stars.
SELECT		COUNT(*) AS review_count
FROM		order_reviews
WHERE		review_comment_title IS NULL AND
			review_score IN (2, 4);


-- Q12. List 5 star reviews answered in 2017.
SELECT		*
FROM		order_reviews
WHERE		review_score = 5 AND
			year(review_answer_timestamp) = 2017;
            
            
-- Q13. Count 2 star reviews answered in April by each year.
SELECT		year(review_answer_timestamp) AS year_answered, COUNT(*) AS review_count
FROM		order_reviews
WHERE		review_score = 2 AND month(review_answer_timestamp) = 4
GROUP BY	year_answered
ORDER BY	year_answered;
            
            
-- Q14. Show the top 10 orders with the most reviews.
SELECT		order_id, COUNT(*) AS review_count
FROM		order_reviews
GROUP BY	order_id
ORDER BY	review_count DESC
LIMIT		10;


-- Q15. List the review comment messages of 5 fastest answered 1 star reviews.
SELECT		review_comment_message
FROM		order_reviews
WHERE		review_score = 1
ORDER BY	timediff(review_answer_timestamp, review_creation_date)
LIMIT		5;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: orders
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all orders that are delivered.
SELECT		*
FROM		orders
WHERE		order_status = 'delivered';


-- Q2. Count orders by order status.
SELECT		order_status, COUNT(*) AS order_count
FROM		orders
GROUP BY	order_status
ORDER BY	order_count DESC;


-- Q3. Find earliest and latest order purchases that were canceled.
SELECT		MIN(order_purchase_timestamp) AS min_order_purchase_timestamp,
			MAX(order_purchase_timestamp) AS max_order_purchase_timestamp
FROM		orders
WHERE		order_status = 'canceled';


-- Q4. List the 10 earlies approved orders that were invoiced.
SELECT		*
FROM		orders
WHERE		order_status = 'invoiced'
ORDER BY	order_approved_at
LIMIT		10;


-- Q5. Find the customers with top 5 most orders done.
SELECT		customer_id, COUNT(*) AS order_count
FROM		orders
GROUP BY	customer_id
ORDER BY	order_count DESC
LIMIT		5;


-- Q6. Find orders where the purchase happened in 2018. 
SELECT		*
FROM		orders
WHERE		order_purchase_timestamp LIKE '2018-%';


-- Q7. Find orders that were delivered in the Spring of 2018.
SELECT		*
FROM		orders
WHERE		order_delivered_customer_date LIKE '2018-03-%' OR
			order_delivered_customer_date LIKE '2018-04-%' OR
            order_delivered_customer_date LIKE '2018-05-%'
ORDER BY	order_delivered_customer_date;


-- Q8. Find the earliest delivered order to the customer from the purchase.
SELECT		*
FROM		orders
ORDER BY	datediff(order_delivered_customer_date, order_purchase_timestamp)
LIMIT		1;


-- Q9. Find the latest delivered order.
SELECT		*
FROM		orders
WHERE		order_status = 'delivered'
ORDER BY	datediff(order_delivered_customer_date, order_purchase_timestamp) DESC
LIMIT		1;


-- Q10. Find the 2 most frequent months where orders are purchased.
SELECT		month(order_purchase_timestamp) AS purchase_month, COUNT(*) AS order_count
FROM		orders
GROUP BY	purchase_month
ORDER BY	order_count DESC
LIMIT 		2;


-- Q11. Count orders where the order delivered carrier date is not null.
SELECT		COUNT(*) AS order_count
FROM		orders
WHERE		order_delivered_carrier_date IS NOT NULL;


-- Q12. List orders with order estimated delivery date is within the same month of the purchase date.
SELECT		*
FROM		orders
WHERE		timestampdiff(MONTH, order_approved_at, order_estimated_delivery_date) = 0;


-- Q13. Count how many distinct customers have at least one shipped order.
SELECT		COUNT(DISTINCT customer_id) AS customer_count
FROM		orders
WHERE		order_status = 'shipped';


-- Q14. Show top 2 order status by number of orders delivered to carrier in Janurary.
SELECT		order_status, COUNT(*) AS order_count
FROM		orders
WHERE		MONTH(order_delivered_carrier_date) = 1
GROUP BY	order_status
ORDER BY	order_count DESC
LIMIT		2;


-- Q15. Find the second to last delivery delivered to the customer in March of 2018
SELECT		*
FROM		orders
WHERE		order_delivered_customer_date LIKE '2018-03-%'
ORDER BY	order_delivered_customer_date DESC
LIMIT		1 OFFSET 1;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: product_category_name_translation
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Find the brazilian translation of 'sports leisure'.
SELECT		product_category_name
FROM 		product_category_name_translation
WHERE		product_category_name_english = 'sports_leisure';


-- Q2. Count how many categories are about 'fashion'.
SELECT		COUNT(*) AS category_count
FROM 		product_category_name_translation
WHERE		product_category_name_english LIKE '%fashion%';


-- Q3. Find minimum and maximum length of the product brazilian category name.
SELECT		MIN(length(product_category_name)) AS min_length, MAX(length(product_category_name)) AS max_length
FROM 		product_category_name_translation;


-- Q4. List brazilian product categories where there is no english translation.
SELECT		product_category_name
FROM 		product_category_name_translation
WHERE		product_category_name_english IS NULL;


-- Q5. Count distinct product category names.
SELECT		COUNT(DISTINCT	product_category_name) AS category_count
FROM 		product_category_name_translation;


-- Q6. Find english product category names and their translation that are about sports or art.
SELECT		*
FROM 		product_category_name_translation
WHERE		(product_category_name_english LIKE '%sport%' OR product_category_name_english LIKE '%art%') AND 
            NOT product_category_name_english LIKE '%party%';


-- Q7. Find the most characters used for the categories.
SELECT		MAX(length(product_category_name)) AS max_length_brazilian,
			MAX(length(product_category_name_english)) AS max_length_english
FROM 		product_category_name_translation;
            
            
-- Q8. Find the number of words used for each of the categories and their translations.
SELECT		length(product_category_name) - length(replace(product_category_name, '_', '')) + 1 AS words_count_brazilian,
			length(product_category_name_english) - length(replace(product_category_name_english, '_', '')) + 1 AS words_count_english
FROM 		product_category_name_translation;


-- Q9. Find one word brazilian categories.
SELECT		product_category_name
FROM 		product_category_name_translation
WHERE		instr(product_category_name, '_') = 0;


-- Q10. Concate the translation with original category with an ":".
SELECT		concat(product_category_name, ': ', product_category_name_english) AS translation
FROM 		product_category_name_translation;


-- Q11. Count english translations that starts with ‘m’.
SELECT		COUNT(product_category_name_english) as category_count
FROM 		product_category_name_translation
WHERE		product_category_name_english LIKE 'm%';


-- Q12. List the first 10 product categories alphabetically.
SELECT		*
FROM 		product_category_name_translation
ORDER BY	product_category_name
LIMIT		10;


-- Q13. Convert the two word translations from lowercase to uppercase
SELECT		upper(product_category_name_english) AS upper_english_category
FROM 		product_category_name_translation
WHERE		length(product_category_name_english) - length(replace(product_category_name_english, '_', '')) + 1 = 2;


-- Q14. Find the first word for all brazilian categories.
SELECT		substr(product_category_name, 1, instr(product_category_name, '_') - 1) AS first_word
FROM 		product_category_name_translation
WHERE		instr(product_category_name, '_') >= 1;


-- Q15. Replace '_' with ' ' for the brazilian categories.
SELECT		replace(product_category_name, '_', ' ') AS new_category
FROM 		product_category_name_translation;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: products
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all products with product weight  greater than a 1kg.
SELECT		* 
FROM		products
WHERE		product_weight_g > 1000;


-- Q2. Count products by product category.
SELECT		product_category_name, COUNT(*) AS product_count 
FROM		products
GROUP BY	product_category_name
ORDER BY	product_count DESC;


-- Q3. Find average product name lenght for products that weight less than 1kg.
SELECT		AVG(product_name_lenght) AS avg_product_name_length
FROM		products
WHERE		product_weight_g < 1000;


-- Q4. Calculate average product description lenght by product category name.
SELECT		product_category_name, AVG(product_description_lenght) AS avg_product_description_lenght
FROM		products
GROUP BY	product_category_name
ORDER BY	avg_product_description_lenght DESC;



-- Q5. Find average dimentions for pcs.
SELECT		AVG(product_length_cm) AS avg_product_length_cm,
			AVG(product_height_cm) AS avg_product_height_cm,
            AVG(product_width_cm) AS avg_product_width_cm
FROM		products
WHERE		product_category_name = 'pcs';


-- Q6. Count baby products by number of pictures per product.
SELECT		product_photos_qty, COUNT(*) AS product_count
FROM		products
WHERE		product_category_name = 'bebes'
GROUP BY	product_photos_qty
ORDER BY	product_photos_qty;


-- Q7. Show the product id and also as: 'art' all products that are part of arts
-- 										'sports' all products that are part of sports
-- 										'fashion' all products that are part of fashion
-- 										NULL that are in neither of the three catrgories
SELECT		product_id, product_category_name,
			CASE	WHEN product_category_name LIKE '%art%' AND NOT product_category_name LIKE '%party%' THEN 'art'
					WHEN product_category_name LIKE '%sport%' THEN 'sports'
                    WHEN product_category_name LIKE '%fashion%' THEN 'fashion'
                    ELSE NULL
			END AS art_sports_fashion
FROM		products;


-- Q8. Count products where their area in cm is more than 1m^2.
SELECT		COUNT(*) AS product_count
FROM		products
WHERE		product_length_cm * product_height_cm > power(100,2);


-- Q9. Show top 5 product category names that have on average volume more than 50m^3.
SELECT		product_category_name, 
			AVG(product_length_cm * product_height_cm * product_width_cm) AS avg_volume_cm
FROM		products
GROUP BY	product_category_name
HAVING		avg_volume_cm > 50 * power(100,3)
ORDER BY	avg_volume_cm DESC
LIMIT		5;


-- Q10. Show the 2 lightest product category names in kg.
SELECT		product_category_name, AVG(product_weight_g) / 1000 AS avg_product_weight_kg
FROM		products
GROUP BY	product_category_name
ORDER BY	avg_product_weight_kg
LIMIT		2;


-- Q11. Show the 10 smallest products and their categories, in m.
SELECT		product_id, product_category_name,
			(product_length_cm * product_height_cm * product_width_cm) / power(10,6) AS product_volume_m
FROM		products
WHERE		(product_length_cm * product_height_cm * product_width_cm) / 10 IS NOT NULL
ORDER BY	product_volume_m
LIMIT		10;


-- Q12. Show minimum and maximum weight for baby products with more than 4 pictures per product in kg.
SELECT		MIN(product_weight_g) / 1000 AS min_product_weight_g,
			MAX(product_weight_g) / 1000 AS max_product_weight_g
FROM		products
WHERE		product_category_name = 'bebes' AND product_photos_qty > 4;


-- Q13. List average product weight for fashion products with product description lenght between 50 and 100 characters.
SELECT		AVG(product_weight_g) AS avg_product_weight_g
FROM		products
WHERE		product_category_name LIKE '%fashion%' AND
			product_description_lenght BETWEEN	50 AND 100;


-- Q14. Show top 10 heaviest sports products.
SELECT		product_id, product_category_name, product_weight_g
FROM		products
WHERE		product_category_name LIKE '%sport%'
ORDER BY	product_weight_g DESC
LIMIT		10;

            
-- Q15. Count art products that weight more than 5kg by arts category.
SELECT		product_category_name, COUNT(*) AS product_count
FROM		products
WHERE		product_category_name LIKE '%art%' AND
			NOT product_category_name LIKE '%party%'
GROUP BY	product_category_name
ORDER BY	product_count DESC;


-------------------------------------------------------------------------------------------------------------------------------
-- Table: sellers
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Select all sellers from Rio de Janeiro.
SELECT		*
FROM		sellers
WHERE		seller_city = 'rio de janeiro';


-- Q2. Count sellers by states.
SELECT		seller_state, COUNT(*) AS seller_count
FROM		sellers
GROUP BY	seller_state
ORDER BY	seller_count DESC;


-- Q3. Find the top 2 cities with the most sellers in Rio de Janeiro state.
SELECT		seller_city, COUNT(*) AS seller_count
FROM		sellers
WHERE		seller_state = 'RJ'
GROUP BY	seller_city
ORDER BY	seller_count DESC
LIMIT		2;


-- Q4. Calculate the number of sellers in cities that start with A.
SELECT		seller_city, COUNT(*) AS city_count
FROM		sellers
WHERE		seller_city LIKE 'a%'
GROUP BY	seller_city
ORDER BY	city_count DESC;


-- Q5. List sellers that are in Rio de Janeiro state but not in Rio de Janeiro city.
SELECT		*
FROM		sellers
WHERE		seller_state = 'RJ' AND NOT seller_city = 'rio de janeiro';


-- Q6. Count the sellers by the first digit of their seller zip code prefix.
SELECT		seller_zip_code_prefix DIV 10000 AS first_digit,
			COUNT(*) AS seller_count
FROM		sellers
GROUP BY	first_digit
ORDER BY	first_digit;


-- Q7. Count the distinct states that their seller zip code prefix starts with two.
SELECT		seller_zip_code_prefix DIV 10000 AS first_digit,
			COUNT(DISTINCT seller_state) AS seller_state_count
FROM		sellers
GROUP BY	first_digit
HAVING		first_digit = 2;


-- Q8. Count sellers in Sao Paolo state that their id ends in 0.
SELECT		COUNT(seller_state) AS seller_count
FROM		sellers
WHERE		seller_state = 'SP' AND
			substr(seller_id, length(seller_id), length(seller_id)) = '0';


-- Q9. Find the number of sellers in the city that is last alphabetically.
SELECT		seller_city, COUNT(*) AS seller_count
FROM		sellers
GROUP BY	seller_city
ORDER BY	seller_city DESC
LIMIT		1;
            
            
-- Q10. Find cities that have more than one words as their name
SELECT		DISTINCT seller_city
FROM		sellers
WHERE		instr(seller_city, ' ') <> 0
ORDER BY	seller_city;


-- Q11. Count sellers in cities with only one word in their name.
SELECT		seller_city, COUNT(*) AS seller_count
FROM		sellers
WHERE		instr(seller_city, ' ') = 0
GROUP BY	seller_city
ORDER BY	seller_count DESC;


-- Q12. List top 10 seller cities by seller count.
SELECT		seller_city, COUNT(*) AS seller_count
FROM		sellers
GROUP BY	seller_city
ORDER BY	seller_count DESC
LIMIT		10;


-- Q13. Count sellers in Sao Paolo state that have 2 as the last digit of their seller zip code prefix.
SELECT		COUNT(*) AS seller_count
FROM		sellers
WHERE		seller_state = 'SP' AND
			seller_zip_code_prefix MOD 10  = 2;


-- Q14. Show sellers in Tupa city that have 2 in their id
SELECT		*
FROM		sellers
WHERE		seller_city = 'tupa' AND
			seller_id LIKE '%2%'; 
            
            
-- Q15. Show all info on Sao Paolo sellers that have seller zip code prefix ending in 3, 5 or 9 ordered 
--      by that last digit first and then their city.
SELECT		*
FROM		sellers
WHERE		seller_state = 'SP' AND
			seller_zip_code_prefix MOD 10 IN (3,5,9)
ORDER BY	seller_zip_code_prefix MOD 10, seller_city;
				
