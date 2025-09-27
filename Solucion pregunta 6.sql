--6.Generar el campo customer_phone
  -- En ocasiones es posible identificar al cliente en alguno de los pasos de detail obteniendo su número de teléfono. Como en el ejercicio anterior, queremos tener un registro por cada llamada y un solo cliente identificado para la misma.

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
  ivr_details.calls_phone_number,
  ivr_details.customer_phone,
  IF(ivr_details.customer_phone = 'UNKNOWN',valid_numbers.valid_number,ivr_details.calls_phone_number) AS filled_customer_phone
  FROM keepcoding.ivr_details
  LEFT JOIN valid_numbers
    ON ivr_details.calls_ivr_id = valid_numbers.calls_ivr_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1)
SELECT * 
FROM filled
WHERE filled_customer_phone IS NOT NULL;
