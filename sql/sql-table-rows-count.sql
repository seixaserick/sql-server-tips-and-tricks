 

USE  mydatabasename
GO

--return all tables from selected DATABASE with respective rows count

SELECT
 SCHEMA_NAME(T.schema_id) + '.' + T.Name    AS TableName 
, SUM(P.rows)                               AS RecordCount 
FROM        sys.objects    AS T 
INNER JOIN  sys.partitions AS P
      ON T.object_id = P.object_id AND T.type = 'U' 
GROUP BY T.schema_id     , T.Name 
ORDER BY RecordCount DESC, TableName ASC 
