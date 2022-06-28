--EASY WAY TO FIND ALL COLUMNS BY NAME
SELECT 

   '[' + T.NAME + '].[' + C.NAME + ']' AS TableAndColumn

FROM          SYS.COLUMNS AS C
   INNER JOIN SYS.TABLES  AS T ON T.object_id = C.object_id

WHERE 
	C.NAME LIKE '%last%'
    

/*  OUTPUT SAMPLE

TableAndColumn 
--------------------
[customers].[last_name]
[customers].[last_password_change]
[sale_transactions].[is_last_delivery_attempt]

(3 rows affected)

*/