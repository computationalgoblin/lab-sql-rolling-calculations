-- Get number of monthly active customers.

with cte_monthly_active_users as 
(select date_format(payment_date, "%Y-%m") as months, count(distinct customer_id) as active_customer
from payment group by months)
select months, active_customer 
from cte_monthly_active_users
order by months;

-- Active users in the previous month.

with cte_monthly_active_users as 
(select date_format(payment_date, "%Y-%m") as months, count(distinct customer_id) as active_customer
from payment group by months)
select months, active_customer, lag(active_customer) over (order by months) as previous_month_active_customers
from cte_monthly_active_users
order by months;

-- Percentage change in the number of active customers.

with cte_monthly_active_users as 
(select date_format(payment_date, "%Y-%m") as months, count(distinct customer_id) as active_customers
from payment group by months),
cte_active_previous_customers as 
(select months, active_customers, lag(active_customers) over (order by months) as previous_month_active_customers 
from cte_monthly_active_users)
select *, (active_customers - previous_month_active_customers) as difference, concat(round((active_customers - previous_month_active_customers)/active_customers*100), "%") as `%_difference`
from cte_active_previous_customers;

-- Retained customers every month.

with cte_payments as 
(select customer_id, year(payment_date) as `year`, month(payment_date) as `month`
    from payment), 
    recurrent_payments as
    (select distinct customer_id, year, month
    from cte_payments
    order by customer_id, year, month
)
select r1.customer_id, r1.year, r1.month, r2.month as prev_month
from recurrent_payments r1
join recurrent_payments r2
on r1.year = r2.year
and r1.month = r2.month + 1
and r1.customer_id = r2.customer_id
order by r1.customer_id, r1.year, r1.month;