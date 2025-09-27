-- 4. Generarel campo vdn_aggregation: Generar el campo para cada llamada, es decir, queremos tener el campo call_ivr_id y el campo vdn_aggregation con la siguiente lógica:
  -- es una generalización del campo vdn_label. Si vdn_label empieza por ATC pondremos FRONT, si empieza con TECH pondremos TECH si es ABSORPTION dejaremos ABSORPTION y si no es ninguna de las anteriores pondremos RESTO. 

SELECT 
  DISTINCT calls_ivr_id,
  -- Declaramos los casos que vamos a tener en cuenta, como se nos ha pedido en el enunciado
  CASE
    WHEN calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
    WHEN calls_vdn_label LIKE 'TECH%' THEN 'TECH'
    WHEN calls_vdn_label LIKE 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vnd_aggregation
FROM keepcoding.ivr_details;