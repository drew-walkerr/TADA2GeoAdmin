/*Code created by Stephanie Beane and Russell Mansfield)*/

/*save ga_mort_18 dataset to H drive*/

libname gamort "C:\Users\awalk55\OneDrive - Emory University\Desktop\TADA Admin Geospatial Network\TADA2GeoAdmin"; 

/*Create formats based upon US MCR user guide*/
proc format;
value EDUCATION
1 = '8th grade or less'
2 = '9 -12th grade, no diploma'
3 = 'high school graduate or GED completed'
4 = 'some college credit, but no degree'
5 = 'Associate degree'
6 = 'Bachelor’s degree'
7 = 'Master’s degree'
8 = 'Doctorate or professional degree'
9 = 'Unknown';
value AGE_12REC 
1	=	'Under 1'
2	=	'1-4 years'
3	=	'5-14 years'
4	=	'15-24'
5	=	'25-34'
6	=	'35-44'
7	=	'45-54'
8	=	'55-64'
9	=	'65-74'
10	=	'75-84'
11	=	'85 and over'
12	=	'Age not stated';
value mn_name
1='January'
2='February'
3='March'
4='April'
5='May'
6='June'
7='July'
8='August'
9='September'
10='October'
11='November'
12='December'
.='Unknown';
value DoW
1	=	'Sunday'
2	=	'Monday'
3	=	'Tuesday'
4	=	'Wednesday'
5	=	'Thursday'
6	=	'Friday'
7	=	'Saturday'
9	=	'Unknown';
value MoD
1	=	'Accident'
2	=	'Suicide'
3	=	'Homicide'
4	=	'Pending investigation'
5	=	'Could not determine'
6	=	'Self-inflicted'
7	=	'Natural'
.   =	'Not specified';
*These values are to isolate our three catagories of interest for race/ethnicity in only one variable: Hispanic, non-hispanic white,
	non-hsipanic black, and other;
value RACETH_REC
1 = 'Hispanic' 2 = 'Hispanic' 3 = 'Hispanic' 4 = 'Hispanic' 5 = 'Hispanic' 9 = 'Hispanic'
6 = 'Non-hispanic White'
7 = 'Non-hispanic Black'
8 = 'Non-hispanic Other';
value RACE_3REC
1	=	'White'
2	=	'Races other than White or Black'
3	=	'Black';
value HISP_ORIG
100-199 = 'Non-Hispanic'
200-299 = 'Hispanic' 
996-999 = 'Unknown';
*In Ruhm 2016-18, place of death and status upon arrival to the hospital are separated into 2 catagorical variables, so we may want to do that later;
value place_status
1	=	'Hospital, clinic or Medical Center -Inpatient'
2	=	'Hospital, Clinic or Medical Center -Outpatient or admitted to Emergency Room'
3	=	'Hospital, Clinic or Medical Center -Dead on Arrival'
4	=	'Decedent’s home'
5	=	'Hospice facility'
6	=	'Nursing home/long term care'
7	=	'Other'
9	=	'Unknown';
/*value Record
1	=	'Resident (yes)'
2	=	'Nonresident (no)';*/
value Resident_Status
1	=	'Resident (yes)'
2	=	'Intrastate Resident (state is same, county is different)'
3	=	'Interstate Resident (state is different, but both in US)'
4	=	'Foreign Residents (Occurance in the US, but reside outside US';
value $ Marital
'S' = 'Never Married'
'M' = 'Married'
'W' = 'Widowed'
'D' = 'Divorced'
'U' = 'Status Unknown';
value OD_Cause
1	=	'Unintentional OD death'
2	=	'OD suicide'
3	=	'OD homicide'
4	=	'Undetermined OD death'
.	=	'Not an OD death';
value YesNoOD
1	=	'Yes'
0	=	'No'
.	=	'No record of drug';
run;
proc contents data=gamort.ga_mort_18;
run;
proc print data=gamort.ga_mort_18 (obs=10);
run;*/


*Main OD mortality flow;
data gamort.ga_od_18;
set gamort.ga_mort_18;
*Identify ICD-10 codes for overdose deaths as an underlyinf cause of death. oddeath=1 means ucd indicates OD;

/*X40	"Accidental poisoning by and exposure to nonopioid analgesics, antipyretics, and antirheumatics"								
	X41	"Accidental poisoning by and exposure to antiepileptic, sedative-hypnotic, antiparkinsonism, and psychotropic drugs, not elsewhere classified"								
	X42	"Accidental poisoning by and exposure to narcotics and psychodysleptics [hallucinogens], not elsewhere classified"								
	X43	Accidental poisoning by and exposure to other drugs acting on the autonomic nervous system								
	X44	"Accidental poisoning by and exposure to other and unspecified drugs, medicaments, and biological substances" */

if ucd = "X40" or ucd = "X41" or ucd = "X42" or ucd = "X43" or ucd = "X44" then do;
	oddeath=1; odint=1; *odint=1 will mean unintentional (accidental);
	end;

else if ucd = "X60" or ucd = "X61" or ucd = "X62" or ucd = "X63" or ucd = "X64" then do;
	oddeath=1; odint=2; *odint=2 will mean suicide;
	end;
else if ucd = "X85" then do;
	oddeath=1; odint=3; *odint=3 will mean homicide;
	end;
else if ucd = "Y10" or ucd = "Y11" or ucd = "Y12" or ucd = "Y13" or ucd = "Y14" then do;
	oddeath=1; odint=4; *odint=4 will mean undetermined;
	end;
else do;
	oddeath=0; odint=.;
	end;

*Check record-axis conditions for specific drug groups (multiple causes of deaths). oddrugid=1 means a drug was identified;
array ra_cond[*] ra_1cond--ra_20cond;
if whichc("T400", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_opioid=1; *oddeath_opioid means OD was due to any opioids;
	end;
else oddeath_opioid=0;
if whichc("T401", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_heroin=1; *oddeath_heroin means OD was due to heroin;
	end;
else oddeath_heroin=0;
if whichc("T402", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_natopioid=1; *oddeath_natopioid means OD was due to natural/semisynthetic opioids;
	end;
else oddeath_natopioid=0;
if whichc("T403", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_mdone=1; *oddeath_mdone means OD was due to methadone;
	end;
else oddeath_mdone=0;
if whichc("T404", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_synth=1; *oddeath_synth means OD was due to synthetic opioids;
	end;
else oddeath_synth=0;
if whichc("T405", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_cok=1; *oddeath_cok means OD was due to cocaine;
	end;
else oddeath_cok=0;
if whichc("T436", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_stim=1; *oddeath_stim means OD was due to psychostimulants with abuse potential;
	end;
else oddeath_stim=0;
if whichc("T406", of ra_cond[*]) > 0 then do;
	oddrugid=1;oddeath_uns=1; *oddeath_uns means OD was unspecified;
	end;
else oddeath_uns=0;
if oddrugid = . then oddrugid=0;

format
oddeath YesNoOD. odint OD_Cause. oddrugid YesNoOD. oddeath_opioid YesNoOD.
oddeath_heroin YesNoOD. oddeath_natopioid YesNoOD. oddeath_mdone YesNoOD. oddeath_synth YesNoOD.
oddeath_cok YesNoOD. oddeath_stim YesNoOD. oddeath_uns YesNoOD.
;
run;


/*Test code;*/
proc print data=gamort.ga_od_18 (obs=15);
where oddeath=1;
run;

*Distribution of types of OD deaths in GA in 2018;
proc freq data=gamort.ga_od_18;
where oddeath=1;
title "Underlying causes for OD deaths";
tables odint/missing;
run;

*Compare deaths with underlying cause recorded as death vs deaths where a drug is recorded as one of multiple causes of deaths; 
proc freq data=gamort.ga_od_18;
title "Sensitivity Analysis: Deaths with underlying cause for OD (oddeath) v Deaths with any record-axis drug code (oddrugid)";
tables oddeath*oddrugid/missing;
run;

*Distribution of drug-related deaths by the type of drug;

proc freq data=gamort.ga_od_18;
title "Drug codes for OD deaths";
tables oddeath_opioid oddeath_heroin oddeath_natopioid oddeath_mdone oddeath_synth
oddeath_cok oddeath_stim oddeath_uns;
run;

*Mean age for OD deaths;
proc means data=gamort.ga_od_18;
title "Age of OD deaths cases";
var age;
where oddeath=1;
run;

*OD deaths by other demographics;
proc freq data=gamort.ga_od_18;
title "OD deaths by demographics ";
tables race3r raceth hisp sex edu marital/missing ;
where oddeath=1;
run;

****sample code for calculating OD death rates pet 100K population;

*calculate totals for each type of OD and export to a new dataset;
proc means data =gamort.ga_od_18;
*class race3r; *this line will break out the results by race;
var oddeath_opioid oddeath_heroin oddeath_natopioid oddeath_mdone oddeath_synth
oddeath_cok oddeath_stim oddeath_uns;
output out=rate(drop=_type_ _freq_) sum= / autoname;
run;

*calculate rate per 100,000 pop-n for some types of ODs;
data rate;
set rate;
oddeath_her_rate = (oddeath_heroin_sum /10511131)*100000; *10511131 is total GA population sizein 2018 Heroin OD death rate;
run;
proc print data = rate;
var oddeath_her_rate;
run;
