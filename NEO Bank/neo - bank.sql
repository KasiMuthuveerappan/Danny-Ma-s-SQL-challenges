use neo_bank;

select * from regions;
select count(*) from customer_transactions;
select count(*) from customer_nodes;


# creating view :

create view databank as (
select * 
from customer_nodes
join regions using(region_id)
left join customer_transactions using(customer_id)
order by customer_id
);


select * from databank;
select count(distinct customer_id) as cust_cnt from databank;

select * from databank
where left(end_date,4)='9999';

#write insight .. 5868 rows has end_date year of 9999 since its a end date we dont have to take any action


#                          A. Customer Nodes Exploration


--    How many unique nodes are there on the Data Bank system?

select count(distinct node_id) as no_of_unique_nodes 
from customer_nodes;


--    What is the number of nodes per region?

SELECT 
    region_name, COUNT(node_id) AS cnt_node,
    COUNT(DISTINCT node_id) AS unique_no_of_nodes
FROM
    customer_nodes cn
        JOIN
    regions r USING (region_id)
GROUP BY 1
ORDER BY 2 DESC;


--    How many customers are allocated to each region?

select region_name,count(distinct customer_id) as cust_cnt
from customer_nodes cn
join regions r
using(region_id)
group by 1
order by 1;


--    How many days on average are customers reallocated to a different node?

select * from customer_nodes;

select round(avg(tot_node_shift_days)) as avg_node_reallocation_days
from(
select customer_id,avg(datediff(end_date,start_date)) as tot_node_shift_days
from customer_nodes
where left(end_date,4) != '9999'
group by 1) as c;


-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

# works in postgre sql and db fiddle...

WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,region_id,
    sum(end_date - start_date) AS days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id,region_id, start_date, end_date
) 
  select region_id,
    percentile_disc(0.5) within group (order by node_days.days_in_node)as median,
    percentile_disc(0.8) within group (order by node_days.days_in_node) as per_80,
    percentile_disc(0.95) within group (order by node_days.days_in_node)as per_95
from node_days
group by 1

/*output:
region_id	median	per_80	per_95
	1		15		23		28
	2		15		23		28
	3		15		24		28
	4		15		23		28
	5		15		24		28
*/

WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,region_id,
    sum(end_date - start_date) AS days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id,region_id, start_date, end_date
) 
  select region_id,
    percentile_cont(0.5) within group (order by node_days.days_in_node)as median,
    percentile_cont(0.8) within group (order by node_days.days_in_node) as per_80,
    percentile_cont(0.95) within group (order by node_days.days_in_node)as per_95
from node_days
group by 1;

/*output:
region_id	median	per_80	per_95
	1		15		23		28
	2		15		23		28
	3		15		24		28
	4		15		23		28
	5		15		24		28
*/

WITH reallocation_day AS
  (SELECT *,
          (datediff(end_date, start_date)) AS reallocation_days
   FROM databank
   WHERE YEAR(end_date)!='9999'
   ),percentile_cte AS(
   SELECT *,
          percent_rank() over(PARTITION BY region_name
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_day
   )
SELECT 
       region_name,
       min(reallocation_days)
FROM percentile_cte
WHERE p >95
GROUP BY 1;


WITH reallocation_day AS
  (SELECT *,
          (datediff(end_date, start_date)) AS reallocation_days
   FROM databank
   WHERE YEAR(end_date)!='9999'
   ),percentile_cte AS(
   SELECT *,
          percent_rank() over(PARTITION BY region_name
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_day
   )
SELECT region_id,
       region_name,
       min(reallocation_days)as '95th pct reallocation'
FROM percentile_cte
WHERE p > 95
GROUP BY 1,2
ORDER BY 1,2;


WITH reallocation_day AS
  (SELECT *,
          (datediff(end_date, start_date)) AS reallocation_days
   FROM databank
   WHERE YEAR(end_date)!='9999'
   ),percentile_cte AS(
   SELECT *,
          percent_rank() over(PARTITION BY region_name
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_day
   )
SELECT region_id,
       region_name,
       min(reallocation_days)as '80th pct reallocation'
FROM percentile_cte
WHERE p > 80
GROUP BY 1,2
ORDER BY 1,2;


WITH reallocation_day AS
  (SELECT *,
          (datediff(end_date, start_date)) AS reallocation_days
   FROM databank
   WHERE YEAR(end_date)!='9999'
   ),percentile_cte AS(
   SELECT *,
          percent_rank() over(PARTITION BY region_name
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_day
   )
SELECT region_id,
       region_name,
       min(reallocation_days)as '50th pct reallocation (median)'
FROM percentile_cte
WHERE p > 50
GROUP BY 1,2
ORDER BY 1,2;

#									B. Customer Transactions

--  What is the unique count and total amount for each transaction type?

select * from customer_transactions;

select txn_type , count(customer_id) as tot_type_transact,
 sum(txn_amount) as total_transact_amt
from  customer_transactions
group by 1;

#unique customers used type of txn:

select count(distinct customer_id) as cust_cnt from databank;

select txn_type , count(Distinct customer_id) as tot_type_transact, sum(txn_amount) as total_transact_amt
from  customer_transactions
group by 1;


# What is the average total historical deposit counts and amounts for all customers?

select * from customer_transactions;

with avg_txn as (
select customer_id,count(txn_type) as txn_cnt ,avg(txn_amount) txn_amt  # (use sum or avg)
from customer_transactions
where txn_type='deposit'
group by 1
)
select round(avg(txn_cnt)) as avg_txn_cnt , round(avg(txn_amt),2) as avg_txn_amt
from avg_txn;

-- For each month - how many Data Bank customers make more than 1 deposit 
-- and either 1 purchase or 1 withdrawal in a single month?

select * from databank;

select txn_month , count(Distinct customer_id) as cnt_cust_txn
from (
select month(txn_date) as txn_month, txn_type, customer_id
from databank
group by 1,2,3
having count(distinct txn_type='deposit')>1 
	and (count(distinct txn_type='withdrawal')>=1 or count(distinct txn_type='purchase')>=1)
order by 1
) as c
group by 1;    # this is wrng ... u r not count distinct

select * from databank
where txn_type='withdrawal';

WITH regular_customers AS (
SELECT 
    customer_id,
    extract(MONTH from txn_date) AS txn_month,
    SUM(case when txn_type = 'deposit' then 1 end) AS d_cnt,
    SUM(case when txn_type = 'purchase' then 1 end) AS p_cnt,
    SUM(case when txn_type = 'withdrawal' then 1 end) AS w_cnt
FROM
    customer_transactions
GROUP BY 1 , 2
)
SELECT 
    txn_month, COUNT(DISTINCT customer_id) AS cust_txn_cnt
FROM
    regular_customers
WHERE
    d_cnt > 1 AND (p_cnt >= 1 OR w_cnt >= 1)
GROUP BY 1
ORDER BY 1;

WITH regular_customers AS (
SELECT 
    customer_id,
    MONTH(txn_date) AS txn_month,
    SUM(IF(txn_type = 'deposit', 1, 0)) AS d_cnt,
    SUM(IF(txn_type = 'purchase', 1, 0)) AS p_cnt,
    SUM(IF(txn_type = 'withdrawal', 1, 0)) AS w_cnt
FROM
    databank # dont take databak bcuz we have all data joined it also gives the count where some transaction will be null
GROUP BY 1 , 2
)
SELECT 
    txn_month, COUNT(DISTINCT customer_id) AS cust_txn_cnt
FROM
    regular_customers
WHERE
    d_cnt > 1 AND (p_cnt >= 1 OR w_cnt >= 1)
GROUP BY 1
ORDER BY 1; 
#doubt .. this answer is not crct i guess



select * from databank;
# What is the closing balance for each customer at the end of the each month?

  create view cust_mnthly_end_balance as(
  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  order by 1
), monthend_bal AS (
  SELECT
    DISTINCT customer_id,
    DATE_ADD('2020-01-31', INTERVAL (seq.seq) MONTH) AS ending_month
  FROM (
    SELECT 0 AS seq UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
  ) AS seq
  CROSS JOIN customer_transactions
), end_bal as(
select eb.customer_id,ending_month,ifnull(transaction_balance,0) as balance
from monthend_bal eb
left join monthly_bal mb
on closing_month = ending_month and eb.customer_id = mb.customer_id
)
SELECT 
  customer_id, 
  ending_month, 
  balance as monthly_transaction_amt,
  sum(balance) over(partition by customer_id order by ending_month range between unbounded preceding and current row) as ending_balence
 FROM end_bal
 GROUP BY 1,2,3
 ORDER BY 1,2
 );
 
 Select * from cust_mnthly_end_balance;
 
 
SELECT 
    customer_id, SUM(monthly_transaction_amt) AS current_balance
FROM
    cust_mnthly_end_balance
GROUP BY 1;
 
 # negative balence cust % & positive balence cust %
 
 with pct_cust as(
 select customer_id,sum(monthly_transaction_amt) as current_balance
 from cust_mnthly_end_balance
 group by 1
 ), pct as(
select 
(sum(case when current_balance < 0 then 1 end)/count(distinct customer_id)*100) as negative_bal_cust_pct
from pct_cust
)

select 
concat(round((negative_bal_cust_pct),2),'%') as Negative_ending_balence_cust_pct,
concat(round((100-negative_bal_cust_pct),2),'%') as positive_ending_balance_cust_pct
from pct;
 
 -- this result is based on four months ending balence (above query)
 
 
  # monthly -ve & +ve balence maintaining customer %'s....
 
  Select * from cust_mnthly_end_balance;
  
 with monthly_pct as(
 select 
 sum(((case when ending_balence <= 0 then 1 end)/(select count(1) from cust_mnthly_end_balance)*100)) as monthly_negative_balance_customers,
 sum(((case when ending_balence > 0 then 1 end)/(select count(1) from cust_mnthly_end_balance)*100)) as monthly_positive_balance_customers
 from cust_mnthly_end_balance
 )
 select 
 concat(round(monthly_negative_balance_customers,2),'%') as monthly_negative_balance_customers_pct,
 concat(round(monthly_positive_balance_customers,2),'%') as monthly_positive_balance_customers_pct
 from monthly_pct;

# What is the percentage of customers who increase their closing balance by more than 5%?

select * from cust_mnthly_end_balance;

with nxt_mnth_txn as(
select *,
ifnull(lead(ending_balence) over(partition by customer_id order by ending_month),0) as nxt_mnth_bal
from cust_mnthly_end_balance
),txn_pct as(
select *, (((nxt_mnth_bal-ending_balence)/ending_balence)*100) as pct
from nxt_mnth_txn
)
select concat(round(count(pct)/(select count(1) from cust_mnthly_end_balance)*100,2),'%') as cust_maintaining_above_5pct
from txn_pct
where pct>5.0;

# followup 
-- cust_maintaining_below_5pct

with nxt_mnth_txn as(
select *,
ifnull(lead(ending_balence) over(partition by customer_id order by ending_month),0) as nxt_mnth_bal
from cust_mnthly_end_balance
),txn_pct as(
select *, (((nxt_mnth_bal-ending_balence)/ending_balence)*100) as pct
from nxt_mnth_txn
)
select concat(round(count(pct)/(select count(1) from cust_mnthly_end_balance)*100,2),'%') as cust_maintaining_below_5pct
from txn_pct
where pct<5.0;


# cust_with_positive_opening_but_negative_closing_bal pct 

select * from cust_mnthly_end_balance;

with nxt_mnth_txn as(
select *,
ifnull(lead(ending_balence) over(partition by customer_id order by ending_month),0) as nxt_mnth_bal
from cust_mnthly_end_balance
),txn_pct as(
select *, (((nxt_mnth_bal-ending_balence)/ending_balence)*100) as pct
from nxt_mnth_txn
)
select concat(round((count(*)/(select count(1) from cust_mnthly_end_balance)*100),2),'%') as cust_with_positive_opening_but_negative_closing_bal
from txn_pct
where pct<=0 and monthly_transaction_amt>0; 

# pct<=0 gives 28.50% 
# pct<0 gives 22.6% 
# pct=0 gives 5.90%


# 								C. Data Allocation Challenge

-- minimum, average and maximum values of the running balance for each customer

SELECT 
    *
FROM
    cust_mnthly_end_balance;

SELECT 
    customer_id,
    MIN(ending_balence) AS Min_txn_amt,
    ROUND(AVG(ending_balence), 2) AS avg_txn_amt,
    MAX(ending_balence) AS Max_txn_amt
FROM
    cust_mnthly_end_balance
GROUP BY 1;

# 									D. Extra Challenge


/* they want to calculate data growth using an interest calculation, 
just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers 
by increasing their data allocation based off the interest calculated on a daily basis at the end of each day,
 how much data would be required for this option on a monthly basis? 
 
 Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, 
however they may also be interested in a daily compounding interest calculation.
*/

select * from databank order by customer_id,txn_date;
Select * from cust_mnthly_end_balance;

-- im doing it monthwise as interest gets added monthly

create view new_bal_roi as(
  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  order by 1
), monthend_bal AS (
  SELECT
    DISTINCT customer_id,
    DATE_ADD('2020-01-31', INTERVAL (seq.seq) MONTH) AS ending_month
  FROM (
    SELECT 0 AS seq UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
  ) AS seq
  CROSS JOIN customer_transactions
), end_bal as(
select eb.customer_id,ending_month,ifnull(transaction_balance,0) as balance
from monthend_bal eb
left join monthly_bal mb
on closing_month = ending_month and eb.customer_id = mb.customer_id
)
SELECT 
  customer_id, 
  ending_month, 
  balance as monthly_txn_amt, if (balance>0,round((balance*6/1200),2),0) as interest ,
  round(balance + (balance*6/1200),2) as new_bal,
round(sum(balance+ (balance*6/1200)) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence_with_si
 FROM end_bal
 GROUP BY 1,2,3
 ORDER BY 1,2
 );
drop view new_bal_roi;
select * from new_bal_roi;  

select customer_id,min(ending_balence) as Min_txn_amt,
round(avg(ending_balence),2) as avg_txn_amt,max(ending_balence) as Max_txn_amt
from new_bal_roi
group by 1;

use neo_bank;
# monthend balence >>> with_SI 
  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  order by 1
), monthend_bal AS (
  SELECT
    DISTINCT customer_id,
    DATE_ADD('2020-01-31', INTERVAL (seq.seq) MONTH) AS ending_month
  FROM (
    SELECT 0 AS seq UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
  ) AS seq
  CROSS JOIN customer_transactions
), end_bal as(
select eb.customer_id,ending_month,ifnull(transaction_balance,0) as balance
from monthend_bal eb
left join monthly_bal mb
on closing_month = ending_month and eb.customer_id = mb.customer_id
),fill as(
SELECT 
  customer_id, 
  ending_month, 
  balance as monthly_txn_amt, if (balance>0,round((balance*6/1200),2),0) as interest ,
 round(if(balance>0,balance + (balance*6/1200),balance),2) as new_bal,
round(sum(balance+ (balance*6/1200)) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence_with_si
 FROM end_bal
 GROUP BY 1,2,3
 ORDER BY 1,2
 ),passbook as(
 select 
customer_id, ending_month, monthly_txn_amt, interest, 
if(interest=0,lag(interest) over(partition by customer_id order by ending_month),interest) as fill_interest,
new_bal,
if(new_bal=0,lag(new_bal) over(partition by customer_id order by ending_month),new_bal) as fill_new_bal
from fill
GROUP BY 1,2,3
ORDER BY 1,2
),showcase_passbook as(
select
customer_id, ending_month, monthly_txn_amt, interest, fill_interest, new_bal, fill_new_bal , 
if(new_bal=0,(fill_interest + fill_new_bal),new_bal) as monthend_bal_with_si
from passbook
GROUP BY 1,2,3
ORDER BY 1,2
)
select 
customer_id, ending_month, monthly_txn_amt, fill_new_bal as monthend_bal, 
fill_interest as roi_amt , monthend_bal_with_si
from showcase_passbook
GROUP BY 1,2,3
ORDER BY 1,2;



# CI = P(1 + (r/12) )^12t – P

# Assume , if there is no txn , no interest for that month....
  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  order by 1
), monthend_bal AS (
  SELECT
    DISTINCT customer_id,
    DATE_ADD('2020-01-31', INTERVAL (seq.seq) MONTH) AS ending_month
  FROM (
    SELECT 0 AS seq UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
  ) AS seq
  CROSS JOIN customer_transactions
), end_bal as(
select eb.customer_id,ending_month,ifnull(transaction_balance,0) as balance
from monthend_bal eb
left join monthly_bal mb
on closing_month = ending_month and eb.customer_id = mb.customer_id
),compound_interest_bal as(
SELECT 
  customer_id, 
  ending_month, 												# 0.0833 is for 1month =(1/12)
  balance as monthly_txn_amt, 
  if (balance>0,round(balance*(1+pow(0.005,(12*0.0833)))-balance,2),0) as interest,
  round(if(balance>0,balance + (balance*(1+pow(0.005,(12*0.0833)))-balance),balance),2) as new_bal
 -- round(sum(balance+(balance*(1+pow(0.005,(12*0.0833)))-balance) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence
 FROM end_bal
 GROUP BY 1,2,3
 order by 1,2
  ),fill as(
 select * ,
if(new_bal=0, lag(interest) over(partition by customer_id order by ending_month),interest) as fill_interest,
if(new_bal=0,lag(new_bal) over(partition by customer_id order by ending_month),new_bal) as fill_new_bal
from compound_interest_bal
group by 1,2,3
order by 1,2
),passbook as(
select customer_id, ending_month, monthly_txn_amt,interest, fill_new_bal as monthend_bal,
if(monthly_txn_amt>0,round(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal,2),interest)as roi 
-- if(monthly_txn_amt=0, round(fill_new_bal+(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal),2),fill_new_bal) as monthend_bal_with_CI
from fill
group by 1,2,3
order by 1,2
),showcase_passbook as(
select
customer_id, ending_month, monthly_txn_amt, monthend_bal, 
if(interest=0,roi,interest)as roi_amt,
round(if(monthly_txn_amt=0,(monthend_bal+if(interest=0,roi,interest)),monthend_bal),2) as mnthend_bal_with_CI
from passbook
group by 1,2,3
order by 1,2
)
select customer_id, ending_month, monthly_txn_amt, 
if(monthend_bal<0,0,monthend_bal) as monthend_balance,
if(roi_amt<0,0,roi_amt) as roi ,mnthend_bal_with_CI
from showcase_passbook
group by 1,2,3
order by 1,2;































  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  order by 1
), monthend_bal AS (
  SELECT
    DISTINCT customer_id,
    DATE_ADD('2020-01-31', INTERVAL (seq.seq) MONTH) AS ending_month
  FROM (
    SELECT 0 AS seq UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
  ) AS seq
  CROSS JOIN customer_transactions
), end_bal as(
select eb.customer_id,ending_month,ifnull(transaction_balance,0) as balance
from monthend_bal eb
left join monthly_bal mb
on closing_month = ending_month and eb.customer_id = mb.customer_id
),compound_interest_bal as(
SELECT 
  customer_id, 
  ending_month, 												# 0.0833 is for 1month =(1/12)
  balance as monthly_txn_amt, 
  if (balance>0,round(balance*(1+pow(0.005,(12*0.0833)))-balance,2),0) as interest,
  round(balance + (balance*(1+pow(0.005,(12*0.0833)))-balance),2) as new_bal
 -- round(sum(balance+(balance*(1+pow(0.005,(12*0.0833)))-balance) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence
 FROM end_bal
 GROUP BY 1,2,3
 ),fill as(
 select * ,
-- if(new_bal=0, lag(interest) over(partition by customer_id order by ending_month),interest) as fill_interest,
if(new_bal=0,lag(new_bal) over(partition by customer_id order by ending_month),new_bal) as fill_new_bal
from compound_interest_bal
group by 1,2,3
order by 1,2)
-- ),passbook as(
select customer_id, ending_month, monthly_txn_amt,interest, fill_new_bal as monthend_bal,
if(monthly_txn_amt>=0,interest,round(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal,2))as roi_amt ,
if(monthly_txn_amt=0, round(fill_new_bal+(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal),2),fill_new_bal) as monthend_bal_with_CI
from fill
group by 1,2,3
order by 1,2;
/*-- ) ,showcase_passbook as(
select
customer_id, ending_month, monthly_txn_amt,interest, monthend_bal, roi_amt ,
round(if(monthly_txn_amt=0,(monthend_bal+roi_amt),monthend_bal),2) as mnthend_bal_with_CI
from passbook
group by 1,2,3
order by 1,2;
/*)
select
customer_id, ending_month, monthly_txn_amt, monthend_bal, roi_amt ,
round(if(monthly_txn_amt<0,monthly_txn_amt,mnthend_bal_with_CI),2) as monthend_bal_with_CI
from showcase_passbook
group by 1,2,3
order by 1,2;
-- round(sum(new_bal) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence_with_ci
 
 # ---------------------
 
 
   WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  order by 1
), monthend_bal AS (
  SELECT
    DISTINCT customer_id,
    DATE_ADD('2020-01-31', INTERVAL (seq.seq) MONTH) AS ending_month
  FROM (
    SELECT 0 AS seq UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
  ) AS seq
  CROSS JOIN customer_transactions
), end_bal as(
select eb.customer_id,ending_month,ifnull(transaction_balance,0) as balance
from monthend_bal eb
left join monthly_bal mb
on closing_month = ending_month and eb.customer_id = mb.customer_id
),compound_interest_bal as(
SELECT 
  customer_id, 
  ending_month, 												# 0.0833 is for 1month =(1/12)
  balance as monthly_txn_amt, 
  if (balance>0,round(balance*(1+pow(0.005,(12*0.0833)))-balance,2),0) as interest,
  round(balance + (balance*(1+pow(0.005,(12*0.0833)))-balance),2) as new_bal
 -- round(sum(balance+(balance*(1+pow(0.005,(12*0.0833)))-balance) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence
 FROM end_bal
 GROUP BY 1,2,3
 
 
 
 ),fill as(
 select * ,
-- if(new_bal=0, lag(interest) over(partition by customer_id order by ending_month),interest) as fill_interest,
if(new_bal=0,lag(new_bal) over(partition by customer_id order by ending_month),new_bal) as fill_new_bal
from compound_interest_bal
group by 1,2,3
order by 1,2
),passbook as(
select customer_id, ending_month, monthly_txn_amt,interest, fill_new_bal as monthend_bal,
if(monthly_txn_amt>=0,round(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal,2),interest)as roi 
-- if(monthly_txn_amt=0, round(fill_new_bal+(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal),2),fill_new_bal) as monthend_bal_with_CI
from fill
group by 1,2,3
order by 1,2
),showcase_passbook as(
select
customer_id, ending_month, monthly_txn_amt, monthend_bal, 
if(interest=0,roi,interest)as roi_amt
-- round(if(monthly_txn_amt=0,(monthend_bal+roi_amt),monthend_bal),2) as mnthend_bal_with_CI
from passbook
group by 1,2,3
order by 1,2
)
select
customer_id, ending_month, monthly_txn_amt, monthend_bal, if(roi_amt<0,0,roi_amt) as roi_amount,
round((monthend_bal + if(roi_amt<0,0,roi_amt)),2) as monthend_bal_with_CI
from showcase_passbook
group by 1,2,3
order by 1,2;
-- round(sum(new_bal) over(partition by customer_id order by ending_month range between unbounded preceding and current row),2) as ending_balence_with_ci
 