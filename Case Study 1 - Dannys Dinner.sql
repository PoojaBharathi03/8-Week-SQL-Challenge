/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select customer_id, sum(price) as Total
from dannys_diner.sales s
join dannys_diner.menu m
on s.product_id = m.product_id
group by customer_id
order by Total desc;



-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date)
from dannys_diner.sales s
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?

with cte_table as(
  select s.customer_id, s.order_date, m.product_name,
  dense_rank() over (partition by s.customer_id order by s.order_date) as rank
  from dannys_diner.sales s
  join dannys_diner.menu m
  on s.product_id = m.product_id)
  
SELECT customer_id, product_name
FROM cte_table
WHERE rank = 1
GROUP BY customer_id, product_name;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name, count(product_name) 
from dannys_diner.menu m
join dannys_diner.sales s
on m.product_id = s.product_id
group by product_name
order by count desc
limit 1;

-- 5. Which item was the most popular for each customer?

with cte_table as(
  select s.customer_id , m.product_name, count(m.product_id) as product_count,
  dense_rank() over(partition by s.customer_id order by count(s.customer_id) desc) as     rank
  from dannys_diner.sales s
  join dannys_diner.menu m
  on s.product_id = m.product_id
  group by s.customer_id, m.product_name)

select customer_id,product_name, product_count
from cte_table
where rank = 1;


-- 6. Which item was purchased first by the customer after they became a member?

with cte_table as(
  select s.customer_id, m.join_date, s.order_date, s.product_id,
  dense_rank() over(partition by s.customer_id order by s.order_date ) as rank
  from dannys_diner.sales s
  join dannys_diner.members m
  on s.customer_id = m.customer_id
  where s.order_date >= m.join_date )
  
select s.customer_id, s.order_date, m2.product_name
from cte_table as s
join dannys_diner.menu m2
on s.product_id = m2.product_id
where rank = 1;



-- 7. Which item was purchased just before the customer became a member?

with cte_table as(
  select s.customer_id, s.order_date, m.join_date, s.product_id,
  dense_rank() over (partition by s.customer_id order by s.order_date desc) as rank
  from dannys_diner.sales s
  join dannys_diner.members m
  on s.customer_id = m.customer_id
  where s.order_date< m.join_date)
  
select s.customer_id, s.order_date, m2.product_name
from cte_table as s
join dannys_diner.menu m2
on s.product_id = m2.product_id
where rank =1;





-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(DISTINCT s.product_id) AS unique_menu_item, SUM(mm.price) AS total_sales
FROM dannys_diner.sales AS s
JOIN dannys_diner.members AS m
 ON s.customer_id = m.customer_id
JOIN dannys_diner.menu AS mm
 ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

  
      
  
  






-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- price table
with cte_table as(
  select *,
      case when product_id = 1 then price*20
      else price*10
      end as points
  from dannys_diner.menu)
  
select customer_id, sum(points) as total_points
from cte_table as p
join dannys_diner.sales s
   on p.product_id = s.product_id
group by s.customer_id
order by s.customer_id;
  
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates_cte AS 
(
 SELECT *, 
  DATEADD(DAY, 6, join_date) AS valid_date, 
  EOMONTH('2021-01-31') AS last_date
 FROM dannys_diner.members AS m
)

SELECT d.customer_id, s.order_date, d.join_date, 
 d.valid_date, d.last_date, m.product_name, m.price,
 SUM(CASE
  WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
  WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
  ELSE 10 * m.price
  END) AS points
FROM dates_cte AS d
JOIN dannys_diner.sales AS s
 ON d.customer_id = s.customer_id
JOIN dannys_diner.menu AS m
 ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price



--Bonus Questions
-- Join All The Things
-- The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

/*Recreate the following table output using the available data:
                    
customer_id	order_date	product_name	price	member
A	2021-01-01	curry	15	N
A	2021-01-01	sushi	10	N
A	2021-01-07	curry	15	Y
A	2021-01-10	ramen	12	Y
A	2021-01-11	ramen	12	Y
A	2021-01-11	ramen	12	Y
B	2021-01-01	curry	15	N
B	2021-01-02	curry	15	N
B	2021-01-04	sushi	10	N
B	2021-01-11	sushi	10	Y
B	2021-01-16	ramen	12	Y
B	2021-02-01	ramen	12	Y
C	2021-01-01	ramen	12	N
C	2021-01-01	ramen	12	N
C	2021-01-07	ramen	12	N*/



select s.customer_id, s.order_date,m2.product_name,m2.price,
  case
    WHEN m1.join_date > s.order_date THEN 'N'
    WHEN m1.join_date <= s.order_date THEN 'Y'
  End as members
from dannys_diner.sales s
left join dannys_diner.members m1
    on s.customer_id = m1.customer_id
left join dannys_diner.menu m2
    on s.product_id = m2.product_id
order by s.order_date;



/*Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.*/


WITH summary_cte AS 
(
 SELECT s.customer_id, s.order_date, m.product_name, m.price,
  CASE
  WHEN mm.join_date > s.order_date THEN 'N'
  WHEN mm.join_date <= s.order_date THEN 'Y'
  ELSE 'N' END AS member
 FROM dannys_diner.sales AS s
 LEFT JOIN dannys_diner.menu AS m
  ON s.product_id = m.product_id
 LEFT JOIN dannys_diner.members AS mm
  ON s.customer_id = mm.customer_id
)
SELECT *, CASE
 WHEN member = 'N' then NULL
 ELSE
  RANK () OVER(PARTITION BY customer_id, member
  ORDER BY order_date) END AS ranking
FROM summary_cte;


