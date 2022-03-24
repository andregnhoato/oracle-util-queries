Declare

v_username VARCHAR2(30);
v_responsibility_key VARCHAR2(250);
v_resp_app VARCHAR2(250);
v_user VARCHAR2(30) := 'USERNAME HERE';

Cursor C_Resp is
select
b.RESPONSIBILITY_KEY, (select APPLICATION_SHORT_NAME
from fnd_application WHERE APPLICATION_ID = B.APPLICATION_ID) APP_SHORT_NAME
from
FND_RESPONSIBILITY_VL b

where b.responsibility_key in ('APPLICATION_DEVELOPER',
'SYSTEM_ADMINISTRATOR',
'ALERT_MANAGER',
'DESKTOP_INTEGRATION_MANAGER'
);
-- B.RESPONSIBILITY_ID IN (SELECT RESPONSIBILITY_ID FROM FND_USER_RESP_GROUPS_DIRECT
--WHERE USER_ID = 1443);

Begin
Begin
DBMS_OUTPUT.put_line ('Start: '||v_user);
For R_Resp in C_Resp loop
---< Add Resp >---
fnd_user_pkg.addresp(username => v_user
,resp_app => R_RESP.APP_SHORT_NAME
,resp_key => R_resp.RESPONSIBILITY_KEY
,security_group => 'STANDARD'
,description => 'DESCRIPTION'
,start_date => SYSDATE
,end_date => NULL
);

COMMIT;
DBMS_OUTPUT.put_line ('Responsibility Added Successfully '||R_resp.RESPONSIBILITY_KEY|| 'for the user: '||v_user);
End Loop;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.put_line ('Responsibility is not added due to'|| SQLCODE|| SUBSTR (SQLERRM, 1, 100));

End;

END;