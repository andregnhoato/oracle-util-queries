SELECT 
    ri.invoice_num "Numero Nota Fiscal Fornecedor",
    (select organization_code from mtl_parameters where organization_id = ri.organization_id ) "Código Empresa",
    (select name from hr_organization_units_v where organization_id = ri.organization_id ) "Empresa",
    ass.segment1 "Código Fornecedor",
    ass.vendor_name "Fornecedor",
    cfit.invoice_type_code "Cód. Tipo de Nota Fiscal no RI",
    cfit.description "Tipo de Nota Fiscal no RI",
    ri.invoice_amount "Valor Nota",
    ri.invoice_date "Data Emissão NF",
    ri.creation_date "Data Entrada RI",
    ri.first_payment_date "Data Prevista Pagamento",
    (select gl.concatenated_segments from apps.gl_code_combinations_kfv gl where gl.code_combination_id = ap.accts_pay_code_combination_id ) "Conta Contábil",
    ph.currency_code "Moeda",
    ph.rate "Valor Moeda",
    ph.segment1 "Ordem de Compra",
    ph.approved_date "Data Apovação OC",
    ril.item_id "Código Produto",
    ril.description "Produto",
    ri.importation_number "Invoice Importação",
    (select gl_forn.concatenated_segments from apps.gl_code_combinations_kfv gl_forn where  gl_forn.code_combination_id = assa.Prepay_Code_Combination_Id) "Conta Contábil Fornecedor"
FROM
    apps.po_headers_all               ph,
    apps.po_lines_all                 pla,
    apps.po_line_locations_all        pll,
    apps.cll_f189_invoice_lines       ril,
    apps.cll_f189_invoices            ri,
    apps.cll_f189_entry_operations    cfe,
    apps.cll_f189_invoice_types       cfit,
    apps.ap_invoice_lines_all         apl,
    apps.ap_invoices_all              ap,
    apps.ap_supplier_sites_all        assa,
    apps.ap_suppliers                 ass
WHERE
        nvl(ph.cancel_flag, 'N') != 'Y'
    AND ph.type_lookup_code = 'STANDARD'
    AND pla.po_header_id = ph.po_header_id
    AND pll.po_line_id = pla.po_line_id
    AND nvl(pll.cancel_flag, 'N') != 'Y'
    AND ril.line_location_id = pll.line_location_id
    AND ri.invoice_id = ril.invoice_id
    AND cfe.operation_id = ri.operation_id
    AND cfe.organization_id = ri.organization_id
    AND cfe.reversion_flag IS NOT NULL
    AND cfit.invoice_type_id = ri.invoice_type_id
    AND assa.vendor_site_id = ph.vendor_site_id
    AND ass.vendor_id = assa.vendor_id
    AND apl.po_line_location_id = pll.line_location_id
    AND ap.invoice_id = apl.invoice_id
    AND cfit.credit_debit_flag = 'C' 
ORDER BY
    1,
    2,
    3,
    4;
