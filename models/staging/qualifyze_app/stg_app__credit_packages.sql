WITH

source AS (
    SELECT * FROM {{ ref('seed__credit_packages') }}
),

final AS (
    SELECT
        -- Primary key
        id_credit_package AS app_credit_package_id,
        -- Foreign keys
        id_organization AS app_organization_id,
        id_subscription AS app_subscription_id,
        -- Strings
        payment_cycle AS credit_package_payment_cycle,
        -- Numerics
        total_value_eur AS credit_package_total_value_eur,
        credits_amount AS credit_package_credits_amount,
        -- Booleans
        CURRENT_DATE > end_date AS is_credit_package_expired,
        payment_cycle = 'monthly' AS is_credit_package_payment_cycle_monthly,
        -- Dates
        signature_date AS credit_package_signature_date,
        start_date AS credit_package_start_date,
        end_date AS credit_package_end_date
    FROM source
)

SELECT * FROM final

{{ dev_limit() }}
