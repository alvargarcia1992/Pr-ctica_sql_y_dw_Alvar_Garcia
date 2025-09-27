-- 12. CREAR TABLA DE IVR_SUMMARY
  -- Con la base de la tabla ivr_detail y el codigo de todos los ejercicios anteriores,vamos a crear la tabla ivr_summary. Ésta será un resumen de la llamada donde se inclyuen los indicadores más importantes de la llamada. Por tanto, sólo tendrá un registro por llamada. Queremos que tenga los siguientes campos: (Especificados en el pdf de la practica y añadidos a continuación en la respuesta).


-- Se crea la tabla pedida:

CREATE OR REPLACE TABLE keepcoding.ivr_summary(
  ivr_id FLOAT64,
  phone_number STRING,
  ivr_result STRING,
  vdn_aggregation STRING,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  total_duration INT64,
  customer_segment STRING,
  ivr_language STRING,
  steps_module INT64,
  module_aggregation STRING,
  document_type STRING,
  document_identification STRING, 
  customer_phone STRING,
  billing_account_id STRING,
  masiva_lg INT64,
  info_by_phone_lg INT64,
  info_by_dni_lg INT64,
  repeated_phone_24H INT64,
  cause_1recall_phone_24H INT64,
);

-- Declaramos todas las columnas que hemos calculado anteriormente como CTEs, para luego juntarlas todas con INNER JOINS

INSERT INTO keepcoding.ivr_summary (
  ivr_id,
  phone_number,
  ivr_result,
  vdn_aggregation,
  start_date,
  end_date,
  total_duration,
  customer_segment,
  ivr_language,
  steps_module,
  module_aggregation,
  document_type,
  document_identification, 
  customer_phone,
  billing_account_id,
  masiva_lg,
  info_by_phone_lg,
  info_by_dni_lg,
  repeated_phone_24H,
  cause_recall_phone_24H
)

WITH vdn_agg AS (
SELECT 
  DISTINCT calls_ivr_id,
  CASE
    WHEN calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
    WHEN calls_vdn_label LIKE 'TECH%' THEN 'TECH'
    WHEN calls_vdn_label LIKE 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vdn_aggregation
FROM keepcoding.ivr_details
),

documents AS (
WITH valid_data AS (
    SELECT 
        calls_ivr_id,
        document_type,
        document_identification,
        ROW_NUMBER() OVER (
            PARTITION BY CAST(calls_ivr_id AS STRING) 
            ORDER BY calls_ivr_id
        ) AS valid_data_by_id
    FROM keepcoding.ivr_details
    WHERE document_type NOT IN ('UNKNOWN','DESCONOCIDO')
       OR document_identification NOT IN ('UNKNOWN','DESCONOCIDO')
),
filled AS (
SELECT 
    ivr_details.calls_ivr_id,
    IF(ivr_details.document_type IN ('UNKNOWN','DESCONOCIDO'), valid_data.document_type, ivr_details.document_type) AS filled_document_type,
    IF(ivr_details.document_identification IN ('UNKNOWN','DESCONOCIDO'), valid_data.document_identification, ivr_details.document_identification) AS filled_document_identification
FROM keepcoding.ivr_details
LEFT JOIN valid_data
    ON CAST (ivr_details.calls_ivr_id AS STRING) = CAST(valid_data.calls_ivr_id AS STRING)
    AND valid_data.valid_data_by_id = 1
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST (ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1)
SELECT * 
FROM filled
WHERE filled_document_identification IS NOT NULL and filled_document_type NOT IN ('UNKNOWN','DESCONOCIDO')
),

cus_phone AS (
WITH valid_numbers AS (
  SELECT
    calls_ivr_id,
    MAX(CASE WHEN calls_phone_number != 'UNKNOWN' THEN calls_phone_number END) AS valid_number
  FROM keepcoding.ivr_details
  GROUP BY calls_ivr_id
),
filled AS (
SELECT
  DISTINCT(ivr_details.calls_ivr_id),
  IF(ivr_details.customer_phone = 'UNKNOWN',valid_numbers.valid_number,ivr_details.calls_phone_number) AS filled_customer_phone
  FROM keepcoding.ivr_details
  LEFT JOIN valid_numbers
    ON ivr_details.calls_ivr_id = valid_numbers.calls_ivr_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1)
SELECT * 
FROM filled
WHERE filled_customer_phone IS NOT NULL
),

billing_account AS (
  WITH valid_billnos AS (
  SELECT
    calls_ivr_id,
    MAX(CASE WHEN billing_account_id != 'UNKNOWN' THEN billing_account_id END) AS valid_billno
  FROM keepcoding.ivr_details
  GROUP BY calls_ivr_id
),
filled AS (
SELECT
  DISTINCT ivr_details.calls_ivr_id,
  ivr_details.billing_account_id,
  IF(ivr_details.billing_account_id = 'UNKNOWN',valid_billnos.valid_billno,ivr_details.billing_account_id) AS filled_billnos
  FROM keepcoding.ivr_details
  LEFT JOIN valid_billnos
    ON ivr_details.calls_ivr_id = valid_billnos.calls_ivr_id
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1)
SELECT *
FROM filled
WHERE filled_billnos IS NOT NULL
),

masiva AS (
  SELECT 
  DISTINCT calls_ivr_id,
  module_name,
  CASE
    WHEN module_name LIKE 'AVERIA_MASIVA' THEN 1
    ELSE 0
  END AS masiva_lg
FROM keepcoding.ivr_details
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1
),

info_by_phone AS (
  SELECT 
  DISTINCT calls_ivr_id,
  step_name,
  CASE
    WHEN step_name LIKE 'CUSTOMERINFOBYPHONE.TX' THEN 1
    ELSE 0
  END AS info_by_phone_lg
FROM keepcoding.ivr_details
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1
),

info_by_dni AS (
  SELECT 
  DISTINCT calls_ivr_id,
  CASE
    WHEN COUNTIF (step_name LIKE 'CUSTOMERINFOBYDNI.TX' AND step_result LIKE 'OK') > 0  THEN 1
    ELSE 0
  END AS Info_by_dni_lg
FROM keepcoding.ivr_details
GROUP BY calls_ivr_id
),

repeated_recall_phone AS (
  SELECT
  DISTINCT ivr.calls_ivr_id,
  ivr.calls_phone_number,
  CASE
    WHEN COUNTIF(ivr_comp.calls_ivr_id IS NOT NULL 
    AND TIMESTAMP_DIFF(ivr.calls_start_date,ivr_comp.calls_start_date,HOUR) BETWEEN 0 AND 24) > 1 THEN 1
    ELSE 0
    END AS repeated_phone_24H,

  CASE
    WHEN COUNTIF(ivr_comp.calls_ivr_id IS NOT NULL
    AND TIMESTAMP_DIFF(ivr_comp.calls_start_date,ivr.calls_start_date,HOUR) BETWEEN 0 AND 24) > 1 THEN 1
    ELSE 0
    END AS cause_recall_phone_24H

FROM keepcoding.ivr_details AS ivr
LEFT JOIN keepcoding.ivr_details AS ivr_comp
ON ivr.calls_phone_number = ivr_comp.calls_phone_number
AND ivr.calls_ivr_id != ivr_comp.calls_ivr_id
GROUP BY ivr.calls_ivr_id, ivr.calls_phone_number
)

SELECT
  DISTINCT ivr_details.calls_ivr_id AS ivr_id,
  ivr_details.calls_phone_number AS phone_number,
  ivr_details.calls_ivr_result AS ivr_result,
  vdn_agg.vdn_aggregation AS vdn_aggregation,
  ivr_details.calls_start_date AS start_date,
  ivr_details.calls_end_date AS end_date,
  ivr_details.calls_total_duration AS total_duration,
  ivr_details.calls_customer_segment AS customer_segment,
  ivr_details.calls_ivr_language AS ivr_language,
  ivr_details.calls_steps_module AS steps_module,
  ivr_details.calls_module_aggregation AS  module_aggregation,
  documents.filled_document_type AS document_type,
  documents.filled_document_identification AS document_identification, 
  cus_phone.filled_customer_phone AS customer_phone,
  billing_account.filled_billnos AS billing_account_id,
  masiva.masiva_lg AS masiva_lg,
  info_by_phone.info_by_phone_lg AS info_by_phone_lg,
  info_by_dni.info_by_dni_lg AS info_by_dni_lg,
  repeated_recall_phone.repeated_phone_24H AS repeated_phone_24H ,
  repeated_recall_phone.cause_recall_phone_24H AS cause_recall_phone_24H
  FROM `keepcoding.ivr_details` ivr_details
  INNER JOIN vdn_agg
    ON ivr_details.calls_ivr_id = vdn_agg.calls_ivr_id
  INNER JOIN documents
    ON ivr_details.calls_ivr_id = documents.calls_ivr_id
  INNER JOIN  cus_phone
    ON ivr_details.calls_ivr_id = cus_phone.calls_ivr_id
  INNER JOIN billing_account
    ON ivr_details.calls_ivr_id = billing_account.calls_ivr_id
  INNER JOIN masiva
    ON ivr_details.calls_ivr_id = masiva.calls_ivr_id
  INNER JOIN info_by_phone
    ON ivr_details.calls_ivr_id = info_by_phone.calls_ivr_id 
  INNER JOIN info_by_dni
    ON ivr_details.calls_ivr_id = info_by_dni.calls_ivr_id 
  INNER JOIN repeated_recall_phone
    ON ivr_details.calls_ivr_id = repeated_recall_phone.calls_ivr_id;