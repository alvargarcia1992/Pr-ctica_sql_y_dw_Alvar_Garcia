-- 11. GENERAR LOS CAMPOS REPEATED_PHONE_24H, CAUSE_RECALL_PHONE_24H
  -- Como en el ejercicio anterior queremos tener un registro por cada llamada y dos flags que indiquen si el calls_phone_number tiene una llamada las anteriores 24 horas o en las siguientes 24 horas. En caso afirmativo pondremos un 1 en estos flag, de lo contrario llevará un 0.

SELECT
  DISTINCT ivr.calls_ivr_id,
  ivr.calls_phone_number,
  CASE
    WHEN COUNTIF(ivr_comp.calls_ivr_id IS NOT NULL 
    AND TIMESTAMP_DIFF(ivr.calls_start_date,ivr_comp.calls_start_date,HOUR) BETWEEN 0 AND 24) > 1 THEN 1
    ELSE 0
    END AS repeated_phone_24h,

  CASE
    WHEN COUNTIF(ivr_comp.calls_ivr_id IS NOT NULL
    AND TIMESTAMP_DIFF(ivr_comp.calls_start_date,ivr.calls_start_date,HOUR) BETWEEN 0 AND 24) > 1 THEN 1
    ELSE 0
    END AS cause_recall_phone_24h

FROM keepcoding.ivr_details AS ivr
LEFT JOIN keepcoding.ivr_details AS ivr_comp
ON ivr.calls_phone_number = ivr_comp.calls_phone_number
AND ivr.calls_ivr_id != ivr_comp.calls_ivr_id
GROUP BY ivr.calls_ivr_id, ivr.calls_phone_number;