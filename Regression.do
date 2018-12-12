/* Hospitalizations*/

reg hospital1  micro_metro remote_rural adj_rural  /*
*/ +  percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual , cluster(state)

outreg2 using updated_hospital.doc, replace

reg hospital1  micro_metro remote_rural adj_rural  average_number_of_total_visits_p/*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual , cluster(state)

outreg2 using updated_emergency.doc, append

/* Emergency*/

reg emergency1  micro_metro remote_rural adj_rural  /*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual , cluster(state)

outreg2 using updated_hospital.doc, replace

reg emergency1  micro_metro remote_rural adj_rural  average_number_of_total_visits_p/*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual , cluster(state)

outreg2 using updated_emergency.doc, append

/* ADL Score*/

reg daily_score  micro_metro remote_rural adj_rural  /*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_daily.doc, replace

reg daily_score  micro_metro remote_rural adj_rural  average_number_of_total_visits_p/*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_daily.doc, append

/*harm score*/
reg harm_score  micro_metro remote_rural adj_rural  /*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_harm.doc, replace

reg harm_score  micro_metro remote_rural adj_rural  average_number_of_total_visits_p/*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_harm.doc, append

/* Pain Score */


reg harm_score  micro_metro remote_rural adj_rural  /*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_harm.doc, replace

reg harm_score  micro_metro remote_rural adj_rural  average_number_of_total_visits_p/*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_harm.doc, append

/*Wound Score*/

reg wound_score  micro_metro remote_rural adj_rural  /*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_wound.doc, replace

reg wound_score  micro_metro remote_rural adj_rural  average_number_of_total_visits_p/*
*/ distinct_beneficiaries__non_lupa percent_non_white percent_female tenure /*
*/ not_for_profit poverty percap_hosp_bed14 percap_pcp_15 percent_dual average_hcc_score, cluster(state)

outreg2 using updated_wound.doc, append


