-- 13. CREAR FUNCIÓN DE LIMPIEZA DE ENTEROS

  -- Crear una función de limpieza de enteros por la que si entra un null la función devuelva el valor -999999.


  CREATE OR REPLACE FUNCTION keepcoding.limpieza(value INT64)
RETURNS INT64 AS (
  IFNULL(value, -999999)
);


-- Aunque no lo pide explicitamente en la pregunta, para aplicar esta función a la creación de la tabla anterior,
-- la aplicariamos sobre las columnas que tenga tipo de dato INTEGER (ya que he realizado estos ejercicios en BigQuery) en el select final 
-- donde se llevan a cabo los INNER JOINS:

-- Ejemplo (modificando parte del codigo del ejercicio anterior, empezando por la linea 197 del mismo, hasta el final):

SELECT
    ivr_details.calls_ivr_id AS ivr_id,
    ivr_details.calls_phone_number AS phone_number,
    ivr_details.calls_ivr_result AS ivr_result,
    vdn_agg.vdn_aggregation AS vdn_aggregation,
    ivr_details.calls_start_date AS start_date,
    ivr_details.calls_end_date AS end_date,
    keepcoding.limpieza(ivr_details.calls_total_duration) AS total_duration,
    ivr_details.calls_customer_segment AS customer_segment,
    ivr_details.calls_ivr_language AS ivr_language,
    keepcoding.limpieza(ivr_details.calls_steps_module) AS steps_module,
    ivr_details.calls_module_aggregation AS module_aggregation,
    documents.filled_document_type AS document_type,
    documents.filled_document_identification AS document_identification,
    cus_phone.filled_customer_phone AS customer_phone,
    billing_account.filled_billnos AS billing_account_id,
    keepcoding.limpieza(masiva.masiva_lg) AS masiva_lg,
    keepcoding.limpieza(info_by_phone.info_by_phone_lg) AS info_by_phone_lg,
    keepcoding.limpieza(info_by_dni.info_by_dni_lg) AS info_by_dni_lg,
    keepcoding.limpieza(repeated_recall_phone.repeated_phone_24H) AS repeated_phone_24H,
    keepcoding.limpieza(repeated_recall_phone.cause_recall_phone_24H) AS cause_1recall_phone_24H
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