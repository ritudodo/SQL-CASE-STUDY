/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
    a.customer_id, SUM(b.price)
FROM
    dannys_diner.sales AS a
        LEFT JOIN
    menu AS b ON a.product_id = b.product_id
GROUP BY a.customer_id;

-- Customer A spent $76, B spent $74 and C spent $36.


-- 2. How many days has each customer visited the restaurant?

SELECT 
    customer_id, COUNT(DISTINCT order_date) AS num_days_visited
FROM
    dannys_diner.sales
GROUP BY customer_id;

-- Customer A visited 4 times, B visited 6 times and C visited 2 times.

-- 3. What was the first item from the menu purchased by each customer?

SELECT 
    s.customer_id, m.product_name AS first_item_purchased
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
WHERE
    s.order_date = (SELECT 
            MIN(order_date)
        FROM
            sales
        WHERE
            customer_id = s.customer_id)
GROUP BY s.customer_id , m.product_name;

-- First item purchasd by A was Sushi & Curry, B purchased Curry and C purchased Ramen.


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    m.product_id, m.product_name, COUNT(s.order_date)
FROM
    dannys_diner.menu AS m
        JOIN
    sales AS s ON m.product_id = s.product_id
GROUP BY m.product_name , m.product_id;

-- Ramen was most purchased item, was purchased 8 times.


-- 5. Which item was the most popular for each customer?

WITH cte1 AS
(
SELECT s.customer_id,m.product_name,
count(m.product_id) as Times_ordered,
dense_rank () over (PARTITION BY s.customer_id order by count(m.product_id) desc ) as ranks
FROM sales as s
JOIN menu as m
ON s.product_id=m.product_id
group by s.customer_id,m.product_name
)

select customer_id,
product_name,
times_ordered
from cte1
where ranks = 1 ;

--  A purchased Ramen 3 times, B purchased all items 2 times and C purchased Ramen 3 times.

-- 6. Which item was purchased first by the customer after they became a member?

WITH cte2 AS
(
SELECT s.customer_id,
m2.product_name,
s.order_date,
m1.join_date,
dense_rank() over ( partition by s.customer_id order by s.order_date ) as first_purchase
FROM sales as s
JOIN members as m1
on s.customer_id=m1.customer_id
join menu as m2
on s.product_id= m2.product_id
where s.order_date >= m1.join_date

)

select customer_id,
product_name,
order_date,
join_date
from cte2
where first_purchase=1;
  
-- A purchased Curry and B purchased Suhsi.
 
-- 7. Which item was purchased just before the customer became a member?

WITH cte2 AS
(
SELECT s.customer_id,
m2.product_name,
s.order_date,
m1.join_date,
dense_rank() over ( partition by s.customer_id order by s.order_date desc) as first_purchase
FROM sales as s
JOIN members as m1
on s.customer_id=m1.customer_id
join menu as m2
on s.product_id= m2.product_id
where s.order_date < m1.join_date

)

select customer_id,
product_name,
order_date,
join_date
from cte2
where first_purchase=1;

-- A purchased Sushi and Curry, B purchased Sushi.

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    a.customer_id,
    COUNT(DISTINCT c.product_id) AS total_items,
    SUM(c.price) AS total_amount
FROM
    sales AS a
        JOIN
    members AS b ON a.customer_id = b.customer_id
        JOIN
    menu AS c ON a.product_id = c.product_id
WHERE
    a.order_date < b.join_date
GROUP BY a.customer_id

-- A spent $25 on two items, B spent $40 on 2 items.

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
    s.customer_id,
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
        ELSE 10 * m.price
    END) AS total_points
FROM
    sales AS s
        JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- A have 860 points, B have 940 points and C have 360 points.

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN s.order_date BETWEEN m1.join_date AND (ADDDATE(m1.join_date, 6)) THEN 2 * 10 * m.price
        WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
        ELSE 10 * m.price
    END) AS total_points
FROM
    sales AS s
        JOIN
    menu AS m ON s.product_id = m.product_id
        JOIN
    members AS m1 ON s.customer_id = m1.customer_id
WHERE
    s.order_date < '2021-02-01'
GROUP BY s.customer_id;

-- A have 1370 points, B have 820 points.