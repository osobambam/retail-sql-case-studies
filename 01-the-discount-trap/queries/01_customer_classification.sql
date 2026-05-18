-- =============================================
-- Project : The Discount Trap
-- Query   : 01 - Customer Classification
-- Purpose : Categorise Customers based on Promo Dependence
-- Author  : Ayodeji Oso
-- =============================================

with numOfPromo as (
-- CTE to get number of promo orders
select 
	customer_id,
	COUNT(order_id)as order_count,
	COUNT(case when promo_id is not null then 1 end) as promo_order_count,
	SUM(gross_revenue) as total_gross,
	SUM(net_revenue) as total_net,
	SUM(gross_revenue) - SUM(net_revenue) as total_disc_received
from Orders
group by customer_id
)
-- Query for customer classification
select
	n.customer_id,
	c.customer_tier,
	c.acquisition_channel,
	round((cast(n.promo_order_count as float)/order_count)*100,1) as promo_order_pct,
	-- Thresholds: 80%+ = Promo-Only, 50–80% = Promo-Heavy, 20–50% = Mixed, else Full-Price
	case 
		when ((cast(n.promo_order_count as float)/order_count)*100) > 80.0 then 'Promo-Only'
		when ((cast(n.promo_order_count as float)/order_count)*100) > 49.0 then 'Promo-Heavy'
		when ((cast(n.promo_order_count as float)/order_count)*100) > 19.0 then 'Mixed'
		else 'Full-Price'
	end as buyer_segment,
	n.order_count,
	n.promo_order_count,
	n.total_gross,
	n.total_net,
	n.total_disc_received
from numOfPromo n
	left join Customers c on n.customer_id=c.customer_id
order by promo_order_pct desc;
