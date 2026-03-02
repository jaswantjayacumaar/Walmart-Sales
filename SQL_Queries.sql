SELECT * FROM walmart;


-- Business Problems

-- Q1. What are the different payment methods, and how many transactions and items were sold with each method?

SELECT
	payment_method,
	COUNT(*) as no_of_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


--Q2.  Which category received the highest average rating in each branch, displaying the branch, category and Avg Rating?

SELECT *
FROM
(SELECT
	branch,
	category,
	AVG(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as RANK
FROM walmart
GROUP BY 1, 2
)
WHERE RANK=1


--Q3. What is the busiest day of the week for each branch based on transaction volume?
SELECT *
FROM
	(SELECT
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1


--Q4. How many items were sold through each payment method?

SELECT
	payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


--Q5. What are the average, minimum, and maximum ratings for each category in each city?

SELECT
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2


--Q6. What is the total profit for each category, ranked from highest to lowest? Total profit = unit_price * quantity * profit_margin

SELECT
	category,
	SUM(unit_price * quantity * profit_margin) as profit
FROM walmart
GROUP BY 1


--Q7. What is the most frequently used payment method in each branch?

SELECT *
FROM
	(SELECT
		branch,
		payment_method,
		COUNT(*) as no_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2)
WHERE rank = 1


--Q8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT
	branch,
	CASE
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END shift,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC


--Q9. Identify 5 branches with highest decrease ratio in revenue compared to last year?

-- 2022 Sales
WITH revenue_2022
AS
(	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),

revenue_2023
AS
(	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100
		, 2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5