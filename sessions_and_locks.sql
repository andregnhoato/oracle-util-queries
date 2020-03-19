SELECT
    c.username                                       ora,
    c.sql_id,
    c.prev_sql_id,
    c.inst_id,
    c.client_identifier                              user,
    c.osuser                                         unix,
    to_char(c.sid)                                   sid,
    c.serial#                                        serial,
    c.status,
    c.module,
    c.action,
    c.process,
    c.terminal,
    c.audsid,
    l.type,
    fnd_date.date_to_canonical(c.logon_time)         logon_time,
    c.client_info,
    l.block,
    c.last_call_et,
    al.object_name,
    al.object_type,
    a.object_name                                    obj_wait,
    a.object_type                                    obj_type_wait,
    CASE
        WHEN a.object_type = 'TABLE' THEN
            'select * from '
            || a.object_name
            || ' where rowid='''
            || dbms_rowid.rowid_create(1, c.row_wait_obj#, c.row_wait_file#, c.row_wait_block#, c.row_wait_row#)
            || ''''
        ELSE
            NULL
    END obj_wait_rowid,
    'alter system kill session '''
    || c.sid
    || ','
    || c.serial#
    || ',@'
    || c.inst_id
    || ''' IMMEDIATE;' kill,
    c.row_wait_obj#,
    c.row_wait_file#,
    c.row_wait_block#,
    c.row_wait_row#
FROM
    all_objects  al,
    all_objects  a,
    gv$lock      l,
    gv$session   c,
    fnd_user     u
WHERE
        u.user_id || '' = nvl((ltrim(rtrim(substr(c.client_info, 45, 5)))), - 1)
    AND l.sid (+) = c.sid
    AND l.inst_id (+) = c.inst_id
    AND al.object_id (+) = l.id1
    AND a.object_id (+) = c.row_wait_obj#
    AND ( al.object_name LIKE upper(:objeto)
          OR :objeto IS NULL )
    AND ( c.client_identifier LIKE upper(:nome)
          OR :nome IS NULL )
    AND ( c.module LIKE :modulo
          OR :modulo IS NULL )
    AND ( to_char(c.sid) = :sid
          OR :sid IS NULL )
    AND ( c.osuser = :osuser
          OR :osuser IS NULL )
    AND ( c.terminal = :terminal
          OR :terminal IS NULL )
ORDER BY
    c.last_call_et DESC,
    rpad(u.user_name, 10)
