use finance_project;
select * from finance;

#---------------------------------------------------------------------------------
# Profit Margin Health Check by Region
SELECT Region,
       ROUND(AVG(Profit_Margin) * 100, 2) AS avg_margin_pct,
       ROUND(AVG(Discount_Rate) * 100, 2) AS avg_discount_pct
FROM finance
GROUP BY Region
ORDER BY avg_margin_pct DESC;

#---------------------------------------------------------------------------------
# Which Quarter Had the Highest Return Rate?
SELECT Quarter,
       ROUND(AVG(Returns) * 100, 2) AS return_rate_pct,
       COUNT(*) AS total_orders
FROM finance
GROUP BY Quarter
ORDER BY return_rate_pct DESC;

#---------------------------------------------------------------------------------
#  Which product category earns the most profit?
SELECT Product_Category,
       ROUND(SUM(Total_Profit), 2) AS total_profit
FROM finance
GROUP BY Product_Category
ORDER BY total_profit DESC;

#------------------------------------------------------------------------------------
# Which region sells the most?
SELECT Region,
       ROUND(SUM(Sales_Amount), 2) AS total_sales
FROM finance
GROUP BY Region
ORDER BY total_sales DESC;

#------------------------------------------------------------------------------------
 # Which customer tier spends the most?
 SELECT Customer_Tier,
       ROUND(AVG(Sales_Amount), 2) AS avg_order_value,
       ROUND(SUM(Total_Profit), 2) AS total_profit
FROM finance
GROUP BY Customer_Tier
ORDER BY avg_order_value DESC;

#------------------------------------------------------------------------------------
# Which payment method is used the most?
SELECT Payment_Method,
       COUNT(*) AS total_orders,
       ROUND(SUM(Sales_Amount), 2) AS total_sales
FROM finance
GROUP BY Payment_Method
ORDER BY total_orders DESC;

#-------------------------------------------------------------------------------------
# Which quarter made the most profit?
SELECT Quarter,
       ROUND(SUM(Sales_Amount), 2) AS total_sales,
       ROUND(SUM(Total_Profit), 2) AS total_profit
FROM finance
GROUP BY Quarter
ORDER BY total_profit DESC;

#-------------------------------------------------------------------------------------
# How does each region rank in sales every quarter?
SELECT Quarter, Region,
       ROUND(SUM(Sales_Amount), 2) AS total_sales,
       RANK() OVER (PARTITION BY Quarter ORDER BY SUM(Sales_Amount) DESC) AS rank_in_quarter
FROM finance
GROUP BY Quarter, Region
ORDER BY Quarter, rank_in_quarter;

#------------------------------------------------------------------------------------
# Running total of sales quarter by quarter
SELECT Quarter,
       ROUND(SUM(Sales_Amount), 2) AS quarterly_sales,
       ROUND(SUM(SUM(Sales_Amount)) OVER (ORDER BY Quarter), 2) AS running_total
FROM finance
GROUP BY Quarter
ORDER BY Quarter;

#-------------------------------------------------------------------------------------
# Which regions are underperforming vs the average?
WITH region_sales AS (
    SELECT Region, ROUND(SUM(Sales_Amount), 2) AS total_sales
    FROM finance
    GROUP BY Region
)
SELECT Region, total_sales,
       CASE WHEN total_sales < AVG(total_sales) OVER () THEN 'Below Average' ELSE 'Above Average' END AS status
FROM region_sales;

#------------------------------------------------------------------------------------
# Orders with high discount but low profit
WITH bad_orders AS (
    SELECT * FROM finance
    WHERE Discount_Rate > 0.25 AND Profit_Margin < 0.10
)
SELECT Product_Category, Region,
       COUNT(*) AS total_bad_orders,
       ROUND(AVG(Discount_Rate) * 100, 2) AS avg_discount_pct
FROM bad_orders
GROUP BY Product_Category, Region
ORDER BY total_bad_orders DESC;

#-----------------------------------------------------------------------------------
# Which segment has the highest return rate?
SELECT Segment,
       ROUND(AVG(Returns) * 100, 2) AS return_rate_pct,
       COUNT(*) AS total_orders
FROM finance
GROUP BY Segment
ORDER BY return_rate_pct DESC;

#--------------------------------------------------------------------------------
# What % of each region's orders are above/below target?
SELECT Region, Sales_Performances,
       COUNT(*) AS order_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY Region), 2) AS pct_share
FROM finance
GROUP BY Region, Sales_Performances
ORDER BY Region, pct_share DESC;

#--------------------------------------------------------------------------------
# Best product category in each region
WITH ranked AS (
    SELECT Region, Product_Category,
           ROUND(SUM(Total_Profit), 2) AS total_profit,
           RANK() OVER (PARTITION BY Region ORDER BY SUM(Total_Profit) DESC) AS rnk
    FROM finance
    GROUP BY Region, Product_Category
)
SELECT Region, Product_Category, total_profit
FROM ranked WHERE rnk = 1
ORDER BY total_profit DESC;

#------------------------------------------------------------------------------
# Which segment generates the most revenue?
SELECT Segment,
       ROUND(SUM(Sales_Amount), 2) AS total_revenue,
       ROUND(SUM(Total_Profit), 2) AS total_profit
FROM finance
GROUP BY Segment
ORDER BY total_revenue DESC;

#----------------------------------------------------------------------------
# How many orders are in each sales performance category?
SELECT Sales_Performances,
       COUNT(*) AS total_orders,
       ROUND(SUM(Sales_Amount), 2) AS total_revenue
FROM finance
GROUP BY Sales_Performances
ORDER BY total_revenue DESC;