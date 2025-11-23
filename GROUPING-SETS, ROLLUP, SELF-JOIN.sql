GROUPING-SETS, ROLLUP, SELF-JOIN

TOPIC: Basic grouping to Pro GROUPING-sets
BASICS
1. Group total amount by staff_id
select staff_id, sum(amount) from payment group by staff_id

2. Group total amount by month/date
select to_char(payment_date, 'Month') as month, sum(amount) from payment
group by to_char(payment_date, 'Month')

3. Group total amount by month and staff_id
select  to_char(payment_date, 'Month') as month, sum(amount), staff_id 
from payment
group by to_char(payment_date, 'Month'), staff_id

GROUPING-SETS
4. Find out how he staff has performed each month, along with total sale of month & sale done by staff monthly
select to_char(payment_date, 'Month') as month, staff_id, sum(amount)
from payment
group by 
		grouping sets(
					(staff_id),
					(month),
					(staff_id, month)
									)
order by 1,

Challenge 1: Write a query that return the sum of the amount for each customer (first_name and last_name) and each staff_id. Also add the overall revenue per customer.


select first_name, last_name, staff_id, sum(amount)
from payment p
left join customer c on p.customer_id = c.customer_id
group by grouping sets(
				(first_name, last_name),
				(staff_id),
				(first_name, last_name, staff_id)
					)
order by 1,2,3

Challenge 2: Write a query that calculates now the share of revenue each staff_id makes per customer. The result should look like this:


select first_name, last_name, staff_id, sum(amount) as total,
round(100*sum(amount)/first_value(sum(amount)) over(partition by first_name, last_name order by sum(amount) desc), 2) as percentage
from payment p
left join customer c on p.customer_id = c.customer_id
group by grouping sets(
				(first_name, last_name),
				(staff_id),
				(first_name, last_name, staff_id)
					)
order by 1,2,3


TOPIC: CUBE & ROLLUP

Q: Create a heirarchy of QUARTER, MONTH & DAY.

select 
'Q' || to_char(payment_date, 'Q') as Quarter,
to_char(payment_date, 'Month') as Month,
date(payment_date),
sum(amount)
from payment
group by 
-- in rollup order is important
rollup(
'Q' || to_char(payment_date, 'Q'),
to_char(payment_date, 'Month'),
date(payment_date)
)
order by 1,2,3

-- OR

select
'Q' || to_char(p.payment_date, 'Q') as Quarter,
extract(month from p.payment_date) as Month,
date(payment_date), sum(amount)
from payment p
group by 
rollup(
'Q' || to_char(p.payment_date, 'Q'),
extract(month from p.payment_date),
date(payment_date)
)
order by 1,2,3


Challenge 3: Write a query that calculates a booking amount rollup for the hierarchy of quarter, month, week in month and day.

select
to_char(payment_date, 'Q') as Quarter,
extract(month from payment_date) as month,
to_char(payment_date, 'W') as week_in_month,
date(payment_date) as day, sum(amount) as booking_amount
from payment
group by rollup(
to_char(payment_date, 'Q'),
extract(month from payment_date),
to_char(payment_date, 'W'),
date(payment_date)
)
order by 1,2,3


TOPIC: CUBE 
Q: What are the totals per customer per staff_id per date. Also all of sub-total. 
-- Here, there is no natural heirarchy as one customer buy from any staff_id.

select customer_id, staff_id, date(payment_date), sum(amount)
from payment
group by cube(customer_id, staff_id, date(payment_date))
order by 1,2,3


Challenge 4: Write a query that returns all grouping sets in all combinations of customer_id, date and title with aggregation of the payment amount.
How do you order the output to get that desired result?


-- NEED
select p.customer_id,  date(payment_date), title, sum(amount) as total from payment p
 left join rental r on p.customer_id = r.customer_id
 left join inventory i on r.inventory_id = i.inventory_id
 left join film f on f.film_id = i.film_id
group by cube (p.customer_id,  date(payment_date), title)
order by 1,2,3

TOPIC: SELF-JOIN
-- use column for self reference in a table

create table employee(employee_id int, name varchar(50), manager_id int);

insert into employee
values
(1, 'Liam Smit', NULL),
(2, 'Shuchita Rajput', 1),
(3, 'Pritam raghav', 1),
(4, 'Shasstri diwakar', 1),
(4, 'Sachi Jayant', 1),
(5, 'Tina Jain', 2),
(6, 'Emma Lopez', 2),
(7, 'Mia Lee', 2),
(8, 'Ava Rani', 3),
(9, 'James Bond', 4)

select emp.employee_id, emp.name as manager, mng.name as employee from employee emp
left join employee mng on emp.manager_id = mng.employee_id

select emp.employee_id, emp.name as employee, mng.name as manager, mng2.name as manager_of_manager 
from employee emp
left join employee mng on emp.manager_id = mng.employee_id
left join employee mng2 on mng.manager_id = mng2.employee_id


Challenge 5: Find all the pairs of films with the same length

select f1.title as title, f2.title as title, f1.length
from film f1
left join film f2 on f2.length = f1.length
and f1.title <> f2.title


select f1.title as title, f2.title as title, f1.length
from film f1
left join film f2 on f2.length = f1.length
where f1.title <> f2.title



TOPIC: CROSS JOIN
-- Cartesian product
-- eg: A, B and 1,2,3 = A1, A2, A3, B1, B2, B3
--all combinations of row, not values. if there are any duplicate values, it will consider them as separate
-- eg: A, B and 1,1,3 = A1, A1, A3, B1, B1, B3

select staff_id, store.store_id, last_name
from staff
cross join store

TOPIC: NATURAL JOIN
-- Automatically joins using columns with the same column name

select * from payment
natural left join customer

select first_name, last_name, sum(amount) from payment
natural inner join customer
group by 1,2

