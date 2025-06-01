
-- 2. Intermediate MySQL questions (total 25)

--  Includes:
-- Joins
-- Unions
-- Subselects
-- CTEs (optional)
-- Aggregations, conditions, filters where appropriate


-------------------------------------------------------------------------------------------------------------------------------
USE e_commerce;
-------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------
-- A. Only use JOINs or INNER JOINs (total 15)
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Find the top 5 customers who spent the most in total across all orders.
SELECT		c.customer_unique_id, 
		SUM(ot.price + ot.freight_value) AS total_price		-- 4. Sum the total costs by customer
FROM		orders o						-- 1. Find common orders between orders and order items table 	
		INNER JOIN order_items ot							
            	ON	o.order_id = ot.order_id						
            	INNER JOIN customers c					-- 2. Find common customers in order to get the unique customer id
            	ON o.customer_id = c.customer_id
GROUP BY	c.customer_unique_id					-- 3. Group by customer
ORDER BY	total_price DESC					-- 5. Order by descending total costs
LIMIT		5;							-- 6. Keep only top five spenders


-- Q2. List all reviews with empty or null messages, along with the corresponding customer and order status.
WITH null_comment_messages AS (SELECT	review_id, order_id		-- 1. CTE: Table with orders that do not
			       FROM	order_reviews			--         have a review
			       WHERE	review_comment_message IS NULL) 
                                            
SELECT		nm.review_id, nm.order_id,				-- 3. Select relevant columns
		o.customer_id, o.order_status
FROM		null_comment_messages nm				-- 2. Join to table with orders that do not have a review the orders
		LEFT JOIN orders o					--    table that contain the customers and the orders' status
            	ON nm.order_id = o.order_id;


-- Q3. Identify how many sellers in their repsective state have freight charges are greater than the product price.
WITH seller_info AS (SELECT	ot.seller_id, ot.price, ot.freight_value,	-- Join seller order info from order_items
				s.seller_id AS s_seller_id, s.seller_state	-- with indivitual seller info to get the states
		     FROM	order_items ot				
				LEFT JOIN sellers s
				ON ot.seller_id = s.seller_id)	
                                
SELECT		seller_state, COUNT(DISTINCT seller_id) AS seller_count		-- 4. Count filtered sellers by state
FROM		seller_info							-- 1. Use joined tables with info needed
WHERE		freight_value > price						-- 2. Filter only sellers that have freight value > price
GROUP BY	seller_state							-- 3. Group by state
ORDER BY	seller_count DESC;			


-- Q4. Find customers who placed orders but never left a review.
SELECT		c.customer_unique_id, 
		SUM(CASE WHEN orev.review_comment_message IS NOT NULL THEN 1	-- 4. Define a new column with
			 ELSE 0							--    1: non null review, 0: null review
		    END) AS total_reviews					--    Sum all the 1s and 0s for each customer 
										--    These customers never left a review										-- 	  Sum = 0 means that all reviews were null
                                                                               
FROM		orders o							-- 1. Join tables to add reviews to order info
		LEFT JOIN order_reviews orev
            	ON o.order_id = orev.order_id
            	INNER JOIN customers c						-- 2. Join the above with customer to add the
            	ON o.customer_id = c.customer_id				--    unique customer id
GROUP BY	c.customer_unique_id						-- 3. Group by customer
HAVING		total_reviews = 0;						-- 5. Filter customers where their total reviews were 0


-- Q5. List orders where customer city differs from seller city.
WITH order_customer_info AS (SELECT	o.order_id, 				-- 2. Keep only relevant columns
					c.customer_unique_id, c.customer_state
			     FROM	orders o				-- 1. Join orders and customers to get customer info
					LEFT JOIN customers c			--    for each order
					ON o.customer_id = c.customer_id),
                                        
     order_items_sellers AS (SELECT	ot.order_id, ot.seller_id,		-- 2. Keep only relevant columns
					s.seller_state
			     FROM	order_items ot				-- 1. Join order_items and sellers to get seller info 
					LEFT JOIN sellers s			--    for each order
					ON ot.seller_id = s.seller_id)
                                        
SELECT	DISTINCT oc.order_id							-- 3. Keep only distinct orders (order_items list each product
										--    and seller in an order (2 products in an order -> 2 rows 
										--    for the same order)
FROM 	order_customer_info oc							-- 1. Join table containing order and customer info with table 
	LEFT JOIN order_items_sellers os					--    containing order and seller info
        ON oc.order_id = os.order_id
WHERE	UPPER(oc.customer_state) <> UPPER(os.seller_state);			-- 2. Filter rows where customer's state is different from seller's state


-- Q6. Identify landing pages that resulted in closed deals in the computers business segment.
SELECT		DISTINCT lq.landing_page_id		-- 3. Keep distinct landing pages
FROM		leads_closed lc				-- 1. Find common leads between the qualified ones and the closed ones
		INNER JOIN leads_qualified lq
            	ON lc.mql_id = lq.mql_id
WHERE		lc.business_segment = 'computers';	-- 2. Filter those in the computers business segment


-- Q7. Get top 5 products most payed by credit card.
WITH orders_credit_card AS  (SELECT	ot.order_id, ot.product_id,					-- 2. Select only relevant columns
					cc.payment_type
			     FROM	order_items ot							-- 1. Find common credit card payments
					INNER JOIN (SELECT	* 					--    in the order_items table
						    FROM 	order_payments
						    WHERE 	payment_type = 'credit_card') cc
                                        ON ot.order_id = cc.order_id)
                                        
SELECT		product_id, COUNT(*) AS total_credit_card_payments	-- 3. Count total credit card payments by product
FROM 		orders_credit_card 					-- 1. Use CTE above for readability
GROUP BY	product_id						-- 2. Group credit card payments by product id
									--    (In an order the same product can be purchased two or more times -> 
									--     These are counted in the final result as seperate credit card payments
ORDER BY	total_credit_card_payments DESC				-- 4. Order by most total credit card payments to least
LIMIT		5;							-- 5. Keep top 5.


-- Q9. Display customers who have placed orders with at least three different sellers.
SELECT		c.customer_unique_id, 						
		COUNT(DISTINCT ot.seller_id) AS total_sellers	-- 4. Calculate number of total distinct sellers by customers
FROM		orders o					-- 1. Find common orders between the two tables	
		INNER JOIN order_items ot
	        ON o.order_id = ot.order_id
         	INNER JOIN customers c				-- 2. Add common customers to use the unique customer id
        	ON o.customer_id = c.customer_id
GROUP BY	c.customer_unique_id				-- 3. Group by customers
HAVING		total_sellers >= 3;				-- 5. Return only customers with total seller >= 3


-- Q10. Return the year and seller's city most of the leads were won in.
SELECT		s.seller_city, 
		YEAR(lc.won_date) AS year_won, 	-- 3. Extract the year the leads were won
            	COUNT(*) AS total_lead_won	-- 4. Calculate total leads won by city and year
FROM		leads_closed lc			-- 1. Find common sellers that won leads with the sellers table
		INNER JOIN sellers s
            	ON lc.seller_id = s.seller_id
GROUP BY	s.seller_city, year_won		-- 2. Group by seller city and year the leads were won (extracted in a column)
ORDER BY	total_lead_won DESC		-- 5. Order from most leads won to least by city and year
LIMIT		1;				-- 6. Return the top result


-- Q11. List orders that had more than one product from different categories (categories in english).

-- Checking if distinct english category names is more than brazilian category names in the products table
-- SELECT	COUNT(DISTINCT	product_category_name_english) FROM product_category_name_translation; -- 71
-- SELECT	COUNT(DISTINCT	product_category_name) FROM products; -- 73

-- Result: 2 product categories do not have english translation -> 'portateis_cozinha_e_preparadores_de_alimentos', 'pc_gamer'

-- Proceed with the query
WITH english_products AS (SELECT	p.product_id, p.product_category_name,						
					eng_p.product_category_name_english
			  FROM		products p							-- 1. Add the eng tanslation 
					LEFT JOIN product_category_name_translation eng_p		--    of the product categories
                        	        ON p.product_category_name = eng_p.product_category_name)
                                    
SELECT		ot.order_id, 
		COUNT(DISTINCT ep.product_category_name_english) AS total_categories	-- 3. Calculate distinct product categories
FROM		order_items ot								-- 1. Add the eng translation of the product 
		LEFT JOIN english_products ep						--    categories to the order_items table
            	ON ot.product_id = ep.product_id
GROUP BY	ot.order_id								-- 2. Group by orders
HAVING		total_categories > 1;							-- 4. Keep orders having more than product category    


-- Q12. Identify sellers whose products are above the average weight for their category (in english).
WITH english_products AS (SELECT	p.product_id, p.product_category_name, p.product_weight_g,	-- Add the eng tanslation 				
					eng_p.product_category_name_english				-- of the product categories
			  FROM		products p													
					LEFT JOIN product_category_name_translation eng_p			
                        	        ON p.product_category_name = eng_p.product_category_name),
                                    
	avg_weight_by_category AS (SELECT	product_category_name_english,		-- Calculate avg weight by 
						AVG(product_weight_g) AS avg_weight	-- product category
				   FROM		english_products
                               	   GROUP BY	product_category_name_english)

SELECT		DISTINCT ot.seller_id								-- 4. Return only distinct sellers
FROM 		order_items ot
		LEFT JOIN english_products ep							-- 1. Add english translations of
            	ON ot.product_id = ep.product_id						--    product categories (not really needed but is asked)
            	LEFT JOIN avg_weight_by_category avg_w						-- 2. Add avg weight of product by category
            	ON ep.product_category_name_english = avg_w.product_category_name_english
WHERE		ep.product_weight_g > avg_w.avg_weight;						-- 3. Filter rows where the weight is above the
																						--    avg of the product's category 
                                                                                        
         
-- Q13. Show the top 5 customer states where credit card were used for order payments with more than one installments.
SELECT		c.customer_state, 
		COUNT(DISTINCT o.order_id) AS total_orders	-- 5. Calculate the total distinct orders by customer state
FROM		orders o					-- 1. Find common orders between the orders and orders_payents tables
		INNER JOIN order_payments op
            	ON o.order_id = op.order_id
	        INNER JOIN customers c				-- 2. Find the common customers between the above and the customers table
        	ON o.customer_id = c.customer_id
WHERE		op.payment_type = 'credit_card' AND		-- 3. Filter payments where credit card is used and also 
		op.payment_installments > 1			--    for more than one installment
GROUP BY	c.customer_state				-- 4. Group by customer state
ORDER BY	total_orders DESC				-- 6. Order from most orders by state to least
LIMIT		5;						-- 7. Keep the top 5 states


-- Q14. Show all customers who made purchases using multiple payment types.
SELECT		c.customer_unique_id,	
		COUNT(DISTINCT op.payment_type) AS total_payment_types	-- 4. Calculate the different number of payment types
FROM		orders o						-- 1. Find common orders between the orders 
		INNER JOIN order_payments op				--    and orders_payents tables
            	ON o.order_id = op.order_id
            	INNER JOIN customers c					-- 2. Add customers to use unique customer id
            	ON o.customer_id = c.customer_id
GROUP BY	c.customer_unique_id					-- 3. Group by customers
HAVING		total_payment_types > 1;				-- 5. Keep customers with more than 1 payment type


-- Q15. List products that were sold in every region.

-- Brazil's five regions and their respective states are:
-- North: AC, AP, AM, PA, RO, RR, TO
-- Northeast: AL, BA, CE, MA, PB, PE, PI, RN, SE
-- Midwest: GO, MT, MS, DF
-- Southeast: ES, MG, RJ, SP
-- South: PR, RS, SC

-- (Source: https://www.researchgate.net/publication/341914696_Spatiotemporal_evolution_of_dengue_outbreaks_in_Brazil/figures?lo=1)

WITH regions AS (SELECT		DISTINCT customer_state AS state,
				CASE	WHEN customer_state in ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'N'
					WHEN customer_state in ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'NE'
                                    	WHEN customer_state in ('GO', 'MT', 'MS', 'DF') THEN 'MW'
                                    	WHEN customer_state in ('ES', 'MG', 'RJ', 'SP') THEN 'SE'
                                    	WHEN customer_state in ('PR', 'RS', 'SC') THEN 'S'
                                    	ELSE NULL
				END AS region
		 FROM		customers)	-- Mapping the states to their respective regions

SELECT		ot.product_id, 
		COUNT(DISTINCT r.region) AS total_stated_sold	-- 5. Count distinct regions where the products were sold
FROM		orders o					-- 1. Find common orders between orders table and order_items_table
		INNER JOIN order_items ot
            	ON o.order_id = ot.order_id
            	INNER JOIN customers c				-- 2. Find common customers between the above and the customers table
            	ON o.customer_id = c.customer_id
            	LEFT JOIN regions r				-- 3. Add the regions to the customers' states
            	ON c.customer_state = r.state
GROUP BY	ot.product_id					-- 4. Group by products
HAVING		total_stated_sold = 5;				-- 6. Keep products that were sold to all five regions



-------------------------------------------------------------------------------------------------------------------------------
-- B. Only use SELF JOINs (total 5)
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. Find all pairs of customers who live in the same city.
SELECT		c1.customer_unique_id, c1.customer_city, 		-- 4. Keep relevant columns
		c2.customer_unique_id, c2.customer_city
FROM		customers c1						-- 1. Self join on customers to find pairs
		INNER JOIN customers c2		
            	ON c1.customer_unique_id > c2.customer_unique_id	-- 2. Avoid duplicates (a = a) and same pairs (a = b, b = a in the same table)
WHERE		c1.customer_city = c2.customer_city;			-- 3. Filter pairs with same city


-- Q2. List pairs of products in the same category having the same dimention.
SELECT		p1.product_id , p2.product_id
FROM		products p1							-- 1. Self join products table to create pairs
		INNER JOIN products p2	
            	ON p1.product_id > p2.product_id				-- 2. Avoid duplicates (a = a) and same pairs (a = b, b = a in the same table)
            	AND p1.product_category_name = p2.product_category_name		-- 3. Pairs should also have the same dimentions
            	AND p1.product_length_cm = p2.product_length_cm
            	AND p1.product_height_cm = p2.product_height_cm
            	AND p1.product_width_cm = p2.product_width_cm;


-- Q3. List sellers who sold to the same customer on different orders.

-- !Warning!: Even though the bellow query is correct, it is extremely slow

WITH order_items_with_customer AS (SELECT	o.order_id,				-- 3. Keep only relevant columns
						ot.seller_id,
                                                c.customer_unique_id
				   FROM		order_items ot				-- 1. Add customer id to order items table
						INNER JOIN orders o			
                                                ON ot.order_id = o.order_id
                                                INNER JOIN customers c			-- 2. Add customers to later use unique id
                                                ON o.customer_id = c.customer_id)

SELECT		ot1.seller_id, ot1.customer_unique_id,			-- 4. Keep relevant columns (customer, seller and pair of orders)
		ot1.order_id, ot2.order_id
FROM		order_items_with_customer ot1				-- 1. Self join order items table (with added customer id)
		INNER JOIN order_items_with_customer ot2
		ON ot1.seller_id = ot2.seller_id			-- 2. Keep pairs where the seller and the customer is the same
            	AND ot1.customer_unique_id = ot2.customer_unique_id	--    but the order is different
            	AND ot1.order_id < ot2.order_id;			-- 3. Avoid duplicates (a = a) and same pairs (a = b, b = a in the same table)
									--    by using '<'
          
-- Alternative faster solution without self join:
SELECT		ot.seller_id, c.customer_unique_id, 
		COUNT(DISTINCT o.order_id) AS total_orders	-- 4. Count total unique orders by the same seller and customer
FROM		order_items ot					-- 1. Find common orders between orders and order items table
		INNER JOIN orders o			
		ON ot.order_id = o.order_id
		INNER JOIN customers c				-- 2. Add customers to later use unique id
		ON o.customer_id = c.customer_id
GROUP BY	ot.seller_id, c.customer_unique_id		-- 3. Group by sellers and customers
HAVING		total_orders > 1				-- 5. Return pairs only when the total orders are more than 
ORDER BY	total_orders DESC;				-- 6. Order from most to least orders by pair of seller, customer


-- Q4. List customers who placed two orders on different dates.
WITH orders_with_customer_info AS (SELECT	o.order_id, o.order_purchase_timestamp,	-- 2. Keep only relevant columns
						c.customer_unique_id
				   FROM		orders o				-- 1. Add customers' info to orders to 
						INNER JOIN customers c			--    get unique id later on	
                                                ON o.customer_id = c.customer_id)

SELECT		o1.customer_unique_id,						-- 2. Keep only relevant columns
		o1.order_id, o1.order_purchase_timestamp, 
            	o2.order_id, o2.order_purchase_timestamp
FROM 		orders_with_customer_info o1					-- 1. Self join to get pairs of orders where
		INNER JOIN orders_with_customer_info o2				--    the customer is the same but they were purchased
		ON o1.customer_unique_id = o2.customer_unique_id		--    in different dates
		AND o1.order_purchase_timestamp < o2.order_purchase_timestamp;


-- Q5. List pairs of product reviews with the same review score but from different customers for the same product.

-- !Warning!: Even though the bellow query is correct, it is extremely slow

WITH reviews_customers	AS (SELECT	o.order_id, c.customer_unique_id, 	-- 2. Keep only relevant columns
					ot.product_id, orev.review_score
			    FROM	order_reviews orev			-- 1. Find commmon orders between orders and order_items
					INNER JOIN orders o			--    table, add reviews and then customers's info
                                        ON orev.order_id = o.order_id
                                        INNER JOIN customers c
                                        ON o.customer_id = c.customer_id
                                        INNER JOIN order_items ot
                                        ON o.order_id = ot.order_id)
			
SELECT		rc1.customer_unique_id AS customer_id_1, 		-- 2. Keep only relevant columns
		rc2.customer_unique_id AS customer_id_2,
            	rc1.product_id, rc1.review_score
FROM		reviews_customers rc1					-- 1. Self join to get the review pairs
		INNER JOIN reviews_customers rc2				
            	ON rc1.customer_unique_id < rc2.customer_unique_id	--    for different customers (avoiding dublicates)
            	AND rc1.product_id = rc2.product_id			--    same products
            	AND rc1.review_score = rc2.review_score;		--    same review score


									
-------------------------------------------------------------------------------------------------------------------------------
-- C. Only use UNIONs or UNION ALLs (total 5)
-------------------------------------------------------------------------------------------------------------------------------

-- Q1. List all unique zip codes from both customers and sellers.
SELECT		*
FROM		(SELECT		customer_zip_code_prefix AS zip_code	-- 1. Get customer's zip codes 
		 FROM		customers				--    NOTE: DISTINCT is not used since UNION will remove diblicates
		 UNION							-- 3. Stack the results to one column
		 SELECT		seller_zip_code_prefix  AS zip_code	-- 2. Get seller's zip codes 
		 FROM		sellers) AS zip_codes
ORDER BY	zip_code;						-- 4. Order by zip code


-- Q2. Count how many times all cities appear between both customers and sellers.
SELECT		city, COUNT(*) AS total_appearances	-- 5. Count total appearnces
FROM		(SELECT		customer_city AS city	-- 1. Get customer's cities
		 FROM		customers				
		 UNION	ALL				-- 3. Stack the results to one column having dublicates
		 SELECT		seller_city  AS city	-- 2. Get seller's cities 
		 FROM		sellers) AS cities
GROUP BY	city					-- 4. Group by city
ORDER BY	total_appearances DESC;			-- 6. Order by most to least city appearing between the two tables


-- Q3. List all customers that payed at least once with credit cards or voucher.

-- Note: It can also be solved using OR conditions using a single table

WITH customer_payment AS (SELECT	c.customer_unique_id, 			-- 3. Keep relevant columns
					op.payment_type
			  FROM		orders o				-- 1. Find common orders with payments tables
					INNER JOIN order_payments op
					ON o.order_id = op.order_id
                                        INNER JOIN customers c			-- 2. Add to the above customers' info
                                        ON o.customer_id = c.customer_id)

(SELECT		customer_unique_id				
FROM		customer_payment
WHERE		payment_type = 'credit_card'	-- A1. Filter to keep only credit card payments
GROUP BY	customer_unique_id		-- A2. Group by customer
HAVING		COUNT(*) >= 1)			-- A3. Keep customers with at least one credi card payment
UNION						-- C. Stack customers using UNION to remove dublicates
(SELECT		customer_unique_id
FROM		customer_payment
WHERE		payment_type = 'voucher'	-- B1. Filter to keep only credit card payments
GROUP BY	customer_unique_id		-- B2. Group by customer
HAVING		COUNT(*) >= 1)			-- B3. Keep customers with at least one credit card payment


-- Q4. Combine customer and seller records with ID, city, and state info.
(SELECT		customer_unique_id AS unique_id,	-- A1. Rename the columns
		customer_city AS city, 
            	customer_state AS state,
            	'customer' AS obj_type			-- A2. Add new column to tag customer records
FROM		customers)
UNION							-- C. Use union to remove dublicates
(SELECT		seller_id AS unique_id,			-- B1. Rename the columns
		seller_city AS city, 
            	seller_state AS state,
            	'seller' AS obj_type			-- B2. Add new column to tag seller records
FROM		sellers);


-- Q5. Count how many customers and sellers are in each state.
SELECT		obj_type, state, COUNT(*) AS total_by_state		-- 3. Count total records by type and state
FROM		(SELECT		customer_unique_id AS unique_id,	-- 1. Using the table from the previous question
				customer_city AS city, 
            			customer_state AS state,
            			'customer' AS obj_type				
		 FROM		customers
		 UNION											
		 SELECT		seller_id AS unique_id,				
				seller_city AS city, 
				seller_state AS state,
				'seller' AS obj_type				
		 FROM		sellers) AS customer_seller_info
GROUP BY	obj_type, state						-- 2. Group by type and state
ORDER BY	total_by_state DESC;					-- 4. Order from most to least type and state pair
