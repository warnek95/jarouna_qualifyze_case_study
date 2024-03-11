WITH

organizations AS (
    SELECT
        COUNT(
            CASE WHEN credit_package_count > 0 THEN 1 END
        ) AS organization_with_subscription_model_count,
        COUNT(
            CASE WHEN expired_partially_used_credit_package_count > 0 THEN 1 END
        ) AS organization_count_with_expired_partially_used_credit_packages
    FROM {{ ref('organizations_bigtable' ) }}
),

final AS (
    SELECT *
    FROM organizations
    WHERE
        organization_count_with_expired_partially_used_credit_packages
        > organization_with_subscription_model_count * 0.1
)

SELECT * FROM final
