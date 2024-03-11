WITH

organizations_that_have_switched_to_subscription_model AS (
    SELECT COUNT(*) AS organization_count
    FROM {{ ref('organizations_bigtable' ) }}
    WHERE has_organization_switched_to_subscription_model = TRUE
),

final AS (
    SELECT *
    FROM organizations_that_have_switched_to_subscription_model
    WHERE organization_count <= 0
)

SELECT * FROM final
