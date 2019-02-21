
option symbolgen;

libname pos 'X:\Data\POS\2015\Data';

%include 'E:\SAS Macros\infile macros\sort.sas';

data pos;
	set pos.pos_2015;
		where PRVDR_CTGRY_SBTYP_CD = "01";

		keep GNRL_CNTL_TYPE_CD FIPS_STATE_CD FIPS_CNTY_CD BED_CNT  CRTFCTN_DT prvdr_num ;
			
					run;
%sort(pos,PRVDR_NUM)

proc import datafile = "E:\puffiles\puf2015v2"
dbms = xlsx out = puf_2015 replace;
run;

data puf_merge ;
	set puf_2015;
	/*keep Provider_ID Distinct_Beneficiaries__non_LUPA episodes_per_bene Average_Number_of_Total_Visits_P Dual_Beneficiar White_Beneficiar Male Average_HCC_Score  percent_non_white percent_female percent_dual;
		*/
		array puf (3)   Dual_Beneficiaries White_Beneficiaries Male_Beneficiaries ;
		array char_puf (3)   Dual_Beneficiar White_Beneficiar Male ;

			do i = 1 to 3;

				if puf(i) = "*" then puf(i)= ".";
				char_puf(i) = input(puf(i), 10.);

			end;

		PRVDR_NUM = put(provider_id, 10. -l);

		percent_female = ((Distinct_Beneficiaries__non_LUPA - Male)/Distinct_Beneficiaries__non_LUPA)*100;
		percent_dual = (Dual_Beneficiar/Distinct_Beneficiaries__non_LUPA)*100;
		percent_non_white = ( ( Distinct_Beneficiaries__non_LUPA - White_Beneficiar)/Distinct_Beneficiaries__non_LUPA)*100;
		episodes_per_bene =  Distinct_Beneficiaries__non_LUPA/VAR7;
run;

%sort(puf_merge, PRVDR_NUM)

data pos_puf;
merge puf_merge (in = a) pos (in = b);
by PRVDR_NUM;
	if a;
	if b;
run;
