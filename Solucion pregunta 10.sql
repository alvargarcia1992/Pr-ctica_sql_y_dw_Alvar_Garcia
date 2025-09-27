-- 10. GENERAR EL CAMPO INFO_BY_DNI_IG
  -- Como en el ejercicio anterior queremos tener un registro por cada llamada y un flag que indique si la llamada para por el step de nombre CUSTOMERINFOBYDNI.TX y su step_result es OK, quiere decir que hemos podido identificar al cliente a través de su número de dni. En ese caso pondremos un 1 en este flag, de lo contrario llevará un 0.

SELECT 
  DISTINCT calls_ivr_id,
  CASE
    WHEN COUNTIF (step_name LIKE 'CUSTOMERINFOBYDNI.TX' AND step_result LIKE 'OK') > 0  THEN 1
    ELSE 0
  END AS Info_by_DNI_Ig
FROM keepcoding.ivr_details
GROUP BY calls_ivr_id;