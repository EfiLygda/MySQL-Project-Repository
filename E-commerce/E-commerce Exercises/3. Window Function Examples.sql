
-- 3. Window function MySQL questions (total 10)

--  Includes:
-- ROW_NUMBER(), RANK(), DENSE_RANK()
-- LAG(), LEAD()
-- NTILE()
-- Aggregate functions with OVER() like SUM(), AVG(), COUNT(), etc.


-------------------------------------------------------------------------------------------------------------------------------
USE e_commerce;
-------------------------------------------------------------------------------------------------------------------------------


-- Q1. Rank customers by total intended spending across all orders.
WITH  customers_total_spend AS (SELECT		c.customer_unique_id, 
						SUM(ot.price + ot.freight_value) AS total_spend		-- 4. Calculate the total spending by customer
				FROM		order_items ot						-- 1. Find common orders and between the 
						INNER JOIN orders o					--    two tables
						ON ot.order_id = o.order_id
						INNER JOIN customers c					-- 2. Add customer info in order to get
						ON o.customer_id = c.customer_id			--    customer unique id
				GROUP BY	c.customer_unique_id)					-- 3. Group by customer unique id

SELECT		customer_unique_id, total_spend,	
            	DENSE_RANK() OVER(ORDER BY total_spend DESC) AS customer_rank		-- 1. Rank (without skipping ranks) all customers
FROM		customers_total_spend;							--    from most to leasr total spendings 


-- Q2. List the first order placed by each customer.
WITH customer_order_info 
	AS (SELECT	c.customer_unique_id, 
			o.order_id, o.order_purchase_timestamp,			-- 3. Keep only relevant columns
			DENSE_RANK() OVER(PARTITION BY c.customer_unique_id 	-- 2. Rank for each customer from oldest to newest order
					  ORDER BY o.order_purchase_timestamp) 
				AS order_time_rank
		 FROM	orders o						-- 1. Add customer info to orders table in order to get 
			INNER JOIN customers c					--    customer unique id
			ON o.customer_id = c.customer_id)
                                        
SELECT		customer_unique_id, order_id	-- 3. Keep only relevant columns
FROM		customer_order_info		-- 1. Use CTE customer and order rankings by purchase date
WHERE		order_time_rank = 1;		-- 2. Keep only oldest order since they are all ranked as '1'


-- Q3. Rank product categories in english by total items sold.
WITH units_sold_by_product AS (SELECT		product_id, COUNT(*) AS total_units	-- 2. Calculate total units sold by product
			       FROM		order_items				-- 1. Each unit of a product is a row in order items
			       GROUP BY		product_id),				-- 2. Group by product id
                               
	product_info AS (SELECT		usp.product_id, usp.total_units,								
                                	COALESCE(ptr.product_category_name_english,		-- 3. Fill null english category names with 
						 p.product_category_name, 			--    the original brazillian name or 'unknown'
                                        	 'unknown') AS product_category			--    if none is available
			 FROM 		units_sold_by_product usp				-- 1. Add product info to previous table
					LEFT JOIN products p
                        	        ON usp.product_id = p.product_id
                                	LEFT JOIN product_category_name_translation ptr		-- 2. Add the english translation of the product categories
                                	ON p.product_category_name = ptr.product_category_name),
                                
	units_sold_by_category AS (SELECT	product_category, SUM(total_units) AS total_units	-- 3. Calculate the total units by product category
				   FROM 	product_info						-- 1. Use previous table to calculate the total products by category
                               	   GROUP BY	product_category)					-- 2. Group by product category

SELECT		product_category, total_units,
		DENSE_RANK() OVER(ORDER BY total_units DESC) AS product_category_sold_rank	-- 2. Rank product categories by most to least total units
FROM		units_sold_by_category;																-- 1. Use table containing how many units were sold by product category


-- Q4. Rank orders by total volume (in m^3)
WITH orders_volume AS (SELECT		ot.order_id, 
					SUM(p.product_length_cm *					-- 3. Calculate total volume for
				    	    p.product_height_cm * 					--    each volume
                               		    p.product_width_cm) / POWER(100, 3) AS total_volume
	               FROM		order_items ot							-- 1. Add product info to order_items
					INNER JOIN products p						--    in order to get product dimentions
                                	ON ot.product_id = p.product_id
		       GROUP BY		ot.order_id)							-- 2. Group by order

SELECT		order_id, total_volume,
		DENSE_RANK() OVER(ORDER BY total_volume DESC) AS total_volume_rank			-- 1. Rank the orders by total volumes per order
FROM		orders_volume;																		


-- Q5. Find for each order the percent of the each item's price in the final price. Format the results as 'PP.pp%'
WITH total_order_price AS (SELECT	order_id, product_id, price,
                                    	SUM(price) OVER(PARTITION BY order_id) AS total_price		-- 1. Calculate total price for each order
			   FROM		order_items)							--    and keep it for each row
                                
SELECT		order_id, product_id, 
		CONCAT(CAST(ROUND(price / total_price * 100, 2) AS CHAR), '%') AS payment_product_pct	-- 1. Calculate the percent and format it
FROM		total_order_price
ORDER BY	order_id;


-- Q6. Find the top 25% of orders by total payment value.
SELECT		order_id, payment_value								-- 3. Keep relevant columns
FROM		(SELECT		order_id, payment_value,								
				NTILE(4) OVER(ORDER BY payment_value DESC) AS payment_ranks	-- 1. Divide orders in 4 groups by most to least payment value
		 FROM		order_payments) AS orders_ranks
WHERE		payment_ranks = 1;								-- 2. FIlter by the top group 


-- Q7. Show the cumulative total of payments per customer ordered by time.
SELECT		o.customer_id, o.order_id, o.order_purchase_timestamp,		-- 4. Keep only relevant columns
		op.payment_value,											
		SUM(op.payment_value) 						-- 3. Calculate the cumulative payments by customers			
			OVER(PARTITION BY c.customer_id				--    using the previous rows for each row
			     ORDER BY o.order_purchase_timestamp
                     	     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
			AS cumsum_payment_by_customer
FROM		orders o							-- 1. Add order payment info to orders table
		INNER JOIN order_payments op
        	ON o.order_id = op.order_id
            	INNER JOIN customers c						-- 2. Add customer info to the table above
            	ON o.customer_id = c.customer_id;


-- Q8. For each seller, find the difference in performance compared to the next best seller.
WITH ranked_sellers AS (SELECT		ot.seller_id, 
					SUM(op.payment_value) AS total_revenue	-- 3. Calculate the total revenue by seller
			FROM		order_items ot				-- 1. Add order payment info to orders table
					INNER JOIN order_payments op
					ON ot.order_id = op.order_id
			GROUP BY	ot.seller_id				-- 2. Group by sellers
                        ORDER BY	total_revenue DESC),			-- 4. Order by most to leas total revenue since later LEAD() will be used
                        
	ranked_seller_paired AS (SELECT		seller_id, total_revenue,												
						LEAD(seller_id) OVER(ORDER BY total_revenue) AS next_best_seller,	-- 1. Add the next best selling seller
						LEAD(total_revenue) OVER(ORDER BY total_revenue) AS next_best_revenue	-- 2. Add the next best selling total revenue
				 FROM 		ranked_sellers)

SELECT		seller_id, next_best_seller,
		total_revenue - next_best_revenue AS diff_rev	-- 1. Calculate the differences 
FROM		ranked_seller_paired;				


-- Q9. Identify leads that were immediately preceded by a successful deal.
SELECT		*
FROM		(SELECT		lq.mql_id, lq.first_contact_date,						-- B2. Keep only relevant columns 			
				LAG(lc.mql_id) OVER(ORDER BY lq.first_contact_date) AS previous_closed_deal	-- A3. Add previous deal next to the current
		 FROM		leads_qualified lq								-- A1. Add closed leads information to qualified ones
				LEFT JOIN leads_closed lc							-- A2. Using LEFT JOIN to keep NULL in case the qualified 
				ON lq.mql_id = lc.mql_id) AS leads_pairs					--     lead is not closed
WHERE		previous_closed_deal IS NOT NULL;								-- B1. Filter previous non closed deals 


-- Q10. Compare total monthly declared product catalog size changes between for resellers.
WITH RECURSIVE monthly_declared_product_sizes AS (
		SELECT		DATE_FORMAT(won_date, '%Y-%m-01') AS month_year,	-- 3. Change dates's day to 1. Later it will be removed
				SUM(declared_product_catalog_size) AS total_dpcs	-- 4. Calculate the total monthly dpcs
		FROM		leads_closed
		WHERE		business_type = 'reseller'				-- 1. Filter resellers
		GROUP BY	month_year),						-- 2. Group by date (like 'Y-m-1')
		
	date_sequence AS (SELECT  	MIN(month_year) AS month_year				-- Recursive CTE to generate dates from the first month
			  FROM 		monthly_declared_product_sizes				-- to the last from the previous table, in order to add 
												-- missing months in case some months between 
                      	  UNION	ALL															
                      	  SELECT	DATE_ADD(month_year, INTERVAL 1 MONTH) AS month_year	-- Add one month to previous date 
                      	  FROM		date_sequence
                      	  WHERE		month_year < (SELECT 	MAX(month_year) 		-- Stop when the date overcomes the last date in the previous table
			  			      FROM	monthly_declared_product_sizes)),
					
      dpcs_sequences AS (SELECT		DATE_FORMAT(ds.month_year, '%m-%Y') AS month_year,	-- 3. Change the date formata to remove the day
					COALESCE(total_dpcs, 0) AS total_dpcs			-- 4. Replace null dpcs (where data were not present) with zeroes
			 FROM 	 	date_sequence ds					-- 1. To all generated dates add the dpcs
					LEFT JOIN monthly_declared_product_sizes mdps		-- 2. Since LEFT JOIN is used, NULL will be added for date where data are not present
					ON ds.month_year = mdps.month_year)
 

SELECT		month_year,
		total_dpcs - LAG(total_dpcs) OVER(ORDER BY month_year) AS diff_total_dpcs	-- 1. Calculate the diffrences using the table abov
FROM		dpcs_sequences;
