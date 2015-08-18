/*
 Util queries to find details about responsabilities.
*/
-- responsability details  
SELECT
  APPLICATION_ID,
  RESPONSIBILITY_ID,
  RESPONSIBILITY_KEY,
  REQUEST_GROUP_ID,
  RESPONSIBILITY_NAME,
  DESCRIPTION
FROM
  fnd_responsibility_vl;
  
-- details about request groups filtered by report/concurrent name
SELECT
  Y.*
FROM
  fnd_request_group_units X,
  FND_REQUEST_GROUPS Y
WHERE
  X.request_unit_id IN
  (
    SELECT
      concurrent_program_id
    FROM
      fnd_concurrent_programs
    WHERE
      concurrent_program_name LIKE '%CONCURRENT_NAME%'
  )
AND x.request_group_id = y.request_group_id;

--find what responsibilities a specific concurrent/report is assigned;
SELECT
  *
FROM
  fnd_responsibility_vl
WHERE
  request_group_id IN
  (
    SELECT
      request_group_id
    FROM
      fnd_request_group_units
    WHERE
      request_unit_id IN
      (
        SELECT
          concurrent_program_id, fnd_concurrent_programs.CONCURRENT_PROGRAM_NAME
        FROM
          fnd_concurrent_programs
        WHERE
          concurrent_program_name LIKE '%CONCURRENT_NAME%'
      )
  );
