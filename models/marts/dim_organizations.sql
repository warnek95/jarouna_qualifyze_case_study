WITH

organizations AS (
    SELECT * FROM {{ ref('stg_app__organizations') }}
),

final AS (
    SELECT organizations.* FROM organizations
)

SELECT * FROM final

{{ dev_limit() }}
