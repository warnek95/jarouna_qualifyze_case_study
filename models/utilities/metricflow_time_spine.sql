{{ config(materialized='table') }}

WITH

days AS (
    {{
        dbt_utils.date_spine(
            "day",
            "cast('2017-01-01' as date)",
            "cast('2030-01-01' as date)"
        )
    }}
),

final AS (
    SELECT
        DATE(date_day) AS date_day,
        DATE(DATE_TRUNC('week', date_day)) AS date_week,
        DATE(DATE_TRUNC('month', date_day)) AS date_month,
        DATE(DATE_TRUNC('quarter', date_day)) AS date_quarter,
        DATE(DATE_TRUNC('year', date_day)) AS date_year
    FROM days
)

SELECT * FROM final
