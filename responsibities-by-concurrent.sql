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
