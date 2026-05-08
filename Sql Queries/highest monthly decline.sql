SELECT 
    formatted_date,
    net_circulation,
    city_id,
    state,
    previous_month,

    ROUND(
        (
            net_circulation - previous_month
        ) * 100.0 / previous_month,
        2
    ) AS decline_pct

FROM (

    SELECT 
        formatted_date,
        net_circulation,
        city_id,
        state,

        LAG(net_circulation)
        OVER (ORDER BY formatted_date) AS previous_month

    FROM fact_print_sales

) x

ORDER BY 6 ASC
LIMIT 3;
