********************************************************************************
** Descriptive statistics
********************************************************************************
/* This code contains the descriptive statistics. To correctly execute the code, 
I assume that the dataset is contained in the "data" global.
*/

version 12
clear all
set more off 
capture log close

********************************************************************************
* 1. PATH SWITCHERS AND DIRECTORIES
********************************************************************************
global fede = 2

if $fede == 1 {
	cd "/Volumes/maxone/Tesi/stata"
	global data = "/Volumes/maxone/Tesi/dataset"
	global tavole = "/Volumes/maxone/Tesi/stata/tables"
	global graphs = "/Volumes/maxone/Tesi/stata/graphs"
}
if $fede == 2 {
	cd "/Users/federicobassi/Desktop/DSE/TESI/stata"
	global data= "/Users/federicobassi/Desktop/DSE/TESI/dataset.nosync"
	global tavole = "/Users/federicobassi/Desktop/DSE/TESI/stata/tables"
	global graphs = "/Users/federicobassi/Desktop/DSE/TESI/stata/graphs"
}


use "$data/panel_long.dta", clear

// Specify the weight
global weight_spec =  1
gen current_weight = .

if $weight_spec == 1 {
    replace current_weight = repeated_cross_w
}
else if $weight_spec == 2 {
    replace current_weight = l_indin91_lw
}
else if $weight_spec == 3 {
    replace current_weight = l_indin01_lw
}
else if $weight_spec == 4 {
    replace current_weight = l_indinus_lw
}
else {
    di "Invalid value for weights variable. No weight applied."
}

// Declare the dataset to be a panel
xtset pidp wave

// Survey design and weights	
svyset, clear
svyset psu [pweight = current_weight], strata(strata)

 
********************************************************************************
* 2. DESCRIPTIVE STATS 
********************************************************************************
// Gender
tab sex, gen(sex_)
label var sex_1 "Male"
label var sex_2 "Female"

// Income
gen income = mon_grs_income
label var income "Mon. grs. income (thous. of pounds)"

// Minorities
tab minority_c, gen(min_)
label var min_1 "White"
label var min_2 "Indian"
label var min_3 "Pakistani"
label var min_4 "Bangladeshi"
label var min_5 "Caribbean"
label var min_6 "African"
label var min_7 "Other minorities"

// Highest qualification
tab highest_qualification, gen(high_qual_)
label var high_qual_1 "No qualification"
label var high_qual_2 "Other qualification"
label var high_qual_3 "GCSE"
label var high_qual_4 "A level"
label var high_qual_5 "Degree/Other High. Degree"

// Marital status
/*tab marital_status, gen(ma_stat_)
label var ma_stat_1 "Married/In a couple"
label var ma_stat_2 "Divorced/Separated"
label var ma_stat_3 "Widowed"
label var ma_stat_4 "Never married"*/

tab in_a_relationship, gen(rel_)
label var rel_1 "In a relationship"
label var rel_2 "Not in a rel. anymore"
label var rel_3 "Never married"

// Own child in house
ta own_child_in_house, gen(own_ch_)
label var own_ch_1 "No own child in household"
label var own_ch_2 "Own child in household"

// Employment
ta lab_force_status, gen(lab_for_st_)
label var lab_for_st_1 "Employed/Retired"
label var lab_for_st_2 "Student/Training"
label var lab_for_st_3 "Not employed"
label var lab_for_st_4 "L.T. Sick/Disabled"


eststo varlist: estpost summarize income age_dv sex_* min_* high_qual_* rel_* ///
		own_ch_* lab_for_st_*  scghq1_dv scghq2_dv life_satisfaction sf12mcs_dv sf12pcs_dv [w=current_weight] 

esttab varlist using "$tavole/descriptive_statistics.tex", replace ///
refcat(sex_1 "\vspace{0.05 cm} \\ \emph{Gender}" ///
	min_1 "\vspace{0.05 cm} \\ \emph{Ethnicity}" ///
	high_qual_1 "\vspace{0.05 cm} \\ \emph{Highest qualification}" ///
	rel_1 "\vspace{0.05cm} \\ \emph{Marital status}" ///
	own_ch_2 "\vspace{0.05cm} \\ \emph{Presence of own child in the household}" ///
	lab_for_st_1 "\vspace{0.05cm} \\ \emph{Labour force status}" ///
	scghq1_dv "\vspace{0.05em} \\ \emph{Outcomes}", nolabel) ///
	cells("mean(fmt(%8.2fc %8.2fc %8.2fc %8.2fc  2)) sd min(fmt(%8.2fc)) max(fmt(%8.2fc)) count(fmt(0))") ///
	nostar unstack nonumber ///
	compress nomtitle nonote noobs label booktabs ///
	collabels("Mean" "SD" "Min" "Max" "N") ///
	title("Descriptive Statistics\label{descriptive}") longtable ///
	note("Note: Results are weighted to represent UK population. Income is measured in thousands of pounds.") ///
	drop(own_ch_1 sex_2)
	


