/*
 SQL to view concurrent request processing time, quite useful
*/
SELECT
  f.request_id ,
  pt.user_concurrent_program_name user_concurrent_program_name ,
  f.actual_start_date actual_start_date ,
  f.actual_completion_date actual_completion_date,
  floor(((f.actual_completion_date-f.actual_start_date)*24*60*60)/3600)
  || ' hh '
  || floor((((f.actual_completion_date-f.actual_start_date)*24*60*60) - floor((
  (f.actual_completion_date           -f.actual_start_date)*24*60*60)/3600)*
  3600)                               /60)
  || ' mm '
  || ROUND((((f.actual_completion_date-f.actual_start_date)*24*60*60) - floor((
  (f.actual_completion_date           -f.actual_start_date)*24*60*60)/3600)*
  3600                                - (floor((((f.actual_completion_date-
  f.actual_start_date)                *24*60*60) - floor(((
  f.actual_completion_date            -f.actual_start_date)*24*60*60)/3600)*
  3600)                               /60)*60) ))
  || ' ss' time_difference ,
  DECODE(p.concurrent_program_name,'ALECDC', p.concurrent_program_name
  ||'['
  ||f.description
  ||']',p.concurrent_program_name) concurrent_program_name ,
  DECODE(f.phase_code,'R','Running','C','Complete',f.phase_code) Phase ,
  f.status_code
FROM
  apps.fnd_concurrent_programs p ,
  apps.fnd_concurrent_programs_tl pt ,
  apps.fnd_concurrent_requests f
WHERE
  f.concurrent_program_id    = p.concurrent_program_id
AND f.program_application_id = p.application_id
AND f.concurrent_program_id  = pt.concurrent_program_id
AND f.program_application_id = pt.application_id
AND pt.language              = USERENV('Lang')
AND f.actual_start_date     IS NOT NULL
ORDER BY
  f.actual_completion_date-f.actual_start_date DESC;
