-- 5.Generar los campos document_type y document_identification:
  -- En ocasiones es posible identificar al cliente en alguno de los pasos de detail obteniendo su tipo de documento y su identificación. Como en el ejercicio anterior queremos tener un registro por cada llamada y un sólo cliente identificado para la misma.

-- Para document_type:

-- Usamos una CTE para obtener una fila por llamada que contenga un dato no 'vacio' de 'document_type' o 'document_identification'
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

-- Usamos otra CTE para generar las columnas 'filled_document_type' y 'filled_document_identification' 
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
WHERE filled_document_identification IS NOT NULL;