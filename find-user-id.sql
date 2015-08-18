/*
Details about user in oracle EBS
change USER_ID to your user id.
*/
SELECT
  user_id,
  user_name,
  description,
  email_address
FROM
  FND_USER
WHERE 
  user_name like 'YOUR_USERNAME';
