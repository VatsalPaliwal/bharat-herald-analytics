WITH yearly_data AS (
    SELECT
        c.city AS city_name,
        YEAR(fps.formatted_date) AS year,
        SUM(fps.net_circulation) AS yearly_net_circulation,
        ROUND(SUM(far.ad_revenue), 2) AS yearly_ad_revenue
    FROM fact_print_sales fps
    JOIN dim_city c 
        ON fps.city_id = c.city_id
    JOIN fact_ad_revenue far 
        ON fps.edition_ID = far.edition_id
       AND YEAR(fps.formatted_date) = far.year_extracted
    GROUP BY c.city, YEAR(fps.formatted_date)
),

check_decline AS (
    SELECT
        city_name,
        year,
        yearly_net_circulation,
        yearly_ad_revenue,
        LAG(yearly_net_circulation) OVER (
            PARTITION BY city_name 
            ORDER BY year
        ) AS prev_net_circulation,

        LAG(yearly_ad_revenue) OVER (
            PARTITION BY city_name 
            ORDER BY year
        ) AS prev_ad_revenue
    FROM yearly_data
)

SELECT
    city_name,

    CASE
        WHEN SUM(
            CASE
                WHEN yearly_net_circulation < prev_net_circulation
                THEN 1
                ELSE 0
            END
        ) = COUNT(prev_net_circulation)
        THEN 'Yes'
        ELSE 'No'
    END AS is_declining_print,

    CASE
        WHEN SUM(
            CASE
                WHEN yearly_ad_revenue < prev_ad_revenue
                THEN 1
                ELSE 0
            END
        ) = COUNT(prev_ad_revenue)
        THEN 'Yes'
        ELSE 'No'
    END AS is_declining_ad_revenue,

    CASE
        WHEN
            SUM(
                CASE
                    WHEN yearly_net_circulation < prev_net_circulation
                    THEN 1
                    ELSE 0
                END
            ) = COUNT(prev_net_circulation)

            AND

            SUM(
                CASE
                    WHEN yearly_ad_revenue < prev_ad_revenue
                    THEN 1
                    ELSE 0
                END
            ) = COUNT(prev_ad_revenue)

        THEN 'Yes'
        ELSE 'No'
    END AS is_declining_both

FROM check_decline
GROUP BY city_name;
