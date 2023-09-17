## <h1 align="center" > 🏦Case Study #4: Data Bank 💰💵💳🪙

<p align="center"><kbd>
<img src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" alt="Image" width="500" height="520"></kbd>

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-4/). 

If you have any questions, reach out to me on [LinkedIn](https://www.linkedin.com/in/kasimuthuveerappan/).

*** 

## 📚Table Of Contents
  - [Introduction](#introduction)
  - [Problem Statement](#problem-statement)
  - [Datasets used](#datasets-used)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Questions and Solutions](#questions-and-solutions)
  
## 🌟Introduction
There is a new innovation in the financial industry called **Neo-Banks**: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!


## 🤔Problem Statement
The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!


## 📑Datasets used
Just like popular cryptocurrency platforms - Data Bank is also run off a network of nodes where both money and data is stored across the globe. In a traditional banking sense - you can think of these nodes as bank branches or stores that exist around the world. The  regions table contains the region_id and their respective region_name values.
  
<img width="176" alt="image" src="https://user-images.githubusercontent.com/81607668/130551759-28cb434f-5cae-4832-a35f-0e2ce14c8811.png">

Customers are randomly distributed across the nodes according to their region - this also specifies exactly which node contains both their cash and data.
This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!
  
Below is a sample of the top 10 rows of the data_bank.customer_nodes

<img width="412" alt="image" src="https://user-images.githubusercontent.com/81607668/130551806-90a22446-4133-45b5-927c-b5dd918f1fa5.png">


Customer transaction table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card
  
<img width="343" alt="image" src="https://user-images.githubusercontent.com/81607668/130551879-2d6dfc1f-bb74-4ef0-aed6-42c831281760.png">

 
## 🪢Entity Relationship Diagram

*Data Modelling* :

<p align="center"><kbd>
<img align="centre" width="631" alt="image" src="https://user-images.githubusercontent.com/81607668/130343339-8c9ff915-c88c-4942-9175-9999da78542c.png"></kbd>

***

## Questions and Solutions

### *Exploring DATA*

🔖 Creating a view for the whole data make it easier to visualize the data and explore to an extent. The advantages of creating views in SQL in a concise manner:

- Simplification: Views simplify complex queries, making it easier for developers to access and manipulate data.

- Security: Views enhance data security by controlling who can access specific data, without affecting underlying tables.

- Performance: Views can improve query performance by storing results and optimizing SQL execution plans.

- Maintenance: Views ease database maintenance by isolating changes and providing code reusability.

```sql

CREATE VIEW databank AS
    (SELECT 
        *
    FROM
        customer_nodes
            JOIN
        regions USING (region_id)
            LEFT JOIN
        customer_transactions USING (customer_id)
    ORDER BY customer_id);


select * from databank;

```

#### Output:

<kbd>![Screenshot 2023-09-17 114434](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/4c692edd-09ab-4f9c-8374-565141507d7c)</kbd>

#### Insight:

- Its a one stop view data of all transactions of all customers.

***
### 👉🏼*Total no.of customers*

```sql

SELECT 
    COUNT(DISTINCT customer_id) AS cust_cnt
FROM
    databank;

```

#### Output:

<kbd>![Screenshot 2023-09-17 114914](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/ca1e2cc5-da25-4a65-85e0-beba6eeebb2a)</kbd>

#### Insight:

- There are a total of 500 customers.

***
### 👉🏼*Some dates with year `'9999'` in enddate*

```sql

SELECT 
    *
FROM
    databank
WHERE
    YEAR(end_date) = '9999';

```

#### Output:

<kbd>![Screenshot 2023-09-17 115619](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/85e8d342-533f-49fa-943f-285323881707)</kbd>

<kbd>![Screenshot 2023-09-17 115644](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/acc73719-1bb5-4b94-9b85-e8412e4c1b00)</kbd>

#### Insight:

- There are 5868 rows with enddate year as *'9999'* , since it is an end_date we are not taking any action.

## 🏦 A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

```sql

SELECT 
    COUNT(DISTINCT node_id) AS no_of_unique_nodes
FROM
    customer_nodes;

```

#### Output:

<kbd>![Screenshot 2023-09-17 115913](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/73642c3a-73af-48dd-8863-dad558fb3d97)</kbd>

#### Insight:

- There are 5 unique nodes in the given Neo Bank system.

***

**2. What is the number of nodes per region?**

```sql

SELECT 
    region_name, COUNT(node_id) AS cnt_node,
    COUNT(DISTINCT node_id) AS unique_no_of_nodes
FROM
    customer_nodes cn
        JOIN
    regions r USING (region_id)
GROUP BY 1
ORDER BY 2 DESC;

```

#### Output:

<kbd>![Screenshot 2023-09-17 120435](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/c8372b50-0e58-44cd-977f-a5516094fbaf)</kbd>

#### Insight:

- There are 5 unique nodes in all the regions and no.of nodes in each region is also showcased.

***

**3. How many customers are allocated to each region?**

```sql

SELECT 
    region_name, COUNT(DISTINCT customer_id) AS cust_cnt
FROM
    customer_nodes cn
        JOIN
    regions r USING (region_id)
GROUP BY 1
ORDER BY 1;
```
or (since we created a view *`databank`* )
```sql
SELECT 
    region_name, COUNT(DISTINCT customer_id) AS cust_cnt
FROM
    databank
GROUP BY 1
ORDER BY 1;

```

#### Output:

<kbd>![Screenshot 2023-09-17 120831](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/e5bb92d9-c89f-4696-9bfb-25e7e3d3c540)</kbd>

***

**4. How many days on average are customers reallocated to a different node?**

```sql

SELECT 
    ROUND(AVG(tot_node_shift_days)) AS avg_node_reallocation_days
FROM
    (SELECT 
        customer_id,
            AVG(DATEDIFF(end_date, start_date)) AS tot_node_shift_days
    FROM
        customer_nodes
    WHERE
        YEAR(end_date) != '9999'
    GROUP BY 1) AS c;

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/6793c81d-b1e0-4b57-a3c5-3236043286cb)</kbd>

#### Insights:

- On an average of Every 15 days , customers are reallocated to a different node 


***

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

*`postgre SQL`*

```sql

WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,region_id,
    SUM(end_date - start_date) AS days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id,region_id, start_date, end_date
) 
  SELECT region_id,
    percentile_disc(0.5) within group (order by node_days.days_in_node)as median,
    percentile_disc(0.8) within group (order by node_days.days_in_node) as per_80,
    percentile_disc(0.95) within group (order by node_days.days_in_node)as per_95
FROM node_days
group by 1

```

*or*

```sql

WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,region_id,
    SUM(end_date - start_date) AS days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id,region_id, start_date, end_date
) 
  SELECT region_id,
    percentile_cont(0.5) within group (order by node_days.days_in_node)as median,
    percentile_cont(0.8) within group (order by node_days.days_in_node) as per_80,
    percentile_cont(0.95) within group (order by node_days.days_in_node)as per_95
FROM node_days
group by 1

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/0ba90457-d7e3-4760-bbb7-0319ac17c336)</kbd>

#### Insights:

- Here, we get the same values of reallocation days in all regions for both percentile_discrete and percentile_continuous functions. 

*`My SQL`* 

*5️⃣0️⃣th percentile or Median*
- using percent_rank

```sql

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
       min(reallocation_days)as 'min 50th pct reallocation (median)'
FROM percentile_cte
WHERE p > 50
GROUP BY 1,2
ORDER BY 1,2;

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/79400e7e-fb83-4775-a5a0-9146346b3eb1)</kbd>

*8️⃣0️⃣th percentile*

```sql
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
```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/3f1795fe-6bec-469d-9ee0-da62a2dc91ba)</kbd>

*9️⃣5️⃣th percentile*

```sql

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

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/2acfbf2d-a207-4936-9992-208801066ba4)</kbd>

#### Insights:

- Here, we ignore the maximum days for reallocation becuz we know that max value for reallocation will max days in a month (i.e 30 days)
 
***

## 🏦 B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

```sql

SELECT 
    txn_type,
    COUNT(customer_id) AS tot_type_transact,
    COUNT(DISTINCT customer_id) AS cust_cnt,
    SUM(txn_amount) AS total_transact_amt
FROM
    customer_transactions
GROUP BY 1;

```


#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/2e5fcc01-0e5d-4b2c-b2c1-d28513902962)</kbd>

#### Insights:

- Out of 500 unique Customers , `All 500` customers made ***Deposits*** , while `448` customers ***Purchased*** and only `439` customers made a ***Withdrawl***.

***


**2. What is the average total historical deposit counts and amounts for all customers?**

```sql
WITH avg_txn AS (
SELECT 
    customer_id,
    COUNT(txn_type) AS txn_cnt,
    AVG(txn_amount) txn_amt
FROM
    customer_transactions
WHERE
    txn_type = 'deposit'
GROUP BY 1
)
SELECT 
    ROUND(AVG(txn_cnt)) AS avg_txn_cnt,
    CONCAT('$ ',ROUND(AVG(txn_amt))) AS avg_txn_amt
FROM
    avg_txn;
```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/a0578c00-7bf0-4cde-a9b7-299124ae6513)</kbd>

#### Insights:

- On an Average of **5** `Deposit` transactions happens and Amount of **$ 509** is *deposited* by the customers of ***Neo Bank***.

***

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**


```sql

WITH regular_customers AS (
SELECT 
    customer_id,
    MONTH(txn_date) AS txn_month,
    SUM(IF(txn_type = 'deposit', 1, 0)) AS d_cnt,
    SUM(IF(txn_type = 'purchase', 1, 0)) AS p_cnt,
    SUM(IF(txn_type = 'withdrawal', 1, 0)) AS w_cnt
FROM
    databank
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

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/d3c1467f-c64a-4ea0-bc0c-057ab526d550)</kbd>

***

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**

The key aspect to understanding the solution is to build up the tabele and run the CTEs cumulatively (run CTE 1 first, then run CTE 1 & 2, and so on). This approach allows for a better understanding of why specific columns were created or how the information in the tables progressed. 

```sql

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
 ORDER BY 1,2;

# I have also created a view for the same in the name of *`cust_mnthly_end_balance`* for further reference..

Select * from cust_mnthly_end_balance;

```

#### Output:

some of the ouput :    
<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/6c81008d-48bd-40a3-b189-ee57fd75e4e0)</kbd>
<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/3b608179-269b-4f63-adbe-79901d0b5594)</kbd>

#### Insights:

- On seeing the output, we can say the given data has only `four`months of transactions of every customers
- so *500 customers* with **4 months** transactions data. An overall `2000 rows` returned as a result.

***

### ** Additional exploration ** 

#### **Current Balance of every customer:**

```sql

SELECT 
    customer_id, SUM(monthly_transaction_amt) AS current_balance
FROM
    cust_mnthly_end_balance
GROUP BY 1;

```

#### Output:

some of the ouput :  
<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/1511c421-ba79-40e0-9272-eec55185e818)</kbd>
<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/a8238a32-5286-446c-bc7d-9b2bc80019ab)</kbd>

#### Insights:

- We can see that some of the customers are having *`Negative Balance`* as well and some are having *`Positive Balance`* but noboday has a *`Zero balence account`*.

***

#### **Negative Balence customer % & Positive Balence customer % (pct) as Current Balance:**

```sql

 WITH pct_cust AS(
SELECT 
    customer_id, SUM(monthly_transaction_amt) AS current_balance
FROM
    cust_mnthly_end_balance
GROUP BY 1
 ), pct as(
SELECT 
    (SUM(CASE
        WHEN current_balance < 0 THEN 1
    END) / COUNT(DISTINCT customer_id) * 100) AS negative_bal_cust_pct
FROM
    pct_cust
)

SELECT 
    CONCAT(ROUND((negative_bal_cust_pct), 2), '%') AS Negative_ending_balence_cust_pct,
    CONCAT(ROUND((100 - negative_bal_cust_pct), 2), '%') AS positive_ending_balance_cust_pct
FROM
    pct;

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/4cac5378-fbc0-4635-95c6-174650c4a98d)</kbd>

#### Insights:

- `57%` customers maintain a *Negative balance* whereas `43%` customers maintain a *positive balance*.
- This query is fetched on overall four months of transactional data.

***

#### **Negative Balence customer % & Positive Balence customer % (pct) based on month end Balance:**

```sql

WITH monthly_pct AS(
SELECT 
    SUM(((CASE
        WHEN ending_balence <= 0 THEN 1
    END) / (SELECT 
            COUNT(1)
        FROM
            cust_mnthly_end_balance) * 100)) AS monthly_negative_balance_customers,
    SUM(((CASE
        WHEN ending_balence > 0 THEN 1
    END) / (SELECT 
            COUNT(1)
        FROM
            cust_mnthly_end_balance) * 100)) AS monthly_positive_balance_customers
FROM
    cust_mnthly_end_balance
 )
SELECT 
    CONCAT(ROUND(monthly_negative_balance_customers, 2),
            '%') AS monthly_negative_balance_customers_pct,
    CONCAT(ROUND(monthly_positive_balance_customers, 2),
            '%') AS monthly_positive_balance_customers_pct
FROM
    monthly_pct;

```


#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/87b8e660-9f8a-47b8-aff8-acba1e948c27)</kbd>

#### Insights:

- `53%` customers maintain a *positive balance* whereas `48%` customers maintain a *Positive balance*.
- This query is fetched on monthly transactional data.

***

**5. What percentage of customers increase their opening month’s positive closing balance by more than 5% in the following month?**

```sql

WITH nxt_mnth_txn AS(
SELECT *,
IFNULL(LEAD(ending_balence) over(partition by customer_id order by ending_month),0) as nxt_mnth_bal
FROM cust_mnthly_end_balance
),txn_pct AS(
SELECT 
    *,
    (((nxt_mnth_bal - ending_balence) / ending_balence) * 100) AS pct
FROM
    nxt_mnth_txn
)
SELECT 
    CONCAT(ROUND(COUNT(pct) / (SELECT 
                            COUNT(1)
                        FROM
                            cust_mnthly_end_balance) * 100,
                    2),
            '%') AS cust_maintaining_above_5pct
FROM
    txn_pct
WHERE
    pct > 5.0;

```


#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/b21e030e-4113-4567-be2b-71fef4e7e088)</kbd>

#### Insights:

- 29 % of the customers try to *increase* their account balance by 5 % at the end of the month.

***

### ** Additional exploration ** 

#### **customers with positive opening balance but negative closing balance pct (%) :**

```sql
 WITH nxt_mnth_txn AS(
SELECT *,
IFNULL(LEAD(ending_balence) over(partition by customer_id order by ending_month),0) as nxt_mnth_bal
FROM cust_mnthly_end_balance
),txn_pct AS(
SELECT 
    *,
    (((nxt_mnth_bal - ending_balence) / ending_balence) * 100) AS pct
FROM
    nxt_mnth_txn
)
SELECT 
    CONCAT(ROUND((COUNT(*) / (SELECT 
                            COUNT(1)
                        FROM
                            cust_mnthly_end_balance) * 100),
                    2),
            '%') AS cust_with_positive_opening_but_negative_closing_bal
FROM
    txn_pct
WHERE
    pct < 0 AND monthly_transaction_amt > 0;


# pct<0 gives 22.6%

# pct<=0 gives 28.50%

# pct=0 gives 5.90%

```

#### Output:

- If pct<0 :

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/0c1fe5de-be3c-4605-9376-d397ca9f2419)</kbd>

- If pct<=0 :

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/0567556a-fe51-4d06-a9c0-95ac263dcad4)</kbd>

- If pct=0 :

<kbd>![Screenshot 2023-09-17 163351](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/88f34e4f-0221-4661-b78b-8e7a7bf3a057)</kbd>


***

#### **Minimum, Average and Maximum values of the running balance for each customer:**

```sql
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
```

#### Output:

<kbd>![Screenshot 2023-09-17 163844](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/422b34cb-453c-4c6c-811a-38a60f6f3fe3)</kbd>

***

### 🤔**Extra Challenge** 

Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!

## Simple Interest calculation :

`SI=PRT/100`

### *Assumptions:*

- Assumed zero balance ending months too 
- 6% Rate of interest has been calculated as per asked in simple interest
- for negative balances , Roi_amount is not calculated.

```sql

  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  ORDER BY 1
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
SELECT 
    eb.customer_id,
    ending_month,
    IFNULL(transaction_balance, 0) AS balance
FROM
    monthend_bal eb
        LEFT JOIN
    monthly_bal mb ON closing_month = ending_month
        AND eb.customer_id = mb.customer_id
),fill as(
SELECT 
  customer_id, 
  ending_month, 
  balance as monthly_txn_amt, 
  IF(balance>0,round((balance*6/1200),2),0) AS interest ,
  ROUND(if(balance>0,balance + (balance*6/1200),balance),2) AS new_bal,
  ROUND(SUM(balance+ (balance*6/1200)) 
				OVER(partition by customer_id order by ending_month
					range between unbounded preceding and current row),2) as ending_balence_with_si
 FROM end_bal
 GROUP BY 1,2,3
 ORDER BY 1,2
 ),passbook as(
 SELECT 
	customer_id, 
	ending_month, 
    monthly_txn_amt, interest, 
	IF(interest=0,LAG(interest) over(partition by customer_id 
							order by ending_month),interest) as fill_interest,
	new_bal,
	IF(new_bal=0,LAG(new_bal) over(partition by customer_id 
							order by ending_month),new_bal) as fill_new_bal
	FROM fill
	GROUP BY 1,2,3	
	ORDER BY 1,2
	),showcase_passbook as(
SELECT 
    customer_id,
    ending_month,
    monthly_txn_amt,
    interest,
    fill_interest,
    new_bal,
    fill_new_bal,
    IF(new_bal = 0,
        (fill_interest + fill_new_bal),
        new_bal) AS monthend_bal_with_si
FROM
    passbook
GROUP BY 1 , 2 , 3
ORDER BY 1 , 2
)
SELECT 
    customer_id,
    ending_month,
    monthly_txn_amt,
    fill_new_bal AS monthend_bal,
    fill_interest AS roi_amt,
    monthend_bal_with_si
FROM
    showcase_passbook
GROUP BY 1 , 2 , 3
ORDER BY 1 , 2;

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/8e78b26e-275f-46eb-90a9-dbffd89274a4)</kbd>

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/7bddd653-d350-4be5-a7f6-2651708103ee)</kbd>

***

## Compound Interest calculation :

*` CI = P(1 + (r/12) )^12t – P`*

### *Assumptions:*

- Assumed zero balance ending months too 
- 6% Rate of interest has been calculated as per asked in compound interest
- For negative balances , Roi_amount is not calculated.
- If there is no transaction, no interest for that month.

```sql

# 0.0833 is for 1month =(1/12)

  WITH monthly_bal AS (
  SELECT 
    customer_id, 
    LAST_DAY(txn_date) AS closing_month,
    SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -txn_amount END) AS transaction_balance
  FROM customer_transactions
  GROUP BY 1,2
  ORDER BY 1
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
SELECT 
    eb.customer_id,
    ending_month,
    IFNULL(transaction_balance, 0) AS balance
FROM
    monthend_bal eb
        LEFT JOIN
    monthly_bal mb ON closing_month = ending_month
        AND eb.customer_id = mb.customer_id
),compound_interest_bal as(
SELECT 
  customer_id, 
  ending_month, 												# 0.0833 is for 1month =(1/12)
  balance as monthly_txn_amt, 
  IF(balance>0,round(balance*(1+pow(0.005,(12*0.0833)))-balance,2),0) as interest,
  ROUND(IF(balance>0,balance + (balance*(1+pow(0.005,(12*0.0833)))-balance),balance),2) as new_bal
 -- round(sum(balance+(balance*(1+pow(0.005,(12*0.0833)))-balance) over(partition by customer_id
                order by ending_month range between unbounded preceding and current row),2) as ending_balence
 FROM end_bal
 GROUP BY 1,2,3
 order by 1,2
  ),fill as(
 select * ,
IF(new_bal=0,LAG(interest) OVER(PARTITION BY customer_id ORDER BY ending_month),interest) as fill_interest,
IF(new_bal=0,LAG(new_bal) OVER(PARTITION BY customer_id ORDER BY ending_month),new_bal) as fill_new_bal
FROM compound_interest_bal
GROUP BY 1,2,3
ORDER BY 1,2
),passbook as(
SELECT
	customer_id,
	ending_month,
  monthly_txn_amt,interest,
  fill_new_bal as monthend_bal,
IF(monthly_txn_amt>0,ROUND(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal,2),interest)as roi 
-- if(monthly_txn_amt=0, round(fill_new_bal+(fill_new_bal*(1+pow(0.005,(12*0.0833)))-fill_new_bal),2),fill_new_bal) as monthend_bal_with_CI
FROM fill
GROUP BY 1,2,3
ORDER BY 1,2
),showcase_passbook as(
SELECT
	customer_id,
    ending_month,
    monthly_txn_amt,
    monthend_bal, 
	IF(interest=0,roi,interest)as roi_amt,
	ROUND(if(monthly_txn_amt=0,(monthend_bal+if(interest=0,roi,interest)),monthend_bal),2) as mnthend_bal_with_CI
FROM passbook
GROUP BY 1,2,3
ORDER BY 1,2
)
SELECT 
    customer_id,
    ending_month,
    monthly_txn_amt,
    IF(monthend_bal < 0, 0, monthend_bal) AS monthend_balance,
    IF(roi_amt < 0, 0, roi_amt) AS roi,
    mnthend_bal_with_CI
FROM
    showcase_passbook
GROUP BY 1 , 2 , 3
ORDER BY 1 , 2;

```

#### Output:

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/5d63728b-ea72-4e5b-8296-13b7d92ed83c)</kbd>

<kbd>![image](https://github.com/KasiMuthuveerappan/Danny-Ma-s-SQL-challenges/assets/142071405/22ab8d3c-5dfc-4126-8058-f2a32c6d4a1c)</kbd>

***

## Do give me a 🌟 if you like what you're reading. Thank you! 🙆
