-- Find tables and columns that include a table and/or column name specified.
SELECT
  owner ,
  table_name ,
  column_name ,
  data_type ,
  data_length ,
  num_nulls
FROM
  dba_tab_columns
WHERE
  column_name LIKE NVL(UPPER('&COLUMN_NAME'), column_name)
AND table_name LIKE NVL(UPPER('&TABLE_NAME'), table_name);
