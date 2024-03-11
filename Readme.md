# Qualifyze Case Study
## Introduction
This is a case study for the company Qualifyze.
This readme is structured as follows:
- [Assumptions](#assumptions) : List of the assumptions that were made during the case study.
- [Questions and answers](#questions-and-answers) : Answer to the questions asked in the case study.
- [Models structure](#models-structure) : Description of the models structure.
- [Naming conventions](#naming-conventions) : Naming conventions used in the project.
- [Installation](#installation) : Installation instructions.
- [Sensitive information](#sensitive-information) : Sensitive information that should not be pushed to a public repository.

For any questions or clarifications about the case study, feel free to contact me by email.
## Assumptions
- I assume that all the provided data are from the Qualifyze app.
- I assume that a customer is an organization.
- Since there is no subscription id or credit package id in the requests table,
I joined the requests table with the credit_packages table on the organization_id assuming that a request
with a signature_date within the start_date and end_date of a credit package is a request that uses a credit package.
- I assume that a year has passed since the launch of the subscription model (2023) so it is possible to check the
impact of the subscription model on the organizations.

## Questions and answers
### 1. Customer Engagement Evolution
#### Question
How does your data model reflect the transition of customers from individual audit requests
(transactional model) to using credit packages (subscription model)? Can it identify which
customers have switched models over the last year?
#### Answer
Based on the assumptions, I defined that an organization has switched from the transactional model to the subscription model if the organization
has at least one credit package and at least one request that does not use a credit package.
You can find a boolean named `has_organization_switched_to_subscription_model` in the `organizations_bigtable` table that can
be used to identify which organizations have switched models.
#### Testing
I would expect that, at least one organization has switched to the subscription model,
so I created a test named `assert_at_least_one_org_switched_to_subscription_model` to check it in order to alert
the necessary stakeholders in the case that no organization has switched to the subscription model after a year.
### 2. Subscription Data Integration
#### Question
How does your model integrate the raw_data_credit_packages with customer data from
raw_data_requests? Can it provide insights into how different subscription types (e.g., number of
credits in a package) are associated with customer profiles or audit request behaviors?
#### Answer
Based on the assumptions and the different models I created,
it is possible to compute the number of credits associated with an organization
and the number of requests associated with an organization before and after an eventual switch to the subscription model.
You could produce many more metrics and drill down on many features (e.g., the audit_type, the request_state etc.)
based on the provided data models.
### 3. Credit Package Utilization and Expiry Analysis
#### Question
How effectively does your model use the raw_data_credit_packages to track the utilization of
credits against their expiration dates? What insights can it provide regarding the rate of credit
usage or unused credits?
#### Answer
Based on the assumptions and the different models I created, it is possible to track the usage of credits against the credit package expiration dates.
You can find numbers named `fully_used_credit_package_count` and `expired_partially_used_credit_package_count` in the `organizations_bigtable` table
that can be used to track the usage of the credit packages by our customers.
#### Testing
- I would expect that at least one credit package has been fully used and at least one credit package has expired partially used,
so I created a test named `assert_at_least_one_org_with_fully_used_credit_packages` to check it in order to alert
the necessary stakeholders in the case that no credit package has been fully used after a year.
- I would expect that the number organizations with partially used credit packages that have expired is not greater
than 10% of the number of organizations that are on the subscription model,
so I created a test named `assert_at_most_10_percent_of_orgs_with_partially_used_credit_packages_have_expired` to check it
in order to alert the necessary stakeholders in the case that too many organizations are not taking advantage of their credit packages
after a year.

## Models structure
The models are organized in the following layers:
- silver layer: the raw data is loaded into the silver layer. Users should not query the silver layer directly.
The following folders are in the silver layer:
  - seeds: some raw data to load to the warehouse that have no source to load from.
    - ⚠️ I used the seeds to load the data but in a real project, It would be
    loaded to the warehouse by an external process.
  - staging: some renaming and casting of the columns are done in the staging layer.
    - ⚠️ Normally, we would use the `source` function instead of the `ref` function.
  - utilities: some utility models that are used by the other models.
    - It mostly contains the date_spine for metricflow.
  - tests: some singular tests to ensure the quality of the data.
    - In conjunction with the generic tests that are directly in the models' documentation.
- gold layer: the data is enriched with joins to other tables. Users may query the gold layer.
  - mart: dimensions and facts are created in the mart folder.
  - semantic layer:
    - metrics: metrics definitions.
    - semantic_models: semantic models definitions. They are used to define the metrics.
    - saved_queries: saved queries based on the metrics for common use cases.
      - ⚠️ The `organizations_kpis_all_time` saved query was generated by dbt-metricflow with the use of the
        `saved_query_helper.sh` script.
- platinum layer: the data is aggregated and transformed to be used by the business users.
  - bigtables: dimensions joined with key metrics computed in the semantic layer.
- macros: some functions that are used by the other models.
  - Mostly used to define the `dev_limit` function that is used to limit the number of rows in the development
  environment to avoid long the overuse of resources in the development environment.

## Naming conventions
Here are the naming conventions I used:
- I used the snake_case naming convention.
- I used the prefix `app_` to make it clear that a column is from the Qualifyze app.
  - Example: `customer_name` -> `app_customer_name`
- I used the suffix `_id` for the id columns.
- The prefix used for booleans are limited to : is|are|has|do|does|did|can|uses
- I used nouns instead of verbs before the `_date` suffix.
  - There was an inconsistency with the naming of the `signature_date` in credit_packages and `signed_date` in requests.
  - It could be the other way around as long as it is consistent.

## Installation
### Prerequisites
This project uses the following:
- Docker and Docker Compose to run the postgres database.
  - You can install Docker and Docker Compose by following the instructions on the [official website](https://docs.docker.com/get-docker/).
- Poetry to manage the python dependencies.
  - You can install Poetry by following the instructions on the [official website](https://python-poetry.org/docs/).
- Pre-commit to enforce the code style.
- dbt to build the data models.
- dbt-metricflow to handle the semantic layer.
### Running the project
- Clone the repository
- Run the following commands:
```bash
docker-compose up -d
poetry install
poetry shell
dbt deps
dbt build
```
- You can see the dbt autogenerated documentation by running the following commands:
```bash
dbt docs generate
dbt docs serve
```

## Sensitive information:
In a real project the following files should not be pushed to a public repository as they contain passwords:
- `profiles.yml`
- docker-compose.yml
