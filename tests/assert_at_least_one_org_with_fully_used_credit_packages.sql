WITH

organizations_that_have_fully_used_credit_packages AS (
    SELECT COUNT(*) AS organization_count
    FROM {{ ref('organizations_bigtable' ) }}
    WHERE fully_used_credit_package_count > 0
),

final AS (
    SELECT *
    FROM organizations_that_have_fully_used_credit_packages
    WHERE organization_count <= 0
)

SELECT * FROM final
