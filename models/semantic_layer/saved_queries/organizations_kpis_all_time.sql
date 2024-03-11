SELECT
  COALESCE(subq_10.organization__app_organization_id, subq_21.organization__app_organization_id, subq_30.organization__app_organization_id, subq_41.organization__app_organization_id, subq_52.organization__app_organization_id) AS organization__app_organization_id
  , MAX(subq_10.audit_requests_paid_with_credit_package_count) AS audit_requests_paid_with_credit_package_count
  , MAX(subq_21.audit_requests_paid_without_credit_package_count) AS audit_requests_paid_without_credit_package_count
  , MAX(subq_30.credit_package_count) AS credit_package_count
  , MAX(subq_41.fully_used_credit_package_count) AS fully_used_credit_package_count
  , MAX(subq_52.expired_partially_used_credit_package_count) AS expired_partially_used_credit_package_count
FROM (
  SELECT
    organization__app_organization_id
    , SUM(audit_request_count) AS audit_requests_paid_with_credit_package_count
  FROM (
    SELECT
      subq_2.audit_request__is_audit_request_paid_with_credit_package AS audit_request__is_audit_request_paid_with_credit_package
      , organizations_src_10000.app_organization_id AS organization__app_organization_id
      , subq_2.audit_request_count AS audit_request_count
    FROM (
      SELECT
        app_organization_id AS organization
        , is_audit_request_paid_with_credit_package AS audit_request__is_audit_request_paid_with_credit_package
        , CASE WHEN app_audit_request_id IS NOT NULL THEN 1 ELSE 0 END AS audit_request_count
      FROM {{ ref("fact_audit_requests") }} audit_requests_src_10000
    ) subq_2
    LEFT OUTER JOIN
      {{ ref("dim_organizations") }} organizations_src_10000
    ON
      subq_2.organization = organizations_src_10000.app_organization_id
  ) subq_6
  WHERE audit_request__is_audit_request_paid_with_credit_package IS TRUE
  GROUP BY
    organization__app_organization_id
) subq_10
FULL OUTER JOIN (
  SELECT
    organization__app_organization_id
    , SUM(audit_request_count) AS audit_requests_paid_without_credit_package_count
  FROM (
    SELECT
      subq_13.audit_request__is_audit_request_paid_with_credit_package AS audit_request__is_audit_request_paid_with_credit_package
      , organizations_src_10000.app_organization_id AS organization__app_organization_id
      , subq_13.audit_request_count AS audit_request_count
    FROM (
      SELECT
        app_organization_id AS organization
        , is_audit_request_paid_with_credit_package AS audit_request__is_audit_request_paid_with_credit_package
        , CASE WHEN app_audit_request_id IS NOT NULL THEN 1 ELSE 0 END AS audit_request_count
      FROM {{ ref("fact_audit_requests") }} audit_requests_src_10000
    ) subq_13
    LEFT OUTER JOIN
      {{ ref("dim_organizations") }} organizations_src_10000
    ON
      subq_13.organization = organizations_src_10000.app_organization_id
  ) subq_17
  WHERE audit_request__is_audit_request_paid_with_credit_package IS FALSE
  GROUP BY
    organization__app_organization_id
) subq_21
ON
  subq_10.organization__app_organization_id = subq_21.organization__app_organization_id
FULL OUTER JOIN (
  SELECT
    organizations_src_10000.app_organization_id AS organization__app_organization_id
    , SUM(subq_24.credit_package_count) AS credit_package_count
  FROM (
    SELECT
      app_organization_id AS organization
      , CASE WHEN app_credit_package_id IS NOT NULL THEN 1 ELSE 0 END AS credit_package_count
    FROM {{ ref("fact_credit_packages") }} credit_packages_src_10000
  ) subq_24
  LEFT OUTER JOIN
    {{ ref("dim_organizations") }} organizations_src_10000
  ON
    subq_24.organization = organizations_src_10000.app_organization_id
  GROUP BY
    organizations_src_10000.app_organization_id
) subq_30
ON
  COALESCE(subq_10.organization__app_organization_id, subq_21.organization__app_organization_id) = subq_30.organization__app_organization_id
FULL OUTER JOIN (
  SELECT
    organization__app_organization_id
    , SUM(credit_package_count) AS fully_used_credit_package_count
  FROM (
    SELECT
      subq_33.credit_package__is_credit_package_fully_used AS credit_package__is_credit_package_fully_used
      , organizations_src_10000.app_organization_id AS organization__app_organization_id
      , subq_33.credit_package_count AS credit_package_count
    FROM (
      SELECT
        app_organization_id AS organization
        , is_credit_package_fully_used AS credit_package__is_credit_package_fully_used
        , CASE WHEN app_credit_package_id IS NOT NULL THEN 1 ELSE 0 END AS credit_package_count
      FROM {{ ref("fact_credit_packages") }} credit_packages_src_10000
    ) subq_33
    LEFT OUTER JOIN
      {{ ref("dim_organizations") }} organizations_src_10000
    ON
      subq_33.organization = organizations_src_10000.app_organization_id
  ) subq_37
  WHERE credit_package__is_credit_package_fully_used IS TRUE
  GROUP BY
    organization__app_organization_id
) subq_41
ON
  COALESCE(subq_10.organization__app_organization_id, subq_21.organization__app_organization_id, subq_30.organization__app_organization_id) = subq_41.organization__app_organization_id
FULL OUTER JOIN (
  SELECT
    organization__app_organization_id
    , SUM(credit_package_count) AS expired_partially_used_credit_package_count
  FROM (
    SELECT
      subq_44.credit_package__is_credit_package_expired AS credit_package__is_credit_package_expired
      , subq_44.credit_package__is_credit_package_fully_used AS credit_package__is_credit_package_fully_used
      , organizations_src_10000.app_organization_id AS organization__app_organization_id
      , subq_44.credit_package_count AS credit_package_count
    FROM (
      SELECT
        app_organization_id AS organization
        , is_credit_package_expired AS credit_package__is_credit_package_expired
        , is_credit_package_fully_used AS credit_package__is_credit_package_fully_used
        , CASE WHEN app_credit_package_id IS NOT NULL THEN 1 ELSE 0 END AS credit_package_count
      FROM {{ ref("fact_credit_packages") }} credit_packages_src_10000
    ) subq_44
    LEFT OUTER JOIN
      {{ ref("dim_organizations") }} organizations_src_10000
    ON
      subq_44.organization = organizations_src_10000.app_organization_id
  ) subq_48
  WHERE credit_package__is_credit_package_expired IS TRUE
  AND credit_package__is_credit_package_fully_used IS FALSE
  GROUP BY
    organization__app_organization_id
) subq_52
ON
  COALESCE(subq_10.organization__app_organization_id, subq_21.organization__app_organization_id, subq_30.organization__app_organization_id, subq_41.organization__app_organization_id) = subq_52.organization__app_organization_id
GROUP BY
  COALESCE(subq_10.organization__app_organization_id, subq_21.organization__app_organization_id, subq_30.organization__app_organization_id, subq_41.organization__app_organization_id, subq_52.organization__app_organization_id)
