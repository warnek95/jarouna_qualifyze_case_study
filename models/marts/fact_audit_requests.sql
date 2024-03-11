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

audit_requests_paid_with_credit_package AS (
    SELECT audit_requests.app_audit_request_id
    FROM audit_requests
    INNER JOIN credit_packages
        ON
            audit_requests.app_organization_id = credit_packages.app_organization_id
            AND audit_requests.audit_request_creation_date
            BETWEEN credit_packages.credit_package_start_date
            AND credit_packages.credit_package_end_date
    GROUP BY audit_requests.app_audit_request_id
),

final AS (
    SELECT
        -- Audit request
        audit_requests.*,
        -- Organization
        organizations.app_organization_name,
        -- Credit package
        audit_with_credit_package.app_audit_request_id IS NOT NULL AS is_audit_request_paid_with_credit_package
    FROM audit_requests
    INNER JOIN organizations ON audit_requests.app_organization_id = organizations.app_organization_id
    LEFT JOIN audit_requests_paid_with_credit_package AS audit_with_credit_package
        ON audit_requests.app_audit_request_id = audit_with_credit_package.app_audit_request_id
)

SELECT * FROM final

{{ dev_limit() }}
