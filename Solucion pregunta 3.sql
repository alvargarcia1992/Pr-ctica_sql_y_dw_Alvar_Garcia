-- 3.CREAR TABLA DE ivr_detail
  -- tablas ivr_calls, ivr_detais e ivr_modules se crean 

-- Creo la tabla requerida:

CREATE OR REPLACE TABLE keepcoding.ivr_details(
  calls_ivr_id FLOAT64,
  calls_phone_number STRING,
  calls_ivr_result STRING,
  calls_vdn_label STRING,
  calls_start_date TIMESTAMP,
  calls_start_date_id FLOAT64,
  calls_end_date TIMESTAMP,
  calls_end_date_id FLOAT64,
  calls_total_duration INT64,
  calls_customer_segment STRING,
  calls_ivr_language STRING,
  calls_steps_module INT64,
  calls_module_aggregation STRING,
  module_sequence INT64,
  module_name STRING,
  module_duration INT64,
  module_result STRING,
  step_sequence INT64,
  step_name STRING,
  step_result STRING,
  step_description_error STRING,
  document_type STRING,
  document_identification STRING, 
  customer_phone STRING,
  billing_account_id STRING
);
-- Selecciono las columnas donde vamos a insertar los datos de las tablas dadas, 

INSERT INTO keepcoding.ivr_details(
  calls_ivr_id,
  calls_phone_number,
  calls_ivr_result,
  calls_vdn_label,
  calls_start_date,
  calls_start_date_id,
  calls_end_date,
  calls_end_date_id,
  calls_total_duration,
  calls_customer_segment,
  calls_ivr_language,
  calls_steps_module,
  module_sequence,
  module_name,
  module_duration,
  module_result,
  step_sequence,
  step_name,
  step_result,
  step_description_error,
  document_type,
  document_identification, 
  customer_phone,
  billing_account_id
)

-- Selecciono las columnas de las tablas dadas que vamos a usar para enriquecer nuestra tabla de datos, y usamos LEFT JOIN para llevar a cabo la inserción de datos

SELECT 
  ivr_calls.ivr_id AS calls_ivr_id,
  ivr_calls.phone_number AS calls_phone_number,
  ivr_calls.ivr_result AS calls_ivr_result,
  ivr_calls.vdn_label AS calls_vdn_label,
  ivr_calls.start_date AS calls_start_date,
  CAST (FORMAT_TIMESTAMP('%Y%m%d', ivr_calls.start_date) AS INT64)  AS calls_start_date_id,
  ivr_calls.end_date AS calls_end_date,
  CAST (FORMAT_TIMESTAMP('%Y%m%d', ivr_calls.end_date) AS INT64) AS calls_end_date_id,
  ivr_calls.total_duration AS calls_total_duration,
  ivr_calls.customer_segment AS calls_customer_segment,
  ivr_calls.ivr_language AS calls_ivr_language,
  ivr_calls.steps_module AS calls_steps_module,
  ivr_modules.module_sequece AS module_sequence,
  ivr_modules.module_name AS module_name,
  ivr_modules.module_duration AS module_duration,
  ivr_modules.module_result AS modules_result,
  ivr_steps.step_sequence AS step_sequence,
  ivr_steps.step_name AS step_name,
  ivr_steps.step_result AS step_result,
  ivr_steps.step_description_error AS step_description_error,
  ivr_steps.document_type AS document_type,
  ivr_steps.document_identification AS document_identification,
  ivr_steps.customer_phone AS customer_phone,
  ivr_steps.billing_account_id AS billing_account_id
FROM `keepcoding.ivr_calls` ivr_calls
LEFT JOIN `keepcoding.ivr_modules` ivr_modules
  ON ivr_calls.ivr_id = ivr_modules.ivr_id
LEFT JOIN `keepcoding.ivr_steps` ivr_steps
  ON ivr_modules.ivr_id = ivr_steps.ivr_id AND ivr_modules.module_sequece = ivr_steps.module_sequece;
