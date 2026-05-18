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
),
customerClass as(
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
),
orderCostCTE as (
select customer_id,
		SUM(quantity*unit_cost) as order_cost
from Orders o
	left join Order_Items oi on o.order_id = oi.order_id
group by customer_id
)
select buyer_segment,
		COUNT(buyer_segment)as customer_count,
		SUM(total_gross)as total_gross_revenue,
		SUM(total_net)as total_net_revenue,
		SUM(total_disc_received)as total_discounts,
		ROUND((SUM(total_disc_received)/SUM(total_gross))*100,2)as avg_disc_rate_pct,
		SUM(order_cost) as total_cogs,
		SUM(total_net - order_cost)as gross_profit,
		ROUND((SUM(total_net - order_cost)/SUM(total_net))*100,2) as gross_margin_pct
from customerClass c
	left join orderCostCTE oc on c.customer_id=oc.customer_id
group by buyer_segment
order by gross_margin_pct desc
;
