WITH

-- Base tables

audit_requests AS (
    SELECT * FROM {{ ref('stg_app__audit_requests') }}
),

credit_packages AS (
    SELECT * FROM {{ ref('stg_app__credit_packages') }}
),

organizations AS (
    SELECT * FROM {{ ref('stg_app__organizations') }}
),

-- Computations

used_credit_packages AS (
    SELECT
        credit_packages.app_credit_package_id,
        COUNT(audit_requests.app_audit_request_id) AS used_credits
    FROM credit_packages
    INNER JOIN audit_requests
        ON
            credit_packages.app_organization_id = audit_requests.app_organization_id
            AND audit_requests.audit_request_creation_date
            BETWEEN credit_packages.credit_package_start_date
            AND credit_packages.credit_package_end_date
    GROUP BY credit_packages.app_credit_package_id
),

final AS (
    SELECT
        -- Credit package
        credit_packages.*,
        -- Organization
        organizations.app_organization_name,
        -- Credits
        used_credit_packages.used_credits AS credit_package_used_credits,
        (
            credit_packages.credit_package_credits_amount - used_credit_packages.used_credits
        ) AS credit_package_remaining_credits,
        (
            credit_packages.credit_package_credits_amount = used_credit_packages.used_credits
        ) AS is_credit_package_fully_used
    FROM credit_packages
    INNER JOIN organizations ON credit_packages.app_organization_id = organizations.app_organization_id
    LEFT JOIN used_credit_packages
        ON credit_packages.app_credit_package_id = used_credit_packages.app_credit_package_id
)

SELECT * FROM final

{{ dev_limit() }}
