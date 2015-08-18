-- Find Object by Type, Name, Status 
SELECT
  owner
  ,object_name
  ,object_type
  ,created
  ,status
FROM
  dba_objects
WHERE
  upper(object_name) LIKE upper('%&object_name%')
AND object_type LIKE upper('%'|| NVL('&object_type', 'TABLE') || '%')
AND status LIKE upper('%' || NVL('&Status', '%') || '%')
ORDER BY
  object_name,
  object_type;
