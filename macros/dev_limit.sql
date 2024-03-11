{#  Limit the number of rows returned in a query for development runs.

    Parameters
    ----------
    row_count   : integer The maximum number of rows to return, default is 10000
    dev_disable : boolean If true, the limit is not applied
#}
{% macro dev_limit(row_count, dev_disable) -%}


  {%- if var('dev_disable', default=false) -%}

    --no operations, if dev_disable then no limit

  {%- else -%}

    {# set row count limit on base tables for dev runs - '10000' is default value if not explicitly defined #}

    {% if target.name not in ['prod', 'ci']  %}

      limit {{ var("row_count", "10000") }}

    {% endif %}


  {%- endif -%}

{%- endmacro %}
