WITH

organizations AS (
    SELECT * FROM {{ ref('dim_organizations') }}
),

organizations_kpis_all_time AS (
    SELECT * FROM {{ ref('organizations_kpis_all_time') }}
),

final AS (
    SELECT
        -- Organization
        organizations.*,
        COALESCE(
            organizations_kpis_all_time.audit_requests_paid_without_credit_package_count > 0
            AND organizations_kpis_all_time.credit_package_count > 0,
            FALSE
        ) AS has_organization_switched_to_subscription_model,
        -- Audit request
        COALESCE(
            organizations_kpis_all_time.audit_requests_paid_with_credit_package_count, 0
        ) AS audit_requests_paid_with_credit_package_count,
        COALESCE(
            organizations_kpis_all_time.audit_requests_paid_without_credit_package_count, 0
        ) AS audit_requests_paid_without_credit_package_count,
        -- Credit package
        COALESCE(
            organizations_kpis_all_time.credit_package_count, 0
        ) AS credit_package_count,
        COALESCE(
            organizations_kpis_all_time.fully_used_credit_package_count, 0
        ) AS fully_used_credit_package_count,
        COALESCE(
            organizations_kpis_all_time.expired_partially_used_credit_package_count, 0
        ) AS expired_partially_used_credit_package_count
    FROM organizations
    LEFT JOIN organizations_kpis_all_time
        ON organizations.app_organization_id = organizations_kpis_all_time.organization__app_organization_id
)

SELECT * FROM final

{{ dev_limit() }}
