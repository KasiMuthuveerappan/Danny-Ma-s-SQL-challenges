
# https://8weeksqlchallenge.com/case-study-1/
-- Danny's Diner 

use dannys_diner;

CREATE VIEW diner_res AS
    SELECT 
        *
    FROM
        sales s
            JOIN
        menu m USING (product_id)
            LEFT JOIN
        members ms USING (customer_id);

SELECT 
    *
FROM
    diner_res;

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
    customer_id, SUM(price) AS tot_amt
FROM
    sales s
        JOIN
    menu m USING (product_id)
GROUP BY customer_id;

SELECT 
    *
FROM
    diner_res;

SELECT 
    customer_id, concat('$ ',SUM(price)) AS tot_amt
FROM
    diner_res
GROUP BY 1;

-- 2.  How many days has each customer visited the restaurant?

SELECT 
    *
FROM
    diner_res;

SELECT 
    customer_id, concat(COUNT(distinct order_date),' days') AS cust_visit
FROM
    diner_res
GROUP BY 1;



-- 3. What was the first item from the menu purchased by each customer?


SELECT 
    *
FROM
    diner_res;

SELECT 
    customer_id, product_name
FROM
    diner_res
WHERE
    (customer_id , order_date) IN (SELECT 
            customer_id, MIN(order_date)
        FROM
            diner_res
        GROUP BY customer_id);

select customer_id,product_name
from(
select *,
dense_rank() over(partition by customer_id order by order_date) as rn
from diner_res
)as c 
where rn=1
group by 1,2;

-- 4.  What is the most purchased item on the menu 
--     and how many times was it purchased by all customers?

SELECT 
    *
FROM
    diner_res;


SELECT 
    product_name, COUNT(customer_id) AS times_cust_bought
FROM
    diner_res
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?

SELECT 
    *
FROM
    diner_res; 

select customer_id,product_name
from (
select customer_id,product_name,
dense_rank() over(partition by customer_id  order by count(product_name)desc) as rn
from diner_res
group by 1,2
)as c
where rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?

SELECT 
    *
FROM
    diner_res;

select customer_id,product_name
from (
select customer_id,product_name,
((min(order_date) over(partition by customer_id))-join_date) as first_order
from diner_res
where order_date>=join_date
group by 1,2,order_date,join_date
order by 3
)as c
group by 1,2;


SELECT 
    customer_id,
    product_name,
    MIN(diff) AS first_order_from_join_date
FROM
    (SELECT 
        customer_id, product_name, (order_date - join_date) AS diff
    FROM
        diner_res
    WHERE
        order_date >= join_date) AS c
GROUP BY 1 , 2
ORDER BY 1 , 3;

with cte as(
select *,rank() over(partition by customer_id order by diff) as rn
from
(
select *,abs(order_date-join_date) as diff
from diner_res
where order_date>=join_date
)as c
)
select customer_id,product_name,order_date,join_date
from cte
where rn=1;


-- 7. Which item was purchased just before the customer became a member?

SELECT 
    *
FROM
    diner_res;

with cte as(
select *,rank() over(partition by customer_id order by diff) as rn
from
(
select *,abs(order_date-join_date) as diff
from diner_res
where order_date<join_date
)as c
)
select customer_id,group_concat(product_name) as items_bought,order_date,join_date
from cte
where rn=1
group by 1,3,4;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    *
FROM
    diner_res;

with cte as(
select * from diner_res
where order_date<join_date
)
select customer_id,count(product_id) as total_items_bought,concat('$ ',sum(price)) as total_cost
from cte
group by 1
order by 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier
-- 		how many points would each customer have?

SELECT 
    *
FROM
    diner_res;

SELECT 
    customer_id,
    SUM(CASE
        WHEN product_name IN ('curry' , 'ramen') THEN price * 10
        ELSE price * 20
    END) AS points
FROM
    diner_res
GROUP BY 1;

-- 10. In the first week after a customer joins the program (including their join date) 
--     they earn 2x points on all items, not just sushi. 
-- 		how many points do customer A and B have at the end of January?

SELECT 
    *
FROM
    diner_res;

SELECT 
    customer_id, 
    SUM(case when product_name='sushi' then price * 20 
    when order_date between join_date and date_add(join_date, interval 6 day) then price*20
    else price* 10 end) AS points
FROM
    diner_res
WHERE
    order_date >= join_date and extract(month from order_date)=1
GROUP BY 1
ORDER BY 1;


-- Danny wants to check if the customers are members. if yes "Y" else "N"

SELECT 
    customer_id,
    order_date,
    product_name,
    price,
    IF(order_date >= join_date, 'Y', 'N') AS member
FROM
    diner_res
ORDER BY 1 , 2 , 3;

/* Danny also requires further information about the ranking of customer products,
 but he purposely does not need the ranking for non-member purchases
 so he expects null ranking values for the records when customers are not yet part of the loyalty program.*/
 
 with cte as(
 SELECT 
    customer_id,
    order_date,
    product_name,
    price,
    IF(order_date >= join_date, 'Y', 'N') AS member
FROM
    diner_res
)

select *, if(member="N" , NULL , rank() over(partition by customer_id,member order by customer_id,order_date,product_name)) as ranking
from cte
order by 1,2,3;