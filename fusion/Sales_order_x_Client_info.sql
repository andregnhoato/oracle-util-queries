select source_order_number "sales order"
       ,to_char(hzps.location_id) location_id
       ,to_char(sold_to_customer_id) sold_to_customer_id
       ,sold_to_party_id
       ,hzp.party_name || ' ' || hzp.party_number "Sold to Customer"
       ,doa.address_use_type
       ,hza.account_number
       ,hzp_ship_to.party_name
       ,hza.account_name
       ,doa.party_site_id
       ,hzl.address1
       ,hzl.address2
       ,hzl.address3
       ,hzl.address4
       ,hzl.city
       ,hzl.postal_code
       ,hzl.state
       ,hzl.country
from fusion.hz_parties             hzp
    ,fusion.hz_parties             hzp_ship_to
    ,fusion.doo_headers_all        dha
    ,fusion.doo_order_addresses    doa
    ,fusion.hz_cust_accounts       hza
    ,fusion.hz_cust_acct_sites_all hzcasa
    ,fusion.hz_party_sites         hzps
    ,fusion.hz_locations           hzl
where hzp.party_id = dha.sold_to_party_id
and dha.header_id = doa.header_id(+)
and (doa.address_use_type = 'SHIP_TO' or doa.address_use_type is null)
and doa.party_site_id = hzps.party_site_id(+)
and hzcasa.party_site_id(+) = hzps.party_site_id
and hzps.party_id = hzp_ship_to.party_id(+)
and hzcasa.cust_account_id = hza.cust_account_id(+)
and hzps.location_id = hzl.location_id(+)
and trunc(dha.creation_date) >= trunc(sysdate) - 20
and dha.status_code <> 'DOO_REFERENCE'
and dha.submitted_flag = 'Y'
