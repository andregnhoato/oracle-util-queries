SELECT
    hcas.global_attribute3 || --raiz
    hcas.global_attribute4 || 
    hcas.global_attribute5 cnpj 
FROM
    apps.ra_customer_trx_all    rct,
    apps.hz_cust_accounts       hca,
    apps.hz_cust_acct_sites_all hcas,
    apps.hz_cust_site_uses_all  hcsu,
    apps.hz_parties             hp,
    apps.hr_operating_units     hou
WHERE
        1 = 1
    AND hca.cust_account_id = hcas.cust_account_id
    AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
    AND hcsu.site_use_id = rct.bill_to_site_use_id
    AND hca.party_id = hp.party_id
    AND rct.org_id = hou.organization_id;
