SELECT *
FROM (

    SELECT
        year_extracted AS year,

        ad_category,

        SUM(ad_revenue) AS category_revenue,

        ROUND(
            SUM(ad_revenue) * 100.0 /
            SUM(SUM(ad_revenue)) OVER (
                PARTITION BY year_extracted
            ),
            2
        ) AS pct_of_year_total

    FROM fact_ad_revenue

    GROUP BY
        year_extracted,
        ad_category

) x

WHERE pct_of_year_total > 50;
