SELECT
    a.invoice_id,
  ---
    e.country                                                            "Country",
    g.flex_segment_value                                                 "GFR",
    l.displayed_field                                                    "Invoice Type (Category)",
    a.invoice_num                                                        "Invoice Number",
    decode(ap_invoices_pkg.get_posting_status(a.invoice_id), 'P', 'Partial', 'N', 'Unaccounted',
           'Y', 'Accounted')                                             "Accounting Status",
    to_char(a.invoice_date, 'DD/MM/YYYY')                                "Invoice Date",
    k.party_name                                                         "Vendor Name",
    c.segment1                                                           "Vendor Number",
    to_char(u.due_date, 'DD/MM/YYYY')                                    "Invoice Due Date",
    v.due_days                                                           "Due Days",
    a.invoice_currency_code                                              "Invoice Currency",
    a.invoice_amount                                                     "Invoice Amount",
    a.description                                                        "Invoice Description",
    CASE
        WHEN a.cancelled_date IS NOT NULL THEN
            'Cancelled'
        WHEN nvl(q.qty_active_holds, 0) > 0 THEN
            'On Hold'
        WHEN ( i.displayed_field = 'Not paid'
               AND a.approval_status = 'APPROVED' ) THEN
            'Ready for payment'
        ELSE
            i.displayed_field
    END                                                                  "Pay Status",
    a.amount_paid                                                        "Paid Invoice Amount",
    ( a.invoice_amount - nvl(a.amount_paid, 0) - nvl(ad.awt_amount, 0) ) "Amount Remaining",
    to_char(a.invoice_received_date, 'DD/MM/YYYY')                       "Invoice Received Date",
    d.vendor_site_code                                                   "Vendor Site",
    m.displayed_field                                                    "Vendor Type",
    n.segment1                                                           "PO Number",
    a.attribute10                                                        "URN",
    af.batch_name                                                        "Invoice Group",
    to_char(a.creation_date, 'DD/MM/YYYY')                               "Invoice Creation Date",
    o.name                                                               "Payment Terms",
    a.created_by                                                         "User Name",
--nvl(q.qty_active_holds,0) "Num Of Holds",
    CASE
        WHEN a.cancelled_date IS NOT NULL THEN
            0
        ELSE
            nvl(q.qty_active_holds, 0)
    END                                                                  "Num Of Holds",
    nvl(p.qty_holds, 0)                                                  "Num Of Released Holds",
    r.hold_lookup_code                                                   "Hold Code",
    r.hold_reason                                                        "Hold Reason",
    a.attribute9                                                         "Approval Method",
    s.distribution_set_name                                              "Distribution Set",
--ab.assignees 
    initcap(ab.approver_id)                                              "Owner (Approval)",
    t.displayed_field                                                    "Paygroup",
    u.payment_method_code                                                "Payment Method",
    to_char(y.check_date, 'DD/MM/YYYY')                                  "Last Pay Date",
--y.check_date "Last Pay Date",
    aa.invoice_num                                                       "Prepayment Invoice Number",
    y.check_number                                                       "Last Payment Document Number",
    trunc(sysdate) - trunc(a.creation_date)                              "Aging",
    w.report_heading1                                                    "Aging Bucket",
    a.source                                                             "Invoice Source",
    to_char(a.cancelled_date, 'DD/MM/YYYY')                              "Cancelled Date",
--nvl(ab.approval_status,'WF not initiated') 
    initcap(ab.response)                                                 "Approval Status",
    nvl(a.exchange_rate, 1)                                              "Rate",
    nvl(ad.awt_amount, 0)                                                "AWT Amount"
FROM
    ap_invoices_all             a,
    hr_all_organization_units_f b,
    poz_suppliers               c,
    poz_supplier_sites_all_m    d,
    hr_locations                e,
    hr_operating_units          f,
    gl_legal_entities_bsvs      g,
    xle_entity_profiles         h,
    ap_lookup_codes             i,
--ap_payment_schedules_all j,
    hz_parties                  k,
    ap_lookup_codes             l,
    poz_lookup_codes            m,
    po_headers_all              n,
    ap_terms                    o,
    (
        SELECT
            invoice_id,
            org_id,
            COUNT(*) qty_holds
        FROM
            ap_holds_all
        WHERE
            release_reason IS NOT NULL
        GROUP BY
            invoice_id,
            org_id
    )                           p,
    (
        SELECT
            invoice_id,
            org_id,
            COUNT(*) qty_active_holds
        FROM
            ap_holds_all
        WHERE
            release_reason IS NULL
        GROUP BY
            invoice_id,
            org_id
    )                           q,
    (
        SELECT
            invoice_id,
            org_id,
            hold_lookup_code,
            hold_reason
        FROM
            ap_holds_all
        WHERE
            ( invoice_id, org_id, hold_id ) IN (
                SELECT
                    invoice_id, org_id, MAX(hold_id)
                FROM
                    ap_holds_all
                WHERE
                    release_reason IS NULL
                GROUP BY
                    invoice_id,
                    org_id
            )
    )                           r,
    ap_distribution_sets_all    s,
    ap_lookup_codes             t,
    (
        SELECT
            invoice_id,
            org_id,
            payment_method_code,
            due_date,
            MAX(payment_num)
        FROM
            ap_payment_schedules_all
        GROUP BY
            invoice_id,
            org_id,
            payment_method_code,
            due_date
    )                           u,
    (
        SELECT
            term_id,
            due_days,
            COUNT(*)
        FROM
            ap_terms_lines
        GROUP BY
            term_id,
            due_days
    )                           v,
    (
        SELECT
            invoice_id,
            org_id,
            MAX(check_id) check_id
        FROM
            ap_invoice_payments_all
        GROUP BY
            invoice_id,
            org_id
    )                           x,
    ap_checks_all               y,
    ap_aging_period_lines       w,
    (
        SELECT DISTINCT
            a1.invoice_id,
            a1.prepay_invoice_id,
            a2.invoice_num
        FROM
            ap_invoice_lines_all a1,
            ap_invoices_all      a2
        WHERE
            a1.prepay_invoice_id IS NOT NULL
            AND a2.invoice_id = a1.prepay_invoice_id
    )                           aa,
    (
        SELECT
            invoice_id,
            approver_id,
            response,
            ROW_NUMBER() OVER (partition BY invoice_id ORDER BY creation_date DESC) AS rn
        FROM
            ap_inv_aprvl_hist_all
        WHERE
            history_type = 'DOCUMENTAPPROVAL'
    )                           ab,
    fun_all_business_units_v    ac,
    (
        SELECT
            invoice_id,
            org_id,
            abs(SUM(amount)) awt_amount
        FROM
            ap_invoice_lines_all
        WHERE
            line_type_lookup_code = 'AWT'
        GROUP BY
            invoice_id,
            org_id
    )                           ad,
    ap_batches_all              af
WHERE
        a.org_id = b.organization_id
    AND a.vendor_id = c.vendor_id
    AND a.vendor_site_id = d.vendor_site_id
    AND e.location_id = b.location_id
    AND h.transacting_entity_flag = 'Y'
    AND h.legal_entity_id = f.default_legal_context_id
    AND f.organization_id = b.organization_id
    AND g.legal_entity_id = h.legal_entity_id
    AND c.party_id = k.party_id
    AND i.lookup_type (+) = 'INVOICE PAYMENT STATUS'
    AND i.lookup_code (+) = a.payment_status_flag
    AND a.invoice_type_lookup_code (+) = l.lookup_code
    AND l.lookup_type (+) = 'INVOICE TYPE'
    AND m.lookup_code (+) = c.vendor_type_lookup_code
    AND m.lookup_type (+) = 'POZ_VENDOR_TYPE'
    AND n.po_header_id (+) = a.po_header_id
    AND o.term_id = a.terms_id
    AND p.invoice_id (+) = a.invoice_id
    AND p.org_id (+) = a.org_id
    AND q.invoice_id (+) = a.invoice_id
    AND q.org_id (+) = a.org_id
    AND r.invoice_id (+) = a.invoice_id
    AND r.org_id (+) = a.org_id
    AND s.distribution_set_id (+) = a.distribution_set_id
    AND s.org_id (+) = a.org_id
    AND t.lookup_code (+) = a.pay_group_lookup_code
    AND t.lookup_type (+) = 'PAY GROUP'
    AND u.invoice_id (+) = a.invoice_id
    AND u.org_id (+) = a.org_id
    AND v.term_id (+) = a.terms_id
    AND x.invoice_id (+) = a.invoice_id
    AND x.org_id (+) = a.org_id
    AND y.check_id (+) = x.check_id
    AND ( trunc(sysdate) - trunc(a.terms_date) ) >= w.days_start
    AND trunc(sysdate) - trunc(a.terms_date) <= w.days_to
    AND aa.invoice_id (+) = a.invoice_id
    AND ab.invoice_id (+) = a.invoice_id
    and ab.rn = 1
    AND ac.bu_id = a.org_id
    AND ac.bu_name IN ( :p_business_unit )
    AND to_char(a.creation_date, 'YYYY-MM-DD') >= :p_date_from
    AND to_char(a.creation_date, 'YYYY-MM-DD') <= nvl(:p_date_to, to_char(a.creation_date, 'YYYY-MM-DD'))
    AND ad.invoice_id (+) = a.invoice_id
    AND ad.org_id (+) = a.org_id
    AND af.batch_id (+) = a.batch_id
    and a.invoice_num = nvl(:p_invoice_num, a.invoice_num)
ORDER BY
    a.invoice_num
