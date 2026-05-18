with windowsCTE as (
select *,
	case when promo_id is not null then 1
	else 0
	end as isPromo
from Orders
),
partitionCTE as(
select *,
		sum(isPromo) over(partition by customer_id order by order_date) as runningPromoPartition,
		ROW_NUMBER() over(partition by customer_id order by order_date)as row_num,
		round(cast(sum(isPromo) over(partition by customer_id order by order_date) as float)/ROW_NUMBER() over(partition by customer_id order by order_date),2) as runningAvgPartition
from windowsCTE
),
driftCTE as(
select customer_id,
	FIRST_VALUE(runningAvgPartition) over (partition by customer_id order by order_date)as firstVal,
	LAST_VALUE(runningAvgPartition) over (partition by customer_id order by order_date rows between unbounded preceding and unbounded following) as lastVal,
	(LAST_VALUE(runningAvgPartition) over (partition by customer_id order by order_date rows between unbounded preceding and unbounded following)-FIRST_VALUE(runningAvgPartition) over (partition by customer_id order by order_date)) as drift
from partitionCTE
)
select customer_id,
	COUNT(customer_id)as numOfOrders,
	MAX(firstVal)firstValue,
	MAX(lastVal)lastValue,
	MAX(drift) drift,
	case
		when MAX(drift) > 0 then 'Increasing Promo Dependent'
		when MAX(drift) = 0 then 'Stable'
		else 'Decreasingly Promo Dependent'
	end as promoDependence
from driftCTE
group by customer_id
having COUNT(customer_id) > 2
order by drift desc
