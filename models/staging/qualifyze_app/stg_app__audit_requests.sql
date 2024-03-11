WITH

source AS (
    SELECT * FROM {{ ref('seed__requests') }}
),

final AS (
    SELECT
        -- Primary key
        id_request AS app_audit_request_id,
        -- Foreign keys
        id_audit AS app_audit_id,
        id_organization AS app_organization_id,
        -- Strings
        customer_name AS app_customer_name,
        supplier_country AS app_supplier_country,
        supplier_name AS app_supplier_name,
        audited_product AS audit_request_audited_product,
        request_state AS audit_request_state,
        audit_type AS audit_request_type,
        -- Numerics
        payment_term_days AS audit_request_payment_term_days,
        price_eur AS audit_request_price_eur,
        -- Booleans
        audit_type = 'EXISTING_AUDIT' AS is_audit_request_for_existing_audit,
        -- Dates
        authorization_requested_date AS audit_request_authorization_request_date,
        audit_confirmation_date AS audit_request_confirmation_date,
        created_date AS audit_request_creation_date,
        report_published_date AS audit_request_report_publication_date,
        audit_selected_date AS audit_request_selected_audit_date,
        signed_date AS audit_request_signature_date
    FROM source
)

SELECT * FROM final

{{ dev_limit() }}
