WITH

credit_packages AS (
    SELECT
        id_organization AS app_organization_id,
        -- In this case, we are using the signature date as the creation date, assuming that the organization was
        -- created when or before it signed its first credit package
        signature_date AS app_organizarion_creation_date
    FROM {{ ref('seed__credit_packages') }}
),

requests AS (
    SELECT
        id_organization AS app_organization_id,
        -- In this case, we are using the signature date as the creation date, assuming that the organization was
        -- created when or before it created its first request
        created_date AS app_organizarion_creation_date
    FROM {{ ref('seed__requests') }}
),

source AS (
    SELECT * FROM credit_packages
    UNION ALL
    SELECT * FROM requests
),

final AS (
    SELECT
        -- Primary key
        app_organization_id,
        -- Strings
        CONCAT('Organization ', app_organization_id) AS app_organization_name,
        -- Dates
        MIN(app_organizarion_creation_date) AS app_organization_creation_date
    FROM source
    GROUP BY app_organization_id
)

SELECT * FROM final

{{ dev_limit() }}
