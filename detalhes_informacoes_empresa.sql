SELECT 
    hou.organization_id,
    hou.name,
    e.hcas_global_attribute3
    || e.hcas_global_attribute4
    || e.hcas_global_attribute5 cnpj,
    c.customer_name                 razao_social,
    c.organization_name_phonetic    fantasia,
    e.*
FROM
    fr_ar_enderecos_v             e,
    fr_ar_locais_v                l,
    fr_ar_clientes_v              c,
    po_location_associations_all  pla,
    hr_locations                  hl,
    hr_organization_units         hou
WHERE
        1 = 1
    AND hl.location_id = hou.location_id
    AND pla.location_id = hl.location_id
    AND pla.site_use_id = l.site_use_id
    AND e.cust_acct_site_id = l.cust_acct_site_id
    AND e.cust_account_id = c.cust_account_id
    AND hou.date_to IS NULL;
