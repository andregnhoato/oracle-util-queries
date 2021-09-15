SELECT DISTINCT 
odm.HEADER_ID 
	, odm.SOURCE_ORDER_NUMBER order_number                
	,	FF.ATTRIBUTE_CHAR1 id_cotacao
	,	FF.ATTRIBUTE_CHAR5 Delivery_Method_id
	,	HCP.postal_code cep_destin
	,	lct.POSTAL_CODE cep_origin
	,	HCP.tax_payer_number doc_cliente
	,	HCP.phone_number
	,	hp.PARTY_NAME full_name
	,	HCP.email_address
	,	HCP.country
	,	HCP.state_code
	,	HCP.city
	,	HCP.street
	,	HCP.address_number
	,	HCP.COMPLEMENTO
	,	HCP.BAIRRO
	,	HCP.doc_type
        ,       HCP.contact_id


FROM
	DOO_HEADERS_ALL odm
RIGHT OUTER JOIN DOO_HEADERS_EFF_B FF              		       
ON odm.HEADER_ID = FF.HEADER_ID
	AND odm.ORDER_TYPE_CODE != 'VD_SERVICO'
	AND odm.ORDER_TYPE_CODE != 'VDA_CONSIG'
	AND FF.CONTEXT_CODE = 'Frete'           				   
	AND FF.ATTRIBUTE_CHAR1 <> '0'
INNER JOIN DOO_HEADERS_EFF_B STS              		       
ON odm.HEADER_ID = STS.HEADER_ID
	AND STS.CONTEXT_CODE = 'Header'           				   
INNER JOIN  hz_cust_accounts cust
ON odm.SOLD_TO_PARTY_ID  =  cust.party_id
INNER JOIN HZ_CUST_ACCT_SITES_ALL HCA
ON cust.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
INNER JOIN hz_parties hp
ON cust.party_id = hp.party_id

INNER JOIN DOO_FULFILL_LINES_ALL dfl
ON dfl.HEADER_ID = odm.HEADER_ID
INNER JOIN hz_cust_site_uses_all hps1
ON hps1.site_use_id = dfl.BILL_TO_SITE_USE_ID

INNER JOIN HZ_CUST_ACCT_SITES_ALL hcs2
on hcs2.cust_acct_site_id = hps1.cust_acct_site_id
INNER JOIN EGP_SYSTEM_ITEMS_B item
ON item.INVENTORY_ITEM_ID = dfl.INVENTORY_ITEM_ID
INNER JOIN HR_ORGANIZATION_UNITS inv
ON dfl.FULFILL_ORG_ID = inv.ORGANIZATION_ID
INNER JOIN HR_LOCATIONS lct
ON lct.LOCATION_ID = inv.LOCATION_ID
RIGHT OUTER JOIN DOO_ORDER_ADDRESSES DOA              		       
ON DOA.CUST_ACCT_ID = cust.CUST_ACCOUNT_ID

INNER JOIN (
SELECT DISTINCT 
	nvl( hps.PARTY_SITE_NAME,'0') tax_payer_number
	,	hp.PRIMARY_PHONE_COUNTRY_CODE||hp.PRIMARY_PHONE_AREA_CODE||hp.PRIMARY_PHONE_NUMBER phone_number
    ,	hps.party_site_id site_id
	,	hp.POSTAL_CODE postal_code
	,	hp.COUNTRY country
	,	hp.STATE state_code
	,	hp.CITY city
	,	hp.ADDRESS1 street
	,	hp.ADDRESS2 address_number
	,	hp.ADDRESS3 COMPLEMENTO
	,	hp.ADDRESS4 BAIRRO
	,	hp.EMAIL_ADDRESS email_address
        ,hp.PREFERRED_CONTACT_PERSON_ID contact_id
	, 
	CASE 
	WHEN LENGTH(hps.PARTY_SITE_NAME) = 11 THEN 'ORA_BR_CPF'
	ELSE 'ORA_BR_CNPJ'
	END  doc_type
  FROM 
     hz_party_sites hps
	,hz_parties hp
WHERE  hp.party_id = hps.party_id


) HCP
ON HCP.site_id = hcs2.party_site_id       
--AND HCP.RN =1
and odm.SUBMITTED_FLAG = 'Y'
AND dfl.STATUS_CODE = 'AWAIT_BILLING'
AND (FF.ATTRIBUTE_CHAR2 = '0' OR FF.ATTRIBUTE_CHAR2 IS NULL)
AND STS.ATTRIBUTE_CHAR4 = 'GAL_INT_PEDIDO_COTACAO'
AND DOO_CROSS_REFERENCE.GETFULFILLMENTVALUE('LOOKUP_CODE', 'WSH_FREIGHT_CHARGE_TERMS', dfl.FREIGHT_TERMS_CODE) = 'CIF'
--AND  odm.SOURCE_ORDER_NUMBER IN ('xxxxxx')
AND  odm.SOURCE_ORDER_NUMBER != '105'
