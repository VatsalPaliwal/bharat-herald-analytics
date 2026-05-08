SELECT
    city_id,
    internet_rate_q1,
    internet_rate_q4,

    (
        internet_rate_q4 - internet_rate_q1
    ) AS delta_internet_rate

FROM fact_city_readiness;