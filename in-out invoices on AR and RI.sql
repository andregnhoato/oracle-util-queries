SELECT
    'Saidas' tipo_nota,
    (
        SELECT
            electronic_inv_access_key
        FROM
            apps.jl_br_customer_trx_exts
        WHERE
            customer_trx_id = rct.customer_trx_id
    ) chave_eletronica,
    rct.trx_number           numero_nota,
    nvl(rbs.global_attribute3, rbs.attribute1) serie,
    to_char(rct.trx_date, 'DD/mm/YYYY') data_emissao,
    to_char(rct.trx_date, 'DD/mm/YYYY') data_gl,
    rctl.global_attribute1   cfop,
    to_char(55) modelo,
    (
        SELECT
            organization_code
        FROM
            apps.mtl_parameters
        WHERE
            organization_id = rctl.warehouse_id
    ) organizacao,
    (
        SELECT
            meaning
        FROM
            apps.fnd_lookups          fl,
            jl_br_customer_trx_exts   a
        WHERE
            fl.lookup_type LIKE 'CLL_F031_ELECT_TRX_STATUS'
            AND fl.lookup_code = a.electronic_inv_status
            AND a.customer_trx_id = rct.customer_trx_id
    ) status,
    '' AS status_lancamento,
    rctt.name                tipo_transacao,
    rctt.description         descricao_tipo_transacao,
    hp.party_name            razao_social,
    decode(hcas.global_attribute2, '1', hcas.global_attribute3, '2', substr(hcas.global_attribute3, 2, 8)
                                                                     || hcas.global_attribute4, '3', hcas.global_attribute3 || hcas
                                                                     .global_attribute4)
    || hcas.global_attribute5 cpf_cnpj,
    hl.city                  local,
    hl.state                 uf_destino,
    (
        SELECT
            a.region_2
        FROM
            apps.hr_organization_units_v a
        WHERE
            a.organization_id = rctl.warehouse_id
    ) uf_origem,
    rctl.quantity_invoiced * nvl(rctl.gross_unit_selling_price, rctl.unit_selling_price) total_lancamento,
    to_char(0) AS indicador_ipi, --RI
    0 AS base_ipi, --RI
    0 AS aliq_ipi,
    0 AS valor_ipi,
    rlc.description          utilizacao_fiscal,
    (
        SELECT
            segment1
        FROM
            mtl_system_items_b
        WHERE
            inventory_item_id = rctl.inventory_item_id
            AND ROWNUM = 1
    ) codigo_produto,
    rctl.description         descricao,
    rctl.global_attribute2   ncm,
    rctl.uom_code            unidade_de_medida,
    rctl.quantity_invoiced   quantidade,
    nvl(rctl.gross_unit_selling_price, rctl.unit_selling_price) valor_unitario,
    nvl(rctl.gross_extended_amount, rctl.extended_amount) valor_total_prod,
    to_char(0) indicador_icms,
    (
        SELECT
            to_number(avt.global_attribute9)
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE 'ICMS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) cst_icms,
    (
        SELECT
            rctli.taxable_amount
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%ICMS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) base_icms,
    (
        SELECT
            rctli.tax_rate
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%ICMS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) aliquota_icms,
    (
        SELECT
            rctli.extended_amount
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%ICMS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) valor_icms,
    (
        SELECT
            avt.global_attribute6
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE 'PIS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) cst_pis,
    (
        SELECT
            rctli.taxable_amount
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%PIS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) valor_base_pis,
    (
        SELECT
            rctli.tax_rate
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%PIS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) aliquota_pis,
    (
        SELECT
            rctli.extended_amount
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%PIS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) valor_pis,
    (
        SELECT
            avt.global_attribute7
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%COFINS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) cst_cofins,
    (
        SELECT
            rctli.taxable_amount
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%COFINS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) base_cofins,
    (
        SELECT
            rctli.tax_rate
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%COFINS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) aliquota_cofins,
    (
        SELECT
            rctli.extended_amount
        FROM
            apps.ra_customer_trx_lines_all   rctli,
            apps.ar_vat_tax_all              avt
        WHERE
            avt.global_attribute2 = 'Y'
            AND avt.tax_code LIKE '%COFINS%'
            AND avt.vat_tax_id = rctli.vat_tax_id
            AND rctli.line_type = 'TAX'
            AND rctli.link_to_cust_trx_line_id = rctl.customer_trx_line_id
            AND ROWNUM = 1
    ) valor_cofins
FROM
    apps.hz_loc_assignments          hla,
    apps.hz_locations                hl,
    apps.hz_parties                  hp,
    apps.hz_party_sites              hps,
    apps.hz_cust_acct_sites_all      hcas,
    apps.hz_cust_site_uses_all       hcsu,
    apps.ra_cust_trx_types_all       rctt,
    apps.ra_customer_trx_all         rct,
    apps.ra_batch_sources_all        rbs,
    apps.ra_customer_trx_lines_all   rctl,
    apps.fnd_lookups                 rlc
WHERE
    hla.org_id = hcas.org_id
    AND hla.location_id = hl.location_id
    AND hl.location_id = hps.location_id
    AND hp.party_id = hps.party_id
    AND hps.party_site_id = hcas.party_site_id
    AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
    AND hcsu.site_use_id = rct.ship_to_site_use_id
    AND rlc.lookup_type = 'CLL_F189_OPERATION_FISCAL_TYPE'
    AND rlc.lookup_code = nvl(rctl.attribute14, '0')
    AND rctl.line_type = 'LINE'
    AND rctl.customer_trx_id = rct.customer_trx_id
    AND rbs.batch_source_id = rct.batch_source_id
    AND rct.complete_flag = 'Y'
    AND rct.cust_trx_type_id = rctt.cust_trx_type_id
    AND rct.org_id = rctt.org_id
    AND rctt.global_attribute2 = 'EXIT'
    AND rctt.type = 'INV'
    AND rct.status_trx = 'OP'
    AND rct.complete_flag = 'Y'
UNION ALL
SELECT
    'Entrada' tipo_nota,
    cfi.eletronic_invoice_key    chave_eletronica,
    to_char(cfil.num_docfis) numero_nota,
    to_char(cfi.series) serie,
    to_char(cfil.data_emissao, 'DD/mm/YYYY') data_emissao,
    to_char(ceo.receive_date, 'DD/mm/YYYY') data_gl,
    cfil.cod_cfo                 cfop,
    cfi.fiscal_document_model    modelo,
    (
        SELECT
            organization_code
        FROM
            apps.mtl_parameters
        WHERE
            organization_id = cfi.organization_id
    ) organizacao,
    decode(status, 'CANCELLED', 'Cancelado', 'INCOMPLETE', 'Incompleto',
           'IN HOLD', 'Em Retenção', 'APPROVED', 'Aprovado', 'COMPLETE',
           'Completo', 'IN REVERSION', 'Em Reversão', 'IN PROCESS', 'Em Processo',
           'PARTIALLY RECEIVED', 'Parcialmente Recebido', 'nulo') status,
    decode(ceo.reversion_flag, 'S', 'Reversão', 'R', 'Revertida',
           'Normal') status_lancamento,
    cfil.invoice_type_code       tipo_transacao,
    (
        SELECT
            x.description
        FROM
            apps.cll_f189_invoice_types x
        WHERE
            x.invoice_type_id = nfe.invoice_type_id
    ) descricao_tipo_transacao,
    loc.razao_social             razao_ocial,
    loc.cgc_cpf                  cpf_cnpj,
    loc.cidade                   local,
    loc.estado                   uf_origem,
    (
        SELECT
            a.region_2
        FROM
            apps.hr_locations a
        WHERE
            a.location_id = cfi.location_id
    ) uf_destino,
    (
        SELECT
            value_total_invoice
        FROM
            cll_f255_ri_invoices_v a
        WHERE
            a.invoice_id = cfi.invoice_id
    ) total_lancamento,
    cfil.tp_trib_ipi             indicador_ipi,
    cfil.vlr_base_ipi            base_ipi,
    cfil.vlr_aliq_ipi            aliq_ipi,
    cfil.vlr_ipi                 valor_ipi,
    cu.description               utilizacao_fiscal,
    cfil.cod_produto             codigo_produto,
    cfil.descricao_compl         descricao,
    NULL ncm,
    cfil.cod_und_medida          unidade_de_medida,
    cfil.quantidade              quantidade,
    cfil.vlr_unit                valor_unitario,
    cfil.vlr_item                valor_total_prod,
    cfil.tp_trib_icms            indicador_icms,
    0 AS cst_icms,
    cfil.vlr_base_icms           base_icms,
    cfil.vlr_aliq_icms           aliquota_icms,
    cfil.vlr_icms                valor_icms,
    cfil.pis_tributary_code      cst_pis,
    nvl(cfil.import_pis_cofins_base_item, cfil.pis_base_amount) valor_base_pis,
    cfil.pis_tax_rate            aliquota_pis,
    nvl(cfil.importation_pis_amount_item, cfil.pis_amount) valor_pis,
    cfil.cofins_tributary_code   cst_cofins,
    nvl(cfil.import_pis_cofins_base_item, cfil.cofins_base_amount) base_cofins,
    cfil.cofins_tax_rate         aliquota_cofins,
    nvl(cfil.importation_cofins_amount_item, cfil.cofins_amount) valor_cofins
FROM
    xxapps.xxapps_rec_invoices_v        cfi,
    xxapps.xxapps_rec_itens_nfe_v       cfil,
    xxapps.xxapps_rec_nfe_v             nfe,
    apps.cll_f189_entry_operations      ceo,
    apps.cll_f189_fiscal_entities_all   cfe,
    apps.cll_f189_invoice_types         cit,
    apps.cll_f189_cfo_utilizations      cu,
    (
        SELECT
            substr(pvs.global_attribute10
                   || pvs.global_attribute11
                   || pvs.global_attribute12, 2) cgc_cpf,
            pv.vendor_name      razao_social,
            NULL nome_fantasia,
            pvs.city            cidade,
            pvs.address_line3   bairro,
            pvs.state           estado,
            cfex.entity_id
        FROM
            apps.po_vendor_sites_all            pvs,
            apps.po_vendors                     pv,
            apps.cll_f189_fiscal_entities_all   cfex
        WHERE
            pv.vendor_id = pvs.vendor_id
            AND pvs.vendor_site_id = cfex.vendor_site_id
            AND 'VENDOR_SITE' = cfex.entity_type_lookup_code
        UNION ALL
        SELECT
            decode(hcas.global_attribute2, '1', hcas.global_attribute3, '2', substr(hcas.global_attribute3, 2, 8)
                                                                             || hcas.global_attribute4, '3', hcas.global_attribute3
                                                                             || hcas.global_attribute4)
            || hcas.global_attribute5 cgc_cpf,
            hp.party_name   razao_social,
            NULL nome_fantasia,
            hl.city         cidade,
            hl.address3     bairro,
            hl.state        estado,
            cfex.entity_id
        FROM
            apps.hz_locations                   hl,
            apps.hz_parties                     hp,
            apps.hz_party_sites                 hps,
            apps.hz_cust_acct_sites_all         hcas,
            apps.cll_f189_fiscal_entities_all   cfex
        WHERE
            hl.location_id = hps.location_id
            AND hp.party_id = hps.party_id
            AND hps.party_site_id = hcas.party_site_id
            AND hcas.cust_acct_site_id = cfex.cust_acct_site_id
            AND 'CUSTOMER_SITE' = cfex.entity_type_lookup_code
    ) loc
WHERE
    cfil.invoice_id = cfi.invoice_id
    AND cfil.organization_id = cfi.organization_id
    AND cfi.location_id = ceo.location_id
    AND cfi.operation_id = ceo.operation_id
    AND cfi.organization_id = ceo.organization_id
    AND cfe.entity_id = cfi.entity_id
    AND loc.entity_id = cfe.entity_id
    AND nfe.invoice_id = cfi.invoice_id
    AND nfe.organization_id = cfi.organization_id
    AND cit.invoice_type_code = cfil.invoice_type_code
    AND cit.organization_id = cfil.organization_id
    AND cit.fiscal_flag = 'Y'
    AND upper(cit.description) NOT LIKE '%SERVI%'
    AND cu.utilization_id = cfil.utilization_id;
