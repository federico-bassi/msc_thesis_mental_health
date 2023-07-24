********************************************************************************
** DATASET CREATION
********************************************************************************
/* This code produces the dataset necessary for the analysis. In particular, I 
assume that the data downloaded from UK Data Service are stored in a path saved
as global "data_input". 
*/

version 12
clear all
set more off 
capture log close

********************************************************************************
* 1. PATH SWITCHERS
********************************************************************************
global fede = 2

if $fede ==1 {
	cd "/Volumes/maxone/Tesi/stata"
	global data_input = "/Volumes/maxone/Tesi/UKDA-6614-stata/stata/stata13_se"
	global data_output = "/Volumes/maxone/Tesi/dataset"
}
if $fede ==2 {
	cd "/Users/federicobassi/Desktop/DSE/TESI/stata"
	global data_input = "/Users/federicobassi/Desktop/DSE/TESI/UKDA-6614-stata.nosync/stata/stata13_se"
	global data_output= "/Users/federicobassi/Desktop/DSE/TESI/dataset.nosync"
}


********************************************************************************
* 2. COMBINING WAVES
********************************************************************************

/* Starting from the British Household Panel Survey (1991-2009), combine each cross-sectional dataset into a panel in long format. Retain only the variables of	interest; in particular, we choose:
IDENTIFIERS
(1) 	pipd: cross-wave person identifier
(2) 	hidp: houshold identifier
(3) 	istrtdaty: start of individual interview (year)
(4) 	istrtdatm: interview start date (month)

SOCIO-DEMOGRAPHICS
(5) 	sex: Respondent's sex based on data from the latest interview.
(6') 	mastat: marital status
(7) 	age_dv: Age, in completed years, at the time of interview
(8)		gor_dv: Government office region
(9)		nchild_dv: Number of own children in the household

EMPLOYMENT
(10)	jbstat: Current labour force status
(11)	jbhas: Did paid job last week
(12') 	jbsat_bh: Job satisfaction: overall

ETHNICITY
(13*) 	race: Ethnic group membership for waves BH01-BH12 (corresponding to the 1991
				Census ethnic group question)
(14*)	racel_bh: Ethnic group membership for waves BH13-BH18 (corresponding to the 2001
				Census ethnic group question)
				
EDUCATION
(15') 	hiqualb_dv: Highest qualification

INCOME
(16) 	fimngrs_dv: total monthly personal income gross	
(17) 	fimnlabgrs_dv: total monthly labour income gross

OUTCOMES
(18) 	scghq1_dv: Subjective wellbeing (GHQ): Likert
(19) 	scghq2_dv: Subjective wellbeing (GHQ): Caseness
(20')	lfsato: Satisfaction with: life overall

WEIGHTS
(21)	weights and survey design data

Repeat the same process for the UK Household Longitudinal Study (2009-present), 
retrieving the same varibles except from:
(6'')	mastat_dv: De facto marital status
(11'')	jbsat:  satisfaction with present job
(13*)	racel_dv: Ethnic group incorp. all waves, codings, modes and bhps
(15'')	hiqual_dv: Highest qualification, UKHLS & BHPS samples
(20'')	sclfsato: Satisfaction with life overall

The following variables are included only in the UKHLS and can therefore be used 
only for analysis starting from 2009:
(22)	sf12mcs_dv: SF-12 Mental Component Summary (PCS)
(23)	sf12pcs_dv: SF-12 Physical Component Summary (PCS)

*/

// Define a counter
local counter = 1

// Loop through each wave
foreach w in ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br{
	// Use the "indresp" of each wave
	use "$data_input/bhps/`w'_indresp", clear
	// Retain the variables of interest
	isvar pidp `w'_hidp `w'_istrtdaty `w'_istrtdatm ///
	`w'_sex `w'_mastat `w'_age_dv `w'_gor_dv `w'_nchild_dv ///
	`w'_jbstat `w'_jbhas  `w'_jbsat_bh ///
	`w'_race `w'_racel_bh  ///
	`w'_hiqualb_dv ///
	`w'_fimngrs_dv ///
	`w'_scghq1_dv `w'_scghq2_dv `w'_lfsato ///
	`w'_scghqa `w'_scghqb `w'_scghqc `w'_scghqd `w'_scghqe `w'_scghqf `w'_scghqg ///
	`w'_scghqh `w'_scghqi `w'_scghqj `w'_scghqk `w'_scghql ///
	`w'_strata `w'_psu `w'_indin91_xw `w'_indin99_xw `w'_indin01_xw
	keep `r(varlist)' 
	gen wave = .
	replace wave = `counter'
	// Generate a flag to indicate that the origin is "BHPS"
	gen origin = "BHPS"
	// Rename each variable by removing the substring "bw"
	rename `w'_* *
	// Save the file as "wtemp.dta"
	save `w'temp.dta, replace
	// Increase the counter
	local counter=`counter'+1
 }

// Repeat for UKHLS
foreach w in a b c d e f g h i j k l{
	use "$data_input/ukhls/`w'_indresp", clear
	isvar pidp `w'_hidp  `w'_istrtdaty `w'_istrtdatm ///
	`w'_sex `w'_mastat_dv `w'_age_dv `w'_gor_dv `w'_nchild_dv ///
	`w'_jbstat `w'_jbhas  `w'_jbsat ///
	`w'_racel_dv ///
	`w'_hiqual_dv ///
	`w'_fimngrs_dv ///
	`w'_health ///
	`w'_scghq1_dv `w'_scghq2_dv  `w'_sclfsato `w'_sf12mcs_dv `w'_sf12pcs_dv ///
	`w'_scghqa `w'_scghqb `w'_scghqc `w'_scghqd `w'_scghqe `w'_scghqf `w'_scghqg ///
	`w'_scghqh `w'_scghqi `w'_scghqj `w'_scghqk `w'_scghql ///
	`w'_strata `w'_psu `w'_indinus_xw `w'_indinub_xw `w'_indinui_xw
	keep `r(varlist)'	
	gen wave = .
	replace wave = `counter'
	gen origin = "UKHLS"
	rename `w'_* *
	save `w'temp.dta, replace
	local counter=`counter'+1
 }

// Use the first temporary file created, append all the others
use batemp, clear

foreach w in bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br a b c d e f g h ///
i j k l {
	append using `w'temp.dta	
}

// Sort and save
sort pidp wave
save "$data_output/panel_long.dta", replace

// Get rid of temporary files
foreach w in ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br a b c d e f g ///
h i j k l{
	erase `w'temp.dta
}

********************************************************************************
* 3. VARIABLE REFACTORING
********************************************************************************

// Label new variables
label var origin "BHPS/UKHLS wave"
label var wave "(Harmonized) survey wave"
label var sex "Gender"

** 3.1 Marital status
********************************************************************************
/* The two variables defining de facto present marital status for BHPS and UKHPS 
are clustered in a variables with 4 levels.

 The logic is the following:
- 1 "Married, Living as a couple, Civil partnership" 
- 2 "Divorced, Separated, Dissolved civil parntership, Separated from civil partner" 
- 3 "Widowed or Surviving civil partner" 
- 4 "Never married or Child under 16"
 */
 
gen marital_status = .
replace marital_status = 1 if (mastat==1 | mastat==2 | mastat==7 | mastat_dv==2 | mastat_dv==3 |mastat_dv==10)
replace marital_status = 2 if (mastat==4 | mastat==5 | mastat==8 | mastat==9 | mastat_dv==4 | mastat_dv==5 | mastat_dv==7 | mastat_dv==8)
replace marital_status = 3 if (mastat==3 | mastat==10 | mastat_dv==6 | mastat_dv==9)
replace marital_status = 4 if (mastat==6 | mastat_dv==1 | mastat==0)

label define marital_status 1 "Married/In a couple" 2 "Divorced/Separated" 3 "Widowed" 4 "Never married"
label value marital_status marital_status
label var marital_status "Present de facto marital status"



// In a relationship
gen in_a_relationship = .
replace in_a_relationship = 0 if marital_status == 1
replace in_a_relationship = 1 if (marital_status==2 | marital_status==3)
replace in_a_relationship = 2 if marital_status == 4
label var in_a_relationship "Marital status"

label define in_a_relationship 0 "In a relationship" 1 "Not in a rel. anymore" 2 "Never married"
label val in_a_relationship in_a_relationship

gen in_a_relationship_b = .
replace in_a_relationship_b = 0 if (marital_status != 1 & marital_status > 0)
replace in_a_relationship_b = 1 if (marital_status == 1) 

label define in_a_relationship_b 0 "Not in a relationship" 1 "In a relationship"
label val in_a_relationship_b in_a_relationship_b
label var in_a_relationship_b "In a relationship"

** 3.2 Age 
********************************************************************************
// Categorical variable
gen age = .
replace age = 1 if (age_dv >= 15 & age_dv < 20)
replace age = 2 if (age_dv >= 20 & age_dv < 25)
replace age = 3 if (age_dv >= 25 & age_dv < 30)
replace age = 4 if (age_dv >= 30 & age_dv < 35)
replace age = 5 if (age_dv >= 35 & age_dv < 40)
replace age = 6 if (age_dv >= 40 & age_dv < 45)
replace age = 7 if (age_dv >= 45 & age_dv < 50)
replace age = 8 if (age_dv >= 50 & age_dv < 55)
replace age = 9 if (age_dv >= 55 & age_dv < 60)
replace age = 10 if (age_dv >= 60 & age_dv < 65)
replace age = 11 if (age_dv >= 65 & age_dv < 70)
replace age = 12 if (age_dv >= 70 & age_dv < 75)
replace age = 13 if (age_dv >= 75 & age_dv < 80)
replace age = 14 if (age_dv >= 80)

label define age 1 "15-19 y.o." 2 "20-24 y.o." 3 "25-29 y.o." ///
4 "30-34 y.o." 5 "35-39 y.o." 6 "40-44 y.o." ///
7 "45-49 y.o." 8 "50-54 y.o." 9 "55-59 y.o." ///
10 "60-64 y.o." 11 "65-69 y.o." 12 "70-74 y.o." ///
13 "75-79 y.o." 14 "80+ y.o."

label value age age
label var age "Age at Date of Interview"

// Binary variable 
gen over_65 = .
replace over_65 = 0 if (age_dv < 65 & age_dv > 0)
replace over_65 = 1 if age_dv >= 65
label var over_65 "Over 65 y.o."

** 3.3 Children
********************************************************************************
gen own_child_in_house = .
replace own_child_in_house = 0 if nchild_dv == 0
replace own_child_in_house = 1 if nchild_dv > 1

label define own_child_in_house 0 "No own child in ouse" 1 "Own child in house"
label value own_child_in_house own_child_in_house
label var own_child_in_house "Own child in house"

** 3.4 Current employment situation
********************************************************************************
/* The variable defining current employment situation is re-defined based on 5
different levels. 
- Level 1: Self Employed, Employed, Materity leave, Family business, Temporarily Laid Off/Short term working, Furlough, Retired; 
- Level 2: FT Student;
- Level 3: Retired;
- Level 4: Unemployed;
- Level 5: LT sick or disabled, Family Care.
*/

gen lab_force_status = .

replace lab_force_status = 1 if (jbstat ==1 | jbstat==2|jbstat==5|jbstat==6| /// 
								jbstat==10|jbstat==12|jbstat==13| jbstat==3)
replace lab_force_status = 2 if (jbstat==7|jbstat==9|jbstat==11) //student|gvm_training| apprentship 
replace lab_force_status = 3 if (jbstat==3) // unemployed
replace lab_force_status = 4 if (jbstat==8) // LT sick, disabled 

label define lab_force_status 1 "Employed/Retired"  2 "Student/Training" 3 "Not employed" 4 "L.T. Sick/Disabled"

label value lab_force_status lab_force_status


// Binary variable for unemployed
gen unemployed = .
replace unemployed = 1 if jbstat == 3 
replace unemployed = 0 if (jbstat!=3 & jbstat >0)

lab define unemployed 0 "Employed/In education/Retired" 1 "Unemployed"
lab values unemployed unemployed
label var unemployed "Unemployed"


// Binary variable for unemployed/sick
gen unemployed_student_sick = .
replace unemployed_student_sick = 1 if (jbstat == 3 | jbstat==8 | jbstat==7| ///
										jbstat==9 | jbstat==11)
replace unemployed_student_sick = 0 if (jbstat==1|jbstat==2|jbstat==5|jbstat==6| ///
										jbstat==10|jbstat==12|jbstat==13| jbstat==3)

lab define unemployed_student_sick 0 "Employed/In education/Retired" 1 "Unemployed/L.T. Sick/Student"
lab values unemployed_student_sick unemployed_student_sick
label var unemployed_student_sick "Unemployed/L.T.Sick/Student"


** 3.5 Job satisfaction 
********************************************************************************
gen jobsat = .
replace jobsat = 1 if ((jbsat_bh < 4 & jbsat_bh > 0) | (jbsat < 4 & jbsat > 0))
replace jobsat = 2 if (jbsat_bh>4 | jbsat>4)
label define jobsat 1 "dissatisfied" 2 "satisfied"
label values jobsat jobsat
label var jobsat "Satisfied about present job"
drop jbsat_bh jbsat


** 3.6 Ethnicity
********************************************************************************
/* Create a binary variable "minority_b" if the person belongs to one of the following ethnic
group: 

- "race": Black-Carib, Black-African, Black-Other Indian, Pakistani, Bangladeshi, 
Chinese, Other ethnic grp

- "racel_bh": Mix W & B Caribbean, Mixed W & B African, Mix white and Asian, 
Other mixed b'ground, Asian/Brit Indian, Asian/Brit Pakistani, Asian/Brit 
Bangladeshi, Other Asian b'ground, Black/Brit Caribbean, Black/Brit African,  
Other Black b'ground, Chinese, Any other

- "racel_dv": white and black caribbean (mixed), white and black african (mixed), 
white and asian (mixed), any other mixed background (mixed), indian (asian or 
asian british), pakistani (asian or asian british), bangladeshi (asian or asian 
british), chinese (asian or asian british), any other asian background (asian or 
asian british), caribbean (black or black british), african (black or black 
britih), any other black background (black or black britih), arab (other ethnic
 group), any other ethnic group (other ethnic group).
 
 
For the analysis 2009-present, create a categorical variable "minority_c", clustering
the minorities group in 7 major groups: White, Indian, Pakistani, Bangladeshi, Carribean, 
Adrican and Other Minorities. 
*/

// Binary varible
gen minority_b = 1
replace minority_b = 2 if (race > 1 & race != . )
replace minority_b = 2 if (racel_bh > 5 & racel_bh != .)
replace minority_b = 2 if (racel_dv > 4 & racel_dv != .)
replace minority_b = . if (race<0 | racel_bh<0 | racel_dv<0)

// Re-label values and variable
label define minority_b 1 "White" 2 "Minority"
label values minority_b minority_b
label var minority_b "Belongs to an ethnic minority group"

// Categorical variable
gen minority_c = .
replace minority_c = 1 if racel_dv == 1 | racel_dv == 2 | racel_dv == 3 ///
							| racel_dv == 4 
replace minority_c = 7 if racel_dv == 7 | racel_dv == 8 | racel_dv == 12 ///
							| racel_dv == 13 | racel_dv == 16 | racel_dv == 17 ///
							| racel_dv == 97
replace minority_c = 2 if racel_dv == 9
replace minority_c = 3 if racel_dv == 10
replace minority_c = 4 if racel_dv == 11
replace minority_c = 5 if racel_dv == 14
replace minority_c = 6 if racel_dv == 15

// Re-label values and variable
label define minority_c 1 "White" 2 "Indian" 3 "Pakistani" 4 "Bangladeshi" ///
						5 "Caribbean" 6 "African" 7 "Other minorities"
label values minority_c minority_c
label var minority_c "Belongs to an ethnic minority group"

drop race racel_bh racel_dv

** 3.7 Highest qualification
********************************************************************************
gen highest_qualification = . 
replace highest_qualification = 1 if (hiqualb_dv==9 | hiqual_dv==9 )
replace highest_qualification = 2 if (hiqualb_dv==5 | hiqual_dv==5)
replace highest_qualification = 3 if (hiqualb_dv==4 | hiqual_dv==4)
replace highest_qualification = 4 if (hiqualb_dv==3 | hiqual_dv==3)
replace highest_qualification = 5 if (hiqualb_dv==1 | hiqual_dv==1 | hiqualb_dv==2 | ///
										hiqual_dv==2)
										
// Re-label values and variable
label define highest_qualification 1 "No qualification" 2 "Other qualification" ///
				3 "GCSE etc." 4 "A level etc" 5 "Degree/Other High. Degree"
label values highest_qualification highest_qualification
label var highest_qualification "Highest qualification"

// carry forward the highest qualification variable
sort pidp wave
by pidp (wave): carryforward highest_qualification, gen(highest_qualification_cf)
replace highest_qualification = highest_qualification_cf if (missing(highest_qualification) & (hiqualb_dv >0) & (hiqual_dv >0))
drop hiqual_dv hiqualb_dv highest_qualification_cf


// Years of education variable
gen educ_years = .
replace educ_years = 6 if highest_qualification == 1
replace educ_years = 11 if highest_qualification == 2
replace educ_years = 11 if highest_qualification == 3
replace educ_years = 13 if highest_qualification == 4
replace educ_years = 17 if highest_qualification == 5

label var educ_years "Years of education"



** 3.8 Income
********************************************************************************
// Generate "mon_grs_income"
gen mon_grs_income = .
replace mon_grs_income = fimngrs_dv if (fimngrs_dv!=-7 & fimngrs_dv!=-9)

// Bottom-coding
_pctile fimngrs_dv, percentiles(0.001)
local bottom_code = r(r1)
di `bottom_code'
replace mon_grs_income = `bottom_code' if mon_grs_income < `bottom_code'

// Generate "mon_grs_income_thousands"
gen mon_grs_income_thousands = mon_grs_income/1000
drop  mon_grs_income
rename mon_grs_income_thousands mon_grs_income

label var mon_grs_income "Monthly gross income"


** 3.9 Mental Health and Life satisfaction
********************************************************************************
// Labeling
label var scghq1_dv "GHQ-12 Likert"
label var scghq2_dv "GHQ-12 Caseness"
label var sf12mcs_dv "SF-12 Mental CS"
label var sf12pcs_dv "SF-12 Physical CS"

// Generate a variable for life satisfaction
gen life_satisfaction = .
replace life_satisfaction = 1 if (lfsato==1 | sclfsato==1)
replace life_satisfaction = 2 if (lfsato==2 | sclfsato==2)
replace life_satisfaction = 3 if (lfsato==3 | sclfsato==3)
replace life_satisfaction = 4 if (lfsato==4 | sclfsato==4)
replace life_satisfaction = 5 if (lfsato==5 | sclfsato==5)
replace life_satisfaction = 6 if (lfsato==6 | sclfsato==6)
replace life_satisfaction = 7 if (lfsato==7 | sclfsato==7)

label define life_satisfaction 1 "Completely dissatisfied" 2 "Mostly dissatisfied" ///
		3 "Somewhat dissatisfied" 4 "Neither Sat nor Dissat" 5 "Somewhat satisfied" ///
		6 "Mostly satisfied" 7 "Completely satisfied"
label value life_satisfaction life_satisfaction
label var life_satisfaction "Satisfaction with life overall"
drop lfsato sclfsato


** 3.11 Time variables
********************************************************************************
/* Generate time variables for coefplot. In particular, we want to consider the 
period of the BHPS as decades/5-years period. The variable "time_1" aggregates 
the years 1991-2009, i.e. the years of the BHPS, in a decade window, while the 
variable "time_2" aggregates it in a 5-years window.*/

gen time_1 = .
replace time_1 = 1995 if (istrtdaty > 1990 & istrtdaty < 2000)
replace time_1 = 2005 if (istrtdaty >= 2000 & istrtdaty < 2009)
replace time_1 = istrtdaty if (istrtdaty >= 2009)

// label var time_1 "Decade in which the interview took place"

gen time_2 = .
replace time_2 = 1992 if (istrtdaty > 1990 & istrtdaty < 1995)
replace time_2 = 1997 if (istrtdaty >= 1995 & istrtdaty < 2000)
replace time_2 = 2002 if (istrtdaty >= 2000 & istrtdaty < 2005)
replace time_2 = 2006 if (istrtdaty >= 2005 & istrtdaty <= 2008)
replace time_2 = istrtdaty if (istrtdaty >= 2009)

// label var time_2 "Time variable for coefplot"

** 3.12 Health
********************************************************************************
recode health (2 = 0) (1 = 1)
lab define health 0 "No long-st. illness" 1 "Long st. illness"
label values health health

********************************************************************************
* 4. STANDARDIZE THE OUTCOMES
********************************************************************************
// Standardize life_satisfaction
summ life_satisfaction
local life_satisfaction_mean = r(mean)
local life_satisfaction_sd = r(sd)
gen life_satisfaction_std = (life_satisfaction - `life_satisfaction_mean') / `life_satisfaction_sd'

// Standardize LF-12
summ sf12mcs_dv 
local sf12mcs_dv_mean = r(mean)
local sf12mcs_dv_sd = r(sd)
gen sf12mcs_dv_std = (sf12mcs_dv - `sf12mcs_dv_mean') / `sf12mcs_dv_sd'

summ sf12pcs_dv 
local sf12pcs_dv_mean = r(mean)
local sf12pcs_dv_sd = r(sd)
gen sf12pcs_dv_std = (sf12pcs_dv - `sf12pcs_dv_mean') / `sf12pcs_dv_sd'

// Standardize scghq1_dv
summ scghq1_dv
local scghq1_dv_mean = r(mean)
local scghq1_dv_sd = r(sd)
gen scghq1_dv_std = (scghq1_dv - `scghq1_dv_mean') / `scghq1_dv_sd'

// Standardize scghq2_dv
summ scghq2_dv
local scghq2_dv_mean = r(mean)
local scghq2_dv_sd = r(sd)
gen scghq2_dv_std = (scghq2_dv - `scghq2_dv_mean') / `scghq2_dv_sd'

********************************************************************************
* 5. MISSING VALUES
********************************************************************************
mvdecode _all, mv(-10/-1)

********************************************************************************
* 6. WEIGHTS
********************************************************************************
/* Understanding Society provides different weights according to the type of analysis (see corresponding documentation). Londitudinal weights correct for design and non-response, 
meaning that weights will correct both for unequal selection probability and for 
individual-level non response. Cross-sectional weights correct for probability of 
selection.*/

// Weights for repeated-cross sectional. 
egen repeated_cross_w = rowmax(indin91_xw indin99_xw indin01_xw indinus_xw indinub_xw indinui_xw)
drop indin91_xw indin99_xw indin01_xw indinus_xw indinub_xw indinui_xw

// Weights for longitudinal analysis from 1991 (BHPS original sample)
merge m:1 pidp using "$data_input/ukhls/l_indresp", keepusing(l_indin91_lw)
drop _merge

// Weights for longitudinal analysis from 2001 (BHPS original sample + boosts)
merge m:1 pidp using "$data_input/ukhls/l_indresp", keepusing(l_indin01_lw)
drop _merge

// Weights for longitudinal analysis from 2009 (GPS & EMB)
merge m:1 pidp using "$data_input/ukhls/l_indresp", keepusing(l_indinus_lw)
drop _merge

********************************************************************************
* 7. SAVE
********************************************************************************
keep if istrtdaty<2022
save "$data_output/panel_long.dta", replace
