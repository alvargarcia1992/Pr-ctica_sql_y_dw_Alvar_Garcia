-- 8. Generar el campo masiva_Ig
  --Como en el ejercicio anterior, queremos tener un registro por cada llamada y un flag que indique si la llamada ha pasado por el módulo AVERIA_MASIVA. Si es asi indicarlo con un 1 de lo contrario con un 0.

SELECT 
  DISTINCT calls_ivr_id,
  module_name,
  CASE
    WHEN module_name LIKE 'AVERIA_MASIVA' THEN 1
    ELSE 0
  END AS masiva_Ig
FROM keepcoding.ivr_details
QUALIFY ROW_NUMBER() OVER (PARTITION BY CAST(ivr_details.calls_ivr_id AS STRING) ORDER BY ivr_details.calls_ivr_id) = 1;