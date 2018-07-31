SELECT /*+ rule */
  rq.parent_request_id                   "Parent Req. ID",
  rq.request_id                          "Req. ID",
  tl.user_concurrent_program_name        "Program Name",
  rq.actual_start_date                   "Start Date",
  rq.actual_completion_date              "Completion Date",
  ROUND((rq.actual_completion_date -
  rq.actual_start_date) * 1440, 2)   "Runtime (in Minutes)"      
FROM applsys.fnd_concurrent_programs_tl  tl,
     applsys.fnd_concurrent_requests     rq
WHERE tl.application_id        = rq.program_application_id
  AND tl.concurrent_program_id = rq.concurrent_program_id
  AND tl.LANGUAGE              = USERENV('LANG')
  AND rq.actual_start_date IS NOT NULL
  AND rq.actual_completion_date IS NOT NULL
  AND tl.user_concurrent_program_name = 'User Concurrent Name'  -- <change it>
  -- AND TRUNC(rq.actual_start_date) = '&start_date'  -- uncomment this for a specific date
ORDER BY rq.request_id DESC
