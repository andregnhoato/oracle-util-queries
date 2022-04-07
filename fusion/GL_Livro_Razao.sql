select    to_char(GJH.DEFAULT_EFFECTIVE_DATE,'DD-MON-YYYY') DATA_DEFAULT,
          GJL.JE_HEADER_ID           ID_LINHA,
          GJH.PERIOD_NAME            PERIODO_CONTABI,
          GJH.CURRENCY_CODE          MOEDA,
          GJB.JE_SOURCE              ORIGEM,
          GJH.NAME                   NOME_LANCAMENTO,
          GJH.JE_CATEGORY            CATEGORIA,
          GJL.JE_LINE_NUM            NUMERO_LINHA,
          GJL.DESCRIPTION            DESCRICAO_LINHA,
          GCC.SEGMENT1               EMPRESA,
          GCC.SEGMENT2               FILIAL,
          GCC.SEGMENT3               CCUSTO,
          GCC.SEGMENT4               CONTA,
          GCC.SEGMENT5               FAMILIA,
          GCC.SEGMENT6               PROJETO,
          GCC.SEGMENT7               INTERCOMPANY,
          GCC.SEGMENT8               FUTURO1,
          GCC.SEGMENT9               FUTURO2,
          GJB.NAME                   NOME_LOTE,
          to_char(GJH.DATE_CREATED,'DD-MON-YYYY')           DATA_LANCAMENTO,
          to_char(GJL.EFFECTIVE_DATE,'DD-MON-YYYY')         DATA_GL,
          GJL.ENTERED_DR DEBITO,
          GJL.ENTERED_CR CREDITO,
          GJL.ACCOUNTED_DR DEBITO_CONTABIL,
          GJL.ACCOUNTED_CR CREDITO_CONTABI,
          GJL.STATUS,
          ATIVO.OBS OBS,
          NVL(PROJETOAP.OBS, ATIVO.OBS) OBS,
    
          TO_CHAR(SUBSTR(PROJETOAP.OBS || ATIVO.OBS || NFRECEBER.NF,1,2999)) OBS,
          --NFRECEBER.NF,
          TO_CHAR(SUBSTR(PROJETOAP.LISTAPROJETO,1,2999)) LISTAPROJETO,
          NVL(NFAP.OBS,NVL(NFRECEBER.OBS,RECEBIMENTO.RECEIPT_NUMBER)) "OBS2",
          NFAP.INVOICE_NUM NF_AP,
          NFAP.CNPJ CNPJ_FORNECEDOR,
          NFAP.FORNECEDOR NOME_FORNECEDOR
                   
    from GL_JE_BATCHES        GJB,
         GL_JE_HEADERS        GJH,
         GL_JE_LINES          GJL,
         GL_CODE_COMBINATIONS GCC,
         -- O COMANDO ABAIXO PEGA A FRENTE E POJETO E AGRUPA EM UMA LINHA POIS O LANÇAMENTO NO GL É AGRUPADO POR CONTA E CUSTO
         (
         SELECT DISTINCT
                JE_LINE_NUM,
                JE_HEADER_ID,         
                RTRIM(XMLAGG(XMLELEMENT(E,OBS,' ').EXTRACT('//text()') ORDER BY OBS).GetClobVal(),' ') AS OBS,
                RTRIM(XMLAGG(XMLELEMENT(E,PROJETO,' ').EXTRACT('//text()')  ORDER BY PROJETO).GetClobVal(),' ') AS LISTAPROJETO

                FROM ( SELECT DISTINCT 
                              GLL.JE_LINE_NUM,
                              GLL.JE_HEADER_ID,
                              APD.DESCRIPTION "OBS",
                              'Projeto: ' || PJF_PROJECTS_ALL_VL.SEGMENT1 || ' - Frente: ' || PJF_TASKS_V.TASK_NUMBER  "PROJETO"
                         
                         FROM GL_LEDGERS GL ,
                              GL_JE_BATCHES GLB ,
                              GL_JE_HEADERS GLH ,
                              GL_JE_LINES GLL ,
                              GL_IMPORT_REFERENCES GLIR ,
                              XLA_AE_LINES XLL ,
                              XLA_AE_HEADERS XLH ,
                              XLA_EVENTS XLE ,
                              XLA_TRANSACTION_ENTITIES XLTE ,
                              XLA_DISTRIBUTION_LINKS XLDL ,
                              AP_INVOICES_ALL APH ,
                              AP_INVOICE_LINES_ALL APL ,
                              AP_INVOICE_DISTRIBUTIONS_ALL APD,
                              PJF_TASKS_V,
                              PJF_PROJECTS_ALL_VL
                         
                         WHERE GL.CHART_OF_ACCOUNTS_ID                    = GLB.CHART_OF_ACCOUNTS_ID
                           AND GL.PERIOD_SET_NAME                         = GLB.PERIOD_SET_NAME
                           AND GL.ACCOUNTED_PERIOD_TYPE                   = GLB.ACCOUNTED_PERIOD_TYPE
                           AND GLB.JE_BATCH_ID                            = GLH.JE_BATCH_ID
                           AND GLH.JE_HEADER_ID                           = GLL.JE_HEADER_ID
                           AND GLL.JE_HEADER_ID                           = GLIR.JE_HEADER_ID
                           AND GLL.JE_LINE_NUM                            = GLIR.JE_LINE_NUM
                           AND GLIR.GL_SL_LINK_TABLE                      = XLL.GL_SL_LINK_TABLE
                           AND GLIR.GL_SL_LINK_ID                         = XLL.GL_SL_LINK_ID
                           AND XLL.APPLICATION_ID                         = XLH.APPLICATION_ID
                           AND XLL.AE_HEADER_ID                           = XLH.AE_HEADER_ID
                           AND XLH.APPLICATION_ID                         = XLE.APPLICATION_ID
                           AND XLH.EVENT_ID                               = XLE.EVENT_ID
                           AND XLE.APPLICATION_ID                         = XLTE.APPLICATION_ID
                           AND XLE.ENTITY_ID                              = XLTE.ENTITY_ID
                           AND XLL.APPLICATION_ID                         = XLDL.APPLICATION_ID
                           AND XLL.AE_HEADER_ID                           = XLDL.AE_HEADER_ID
                           AND XLL.AE_LINE_NUM                            = XLDL.AE_LINE_NUM
                           AND XLTE.SOURCE_ID_INT_1                       = APH.INVOICE_ID
                           AND APH.INVOICE_ID                             = APL.INVOICE_ID
                           AND APL.INVOICE_ID                             = APD.INVOICE_ID
                           AND APL.LINE_NUMBER                            = APD.INVOICE_LINE_NUMBER
                           AND XLDL.SOURCE_DISTRIBUTION_ID_NUM_1          = APD.INVOICE_DISTRIBUTION_ID
                           AND APD.PJC_TASK_ID                            = PJF_TASKS_V.TASK_ID
                           AND APD.PJC_PROJECT_ID                         = PJF_PROJECTS_ALL_VL.PROJECT_ID
                           AND PJF_PROJECTS_ALL_VL.OBJECT_VERSION_NUMBER  = (SELECT MAX(PVL.OBJECT_VERSION_NUMBER) FROM PJF_PROJECTS_ALL_VL PVL WHERE PVL.PROJECT_ID = PJF_PROJECTS_ALL_VL.PROJECT_ID)
                           AND GLL.ENTERED_DR                            IS NOT NULL
                      )

           GROUP BY JE_LINE_NUM,
                    JE_HEADER_ID
         ) "PROJETOAP",

         (SELECT GJL.JE_LINE_NUM,
                 GJL.JE_HEADER_ID,
                 'Ativo: ' || FAB.ASSET_NUMBER || ' - ' || FTL.DESCRIPTION "OBS"
          FROM 
                GL_JE_LINES GJL,
                GL_JE_HEADERS GJH,
                GL_IMPORT_REFERENCES GIR,
                XLA_AE_LINES XAL,
                XLA_AE_HEADERS XAH,
                FA_TRANSACTION_HEADERS FTH,
                FA_ADDITIONS_B FAB,
                FA_ADDITIONS_TL FTL
         
          WHERE 0=0 
            AND GJH.JE_HEADER_ID                 =GJL.JE_HEADER_ID
            AND GJH.JE_HEADER_ID                 =GIR.JE_HEADER_ID
            --AND GJL.JE_LINE_ID=GIR.JE_LINE_ID
            AND GJL.JE_LINE_num                  =GIR.JE_LINE_num
            AND GIR.GL_SL_LINK_ID                =XAL.GL_SL_LINK_ID
            AND XAL.AE_HEADER_ID                 =XAH.AE_HEADER_ID
            AND XAH.EVENT_ID                     =FTH.EVENT_ID
            AND FTH.asset_id                     =FAB.asset_id
            AND FTL.LANGUAGE                     = 'PTB'
            AND FAB.ASSET_ID                     = FTL.ASSET_ID
         ) "ATIVO",

         (SELECT DISTINCT
                 GL_JE_LINES.JE_LINE_NUM,
                 GL_JE_LINES.JE_HEADER_ID,
                 RA_CUSTOMER_TRX_ALL.ATTRIBUTE1 "NF",
                 'Transação: ' || RA_CUSTOMER_TRX_ALL.TRX_NUMBER "OBS"
            FROM RA_CUSTOMER_TRX_ALL,
                 RA_CUST_TRX_LINE_GL_DIST_ALL,
                 XLA_DISTRIBUTION_LINKS,
                 XLA_AE_HEADERS,
                 XLA_AE_LINES,
                 GL_IMPORT_REFERENCES,
                 GL_JE_LINES
          
           WHERE RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID                    = RA_CUST_TRX_LINE_GL_DIST_ALL.CUSTOMER_TRX_ID
             AND RA_CUST_TRX_LINE_GL_DIST_ALL.CUST_TRX_LINE_GL_DIST_ID  = XLA_DISTRIBUTION_LINKS.SOURCE_DISTRIBUTION_ID_NUM_1
             AND XLA_DISTRIBUTION_LINKS.SOURCE_DISTRIBUTION_TYPE        = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
             AND XLA_AE_HEADERS.AE_HEADER_ID                            = XLA_DISTRIBUTION_LINKS.AE_HEADER_ID
             AND XLA_AE_LINES.AE_HEADER_ID                              = XLA_DISTRIBUTION_LINKS.AE_HEADER_ID
             AND XLA_AE_LINES.AE_LINE_NUM                               = XLA_DISTRIBUTION_LINKS.AE_LINE_NUM
             AND GL_IMPORT_REFERENCES.GL_SL_LINK_ID                     = XLA_AE_LINES.GL_SL_LINK_ID 
             AND GL_IMPORT_REFERENCES.GL_SL_LINK_TABLE                  = XLA_AE_LINES.GL_SL_LINK_TABLE
             AND GL_JE_LINES.JE_HEADER_ID                               = GL_IMPORT_REFERENCES.JE_HEADER_ID
             AND GL_JE_LINES.JE_LINE_NUM                                = GL_IMPORT_REFERENCES.JE_LINE_NUM
          ) "NFRECEBER", 
          
         (
                       SELECT DISTINCT 
                              GLL.JE_LINE_NUM,
                              GLL.JE_HEADER_ID,
                              'NF: ' || APH.INVOICE_NUM "OBS",
                              APH.INVOICE_NUM,
                               (select  vendor_site_code  from 
                    poz_supplier_sites_all_m pvs where pvs.vendor_site_id = aph.vendor_site_id) CNPJ,
                   (select ps.vendor_name from poz_suppliers_v ps where ps.vendor_id = aph.vendor_id) FORNECEDOR
                         
                         FROM GL_LEDGERS GL ,
                              GL_JE_BATCHES GLB ,
                              GL_JE_HEADERS GLH ,
                              GL_JE_LINES GLL ,
                              GL_IMPORT_REFERENCES GLIR ,
                              XLA_AE_LINES XLL ,
                              XLA_AE_HEADERS XLH ,
                              XLA_EVENTS XLE ,
                              XLA_TRANSACTION_ENTITIES XLTE ,
                              XLA_DISTRIBUTION_LINKS XLDL ,
                              AP_INVOICES_ALL APH ,
                              AP_INVOICE_LINES_ALL APL ,
                              AP_INVOICE_DISTRIBUTIONS_ALL APD
                         
                         WHERE GL.CHART_OF_ACCOUNTS_ID                    = GLB.CHART_OF_ACCOUNTS_ID
                           AND GL.PERIOD_SET_NAME                         = GLB.PERIOD_SET_NAME
                           AND GL.ACCOUNTED_PERIOD_TYPE                   = GLB.ACCOUNTED_PERIOD_TYPE
                           AND GLB.JE_BATCH_ID                            = GLH.JE_BATCH_ID
                           AND GLH.JE_HEADER_ID                           = GLL.JE_HEADER_ID
                           AND GLL.JE_HEADER_ID                           = GLIR.JE_HEADER_ID
                           AND GLL.JE_LINE_NUM                            = GLIR.JE_LINE_NUM
                           AND GLIR.GL_SL_LINK_TABLE                      = XLL.GL_SL_LINK_TABLE
                           AND GLIR.GL_SL_LINK_ID                         = XLL.GL_SL_LINK_ID
                           AND XLL.APPLICATION_ID                         = XLH.APPLICATION_ID
                           AND XLL.AE_HEADER_ID                           = XLH.AE_HEADER_ID
                           AND XLH.APPLICATION_ID                         = XLE.APPLICATION_ID
                           AND XLH.EVENT_ID                               = XLE.EVENT_ID
                           AND XLE.APPLICATION_ID                         = XLTE.APPLICATION_ID
                           AND XLE.ENTITY_ID                              = XLTE.ENTITY_ID
                           AND XLL.APPLICATION_ID                         = XLDL.APPLICATION_ID
                           AND XLL.AE_HEADER_ID                           = XLDL.AE_HEADER_ID
                           AND XLL.AE_LINE_NUM                            = XLDL.AE_LINE_NUM
                           AND XLTE.SOURCE_ID_INT_1                       = APH.INVOICE_ID
                           AND APH.INVOICE_ID                             = APL.INVOICE_ID
                           AND APL.INVOICE_ID                             = APD.INVOICE_ID
                           AND APL.LINE_NUMBER                            = APD.INVOICE_LINE_NUMBER
                           AND XLDL.SOURCE_DISTRIBUTION_ID_NUM_1          = APD.INVOICE_DISTRIBUTION_ID
                           AND GLL.ENTERED_DR                            IS NOT NULL
         ) "NFAP",
         
      (SELECT DISTINCT
                 GJH.JE_HEADER_ID,
                 GJL.JE_LINE_NUM,
                 'Recebimento: ' || ACR.RECEIPT_NUMBER RECEIPT_NUMBER
            FROM GL_JE_HEADERS GJH,
                 GL_JE_LINES GJL,
                 GL_PERIODS GLP,
                 GL_IMPORT_REFERENCES IMP,
                 XLA_AE_LINES XAL,
                 XLA_AE_HEADERS XAH,
                 XLA_EVENTS XE,
                 XLA_TRANSACTION_ENTITIES XTE,
                 AR_CASH_RECEIPTS_ALL ACR
           WHERE 1 = 1
                 AND GJH.JE_HEADER_ID           = GJL.JE_HEADER_ID
                 AND GJH.PERIOD_NAME            = GLP.PERIOD_NAME
                 --AND GLP.ADJUSTMENT_PERIOD_FLAG > 'Y'
                 AND GJH.JE_SOURCE              = 'Receivables'
                 AND GJL.JE_HEADER_ID           = IMP.JE_HEADER_ID
                 AND GJL.JE_LINE_NUM            = IMP.JE_LINE_NUM
                 AND IMP.GL_SL_LINK_ID          = XAL.GL_SL_LINK_ID
                 AND IMP.GL_SL_LINK_TABLE       = XAL.GL_SL_LINK_TABLE
                 AND XAL.APPLICATION_ID         = XAH.APPLICATION_ID
                 AND XAL.AE_HEADER_ID           = XAH.AE_HEADER_ID
                 AND XAH.APPLICATION_ID         = XE.APPLICATION_ID
                 AND XAH.EVENT_ID               = XE.EVENT_ID
                 AND XE.APPLICATION_ID          = XTE.APPLICATION_ID
                 AND XTE.APPLICATION_ID         = 222
                 AND XE.ENTITY_ID               = XTE.ENTITY_ID
                 AND XTE.ENTITY_CODE            = 'RECEIPTS'
                 AND XTE.SOURCE_ID_INT_1        = ACR.CASH_RECEIPT_ID
          ) "RECEBIMENTO"
        
where GJB.JE_BATCH_ID           = GJH.JE_BATCH_ID
and     GJH.JE_HEADER_ID        = GJL.JE_HEADER_ID
and     GJL.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID

and GCC.SEGMENT1 in (:EMPRESA)
and GCC.SEGMENT2 in (:FILIAL)
and GCC.SEGMENT4 in (:CONTA)

and     GJL.EFFECTIVE_DATE >= :BEGIN_GL_DATE and GJL.EFFECTIVE_DATE <= :END_GL_DATE
and      GJB.JE_SOURCE       =   NVL (:ORIGEM,GJB.JE_SOURCE)

and     GJL.JE_LINE_NUM         = PROJETOAP.JE_LINE_NUM  (+)
and     GJL.JE_HEADER_ID        = PROJETOAP.JE_HEADER_ID (+)
And     GJL.JE_LINE_NUM         = ATIVO.JE_LINE_NUM  (+)
and     GJL.JE_HEADER_ID        = ATIVO.JE_HEADER_ID (+)
And     GJL.JE_LINE_NUM         = NFRECEBER.JE_LINE_NUM  (+)
and     GJL.JE_HEADER_ID        = NFRECEBER.JE_HEADER_ID (+)
and     GJL.JE_LINE_NUM         = NFAP.JE_LINE_NUM  (+)
and     GJL.JE_HEADER_ID        = NFAP.JE_HEADER_ID (+)
and     GJL.JE_LINE_NUM         = RECEBIMENTO.JE_LINE_NUM  (+)
and     GJL.JE_HEADER_ID        = RECEBIMENTO.JE_HEADER_ID (+)
