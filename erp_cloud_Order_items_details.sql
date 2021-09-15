SELECT DISTINCT
	odm.HEADER_ID
	,	dfl.SOURCE_ORDER_NUMBER order_number  
	,	dfl.ORDERED_QTY quantity   
    ,	dfl.STATUS_CODE STATUS
	,	dfl.FULFILL_ORG_ID inventory_ord_id     		  	       
    ,	dfl.ORDERED_UOM	unit_measure		   			 	
	,	dfl.INVENTORY_ITEM_ID inventory_item_id
	,	dfl.UNIT_SELLING_PRICE unit_price
	,	item.ITEM_NUMBER item_number
	,	item.UNIT_WEIGHT unit_weigth
	,	item.UNIT_WIDTH unit_width
	,	item.UNIT_HEIGHT unit_height
	,	item.UNIT_LENGTH unit_length
	FROM 
		DOO_HEADERS_ALL odm,
		DOO_FULFILL_LINES_ALL dfl,
		EGP_SYSTEM_ITEMS_B item
	WHERE
		odm.HEADER_ID = dfl.HEADER_ID
		AND dfl.INVENTORY_ITEM_ID = item.INVENTORY_ITEM_ID
and dfl.FULFILL_ORG_ID = item.ORGANIZATION_ID
AND ITEM.ENABLED_FLAG = 'Y'
AND dfl.STATUS_CODE = 'AWAIT_BILLING'
