SELECT zregim.tax_regime_code
     , ztb.tax_id
     , ztb.tax
     , zrb.tax_rate_code
     , zrb.tax_status_code
     , zrb.rate_type_code
     , zrb.percentage_rate
     , zrb.tax_jurisdiction_code
     , zrb.active_flag
     , zrb.tax_rate_id
     , zrb.inclusive_tax_flag
	 , 'TR' tax_type
	 , fnd_global.who_user_name user_name
     , zrca.reporting_code_char_value tax_type_code
	 , ''  awt_group_name
	 , zrca_rate.reporting_code_char_value  main_tax_flag	
     , zrca.effective_to
	 , zrb.content_owner_id
	 , zptp.party_type_code
     , DECODE(zptp.party_type_code, 'FIRST_PARTY', (SELECT xep.legal_entity_id
								                      FROM xle_entity_profiles xep
													 WHERE xep.party_id = zptp.party_id
                                                   )
                                  , zptp.party_id
	         ) owner_party_entity_id	
  FROM zx_report_codes_assoc     zrca
     , zx_reporting_codes_tl     zrct
     , zx_reporting_codes_b      zrcb
     , zx_reporting_types_tl     zrtt
     , zx_reporting_types_b      zrtb
     , zx_rates_b                zrb
     , zx_taxes_b                ztb
	 , zx_regimes_b              zregim
	 --
	 , zx_report_codes_assoc     zrca_rate
     , zx_reporting_codes_tl     zrct_rate
     , zx_reporting_codes_b      zrcb_rate
     , zx_reporting_types_tl     zrtt_rate
     , zx_reporting_types_b      zrtb_rate
	 --cacasant 03-09-2021
     , zx_regimes_vl             zrv
     , zx_regimes_usages         zru
     , zx_subscription_options   zso
     , zx_subscription_details   zsd
     , zx_party_tax_profile      zptp
 WHERE 1=1
   AND zregim.country_code                 = 'MX'
   AND TRUNC(SYSDATE)                      BETWEEN zregim.effective_from and NVL(zregim.effective_to, TRUNC(SYSDATE))
   --
   AND zrtb_rate.reporting_type_code       = 'LACLS_MX_EXPENSE_TAX_RATE'
   AND zrca_rate.entity_code               = 'ZX_RATES'
   AND zrtb_rate.has_reporting_codes_flag  = 'Y'
   AND zrtt_rate.language                  = userenv('LANG')
   AND zrct_rate.language                  = userenv('LANG')
   AND zrtb_rate.reporting_type_id         = zrtt_rate.reporting_type_id
   AND TRUNC(SYSDATE)                      BETWEEN zrtb_rate.effective_from and NVL(zrtb_rate.effective_to, TRUNC(SYSDATE))
   AND zrtb_rate.reporting_type_id         = zrcb_rate.reporting_type_id
   AND zrct_rate.reporting_code_id         = zrcb_rate.reporting_code_id
   AND TRUNC(SYSDATE)                      BETWEEN zrcb_rate.effective_from and NVL(zrcb_rate.effective_to, TRUNC(SYSDATE))
   AND zrcb_rate.reporting_code_id         = zrca_rate.reporting_code_id
   AND TRUNC(SYSDATE)                      BETWEEN zrca_rate.effective_from and NVL(zrca_rate.effective_to,TRUNC(SYSDATE))
   --
   AND zrv.tax_regime_id 		           = zru.tax_regime_id
   AND zru.regime_usage_id                 = zso.regime_usage_id
   AND zso.enabled_flag                    = 'Y'
   AND zso.subscription_option_id          = zsd.subscription_option_id
   AND zru.first_pty_org_id                = zsd.first_pty_org_id
   AND zru.first_pty_org_id                = zptp.party_tax_profile_id
   AND zptp.party_tax_profile_id           = zsd.parent_first_pty_org_id
   --
   AND zptp.party_tax_profile_id           = zrb.content_owner_id
   AND zrv.tax_regime_code                 = zregim.tax_regime_code
   --
 UNION ALL
   --
SELECT zregim.tax_regime_code
     , ztb.tax_id
     , ztb.tax
     , zrb.tax_rate_code
     , zrb.tax_status_code
     , zrb.rate_type_code
     , zrb.percentage_rate
     , zrb.tax_jurisdiction_code
     , zrb.active_flag
     , zrb.tax_rate_id
     , zrb.inclusive_tax_flag
	 , 'TR' tax_type
	 , fnd_global.who_user_name             user_name
     , zrca.reporting_code_char_value       tax_type_code
	 , ''                                   awt_group_name
	 , zrca_rate.reporting_code_char_value  main_tax_flag	
     , zrca.effective_to
	 , zrb.content_owner_id
	 , 'GCO'                                party_type_code
	 , zrb.content_owner_id                 owner_party_entity_id
  FROM zx_report_codes_assoc zrca
     , zx_reporting_codes_tl zrct
     , zx_reporting_codes_b  zrcb
     , zx_reporting_types_tl zrtt
     , zx_reporting_types_b  zrtb
     , zx_rates_b            zrb
     , zx_taxes_b            ztb
	 , zx_regimes_b          zregim
	 --
	 , zx_report_codes_assoc zrca_rate
     , zx_reporting_codes_tl zrct_rate
     , zx_reporting_codes_b  zrcb_rate
     , zx_reporting_types_tl zrtt_rate
     , zx_reporting_types_b  zrtb_rate
 WHERE zrtb.reporting_type_code       = 'LACLS_MX_EFD_TAX_TYPE'
   AND zrca.entity_code               = 'ZX_TAXES'
   AND zrb.active_flag                = 'Y'
   AND ztb.source_tax_flag            = 'Y'
   AND zrtb.has_reporting_codes_flag  = 'Y'
   AND zrtt.language                  = userenv('LANG')
   AND zrct.language                  = userenv('LANG')
   AND zrb.tax                        = ztb.tax
   AND ztb.tax_regime_code            = zrb.tax_regime_code
   AND zrtb.reporting_type_id         = zrtt.reporting_type_id
   AND TRUNC(SYSDATE)           BETWEEN zrtb.effective_from and NVL(zrtb.effective_to, TRUNC(SYSDATE))
   AND zrtb.reporting_type_id         = zrcb.reporting_type_id
   AND zrct.reporting_code_id         = zrcb.reporting_code_id
   AND TRUNC(SYSDATE)           BETWEEN zrcb.effective_from and NVL(zrcb.effective_to, TRUNC(SYSDATE))
   AND zrcb.reporting_code_id         = zrca.reporting_code_id
   AND TRUNC(SYSDATE)           BETWEEN zrca.effective_from and NVL(zrca.effective_to,TRUNC(SYSDATE))
   AND zrca.entity_id                 = ztb.tax_id
   AND TRUNC(SYSDATE)           BETWEEN ztb.effective_from and NVL(ztb.effective_to, TRUNC(SYSDATE))
   AND TRUNC(SYSDATE)           BETWEEN zrb.effective_from and NVL(zrb.effective_to, TRUNC(SYSDATE))
   AND zregim.country_code            = 'MX'
   AND zregim.tax_regime_code         = ztb.tax_regime_code
   AND TRUNC(SYSDATE)           BETWEEN zregim.effective_from and NVL(zregim.effective_to, TRUNC(SYSDATE))
   --
   AND zrtb_rate.reporting_type_code       = 'LACLS_MX_EXPENSE_TAX_RATE'
   AND zrca_rate.entity_code               = 'ZX_RATES'
   AND zrtb_rate.has_reporting_codes_flag  = 'Y'
   AND zrtt_rate.language                  = userenv('LANG')
   AND zrct_rate.language                  = userenv('LANG')
   AND zrtb_rate.reporting_type_id         = zrtt_rate.reporting_type_id
   AND TRUNC(SYSDATE)           BETWEEN zrtb_rate.effective_from and NVL(zrtb_rate.effective_to, TRUNC(SYSDATE))
   AND zrtb_rate.reporting_type_id         = zrcb_rate.reporting_type_id
   AND zrct_rate.reporting_code_id         = zrcb_rate.reporting_code_id
   AND TRUNC(SYSDATE)           BETWEEN zrcb_rate.effective_from and NVL(zrcb_rate.effective_to, TRUNC(SYSDATE))
   AND zrcb_rate.reporting_code_id         = zrca_rate.reporting_code_id
   AND TRUNC(SYSDATE)           BETWEEN zrca_rate.effective_from and NVL(zrca_rate.effective_to,TRUNC(SYSDATE))
   AND zrca_rate.entity_id                 = zrb.tax_rate_id
   --cacasant 03-09-2021
   AND zrb.content_owner_id                = -99
