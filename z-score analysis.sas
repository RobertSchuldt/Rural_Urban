
options ls=110 ps=55 nodate nonumber formdlim=" " nocenter;
/* Change location to where the data reside. */ 
%let LOCATION = E:\HHBVP\11-5-2018 2016 Redux ;





/*
  010 - Importing the data. Renaming some variables.
        Keeping those variables to be used in analyses.
        Transforming ORIG dataset from short-wide to long-narrow. 
*/
proc import datafile="&LOCATION\updated data landes (01-30-2019).csv" out=ORIG0 replace;
 run;

data ORIG1;
 set ORIG0;
 keep STATE CMS_Certification_Number__CCN_  tenure not_for_profit hospital1 emergency1 daily_score harm_score pain_score wound_score 
 Distinct_Beneficiaries__non_LUPA Average_Number_of_Total_Visits_P Average_HCC_Score percent_female percent_dual percent_non_white urban
micro_metro adj_rural remote_rural percap_pcp_15 percap_hosp_bed15 poverty star ;
run;

data RENAME_ORIG1;
 set ORIG1;
 FourSTAR = (STAR ge 4);
 if REMOTE_RURAL = 1 then URB_RUR = '4 RemRural';
 else if URBAN = 1 then URB_RUR = '1 Urban';
 else if MICRO_METRO = 1 then URB_RUR = '2 MicroMet';
 else if ADJ_RURAL = 1 then URB_RUR = '3 AdjRural';
 else URB_RUR = " ";
 rename 
 CMS_Certification_Number__CCN_ = ID
 not_for_profit = NONPROF
 Distinct_Beneficiaries__non_LUPA = PATIENT_N
 Average_Number_of_Total_Visits_P = VISIT_AVG
 Average_HCC_Score = HCC_SCORE
 percent_female = FEMALE
 percent_dual = DUAL
percent_non_white = NON_WHITE
percap_pcp_15 = PCP
percap_hosp_bed15 = HOSP_BED;
run;
data LONG1;
 retain State ID MSR Y NONPROF TENURE  URB_RUR
  PATIENT_N VISIT_AVG FEMALE DUAL NON_WHITE HCC_SCORE  PCP HOSP_BED POVERTY URBAN	
  MICRO_METRO ADJ_RURAL REMOTE_RURAL;
 set RENAME_ORIG1;
 MSR = "EMERGENCY"; Y = emergency1; output;
 MSR = "HOSPITAL"; Y = hospital1; output;
 MSR = "DAILY"; Y = daily_score; output;
 MSR = "HARM"; Y = harm_score; output;
 MSR = "PAIN"; Y = pain_score; output;
 MSR = "WOUND"; Y = wound_score; output;
 MSR = "STAR"; Y = STAR; output;
 MSR = "4 STAR"; Y = FourSTAR; output;
 drop hospital1 emergency1 daily_score harm_score pain_score wound_score STAR FourSTAR ;
 run;

/*
  020 - For each measure, get mean & SD (without regard to anything else.)
        Create LONG2 - a merge of means & SDs into LONG1.
        Compute Z scores. Z = (Y - Y_mean) / Y_StdDev ;
        Then, in section 040, analyze Z as we do for Y. 
        Main output file from section 040 should be LSMTMP4_Z.
        Compare t-scores between LSMTMP4_Y and LSMTMP4_Z.  Are they the same?  
*/

 proc sql;
create table calc as 
select *, 
/*Using SAS SQL to calculate the means and STD because it 
be the best way to do it IMO considering the long structure 
of the data we have and the labeling of the MSR variable. 
With names that have spaces it is hard to throw into Macro 
language programming*/

mean(case
when MSR = "EMERGENCY" then Y else .
end) as mean_emergency,
std(case
when MSR = "EMERGENCY" then Y else .
end) as std_emergency,
mean(case
when MSR = "HOSPITAL" then Y else .
end) as mean_hospital,
std(case
when MSR = "HOSPITAL" then Y else .
end) as std_hospital,
mean(case
when MSR = "DAILY" then Y else .
end) as mean_daily,
std(case
when MSR = "DAILY" then Y else .
end) as std_daily,
mean(case
when MSR = "HARM" then Y else .
end) as mean_harm,
std(case
when MSR = "HARM" then Y else .
end) as std_harm,
mean(case
when MSR = "PAIN" then Y else .
end) as mean_pain,
std(case
when MSR = "PAIN" then Y else .
end) as std_pain,
mean(case
when MSR = "WOUND" then Y else .
end) as mean_wound,
std(case
when MSR = "WOUND" then Y else .
end) as std_wound,
mean(case
when MSR = "STAR" then Y else .
end) as mean_star,
std(case
when MSR = "STAR" then Y else .
end) as std_star,
mean(case
when MSR = "4 STAR" then Y else .
end) as mean_4star,
std(case
when MSR = "4 STAR" then Y else .
end) as std_4star

from LONG1;
quit;

data LONG2;
	set calc;

%let varmean = mean_emergency mean_hospital mean_daily mean_harm mean_pain mean_wound mean_star mean_4star;
%let vartd = std_emergency std_hospital std_daily std_harm std_pain std_wound std_star std_4star;

%macro zs();
%let i=1;
%let v1=%Scan(&varmean, &i);
%let v2=%Scan(&vartd, &i);
%do %while(&v1 ne );
	if Y = . then Z = .;
	else Z = (Y-&v1)/&v2;
%let i=%eval(&i+1);
%let v1=%scan(&varmean, &i);
%let v2=%scan(&vartd, &i);
%end;
%mend;

%zs
run;










 
/*
  030 - For each MSR, fitting 
  Y =      URB_RUR 
           FEMALE NON_WHITE DUAL
           HCC_SCORE VISIT_AVG TENURE NONPROF
           POVERTY HOSP_BED PCP   STATE 
*/
proc sort data=LONG1;
 by MSR STATE URB_RUR ID;
 run;

title1 "Model 2"; title2 "By MSR";
proc mixed data=LONG1;
 where MSR ne "4 STAR";
 by MSR;
 class URB_RUR (ref=first) STATE;
 model Y = URB_RUR 
           FEMALE NON_WHITE DUAL               /* Patient characteristics */
           HCC_SCORE VISIT_AVG TENURE NONPROF  /* HHA characteristics */
           POVERTY HOSP_BED PCP                /* Community characteristics */
           STATE / solution cl; 
 weight PATIENT_N;
 lsmeans URB_RUR / pdiff cl;
 ods output solutionf=SOLNtmp1 lsmeans=LSMtmp1 diffs=DIFFtmp1;
 ods listing exclude solutionf;
 run;
data SOLN_bM2;
 set SOLNtmp1;
 run;
data DIFFTMP2;
 set DIFFtmp1;
 if _URB_RUR ne '1 Urban' then delete;
 run;
data LSMTMP2;
 set LSMTMP1;
 if URB_RUR ne '1 Urban';
 run;
data LSMTMP3;
 set LSMTMP2;
 NON_URBAN = ESTIMATE;
 drop EFFECT ESTIMATE STDERR DF TVALUE PROBT;
 run;
proc sort data=LSMTMP3;
 by MSR URB_RUR;
 run;
data DIFFTMP3;
 merge DIFFTMP2 LSMTMP3;
 by MSR URB_RUR;
 URBAN = NON_URBAN - ESTIMATE;
 rename ESTIMATE = DIFF 
        STDERR = SE_DIFF
        LOWER = LOWER95 
        UPPER = UPPER95;
 run;
data DIFF_bM2;
 retain MSR URB_RUR NON_URBAN URBAN DIFF LOWER95 UPPER95 SE_DIFF DF TVALUE PROBT ;
 set DIFFTMP3;
 keep MSR URB_RUR NON_URBAN URBAN DIFF LOWER95 UPPER95 SE_DIFF DF TVALUE PROBT ;
 run;
data LSMTMP4_Y;
 set LSMTMP1;
 keep MSR URB_RUR ESTIMATE STDERR LOWER UPPER DF TVALUE ;
 run;
proc sort data=LSMTMP4_Y;
 by MSR URB_RUR;
 run;
proc export data=LSMTMP4_Y  outfile="&LOCATION\Model means for Urban-Rural groups.csv" replace; run; quit;

proc datasets; 
 delete DIFFTMP1-DIFFTMP3 LSMTMP1-LSMTMP3 SOLNTMP1;
 run;quit;
/*
  040 - For each MSR, fitting 
  Z =      URB_RUR 
           FEMALE NON_WHITE DUAL
           HCC_SCORE VISIT_AVG TENURE NONPROF
           POVERTY HOSP_BED PCP   STATE 
*/
 proc sort data=LONG2;
 by MSR STATE URB_RUR ID;
 run;
title1 "Model 2"; title2 "By MSR";
proc mixed data=Long2;
 where MSR ne "4 STAR";
 by MSR;
 class URB_RUR (ref=first) STATE;
 model Z = URB_RUR 
           FEMALE NON_WHITE DUAL               /* Patient characteristics */
           HCC_SCORE VISIT_AVG TENURE NONPROF  /* HHA characteristics */
           POVERTY HOSP_BED PCP                /* Community characteristics */
           STATE / solution cl; 
 weight PATIENT_N;
 lsmeans URB_RUR / pdiff cl;
 ods output solutionf=SOLNtmp1 lsmeans=LSMtmp1 diffs=DIFFtmp1;
 ods listing exclude solutionf;
 run;
 data SOLN_bM2;
 set SOLNtmp1;
 run;
data DIFFTMP2;
 set DIFFtmp1;
 if _URB_RUR ne '1 Urban' then delete;
 run;
data LSMTMP2;
 set LSMTMP1;
 if URB_RUR ne '1 Urban';
 run;
data LSMTMP3;
 set LSMTMP2;
 NON_URBAN = ESTIMATE;
 drop EFFECT ESTIMATE STDERR DF TVALUE PROBT;
 run;
proc sort data=LSMTMP3;
 by MSR URB_RUR;
 run;
data DIFFTMP3;
 merge DIFFTMP2 LSMTMP3;
 by MSR URB_RUR;
 URBAN = NON_URBAN - ESTIMATE;
 rename ESTIMATE = DIFF 
        STDERR = SE_DIFF
        LOWER = LOWER95 
        UPPER = UPPER95;
 run;
data DIFF_bM2;
 retain MSR URB_RUR NON_URBAN URBAN DIFF LOWER95 UPPER95 SE_DIFF DF TVALUE PROBT ;
 set DIFFTMP3;
 keep MSR URB_RUR NON_URBAN URBAN DIFF LOWER95 UPPER95 SE_DIFF DF TVALUE PROBT ;
 run;
data LSMTMP4_Z;
 set LSMTMP1;
 keep MSR URB_RUR ESTIMATE STDERR LOWER UPPER DF TVALUE ;
 run;
proc sort data=LSMTMP4_Z;
 by MSR URB_RUR;
 run;
proc export data=LSMTMP4_Z  outfile="&LOCATION\Model means for Urban-Rural groups zscore.csv" replace; run; quit;

proc datasets; 
 delete DIFFTMP1-DIFFTMP3 LSMTMP1-LSMTMP3 SOLNTMP1;
 run;quit;
