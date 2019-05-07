local depen micro_metro adj_rural remote_rural percent_female percent_non_white percent_dual average_hcc_score average_number_of_total_visits_p not_for_profit tenure percap_hosp_bed15 percap_pcp_15 poverty

foreach var of varlist hospital1 emergency1 high_quality daily_score pain_score harm_score wound_score{

reg `var' `depen', cluster(state)

}

local depen percent_female percent_non_white percent_dual average_hcc_score average_number_of_total_visits_p not_for_profit tenure percap_hosp_bed15 percap_pcp_15 poverty
foreach var of varlist urban micro_metro adj_rural remote_rural { 
sum  hospital1 emergency1 high_quality daily_score pain_score harm_score wound_score `depen' if `var' ==1
}
