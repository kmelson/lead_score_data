Select
	nullif(t5.APLD_AMOUNT_FINANCED, 0) as amount_financed_cust,
	case
		when t2.APPL_SPON_ID = 3 then
			case
				when t9.funded_date is not null then 155.94 + IFNULL(t6.APDD_GAP_COST, 0) + IFNULL(t6.APDD_WARRANTY_COST, 0)
				when t9.closed_date is not null then 112.96
				when t9.approved_date is not null then 82.00
				else 11.53
			end
		when t2.APPL_SPON_ID in (1, 272, 655) then
			case
				when t9.funded_date is not null then 107.54 + IFNULL(t6.APDD_GAP_COST, 0) + IFNULL(t6.APDD_WARRANTY_COST, 0)
				when t9.closed_date is not null then 65.25
				when t9.approved_date is not null then 37.41
				else 4.19
			end
		when t2.APPL_SPON_ID = 212 then
			case
				when t9.funded_date is not null then 129.61 + IFNULL(t6.APDD_GAP_COST, 0) + IFNULL(t6.APDD_WARRANTY_COST, 0)
				when t9.closed_date is not null then 86.37
				when t9.approved_date is not null then 59.50
				else 5.80
			end
		else
			case
				when t9.funded_date is not null then 143.61 + IFNULL(t6.APDD_GAP_COST, 0) + IFNULL(t6.APDD_WARRANTY_COST, 0)
				when t9.closed_date is not null then 99.92
				when t9.approved_date is not null then 71.38
				else 5.85
			end
	end as app_cost,
    date_format(t2.APPL_CREATE_DT, '%d/%m/%Y') as app_date,
	t8.APPS_APPL_ID as app_id,
    month(t2.APPL_CREATE_DT) as app_month,
    year(t2.APPL_CREATE_DT) as app_year,
    t4.APBD_EX_MAIN_AUTO_HIST as auto_history,
    t4.APBD_EX_MAIN_AUTO as auto_tradelines,
    t4.APBD_EX_MAIN_BANKRUPTCY as bankruptcies,
    year(t2.APPL_CREATE_DT) - ifnull(t5.APLD_YEAR,0) as car_age,
	case when t5.APLD_YEAR between 1900 and year(curdate()) + 2 then t5.APLD_YEAR
		else year(t2.APPL_CREATE_DT)
	end as car_year,
    t4.APBD_EX_MAIN_CHARGE_OFF as charge_off,
    t4.APBD_EX_MAIN_COLLECTION as collection,
	t4.APBD_EX_HIST as credit_history,
    t4.APBD_EX_MAIN_BEACON as credit_score,
    concat(t3.APPU_FIRST_NAME, t3.APPU_LAST_NAME, t3.APPU_CUR_ZIP, t5.APLD_YEAR, t5.APLD_MAKE) as customer_id,
    case when t5.APLD_MONTHLY_PAYMENT = 300 then t4.APBD_EX_DEBT + 300
		when t5.APLD_MONTHLY_PAYMENT = 500 then t4.APBD_EX_DEBT + 500
		else t4.APBD_EX_DEBT
	end as debt,
	100 * (CASE t4.APBD_DEFAULT_BUREAU
			WHEN 'TU' THEN t4.APBD_TU_DEBT
			WHEN 'EQ' THEN t4.APBD_EQ_DEBT
			WHEN 'EX' THEN t4.APBD_EX_DEBT
			ELSE t4.APBD_EX_DEBT
			END + IF(t3.APPU_RESIDENCE_TYPE <> 'OWN', t3.APPU_MONTHLY_PAYMENT, 0))
			/
			(
			  t3.APPU_GROSS_MTH_INC + IF(t3.APPU_OTHER_MTH_INC > 0 AND (t3.APPU_OTHER_INC_SOURCE <> 'SPOUSE' OR t3.APPU_JT_APP <> 'YES'), t3.APPU_OTHER_MTH_INC, 0) +
			  IF(t3.APPU_JT_APP = 'YES', t3.APPU_JT_GROSS_MTH_INC, 0) + IF(t3.APPU_JT_APP = 'YES' AND t3.APPU_JT_OTHER_MTH_INC > 0 AND t3.APPU_JT_OTHER_INC_SOURCE <> 'SPOUSE', t3.APPU_JT_OTHER_MTH_INC, 0)
			)
	as debt_to_income,
    t3.APPU_CUR_EMP_TIME_Y as employed_time,
    case
		when t3.APPU_CUR_EMP_TYPE in ('Full-Time', 'FULL') then 'FULL TIME'
		when t3.APPU_CUR_EMP_TYPE = 'DISABILITY' then 'DISABLED'
		when t3.APPU_CUR_EMP_TYPE = 'PART-TIME' then 'PART TIME'
        when t3.APPU_CUR_EMP_TYPE is null then 'MISSING'
		else t3.APPU_CUR_EMP_TYPE
	end as employment_type,
    case when t6.APDD_FLAT_FEE is not null and t6.APDD_FLAT_FEE > 0 and t8.apps_status in ('COMPLETE','NOTIFICATION_OF_FUND') then 1
		else 0
	end as fee_flag,
    case when t6.APDD_GAP_SALE is not null and t6.APDD_GAP_SALE > 0 and t8.apps_status in ('COMPLETE','NOTIFICATION_OF_FUND') then 1
		else 0
	end as gap_flag,
    case when t6.APDD_WARRANTY_SALE is not null and t6.APDD_WARRANTY_SALE > 0 and t8.apps_status in ('COMPLETE','NOTIFICATION_OF_FUND') then 1
		else 0
	end as war_flag,
	case
		when t9.approved_date is not null then 1
		else 0
	end as flag_approved,
	case
		when t9.closed_date is not null then 1
		else 0
	end as flag_closed,
	case
		when t9.received_date is not null then 1
		else 0
	end as flag_received,
    case when t8.apps_status in ('COMPLETE','NOTIFICATION_OF_FUND') then IFNULL(t6.APDD_FLAT_FEE, 0) + IFNULL(t6.APDD_GAP_SALE, 0) + IFNULL(t6.APDD_WARRANTY_SALE, 0)
		else 0
	end as gross_revenue,
    t5.APLD_INTEREST as interest_rate,
    t5.APLD_LOAN_VALUE as loan_value,
	t5.APLD_MAKE as make,
	case
		when t5.APLD_MILEAGE REGEXP '^[0-9]+$' then t5.APLD_MILEAGE
		else 0
	end as mileage,
	t5.APLD_MONTHLY_PAYMENT as monthly_payment,
    t5.APLD_MSRP_VALUE as msrp,
    round(datediff(t2.APPL_CREATE_DT, STR_TO_DATE(t5.APLD_FIRST_PAYMENT,'%m/%d/%Y'))/30) as paid_term,
	replace(t5.APLD_CURRENT_PAYOFF, ',', '') as payoff,
    t4.APBD_EX_MAIN_PUBLIC as public_records,
	t3.APPU_RESIDENCE_TYPE as residence_ownership,
	t3.APPU_MONTHLY_PAYMENT as residence_payment,
    t3.APPU_CUR_TIME_Y as residence_time,
	nullif(t5.APLD_RETAIL_VALUE, 0) as retail_value,
    t4.APBD_EX_REVOLVING as revolving_debt,
    t2.APPL_SPON_ID as sponsor_id,
	case
		when t3.APPU_CUR_STATE = 51 then 'WY'
		else t3.APPU_CUR_STATE
	end as state,
    t5.APLD_TERM as term,
    t3.APPU_GROSS_MTH_INC as total_income,
    t5.APLD_TRADE_VALUE as trade_value,
    t4.APBD_EX_MAIN_TRADES as trades,
	case when t3.APPU_CUR_ZIP > 5 then left(t3.APPU_CUR_ZIP, 5)
		else t3.APPU_CUR_ZIP
	end as zip_code
from
    (select
        max(APPS_ID) as max_primary_key,
        APPS_APPL_ID
    from APPS_APP_STATUS
    group by APPS_APPL_ID) t1
left join APPS_APP_STATUS t8
    on t8.APPS_ID = t1.max_primary_key
left join APPU_APP_USER t3
	on t3.APPU_APPL_ID = t8.APPS_APPL_ID
left join APBD_APP_BASIC_DATA t4
	on t4.APBD_APPL_ID = t8.APPS_APPL_ID
left join APLD_APP_LOAN_DATA t5
	on t5.APLD_APPL_ID = t8.APPS_APPL_ID
left join APDD_APP_DEAL_DATA t6
	on t6.APDD_APPL_ID = t8.APPS_APPL_ID
left join APPL_APP t2
	on  t2.APPL_ID = t8.APPS_APPL_ID
left join (
	select
		APPS_APPL_ID,
		max(case when apps_status in ('WAITING') then APPS_CREATE_DT else null end) as submitted_date,
		min(case when apps_status in ('LENDER_APPROVED') then APPS_CREATE_DT else null end) as approved_date,
		max(case when apps_status in ('SENT_TO_CUSTOMER') then APPS_CREATE_DT else null end) as closed_date,
		max(case when apps_status in ('RECV_FROM_CUSTOMER') then APPS_CREATE_DT else null end) as received_date,
		min(case when apps_status in ('Complete', 'NOTIFICATION_OF_FUND') then APPS_CREATE_DT else null end) as funded_date
	from (
		(SELECT
			APPS_APP_STATUS.APPS_APPL_ID AS APPS_APPL_ID,
			APPS_APP_STATUS.APPS_STATUS AS apps_status,
			APPS_APP_STATUS.APPS_CREATE_DT AS APPS_CREATE_DT
		FROM
			APPS_APP_STATUS)
		UNION
        (SELECT
			APPD_APP_DECISION.APPD_APPL_ID AS APPS_APPL_ID,
			APPD_APP_DECISION.APPD_STATUS AS apps_status,
			APPD_APP_DECISION.APPD_MARK_DT AS APPS_CREATE_DT
		FROM
			APPD_APP_DECISION)) a
	group by APPS_APPL_ID) t9
	on t9.APPS_APPL_ID = t8.APPS_APPL_ID
where   t4.APBD_EX_MAIN_BEACON is not null
	and	t4.APBD_EX_MAIN_TRADES is not null
	and	t4.APBD_EX_MAIN_AUTO_HIST is not null
	and	t4.APBD_EX_MAIN_AUTO is not null
	and	t4.APBD_EX_MAIN_CHARGE_OFF is not null
	and	t4.APBD_EX_MAIN_REPO is not null
	and	t4.APBD_EX_MAIN_PUBLIC is not null
	and	t4.APBD_EX_MAIN_COLLECTION is not null
	and	t4.APBD_EX_MAIN_FORECLOSURE is not null
	and	t4.APBD_EX_MAIN_BANKRUPTCY is not null
	and t2.APPL_SPON_ID is not null
	and t8.apps_status in ('Complete','Killed','NOTIFICATION_OF_FUND')
