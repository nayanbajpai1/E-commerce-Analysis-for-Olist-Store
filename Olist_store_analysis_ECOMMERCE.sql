CREATE DATABASE olist
USE olist


--Cleaning and Removing unwanted columns 

SELECT * 
FROM [dbo].[olist_geolocation_dataset]

--Droping  columns (geolocation_lat , geolocation_lng)

ALTER TABLE [dbo].[olist_geolocation_dataset] DROP COLUMN geolocation_lat , geolocation_lng

------------------------------------------------------------------------------------------------------------------------------

--Checking data type

SELECT column_name , data_type 
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'olist_geolocation_dataset'

SELECT * 
FROM [dbo].[olist_geolocation_dataset]

-- changing the data type

ALTER TABLE [dbo].[olist_geolocation_dataset] ALTER COLUMN geolocation_zip_code_prefix INT

----------------------------------------------------------------------------------------------------------------------------

SELECT column_name , data_type 
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'olist_products_dataset'

-- changing datatype

ALTER TABLE olist_products_dataset ALTER COLUMN product_weight_g INT


-----------------------------------------------------------------------------------------------------------------------------

--Adding column name product_category_name_english to [olist_products_dataset]


SELECT * 
FROM [dbo].[olist_products_dataset]

SELECT * 
FROM product_category_name_translation

ALTER TABLE [dbo].[olist_products_dataset] ADD product_category_name_english varchar(100)

UPDATE [dbo].[olist_products_dataset] SET product_category_name_english = (select product_category_name_english 
from product_category_name_translation WHERE product_category_name_translation.product_category_name = 
[dbo].[olist_products_dataset].product_category_name)


------------------------------------------------------------------------------------------------------------------------------

SELECT * 
FROM [dbo].[olist_order_items_dataset]

-- Rounding price and freight_value

UPDATE olist_order_items_dataset SET price = ROUND(price,1)

UPDATE olist_order_items_dataset SET freight_value = ROUND(freight_value,2)

---------------------------------------------------------------------------------------------------------------------------------

SELECT * 
FROM [dbo].[olist_order_payments_dataset]

-- Rounding payment_value

UPDATE [dbo].[olist_order_payments_dataset] SET payment_value = ROUND(payment_value,2)

----------------------------------------------------------------------------------------------------------------------------------

SELECT * 
FROM [dbo].[olist_products_dataset]

-- removing product len , height , width , name length , description lenght

ALTER TABLE [dbo].[olist_products_dataset] DROP COLUMN product_name_lenght , product_description_lenght , product_length_cm,
product_height_cm , product_width_cm

-----------------------------------------------------------------------------------------------------------------------------------
-- Renaming the columns name

SP_RENAME '[dbo].[product_category_name_translation].column2' ,'product_category_name_english' , 'column'

DELETE FROM [dbo].[product_category_name_translation] WHERE product_category_name = 'product_category_name'


--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------- PRODUCT ANALYSIS ---------------------------------------------------------------------------

--TOP 10 PRODUCTS WITH RESPECT TO PAYMENTS

SELECT TOP 10 p.product_category_name, product_category_name_english , ROUND(SUM(payment_value),2) sum_of_payments 
FROM olist_products_dataset p
INNER JOIN [dbo].[olist_order_items_dataset] o ON p.product_id = o.product_id
INNER JOIN [dbo].[olist_orders_dataset] ord ON o.order_id = ord.order_id
INNER JOIN [dbo].[olist_order_payments_dataset] pay ON ord.order_id = pay.order_id
GROUP BY p.product_category_name,product_category_name_english 
ORDER BY sum_of_payments DESC 

/*Insights:

1. The Bed, Bath, and Table category has the highest total payment value, approximately 1.7 million.

2. The Health & Beauty and Computer Accessories categories also show significant payment values, each exceeding 1.5 million. */


-----------------------------------------------------------------------------------------------------------------------------------


--BOTTOM 10 PRODUCTS WITH RESPECT TO PAYMENTS

SELECT TOP 10 p.product_category_name, Coalesce(product_category_name_english,'No Name') AS English_name , ROUND(SUM(payment_value),2) sum_of_payments 
FROM olist_products_dataset p
INNER JOIN [dbo].[olist_order_items_dataset] o ON p.product_id = o.product_id
INNER JOIN [dbo].[olist_orders_dataset] ord ON o.order_id = ord.order_id
INNER JOIN [dbo].[olist_order_payments_dataset] pay ON ord.order_id = pay.order_id
GROUP BY p.product_category_name,product_category_name_english 
ORDER BY sum_of_payments 


/* Insights:

1. Security and Services (seguros_e_servicos) has the lowest payment value at 324.51, reflecting minimal customer engagement.

2. Fashion - Children's Clothes (fashion_roupa_infanto_juvenil) ranks second-lowest, with a payment value of 785.67.

3. CDs and DVDs - Musicals (cds_dvds_musicais) contributed 1,199.43, showing limited relevance in a digital-focused market. */

---------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------Product-wise order counts-----------------------------------------------------------

SELECT product_category_name_english , COUNT(order_id) order_counts 
FROM olist_products_dataset p
INNER JOIN olist_order_items_dataset O ON P.product_id = O.product_id
GROUP BY product_category_name_english
ORDER BY order_counts DESC

/* Insights:

1. Bed, bath, and table categories have over 11,000 order counts.

2. Health & beauty, sports & leisure, furniture & decor, computer accessories, housewares, and watches & gifts categories 
each have over 5,000 order counts.

3. Security & services and fashion children's clothes categories have fewer than 10 order counts.*/


---------------------------------------------------------------------------------------------------------------------------------

-- PRODUCT WITH MAXIMUM WEIGHT

SELECT * 
FROM olist_products_dataset 
WHERE product_weight_g = (SELECT MAX(product_weight_g) FROM olist_products_dataset)


/* Insight:

1. Bed, bath, table has the highest weight which is around 40kg */


------------------------------------------------ CUSTOMER ANALYSIS ---------------------------------------------------------


-- TOP 10 VALUABLE CUSTOMERS

SELECT TOP 10 c.customer_id , SUM(payment_value) AS total_payment 
FROM olist_customers_dataset C
INNER JOIN olist_orders_dataset O ON c.customer_id = o.customer_id
INNER JOIN olist_order_payments_dataset P ON o.order_id = p.order_id
GROUP BY c.customer_id 
ORDER BY total_payment DESC


/* Insight:

1. There are six customers with payment values exceeding ₹5,000.*/

--------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------CITY ANALYSIS----------------------------------------------------------

-- TOP 10 CITIES  BY TOTAL PAYMENTS.


SELECT TOP 10 c.customer_city , ROUND(SUM(payment_value),2) AS total_payment 
FROM olist_customers_dataset C
INNER JOIN olist_orders_dataset O ON c.customer_id = o.customer_id
INNER JOIN olist_order_payments_dataset P ON o.order_id = p.order_id
GROUP BY c.customer_city
ORDER BY total_payment DESC

-- BOTTOM 10 CITIES  BY TOTAL PAYMENTS.


SELECT  TOP 10 c.customer_city , ROUND(SUM(payment_value),2) AS total_payment 
FROM olist_customers_dataset C
INNER JOIN olist_orders_dataset O ON c.customer_id = o.customer_id
INNER JOIN olist_order_payments_dataset P ON o.order_id = p.order_id
GROUP BY c.customer_city
ORDER BY total_payment 


/* Insight:

1. Sao paulo has a total payment value exceeding 22 millions 

2. There are 473 cities with patment values in double digits only.*/




----------------------------------------------STATE ANALYSIS-------------------------------------------------------

-- TOP 10 STATE BY TOTAL PAYMENTS


SELECT TOP 10 c.customer_state , ROUND(SUM(payment_value),2) AS total_payment 
FROM olist_customers_dataset C
INNER JOIN olist_orders_dataset O ON c.customer_id = o.customer_id
INNER JOIN olist_order_payments_dataset P ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_payment DESC


-- BOTTOM 10 STATE BY TOTAL PAYMENTS


SELECT TOP 10 c.customer_state , ROUND(SUM(payment_value),2) AS total_payment 
FROM olist_customers_dataset C
INNER JOIN olist_orders_dataset O ON c.customer_id = o.customer_id
INNER JOIN olist_order_payments_dataset P ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_payment 


---------------------------------------RATING & REVIEW ANALYSIS--------------------------------------------------------


SELECT product_category_name_english , AVG(review_score) Reviews 
FROM olist_products_dataset P
INNER JOIN olist_order_items_dataset O ON p.product_id = o.product_id
INNER JOIN olist_orders_dataset ORD ON O.order_id = ORD.order_id
INNER JOIN olist_order_reviews_dataset R ON ORD.order_id = R.order_id
GROUP BY product_category_name_english 
ORDER BY Reviews DESC



/* Insights:

1. Security and services received an average rating of 2 out of 5.

2. The "Bad Bath Table," which has the highest payments, received an average rating of 3 out of 5.

3. Garden tools, watches & gifts, and food & drinks received an average rating of 4 out of 5.*/


-----------------------------------------------SELLER ANALYSIS---------------------------------------------------------------

--TOP 10 SELLERS 


SELECT TOP 10  s.seller_id , ROUND(SUM(payment_value),2) Total_payments 
FROM olist_sellers_dataset s
INNER JOIN olist_order_items_dataset ORD ON S.seller_id = ORD.seller_id
INNER JOIN olist_orders_dataset O ON ORD.order_id = O.order_id
INNER JOIN olist_order_payments_dataset P ON O.order_id = P.order_id
GROUP BY s.seller_id
ORDER BY Total_payments DESC


--BOTTOM 10 SELLERS


SELECT TOP 10  s.seller_id , ROUND(SUM(payment_value),2) Total_payments 
FROM olist_sellers_dataset s
INNER JOIN olist_order_items_dataset ORD ON S.seller_id = ORD.seller_id
INNER JOIN olist_orders_dataset O ON ORD.order_id = O.order_id
INNER JOIN olist_order_payments_dataset P ON O.order_id = P.order_id
GROUP BY s.seller_id
ORDER BY Total_payments 


------------------------------------------ANALYSIS OF PAYMENT TYPES---------------------------------------------------------


SELECT payment_type , COUNT(payment_type) payment_type 
FROM olist_order_payments_dataset
GROUP BY payment_type


/*Insights:

Approximately 77,000 people made purchases using credit cards.


----------------------------------------RECOMMENDATIONS--------------------------------------------------------------


1. Improve Underperforming Categories:

-- Security & Services: Increase customer engagement through targeted marketing or service improvements, and reassess pricing models.

-- Fashion - Children's Clothes: Boost sales through promotions, product expansion, or market research on customer preferences.

-- CDs & DVDs - Musicals: Consider phasing out physical products and focusing on digital alternatives.

2. Leverage High-Performing Categories:

-- Bed, Bath, and Table: Retain customer loyalty through personalized offers and promotions.
-- Health & Beauty, Computer Accessories: Focus on customer retention and cross-selling with special deals.

3. Enhance Customer Satisfaction:

-- Security & Services: Address customer dissatisfaction by gathering feedback and improving service quality.
-- Bed, Bath, and Table: Improve customer ratings by addressing product quality or service issues based on reviews.

4. Focus on Key Cities:

-- Sao Paulo: With its significant payment value, consider strengthening marketing and customer loyalty programs in Sao Paulo to maintain growth.
-- Expand in high-potential cities to increase market share and improve engagement.


5.State-Wise Strategy:

-- Concentrate on States with High Payment Values: States with strong performance, like Sao Paulo, should be prioritized for targeted campaigns and product expansion.
-- Explore New Markets in Lesser-Performing States: Investigate states with lower performance and tailor strategies to increase engagement and sales, focusing on improving customer experience and offering promotions

*/
----------------------------------------------------THANK YOU-------------------------------------------------------------------------------












