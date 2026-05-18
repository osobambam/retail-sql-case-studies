with category_cte as(
select 
	   sum(quantity)quantity,
	   sum(unit_price*quantity) as revenue,
	   sum(unit_cost*quantity) as cost,
	   AVG(((unit_price*quantity)-(unit_cost*quantity))/(unit_price*quantity))avg_full_price_margin,
	   AVG(((unit_price*quantity)*((100.0-isnull(discount_pct,0))/100.0)-(unit_cost*quantity))/((unit_price*quantity)*((100.0-isnull(discount_pct,0))/100.0)))avg_realised_margin,
	   sum((unit_price*quantity)*((100.0-isnull(discount_pct,0))/100.0)) as discounted_price,
	   sum((unit_price*quantity)-((unit_price*quantity)*((100.0-isnull(discount_pct,0))/100.0))) as discount_value,
	   category
from Orders o
    left join Order_Items oi on o.order_id = oi.order_id
    left join Products p on oi.product_id = p.product_id
	left join Promotions pr on o.promo_id = pr.promo_id
group by category
),
cte2 as(
select 
       category,
       count(distinct(o.order_id)) as orderCount,
        count(distinct (case
            when promo_id is not null then o.order_id
        end)) as isPromo
from Orders o
    left join Order_Items oi on o.order_id = oi.order_id
    left join Products p on oi.product_id = p.product_id
group by category
)
select a.category,
	   orderCount,
	   isPromo,
	   round((cast(isPromo as float)/orderCount)*100,2) promo_dependence_pct,
	   CAST(ROUND(avg_full_price_margin * 100, 2) AS DECIMAL(10,2)) AS avg_full_price_margin,
	   CAST(ROUND(avg_realised_margin * 100, 2) AS DECIMAL(10,2)) AS avg_realised_margin,
	   CAST(ROUND(discount_value, 2) AS DECIMAL(10,2)) AS discount_value,
	   RANK() over(order by round((cast(isPromo as float)/orderCount)*100,2) desc) as rank_num
from category_cte a
left join cte2 b on a.category = b.category
;
