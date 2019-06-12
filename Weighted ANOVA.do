reg hospital1 micro_metro adj_rural remote_rural [w=Distinct_Beneficiaries__non_LUPA]
test micro_metro adj_rural remote_rural 

foreach var of varlist emergency1 star_num daily_score pain_score harm_score /*
*/ wound_score percent_female percent_non_white percent_dual Average_HCC_Score /*
*/ Average_Number_of_Total_Visits_P not_for_profit tenure percap_hosp_bed15 /*
*/percap_pcp_15 poverty Distinct_Beneficiaries__non_LUPA {
reg `var' micro_metro adj_rural remote_rural [w=Distinct_Beneficiaries__non_LUPA]
test micro_metro adj_rural remote_rural 
}
