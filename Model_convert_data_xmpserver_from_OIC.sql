select 
from_currency
,to_currency
,conversion_date
,conversion_type
,conversion_rate
from
 gl_daily_rates
where 
1=1
AND (conversion_date >= TO_DATE (SUBSTR(REPLACE(:p_date_from,'T',' '),1,19), 'YYYY-MM-DD HH24:MI:SS'))
AND (conversion_date <= TO_DATE (SUBSTR(REPLACE(:p_date_to,'T',' '),1,19), 'YYYY-MM-DD HH24:MI:SS'))
