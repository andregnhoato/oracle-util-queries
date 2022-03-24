begin
fnd_user_pkg.CreateUser (
x_user_name => 'USERNAMEHERE',
x_owner => 'SEED',
x_unencrypted_password => 'mae1940',
x_session_number => 0,
x_start_date => SYSDATE,
x_end_date => null,
x_last_logon_date => null,
x_description => 'DESCRIPTION HERE',
x_password_date => null,
x_password_accesses_left => null,
x_password_lifespan_accesses => null,
x_password_lifespan_days => null,
x_employee_id => null,
x_email_address => 'EMAILHERE@MAIL.COM',
x_fax => null,
x_customer_id => null,
x_supplier_id => null);
end;