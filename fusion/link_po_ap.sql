SELECT d.segment1                        "PO NUMBER",
       a.invoice_id
  FROM ap_invoices_all              a,
       ap_invoice_distributions_all b,
       po_distributions_all         c,
       po_headers_all               d
      
 WHERE     a.invoice_id = b.invoice_id
       AND b.po_distribution_id = c.po_distribution_id(+)
       AND c.po_header_id = d.po_header_id(+)
       AND c.po_header_id IS NOT NULL
       --AND a.payment_status_flag = 'Y'
       AND d.type_lookup_code != 'BLANKET'
