--
--------------------------------------------------------------------------------
-- RELATÓRIO DE AGING HISTÓRICO DO CONTAS A PAGAR
--------------------------------------------------------------------------------
--
SELECT
    xxx.corte               data_corte,
    xxx.fornecedor,
    xxx.cod_for,
    xxx.tipo_fornecedor,
    xxx.site_for,
    xxx.source              origem_titulo,
    xxx.inv_type,
    xxx.num_titulo,
    xxx.invoice_date        data_titulo,
    xxx.creation_date       data_insert,
    xxx.receipt_date        data_receb,
    to_char(xxx.valor_titulo_original) vlr_titulo_orig,
    to_char(xxx.valor_adto_original) vlr_adto_original,
    to_char(xxx.valor_pago_original) vlr_pagto_original,
    to_char(xxx.valor_imp_ret_original) vlr_ret_imp_original,
    to_char(xxx.valor_desconto_original) vlr_desconto_original,
    to_char(xxx.saldo_original) saldo_pagar_original,
    xxx.moeda_titulo,
    to_char(xxx.taxa_conversao) taxa_conversao,
    to_char(xxx.valor_titulo_brl) vlr_titulo_brl,
    to_char(xxx.valor_adto_brl) vlr_adto_brl,
    to_char(xxx.valor_pago_brl) vlr_pagto_brl,
    to_char(xxx.valor_imp_ret_brl) vlr_ret_imp_brl,
    to_char(xxx.valor_desconto_brl) vlr_desconto_brl,
    to_char(xxx.saldo_brl) saldo_pagar_brl,
    xxx.var_cambial_pagto   variaçao_cambial
FROM
    (
        SELECT
            trunc(to_date(&pdata, 'DD-MM-RRRR')) corte,
            pov.vendor_name                fornecedor,
            pov.segment1                   cod_for,
            pov.vendor_type_lookup_code    tipo_fornecedor,
            pvs.vendor_site_code           site_for,
            aia.source,
            aia.invoice_type_lookup_code   inv_type,
            aia.invoice_num                num_titulo,
            aia.invoice_currency_code      moeda_titulo,
            nvl(aia.exchange_rate, 1) taxa_conversao,
            aia.invoice_date               invoice_date,
            aia.creation_date              creation_date,
            aia.invoice_received_date      receipt_date
        -------------------------------------------------------------------------------------------------------------------------------------------------------
            ,
            decode(aia.cancelled_date, NULL, aia.invoice_amount, aia.cancelled_amount) valor_titulo_original,
            nvl(pre.valor_orig, 0) valor_adto_original,
            nvl(aip.amount_pgt, 0) valor_pago_original,
            nvl(aip.amount_awt, 0) valor_imp_ret_original,
            nvl(aip.discount_taken, 0) valor_desconto_original,
            decode(aia.cancelled_date, NULL, aia.invoice_amount, aia.cancelled_amount) - ( nvl(pre.valor_orig, 0) + nvl(aip.amount_pgt
            , 0) + nvl(aip.amount_awt, 0) + nvl(aip.discount_taken, 0) ) saldo_original,
            round(decode(aia.cancelled_date, NULL, aia.invoice_amount, aia.cancelled_amount) * nvl(aia.exchange_rate, 1), 2) valor_titulo_brl
            ,
            nvl(pre.valor_conv, 0) valor_adto_brl,
            nvl(aip.amount_pgt_brl, 0) valor_pago_brl,
            nvl(aip.amount_awt, 0) valor_imp_ret_brl,
            nvl(aip.discount_taken_brl, 0) valor_desconto_brl,
            round((decode(aia.cancelled_date, NULL, aia.invoice_amount, aia.cancelled_amount) * nvl(aia.exchange_rate, 1)) -(nvl(
            pre.valor_conv, 0) + nvl(aip.amount_pgt_brl, 0) + nvl(aip.amount_awt, 0) + nvl(aip.discount_taken_brl, 0)), 2) saldo_brl
            ,
            nvl(aip.variação_cambial, 0) var_cambial_pagto,
            pov.vendor_id,
            aia.invoice_id                 invoice_id
        FROM
            apps.po_vendors                 pov,
            apps.po_vendor_sites_all        pvs,
            apps.ap_invoices_all            aia,
            apps.ap_accounting_events_all   aea
        --------------------------------------------------------------------------------
            ,
            (
                SELECT
                    pgt.invoice_id invoice_id,
                    SUM(awt.amount *(- 1)) amount_awt,
                    SUM(pgt.amount) amount_pgt,
                    SUM(pgt.discount_taken) discount_taken,
                    SUM(round(pgt.amount * nvl(aca.exchange_rate, 1), 2)) amount_pgt_brl,
                    SUM(round(pgt.discount_taken * nvl(aca.exchange_rate, 1), 2)) discount_taken_brl,
                    SUM(round((pgt.amount * nvl(inv.exchange_rate, 1)) -(pgt.amount * nvl(aca.exchange_rate, 1)), 2)) variação_cambial
                FROM
                    apps.ap_invoice_payments_all   pgt,
                    apps.ap_checks_all             aca,
                    apps.ap_invoices_all           inv,
                    apps.po_vendors                pv1,
                    (
                        SELECT
                            invoice_id,
                            awt_invoice_payment_id invoice_payment_id,
                            SUM(amount) amount
                        FROM
                            apps.ap_invoice_distributions_all
                        WHERE
                            org_id = 4719
                            AND line_type_lookup_code = 'AWT'
                            AND trunc(accounting_date) <= trunc(to_date(&pdata, 'DD-MM-RRRR'))
                        GROUP BY
                            invoice_id,
                            awt_invoice_payment_id
                    ) awt
                WHERE
                    pgt.org_id = 4719
                    AND nvl(pgt.reversal_inv_pmt_id, 0) = 0
                    AND pgt.check_id = aca.check_id
                    AND aca.vendor_id = pv1.vendor_id
--                AND     UPPER(PV1.VENDOR_NAME)             LIKE  UPPER('%'||NVL(&FORNECEDOR,PV1.VENDOR_NAME)||'%')
--                AND     UPPER(NVL(PV1.VENDOR_TYPE_LOOKUP_CODE,'VENDOR')) 
--                                                           LIKE  UPPER('%'||NVL(&TIPO_FORNECEDOR,NVL(PV1.VENDOR_TYPE_LOOKUP_CODE,'VENDOR'))||'%')
                    AND pgt.invoice_id = inv.invoice_id
                    AND ( pgt.invoice_payment_id = awt.invoice_payment_id (+)
                          AND pgt.invoice_id = awt.invoice_id (+) )
                    AND trunc(aca.check_date) <= trunc(to_date(&pdata, 'DD-MM-RRRR'))
                    AND ( aca.void_date IS NULL
                          OR trunc(aca.void_date) > trunc(to_date(&pdata, 'DD-MM-RRRR')) )
                GROUP BY
                    pgt.invoice_id
            ) aip
       --------------------------------------------------------------------------------
            ,
            (
                SELECT
                    SUM(zz.vlr_adto_conv) valor_conv,
                    SUM(zz.vlr_adto_orig) valor_orig,
                    zz.invoice_id invoice_id
                FROM
                    (
                        SELECT
                            (
                                CASE
                                    WHEN ai.invoice_currency_code = 'BRL' THEN
                                        ( - 1 ) * aid1.amount
                                    ELSE
                                        ( - 1 ) * round((aid1.amount * ai.exchange_rate), 2)
                                END
                            ) vlr_adto_conv,
                            ( - 1 ) * aid1.amount vlr_adto_orig,
                            aid1.invoice_id invoice_id
                        FROM
                            apps.ap_invoices_all                ai,
                            apps.po_vendors                     pv,
                            apps.ap_invoice_distributions_all   aid1,
                            apps.ap_invoice_distributions_all   aid2,
                            apps.ap_tax_codes                   atc,
                            apps.po_distributions               pd,
                            apps.po_headers                     ph,
                            apps.po_lines                       pl,
                            apps.po_line_locations              pll,
                            apps.rcv_transactions               rtxns,
                            apps.rcv_shipment_headers           rsh,
                            apps.rcv_shipment_lines             rsl
                        WHERE
                            aid1.prepay_distribution_id = aid2.invoice_distribution_id
                            AND ai.invoice_id = aid1.invoice_id
                            AND ai.vendor_id = pv.vendor_id
                            AND aid2.tax_code_id = atc.tax_id (+)
                            AND aid1.line_type_lookup_code = 'PREPAY'
                            AND aid1.po_distribution_id = pd.po_distribution_id (+)
                            AND pd.po_header_id = ph.po_header_id (+)
                            AND pd.line_location_id = pll.line_location_id (+)
                            AND pll.po_line_id = pl.po_line_id (+)
                            AND aid1.rcv_transaction_id = rtxns.transaction_id (+)
                            AND rtxns.shipment_line_id = rsl.shipment_line_id (+)
                            AND rsl.shipment_header_id = rsh.shipment_header_id (+)
                            AND ai.org_id = 4719
                            AND trunc(aid1.accounting_date) <= trunc(to_date(&pdata, 'DD-MM-RRRR'))
--                        AND     UPPER(PV.VENDOR_NAME)              LIKE  UPPER('%'||NVL(&FORNECEDOR,PV.VENDOR_NAME)||'%')
--                        AND     UPPER(NVL(PV.VENDOR_TYPE_LOOKUP_CODE,'VENDOR'))  
--                                                                   LIKE  UPPER('%'||NVL(&TIPO_FORNECEDOR,NVL(PV.VENDOR_TYPE_LOOKUP_CODE,'VENDOR'))||'%')
                            AND ai.invoice_type_lookup_code NOT IN (
                                'PREPAYMENT',
                                'CREDIT',
                                'DEBIT'
                            )
                    ) zz
                GROUP BY
                    zz.invoice_id
            ) pre
        --------------------------------------------------------------------------------
        WHERE
            aia.org_id = 4719
            AND aia.vendor_id = pov.vendor_id
            AND ( aia.vendor_id = pvs.vendor_id
                  AND aia.vendor_site_id = pvs.vendor_site_id )
--        AND     UPPER(POV.VENDOR_NAME)             LIKE  UPPER('%'||NVL(&FORNECEDOR,POV.VENDOR_NAME)||'%')
--        AND     UPPER(NVL(POV.VENDOR_TYPE_LOOKUP_CODE,'VENDOR')) 
--                                                   LIKE  UPPER('%'||NVL(&TIPO_FORNECEDOR,NVL(POV.VENDOR_TYPE_LOOKUP_CODE,'VENDOR'))||'%')
            AND aea.event_type_code = 'INVOICE'
            AND aea.source_table = 'AP_INVOICES'
            AND aea.source_id = aia.invoice_id
            AND trunc(aea.accounting_date) <= trunc(to_date(&pdata, 'DD-MM-RRRR'))
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    apps.ap_invoices_all            ai2,
                    apps.ap_accounting_events_all   ae2
                WHERE
                    ai2.org_id = 4719
                    AND ai2.vendor_id = aia.vendor_id
                    AND ai2.vendor_site_id = aia.vendor_site_id
                    AND ai2.invoice_id = aia.invoice_id
                    AND ai2.cancelled_date IS NOT NULL
                    AND ai2.invoice_id = ae2.source_id
                    AND ae2.event_type_code = 'INVOICE CANCELLATION'
                    AND ae2.source_table = 'AP_INVOICES'
                    AND trunc(ae2.accounting_date) <= trunc(to_date(&pdata, 'DD-MM-RRRR'))
            )
--------------------------------------------------------------------------------
            AND NOT EXISTS (
                SELECT
                    'X'
                FROM
                    apps.ap_invoices_all nff
                WHERE
                    nff.org_id = 4719
                    AND nff.cancelled_date IS NOT NULL
                    AND NOT EXISTS (
                        SELECT
                            *
                        FROM
                            apps.ap_accounting_events_all aae
                        WHERE
                            aae.org_id = 4719
                            AND aae.event_type_code = 'INVOICE CANCELLATION'
                            AND nff.invoice_id = aae.source_id
                    )
                    AND nff.invoice_id = aia.invoice_id
            )
--------------------------------------------------------------------------------
            AND aia.invoice_id = aip.invoice_id (+)
            AND aia.invoice_id = pre.invoice_id (+)
    ) xxx
WHERE
    xxx.saldo_original <> 0
ORDER BY
    xxx.fornecedor,
    xxx.site_for,
    xxx.num_titulo
