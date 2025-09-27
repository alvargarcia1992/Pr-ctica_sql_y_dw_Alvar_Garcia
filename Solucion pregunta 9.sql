-- 9. GENERAR EL CAMPO INFO_BY_PHONE_IG
  -- Como en el ejercicio anterior, queremos tener un registro por cada llamada y un flag que indique si la llamada pasa por el step de nombre CUSTOMERINFOBYPHONE.TX y su step_result es OK, quiere decir que hemos podido identificar al cliente a través de su número de teléfono.En ese caso, pondremos un 1 en este flag, de lo contrario llevará un 0.

SELECT 
  DISTINCT calls_ivr_id,
  step_name,
  CASE
    WHEN step_name LIKE 'CUSTOMERINFOBYPHONE.TX' THEN 1
    ELSE 0
  END AS Info_by_phone_Ig
FROM keepcoding.ivr_details
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1;
