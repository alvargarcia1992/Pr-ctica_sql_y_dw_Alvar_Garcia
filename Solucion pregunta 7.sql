-- 7.GENERAR CAMPO BILLING_ACOUNT_ID
  -- En ocasiones es posible identificar al cliente en alguno de los pasos de detail obteniendo su numero de cliente. Como en el ejercicio anterior queremos tener un registro por cada llamada y un sólo cliente identificado para la misma.

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
WHERE filled_billnos IS NOT NULL;