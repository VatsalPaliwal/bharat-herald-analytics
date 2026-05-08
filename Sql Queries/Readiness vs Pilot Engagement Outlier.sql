with readiness as(
	select 
	c.city as city,
	round(avg(cr.literacy_rate + cr.smartphone_penetration + cr.internet_penetration)/3,2) 
	as readiness_score
	from fact_city_readiness cr
	join dim_city c on cr.city_id=c.city_id
	where cr.quarter like "%2021%"
	group by c.city 
),
engagement as( 
select c.city,
coalesce(sum(dp.downloads_or_accesses),0) as engagement_metric
from fact_digital_pilot dp 
join dim_city c on c.city_id=dp.city_id
group by c.city 
)
select 
r.city,
r.readiness_score,
e.engagement_metric,
rank() over (order by r.readiness_score desc) as readiness_rank_desc,
rank() over (order by e.engagement_metric asc) as engagement_rank_asc,
    CASE 
       WHEN RANK() OVER (ORDER BY r.readiness_score DESC) = 1
        AND RANK() OVER (ORDER BY e.engagement_metric ASC) <= 3 
       THEN 'Yes' ELSE 'No' END AS is_outlier
from readiness r 
join engagement e on r.city=e.city;
