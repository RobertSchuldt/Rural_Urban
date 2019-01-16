/*** Robert F Schuldt 12/5/2018****************************************************************
*** SAS Code of my program used to generate the data set for the Rural/Urban project***********
*This code is meant for Dr. Reid who will be assisting Dr. Hsueh-Fen Chen and I with analysis**
**********************************************************************************************/

/* First identify libraries we will be using*/
libname primary "E:\HHBVP\11-5-2018 2016 Redux";
libname ahrf "\\FileSrv1\CMS_Caregiver\DATA\HRRP\AHRF";
libname puf "E:\puffiles";

/* We will be using the year 2015 in many variable names*/

%let td = 2015; 
/* I use TD = The Date*/
/* A macro I am making that I can call to sort data whenever I need to without 
having to write out the whole statement */
proc options option = macro;
run;
%macro sort(dataset, sorted);
proc sort data = &dataset;
by &sorted;
run;

%mend sort;


/*Start with base data set of home health compare data from 2015. We need two files to 
create a complete data set because they measure different variables at different times*/

/*Quality measures not including hospitalization and emergency room visits*/
proc import datafile = "E:\HHBVP\11-5-2018 2016 Redux\2015_quality"
dbms = xlsx out = quality&td replace;
run;

/*Hospitlizations and ER visits*/
proc import datafile = "E:\HHBVP\11-5-2018 2016 Redux\2015_hosps"
dbms = xlsx out = hosp&td replace;
run;

/*Now we need to merge these two together in order to get the full set*/

data primary.full_&td;
merge hosp&td (in = a) quality&td (in = b);
by CMS_Certification_Number__CCN_;
if a;
if b;
run;
/* We have 12,011 observations after this first merge*/


/* To generate our Tenure variable we need to create a base MDY variable for us to calcuate off of
we will also use this to generate our ownership variable values*/
data date_&td;
	set primary.full_&td;
	/* Tenure Date*/
	tenure_base = mdy(12,21,2015);
		format tenure_base mmddyy10.;
	
	tenure = tenure_base - Date_Certified;
	tenure = tenure/365;

	/*Ownership*/
	%let nfp = %str(not_for_profit =1;) ;
	not_for_profit = 0;
	if Type_of_Ownership = "Government - State/ County" then &nfp and gov = 1;
	if Type_of_Ownership = "Government - Combination Government & Voluntary" then &nfp and gov = 1;
	if Type_of_Ownership = "Government - Local" then &nfp and gov = 1;
	if Type_of_Ownership = "Non - Profit Private" then &nfp and nfp = 1;
	if Type_of_Ownership = "Non - Profit Religious" then &nfp and nfp = 1;
	if Type_of_Ownership = "Non - Profit Other" then &nfp and nfp = 1;
	
	

	if Type_of_Ownership = "Proprietary"
	then for_profit = 1 and fp = 1;
		else for_profit = 0;
	

	/* High Quality Indicator*/

	if star = "4" or "5" then high_quality = 1;
	if star = "1" or "2" or "3" then high_quality = 0;
	if star ="." then high_quality = .;

run;

/* Now we create out ID variables to ensure that we calculate the correct measurements 
However, since we have completed this in the past, we know that the ID variable is redundant because
the agency has either ALL or NONE of the measurements for a particular composite score*/

data id_&td;
	set date_&td;
/* It keeps importing them as a character variable and I cannot just replace it using the input command resulting in this 
	large chunk of code to replace it*/

	array numeric (22) timely_manner taught_drugs check_falling check_depression  flu_shot pn_shot diab_footcare_talk check_pain
	treat_pain treat_heartfail doc_pressure_sore treat_pressure_sore check_risk_sores  walk bed bath drugs_mouth hospital emergency
	lesspain_move breathing wounds_heal;
	array place (22) timely_manner1 taught_drugs1 check_falling1 check_depression1  flu_shot1 pn_shot1 diab_footcare_talk1 check_pain1
	treat_pain1 treat_heartfail1 doc_pressure_sore1 treat_pressure_sore1 check_risk_sores1  walk1 bed1 bath1 drugs_mouth1 hospital1 emergency1
	lesspain_move1 breathing1 wounds_heal1;
	array id (22) timely_manner_id taught_drugs_id check_falling_id check_depression_id  flu_shot_id pn_shot_id diab_footcare_talk_id check_pain_id
	treat_pain_id treat_heartfail_id doc_pressure_sore_id treat_pressure_sore_id check_risk_sores_id walk_id bed_id bath_id drugs_mouth_id hospital_id emergency_id
	lesspain_move_id breathing_id wounds_heal_id;
		do i = 1 to 22;

			 place(i) = input(numeric(i) , 3.);

			 numeric(i) = place(i);
			 if id(i) = . then id(i) = 0;
			 if place(i) ge 1 then id(i) = 1;
			 	else id(i) = 0;
		end;
		
	run;

data composite_&td;
	set id_&td;

	/* Getting rid of the character variables*/
		drop timely_manner taught_drugs check_falling check_depression  flu_shot pn_shot diab_footcare_talk check_pain
		treat_pain treat_heartfail doc_pressure_sore treat_pressure_sore check_risk_sores  walk bed bath drugs_mouth hospital emergency
		lesspain_move breathing wounds_heal;


		label daily_score = "Activities of Daily Living";
		label harm_score = "Preventing Harm";
		label pain_score = "Managing Pain and Treating Symptoms";
		label wound_score = "Wound Care";
	/* Start generating my composite score*/
		/* Daily Score*/
			daily_sum = walk1+bed1+bath1;
			daily_div =walk_id + bed_id + bath_id;
			if daily_div = 0 then daily_div = .;
			daily_score = daily_sum/daily_div;

		/*Managing Pain and Treating Symptoms*/
			pain_sum = treat_pain1 + treat_heartfail1 + lesspain_move1 + breathing1;
			pain_div = treat_pain_id + treat_heartfail_id + lesspain_move_id + breathing_id;
			if pain_div = 0 then pain_div = .;
			pain_score = pain_sum/pain_div;

		/*Wound Score*/
			wound_sum = doc_pressure_sore1 + treat_pressure_sore1 + check_risk_sores1 + wounds_heal1;
			wound_div = doc_pressure_sore_id + treat_pressure_sore_id + check_risk_sores_id + wounds_heal_id;
			if wound_div = 0 then wound_div = . ;
			wound_score = wound_sum/wound_div;

		/*Harm Score*/
			harm_sum = timely_manner1 + taught_drugs1 + check_falling1 + check_depression1 + flu_shot1 + pn_shot1 +
			diab_footcare_talk1 + drugs_mouth1;
			harm_div = timely_manner_id + taught_drugs_id + check_falling_id + check_depression_id + flu_shot_id + pn_shot_id +
			diab_footcare_talk_id + drugs_mouth_id;
			if harm_div = 0 then harm_div = .;
			harm_score = harm_sum/harm_div;

run;

/*Checking that these scores make sense*/

proc means data = composite_&td
mean N nmiss ;
var harm_score pain_score wound_score daily_score;
title "Means of Composite Scores";
footnote "Created &sysdate9";
run;

/*Now I will merge in the Provider of Service file that I have cleaned up*/

proc import datafile = "E:\HHBVP\11-5-2018 2016 Redux\pos2"
dbms = xlsx out = pos2 replace;
run;

%sort(pos2,CMS_Certification_Number__CCN_)
%sort(composite_2015, CMS_Certification_Number__CCN_)

data hha_pos_&td;
	merge composite_&td (in = a) pos2 (in = b);
	by CMS_Certification_Number__CCN_;
	if a;
	if b;
	run;
/* We end up with 11874 Observations after the merge this matches my STATA work*/
/* One FIPS code needs to be changed because it was adjusted in future data*/
	data hha_pos_correct&td;
		set hha_pos_&td;
		if fips = "12086" then fips ="12025";
	run;
/* Now w e bring in the PUF file to get our information on race and HCC score */

proc import datafile = "E:\puffiles\puf2015v2"
dbms = xlsx out = puf_&td replace;
run;

data puf_merge (rename = (Provider_ID = CMS_Certification_Number__CCN_)) ;
	set puf_&td;
	keep Provider_ID Distinct_Beneficiaries__non_LUPA episodes_per_bene Average_Number_of_Total_Visits_P Dual_Beneficiar White_Beneficiar Male Average_HCC_Score  percent_non_white percent_female percent_dual;

		array puf (3)   Dual_Beneficiaries White_Beneficiaries Male_Beneficiaries ;
		array char_puf (3)   Dual_Beneficiar White_Beneficiar Male ;

			do i = 1 to 3;

				if puf(i) = "*" then puf(i)= ".";
				char_puf(i) = input(puf(i), 10.);

			end;

		percent_female = ((Distinct_Beneficiaries__non_LUPA - Male)/Distinct_Beneficiaries__non_LUPA)*100;
		percent_dual = (Dual_Beneficiar/Distinct_Beneficiaries__non_LUPA)*100;
		percent_non_white = ( ( Distinct_Beneficiaries__non_LUPA - White_Beneficiar)/Distinct_Beneficiaries__non_LUPA)*100;
		episodes_per_bene =  Distinct_Beneficiaries__non_LUPA/VAR7;
run;
		
%sort( puf_merge, CMS_Certification_Number__CCN_)

data puf_hha_pos&td;
merge  hha_pos_&td (in = a) puf_merge (in = b);
by CMS_Certification_Number__CCN_;
if a;
if b;
run;
/* End up with 10249 obs*/
 
/* Now I will import the AHRF file for 2016-2017.*/

data ahrf;
	set ahrf.ahrf_2017_2018;

	keep low_density urban micro_metro fips adj_rural remote_rural poverty unemployment income
		 percap_pcp_15 age_65_plus hha_count percap_hosp_bed14;  
			/* Making the rural encoding variables*/
				
				urban = 0;
				if f1255913 = "1" or f1255913 = "2" then urban = 1;

				micro_metro = 0;
				if f1255913 = "3" or f1255913 = "5" or f1255913 = "8" then micro_metro = 1;

				adj_rural = 0;
				if f1255913 = "4" or f1255913 = "6" or f1255913 = "7" then adj_rural = 1;

				remote_rural = 0;
				if f1255913 = "9" or f1255913 = "10" or f1255913 = "12" or f1255913 = "11" then remote_rural = 1;
				
				/* Adjusting two areas that CMS considers Urban but our Data does not*/

				if fips = "16083" or fips = "40047" then urban = 1;
			
			/*makeing FIPS variable*/

				fips = f00002;


			/* Per Cap Physicians */
				percap_pcp_15 = (f1467515/f1198415)*1000;

			/* Count of Home health agencies in county*/
				hha_count = f1321415;

			/*For Hospital Beds we had to use 2014 observation. This variable is VERY hard to get for some reason*/
				percap_hosp_bed15 = (F0892115/f1198415)*1000;

			/*Median House Hold Income*/
				income = f1322615;

			/* Poverty Rate*/
				poverty = f1332115;

			/* Unemployment */
				unemployment = f0679515;

			/*Population Aged 65+ */
				age_65_plus = f1408315/f1198415;

			/* Identifying counties with population density LT 6 */
				low_density = 0;
				if f1387610 <= 6 then low_density = 1;
				
	run;
%sort(ahrf, fips)
%sort(puf_hha_pos2015, fips)

data complete_set_&td;
merge puf_hha_pos&td (in = a) ahrf (in = b);
by fips;
if a;
if b;
run;
/* Adding in the CMS designated low density, high utlization counties*/

proc import datafile = "\\FileSrv1\CMS_Caregiver\DATA\Rural Urban Project\FIPS Codes and County Names and their rural add-on category"
dbms = xls out = high replace;
run;

data high_util (rename = (FIPS_State_and_County_Code__requ = fips));
	set high;
run;

%sort(high_util, fips)
%sort(complete_set_&td, fips)
data complete_high;
merge complete_set_&td (in = a) high_util ( in = b);
by fips;
if a;
run;



/* The above code should create the complete data set that was used for our analysis. Please let me know if you have any other questions
that I can answer for you.*/
data primary.complete_data_&td;
set complete_high;

run;


proc surveyreg data = primary.complete_data_&td;
cluster state;
weight Distinct_Beneficiaries__non_LUPA;
model hospital1 = micro_metro remote_rural adj_rural percent_non_white percent_female tenure not_for_profit poverty 
percap_hosp_bed14 percap_pcp_15 percent_dual;
run;

/* Requested regressions from Dr. Landes */




title 'Regression Models for Dr. Landes';
title2 'Order: M1 M2 M3 M4';

ods escapechar = '^';
goptions reset=all hsize=7in vsize=2in;
ods pdf file='\\FileSrv1\CMS_Caregiver\DATA\HRRP\Output\regression_output.pdf' 
startpage=no; 

ods pdf text = "^{newline 4}"; 
ods pdf text = "^{style [just=center]}Regression Output";

proc surveyreg data = primary.complete_data_&td;
model daily_score = micro_metro remote_rural adj_rural;
run;

proc surveyreg data = primary.complete_data_&td;
cluster state;
model daily_score = micro_metro remote_rural adj_rural;
run;

proc surveyreg data = primary.complete_data_&td;
weight Distinct_Beneficiaries__non_LUPA;
model daily_score = micro_metro remote_rural adj_rural;
run;

proc surveyreg data = primary.complete_data_&td;
cluster state;
weight Distinct_Beneficiaries__non_LUPA;
model daily_score = micro_metro remote_rural adj_rural ;
run;


ods pdf close;

proc format;
value id
0 = 'No'
1 = 'Yes'
;
run;

proc format;
value r
0 = 'Q1'
1 = 'Q2'
2 = 'Q3'
3 = 'Q4'
;
run;


title 'Dr. Chen Request for Utlization';
title2 'Impact of New Rural Payments Policy';

ods escapechar = '^';
goptions reset=all hsize=7in vsize=2in;
ods pdf file='\\FileSrv1\CMS_Caregiver\DATA\HRRP\Output\payment_policy.pdf' 
startpage=no;

proc freq;
table micro_metro*Rural_Add_on_Category adj_rural*Rural_Add_on_Category remote_rural*Rural_Add_on_Category;
format micro_metro id. adj_rural id. remote_rural id. ; 
run;

ods pdf close;

proc means;
var (not_for_profit for_profit)*Average_HCC_Score;
run;


/*

While this section of code works. A CMS data set was located that identies
the high utlization counties that we were looking for and attempting to 
create with this section of the program. Will keep on the end in case it
is needed in the future
****************************************************************************
title 'Dr. Chen Request for Utlization';
title2 'Impact of New Rural Payments Policy';

ods escapechar = '^';
goptions reset=all hsize=7in vsize=2in;
ods pdf file='\\FileSrv1\CMS_Caregiver\DATA\HRRP\Output\payment_policy_old.pdf' 
startpage=no; 

ods pdf text = "^{newline 4}"; 
ods pdf text = "^{style [just=center]}Tables";
proc rank  data = primary.complete_data_&td out = ranked groups = 4;
	var episodes_per_bene;
	ranks rank_ut;
run;



data payment_policy;
	set ranked;
proc freq; 
table (micro_metro adj_rural remote_rural)*rank_ut;
where micro_metro = 1 or adj_rural = 1 or remote_rural = 1;
format micro_metro id. adj_rural id. remote_rural id. rank_ut r.;
run;

proc freq;
table (low_density)*rank_ut;
where urban ne 1;
format low_density id. rank_ut r.;
run;

ods pdf close;
*/
proc freq;
table urban;
run;
