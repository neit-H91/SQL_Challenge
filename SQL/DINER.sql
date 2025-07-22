-- 1. What is the total amount each customer spent at the restaurant?
select sum(price), customer_id 
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
group by customer_id;

-- 2. How many days has each customer visited the restaurant?
select count(order_date), customer_id
from dannys_diner.sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT ON (customer_id) *
FROM dannys_diner.sales
ORDER BY customer_id, order_date, product_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_id, COUNT(*) as total_purchases
FROM dannys_diner.sales
GROUP BY product_id
ORDER BY total_purchases DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?
SELECT customer_id, product_id, total
FROM (
  SELECT customer_id, product_id, COUNT(*) AS total,
         RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) as rank
  FROM dannys_diner.sales
  GROUP BY customer_id, product_id
) sub
WHERE rank = 1;	

-- 6. Which item was purchased first by the customer after they became a member?
select distinct on (m.customer_id) * from
dannys_diner.sales s
join dannys_diner.members m
on s.customer_id = m.customer_id
where s.order_date > m.join_date
order by m.customer_id, order_date asc;

-- 7. Which item was purchased just before the customer became a member?
select distinct on (s.customer_id) * from
dannys_diner.sales s
join dannys_diner.members m
on s.customer_id = m.customer_id
where s.order_date < m.join_date
order by s.customer_id, order_date desc;

-- 8. What is the total items and amount spent for each member before they became a member?
select count(*), sum(price), m.customer_id 
from dannys_diner.sales s
join dannys_diner.members m
on s.customer_id = m.customer_id
join dannys_diner.menu mn
on s.product_id = mn.product_id
where s.order_date < m.join_date
group by m.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select sum(case when product_name = 'sushi' then price*20 else price*10 end), customer_id
from dannys_diner.sales s
join dannys_diner.menu m
on s.product_id = m.product_id
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select sum(case when order_date between join_date and join_date + INTERVAL '7 days' then price*20 when product_name = 'sushi' then price*20 else price*10 end), s.customer_id
from dannys_diner.sales s
join dannys_diner.menu mn
on s.product_id = mn.product_id
join dannys_diner.members mm
on s.customer_id = mm.customer_id
where order_date between '2021-01-01' and '2021-01-31'
group by s.customer_id;