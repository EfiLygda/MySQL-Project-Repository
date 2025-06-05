
-------------------------------------------------------------------------------------------------------------------------------
USE e_commerce;
-------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------
-- Part A. Order & Sales Summary
-------------------------------------------------------------------------------------------------------------------------------

-- 1. How many orders were placed per month?
SELECT		YEAR(order_purchase_timestamp) AS order_year,	-- 1. Extract the year from the purchase timestamp of each order
			MONTH(order_purchase_timestamp) AS order_month,	-- 2. Extract the month from the purchase timestamp of each order
			COUNT(DISTINCT order_id) AS total_orders		-- 4. Calculate total orders by year and month
FROM		orders
GROUP BY	order_year, order_month							-- 3. Group by year and month
ORDER BY	order_year, order_month;						-- 5. Order by date


-- 2. What is the monthly GMV (gross merchandise volume)?
SELECT		YEAR(order_purchase_timestamp) AS order_year,			-- 3. Extract the year from the purchase timestamp of each order
			MONTH(o.order_purchase_timestamp) AS order_month,		-- 4. Extract the month from the purchase timestamp of each order
			ROUND(SUM(ot.price) / POWER(10,3),2) AS gmv_thousands	-- 6. Calculate the total GMV in thousands for each month
FROM		order_items ot											-- 1. Add order info to order items table
			INNER JOIN orders o
            ON ot.order_id = o.order_id
WHERE		o.order_status = 'delivered'							-- 2. Filter for orders that were delivered
GROUP BY	order_year, order_month									-- 5. Group by year and month
ORDER BY	order_year, order_month;								-- 7. Order by year and month


-- 3. What is the average order value (AOV) and total spending over time?
SELECT		YEAR(order_purchase_timestamp) AS order_year,					-- 3. Extract the year from the purchase timestamp of each order
			MONTH(o.order_purchase_timestamp) AS order_month,				-- 4. Extract the month from the purchase timestamp of each order
			ROUND(SUM(ot.price) / COUNT(DISTINCT o.order_id), 2) AS AOV,	-- 6. Calculate average value per order for each month 
            ROUND(SUM(ot.price + ot.freight_value) / 
				  COUNT(DISTINCT o.order_id), 2) AS average_spend_per_order	-- 7. Calculate average customer spending per order for each month
FROM		order_items ot													-- 1. Add order info to order items table
			INNER JOIN orders o
            ON ot.order_id = o.order_id
WHERE		o.order_status = 'delivered'									-- 2. Filter for orders that were delivered
GROUP BY	order_year, order_month											-- 5. Group by year and month
ORDER BY	order_year, order_month;										-- 8.Order by year and month

 
 
-------------------------------------------------------------------------------------------------------------------------------
-- Part B. Delivery Performance
-------------------------------------------------------------------------------------------------------------------------------

-- 1. What’s the average delivery time per product category?
WITH delivery_times_by_product_in_orders AS 
	(SELECT		CASE WHEN tr.product_category_name_english IS NULL THEN p.product_category_name	-- 5. In case the english translation for a category
					 ELSE tr.product_category_name_english										--    is NULL then the original brazilian name is used
				END AS product_category_name,													--    NOTE: Even after this some names are NULL originally
				TIMESTAMPDIFF(DAY, 																-- 6. Calculate the delivery time for each order using 
							  o.order_purchase_timestamp, 										--    the difference between the purchase timestamp and the delivery one
							  o.order_delivered_customer_date)
					AS delivery_time_days
	FROM		order_items ot																	-- 1. Add order info to order items table
				INNER JOIN orders o
				ON ot.order_id = o.order_id														
				INNER JOIN products p															-- 2. Add product ingo to order items table
				ON ot.product_id = p.product_id
				LEFT JOIN product_category_name_translation tr									-- 3. Add english translations for product category names
				ON p.product_category_name = tr.product_category_name							--    LEFT JOIN is used in case some categories do not have translation
	WHERE		o.order_status = 'delivered')													-- 4. Filter for orders that were delivered 
            
SELECT		product_category_name,
			ROUND(AVG(delivery_time_days), 2) AS avg_delivery_days		-- 2. Calculate the average delivery days
FROM		delivery_times_by_product_in_orders
GROUP BY	product_category_name										-- 1. Group by product category name
ORDER BY	avg_delivery_days DESC;										-- 3. Order by average delivery days


-- 2. What percentage of deliveries were late?           
SELECT		ROUND(COUNT(DISTINCT order_id) / 
					   (SELECT COUNT(DISTINCT	order_id) FROM orders) * 100, 2) 
				AS pct_late_deliveries												-- 2. Calculate the percent of delieveries that are late
FROM		orders
WHERE 		order_status = 'delivered' AND 											-- 1. Filter delivered orders that are late
			TIMESTAMPDIFF(DAY, 
						  order_estimated_delivery_date, 
						  order_delivered_customer_date) > 0;


-- 3. Which cities have the most delays?
SELECT		c.customer_city, 	
			COUNT(DISTINCT o.order_id) AS total_late_deliveries			-- 4. Calculate total late deliveries by customer city			
FROM		orders o													-- 1. Add customer info to order info
			INNER JOIN customers c
			ON o.customer_id = c.customer_id
WHERE 		order_status = 'delivered' AND 								-- 2. Filter delivered orders that are late
			TIMESTAMPDIFF(DAY, 
						  order_estimated_delivery_date, 
						  order_delivered_customer_date) > 0
GROUP BY	c.customer_city												-- 3. Group by customer city
ORDER BY	total_late_deliveries DESC;									-- 5. Order by total late deliveries by city



-------------------------------------------------------------------------------------------------------------------------------
-- Part C. Customer Behavior
-------------------------------------------------------------------------------------------------------------------------------

-- 1. What’s the average number of items per order?
SELECT		ROUND(AVG(total_items_per_order), 2) AS avg_items_per_order	-- B. Average number of items by order
FROM		(SELECT		order_id, 
						MAX(order_item_id) AS total_items_per_order		-- A2. Find maximum number of items = number of items by order
			FROM		order_items				
			GROUP BY	order_id) AS tipo;								-- A1. Group by order


-- 2. What’s the cancel rate?
SELECT		ROUND(COUNT(DISTINCT order_id) / 
				 (SELECT COUNT(DISTINCT order_id) FROM orders) * 100, 2) 	-- 2. Calculate percent of canceled orders
				AS cancel_rate
FROM		orders
WHERE 		order_status = 'canceled';										-- 1. Filter canceled orders


-- 3. How many repeat customers are there?
WITH numbered_orders_by_customers AS (
	SELECT		c.customer_unique_id,											-- 2. Use unique customer id to find repeat customers
				ROW_NUMBER() 													-- 3. Partition by unique customer id and order each partition by the  
					OVER(PARTITION BY c.customer_unique_id						--    purchase date, then add the row number to each row
                         ORDER BY o.order_purchase_timestamp) AS order_number
	FROM		orders o														-- 1. Add customer info to orders' info
				INNER JOIN customers c
				ON o.customer_id = c.customer_id)
                
SELECT		COUNT(DISTINCT customer_unique_id) AS total_repeat_customers	-- 2. Count distinct customers from the below subset
FROM		numbered_orders_by_customers
WHERE		order_number > 1;												-- 1. Filter orders that for each customer after the first chronologicaly



-------------------------------------------------------------------------------------------------------------------------------
-- Part D. Payment Methods
-------------------------------------------------------------------------------------------------------------------------------

-- 1. Distribution of payment methods (credit card, boleto, voucher, etc.)
SELECT		payment_type, COUNT(*) AS total_payments 	-- 2. Calculate total payments by payment type
FROM		order_payments
GROUP BY	payment_type;								-- 1. Group by payment type


-- 2. Average number of installments by payment type
SELECT		payment_type, 
			ROUND(AVG(payment_installments), 2) AS avg_installments	-- 2. Calculate average payments by payment type
FROM		order_payments
GROUP BY	payment_type;											-- 1. Group by payment type



-------------------------------------------------------------------------------------------------------------------------------
-- Part E. Reviews & Customer Satisfaction
-------------------------------------------------------------------------------------------------------------------------------

-- 1. What’s the average review score by product category?
WITH orders_category_reviews AS (
	SELECT		DISTINCT ot.order_id,															-- 5. Select distinct rows in order not add the same review score for same items in the same orders 
				COALESCE(tr.product_category_name_english, p.product_category_name)				-- 6. Fill null translations with the original name and leave null where none is available
                AS product_category,
				orev.review_score		
	FROM		order_items ot																	-- 1. Add order info to order items
				INNER JOIN orders o
				ON ot.order_id = o.order_id
				INNER JOIN order_reviews orev													-- 2. Add reviews from each order to each order item
				ON ot.order_id = orev.order_id
				INNER JOIN products p															-- 3. Add product info to each order item
				ON ot.product_id = p.product_id
				INNER JOIN product_category_name_translation tr									-- 4. Add product category name translation to each product
				ON p.product_category_name = tr.product_category_name)
                
SELECT		product_category, 
			ROUND(AVG(review_score), 2) AS avg_review_score	-- 2. Calculate average review score for each category
FROM		orders_category_reviews
GROUP BY	product_category								-- 1. Group by product category
ORDER BY	avg_review_score DESC;							-- 3. Order by most to least average score by category


-- 2. How do late deliveries affect review scores?
WITH orders_category_reviews AS (
	SELECT		DISTINCT ot.order_id,													-- 5. Select distinct rows in order not add the same review score for same items in the same orders 
				COALESCE(tr.product_category_name_english, p.product_category_name)		-- 6. Fill null translations with the original name and leave null where none is available
					AS product_category,
				orev.review_score,
                CASE WHEN order_status = 'delivered' AND 								-- 7. Add one-hot encoding for order items in orders that were delivered, but were delayed
					  TIMESTAMPDIFF(DAY, 
						  order_estimated_delivery_date, 
						  order_delivered_customer_date) > 0
					 THEN 1
					 ELSE 0
				END AS delayed_order
	FROM		order_items ot															-- 1. Add order info to order items
				INNER JOIN orders o
				ON ot.order_id = o.order_id
				INNER JOIN order_reviews orev											-- 2. Add reviews from each order to each order item
				ON ot.order_id = orev.order_id
				INNER JOIN products p													-- 3. Add product info to each order item
				ON ot.product_id = p.product_id
				LEFT JOIN product_category_name_translation tr							-- 4. Add product category name translation to each product
				ON p.product_category_name = tr.product_category_name),
                
	delayed_non_delayed_avg_scores_by_category AS (                
	SELECT		product_category, 
				AVG(CASE WHEN delayed_order = 1 THEN review_score END) AS avg_delayed_score,	-- 2. Calculate average review score for delayed orders
				AVG(CASE WHEN delayed_order = 0 THEN review_score END) AS avg_non_delayed_score	-- 3. Calculate average review score for non delayed orders
	FROM		orders_category_reviews
	GROUP BY	product_category)																-- 1. Group by product category
    
    
SELECT		product_category,
			ROUND(avg_delayed_score, 2) AS avg_delayed_score,						
			ROUND(avg_non_delayed_score, 2) AS avg_non_delayed_score,
			ROUND(avg_delayed_score - avg_non_delayed_score, 2) AS avg_score_diff	-- 1. Calculate the difference of average review score for delayed and non delayed orders
FROM		delayed_non_delayed_avg_scores_by_category
ORDER BY	ABS(avg_score_diff) DESC;												-- 2. Order from most to least average scores differences by magnitude


-- 3. Distribution of 1–5 star reviews over time
WITH reviews_by_score AS (
	SELECT		YEAR(review_creation_date) AS review_year,				-- 1. Extract year of when the review was created
				MONTH(review_creation_date) AS review_month,			-- 2. Extract month of when the review was created
				review_score,											-- 3. Add the review score
				COUNT(DISTINCT order_id) AS total_reviews_by_score		-- 5. Calculate the total reviews by date and score
	FROM		order_reviews
	GROUP BY	review_year, review_month, review_score),				-- 4. Group reviews by year, month and score

	reviews_by_score_month AS (
	SELECT		review_year, review_month, review_score, total_reviews_by_score,	-- 1. Keep relevant columns
				SUM(total_reviews_by_score) 										-- 2. Calculate total reviews by each year, month, score
					OVER(PARTITION BY review_year, review_month) 
					AS total_review_by_month
	FROM		reviews_by_score)
    
SELECT		review_year, review_month, review_score,
			total_reviews_by_score, total_review_by_month,					-- 1. Keep relevant columsn
			ROUND(total_reviews_by_score * 1.0 / 							-- 2. Calculate percent of review for each score in a certain date (year/month)
				  total_review_by_month * 100, 2) 
				AS pct_review_by_score_and_month
FROM		reviews_by_score_month
ORDER BY	review_year, review_month, pct_review_by_score_and_month DESC;	-- 3. Order by review year, month and percent
