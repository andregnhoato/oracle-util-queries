declare
  v_user_name varchar2(30):=upper('&Enter_User_Name');
  v_new_password varchar2(30):='&Enter_New_Password';
  v_status boolean;
begin
  v_status:= fnd_user_pkg.ChangePassword ( username => v_user_name
                                         , newpassword => v_new_password );
  if v_status =true then
    dbms_output.put_line ('The password reset successfully for the User:'||v_user_name);
    commit;
  else
    DBMS_OUTPUT.put_line ('Unable to reset password due to'||SQLCODE||' '||SUBSTR(SQLERRM, 1, 100));
    rollback;
  END if;
end;
