/*
Set user on session
change USER_ID to your user id.
*/
ALTER session
SET nls_date_language = portuguese
/
--alter session set nls_language='AMERICAN'
ALTER session
SET nls_language = 'BRAZILIAN PORTUGUESE'
/
ALTER session
SET NLS_NUMERIC_CHARACTERS = ",."
/
DECLARE
  context_area      VARCHAR2(2000);
  application_id    NUMBER := 1;     --Administrator
  responsibility_id NUMBER := 51750; --Responsability id
  resp_appl_id      NUMBER := 20111;
  user_id           NUMBER := 15409;
  security_group_id NUMBER := 0;
BEGIN
  fnd_global.apps_initialize(user_id,responsibility_id,resp_appl_id,
  security_group_id);
  fnd_client_info.setup_client_info(application_id, responsibility_id, user_id,
  security_group_id);
  mo_global.init('AR');
  mo_global.init('SQLAP');
  ARP_GLOBAL.init_global;
END;
