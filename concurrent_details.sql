--Concurrent Programs details

SELECT fcp.concurrent_program_id,
       fcp.concurrent_program_name,
       fcpt.user_concurrent_program_name,
       fcpt.description,
       fe.executable_name,
       fet.user_executable_name,
       fe.execution_file_name
  FROM apps.fnd_concurrent_programs fcp,
       apps.fnd_concurrent_programs_tl fcpt,
       apps.fnd_executables fe,
       apps.fnd_executables_tl fet
 WHERE     fe.executable_id = fet.executable_id
       AND fcp.concurrent_program_id = fcpt.concurrent_program_id
       AND fcpt.language = fet.language
       AND fcp.executable_id = fe.executable_id
       AND fcp.executable_application_id = fe.application_id
       AND fcpt.language = 'US'
       AND fcpt.user_concurrent_program_name LIKE
              'Meter Collection Main Program'



--To find Responsibilities having a particular Concurrent Program

  SELECT frt.responsibility_name, fcpt.user_concurrent_program_name
    FROM fnd_concurrent_programs fcp,
         fnd_concurrent_programs_tl fcpt,
         fnd_request_group_units frgu,
         fnd_responsibility fr,
         fnd_responsibility_tl frt
   WHERE     fcp.concurrent_program_id = fcpt.concurrent_program_id
         AND fcp.application_id = fcpt.application_id
         AND fcp.concurrent_program_id = frgu.request_unit_id(+)
         AND frgu.unit_application_id(+) = fcp.application_id
         AND frgu.request_group_id = fr.request_group_id(+)
         AND fr.responsibility_id = frt.responsibility_id(+)
         AND fr.application_id = frt.application_id(+)
         AND frgu.request_unit_type(+) = 'P'
         AND frt.language(+) = 'US'
         AND fcpt.language = 'US'
         AND fcpt.user_concurrent_program_name LIKE 'I%Materialized%'
ORDER BY frt.responsibility_name



--Concurrent Request Details

SELECT           
        fcr.request_id request_id,
         NVL (fu.description, fu.user_name) requested_by,
         DECODE (fcp.concurrent_program_name,
                 'FNDRSSUB', 'Request Set - ' || fcr.description,
                 fcpt.user_concurrent_program_name)
            concurrent_program,
         DECODE (fcr.phase_code,
                 'I', 'Inactive',
                 'P', DECODE (fcr.hold_flag, 'Y', 'Inactive', 'Pending'),
                 'R', 'Running',
                 'C', 'Complete',
                 fcr.phase_code)
            phase,
         DECODE (
            fcr.status_code,
            'U', 'Disabled',
            'W', 'Paused',
            'X', 'Terminated',
            'Z', 'Waiting',
            'M', 'No Manager',
            'Q', 'Standby',
            'R', 'Normal',
            'S', 'Suspended',
            'T', 'Terminating',
            'D', 'Cancelled',
            'E', 'Error',
            'F', 'Scheduled',
            'G', 'Warning',
            'H', 'On Hold',
            'I', CASE
                    WHEN fcr.request_date < fcr.requested_start_date
                    THEN
                       'Scheduled'
                    ELSE
                       'Normal'
                 END,
            'A', 'Waiting',
            'B', 'Resuming',
            'C', 'Normal',
            fcr.status_code)
            status,
         fcr.argument_text,
         TO_CHAR (fcr.request_date, 'DD-Mon-RRRR HH12:MI:SS AM') date_requested,
         TO_CHAR (fcr.requested_start_date, 'DD-Mon-RRRR HH12:MI:SS AM')
            requested_start_date,
         TO_CHAR (fcr.actual_start_date, 'DD-Mon-RRRR HH12:MI:SS AM')
            date_started,
         TO_CHAR (fcr.actual_completion_date, 'DD-Mon-RRRR HH12:MI:SS AM')
            date_completed,
         fcr.oracle_process_id,
         fcr.os_process_id,
         fcr.logfile_node_name || ': ' || fcr.logfile_name logfile_name,
         fcr.outfile_node_name || ': ' || fcr.outfile_name output_name
    FROM fnd_concurrent_requests fcr,
         fnd_concurrent_programs fcp,
         fnd_concurrent_programs_tl fcpt,
         fnd_user fu
   WHERE     fcr.concurrent_program_id = fcp.concurrent_program_id
         AND fcp.concurrent_program_id = fcpt.concurrent_program_id
         AND fcr.program_application_id = fcp.application_id
         AND fcp.application_id = fcpt.application_id
         AND fcr.requested_by = fu.user_id
         AND fcpt.language = 'US'
ORDER BY fcr.request_date DESC
