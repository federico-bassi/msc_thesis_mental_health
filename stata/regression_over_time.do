********************************************************************************
** Regression over time
********************************************************************************
/* This code contains the regression estimations. To correctly execute the code, 
I assume that the dataset is contained in the "data" global.
*/

version 12
clear all
set more off 
capture log close
set scheme plottigblind


********************************************************************************
* 1. PATH SWITCHERS AND DIRECTORIES
********************************************************************************
global fede = 2

if $fede ==1 {
	cd "/Volumes/maxone/Tesi/stata"
	global data = "/Volumes/maxone/Tesi/dataset"
	global tavole = "/Volumes/maxone/Tesi/stata/tables"
	global graphs = "/Volumes/maxone/Tesi/stata/graphs"
}
if $fede ==2 {
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
    replace current_weight = repeated_cross
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
    di "Invalid value for weights variable."
}

********************************************************************************
* 2. DATASET PREPARATION
********************************************************************************

// Declare the dataset to be a panel
xtset pidp wave

// Survey design and weights	
svyset, clear
svyset psu [pweight = current_weight], strata(strata) singleunit(scaled)


// Keep only data from UKHLS
keep if istrtdaty>=2009


********************************************************************************
* 3. ANALYSIS OVER TIME - NON PARAMETRIC FORM
********************************************************************************
** 3.1 Regression estimation
********************************************************************************
eststo model1A: ///
reghdfe scghq1_dv_std c.sex#i.istrtdaty ///
				c.over_65#i.istrtdaty ///
				c.in_a_relationship_b#i.istrtdaty /// 
				c.own_child_in_house#i.istrtdaty ///
				c.minority_b#i.istrtdaty /// 
				c.educ_years#i.istrtdaty ///
				c.mon_grs_income#i.istrtdaty ///
				c.unemployed#i.istrtdaty ///
				[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)

eststo model1B: ///
reghdfe scghq1_dv_std c.sex#i.istrtdaty [pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)

eststo model1C: ///
reghdfe scghq1_dv_std c.minority_b#i.istrtdaty [pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)

eststo model1D: ///
reghdfe scghq1_dv_std c.mon_grs_income#i.istrtdaty [pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)

				

/*reghdfe scghq1_dv c.sex#i.time_1 ///
		c.over_65#i.time_1 ///
		c.in_a_relationship#i.time_1 ///
		c.own_child_in_house#i.time_1 ///
		c.employed#i.time_1 ///
		c.minority_b#i.time_1 ///
		c.educ_years#i.time_1 ///
		c.log_mon_gr#i.time_1 ///
		c.income_flag#i.time_1 ///
		[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp) */
				
** 3.2 "Gender effect" over time
********************************************************************************
coefplot (model1A, label(Conditional estimate) offset(0.07)) ///
        (model1B, label(Unconditional estimate) offset(-0.07)), ///
		keep(*sex*) title(Associations between time and gender variable) ///
		vertical legend(pos(6) col(2)) nobaselevel ///
		coeflabels(2009.istrtdaty#c.sex= "2009" 2010.istrtdaty#c.sex= "2010" 2011.istrtdaty#c.sex= "2011"2012.istrtdaty#c.sex= "2012" 2013.istrtdaty#c.sex= "2013" 2014.istrtdaty#c.sex= "2014" 2015.istrtdaty#c.sex= "2015" 2016.istrtdaty#c.sex= "2016" 2017.istrtdaty#c.sex= "2017" 2018.istrtdaty#c.sex= "2018" 2019.istrtdaty#c.sex= "2019" 2020.istrtdaty#c.sex= "2020" 2021.istrtdaty#c.sex= "2021", angle(45)) saving("$graphs/gender_effect", replace) ///
		note("Plotted category: Female" "Reference category: Male" ///
		"Conditional and unconditional coefficients for the interaction between time and gender variable. The" "outcome is mental health as measured by GHQ-12, where higher values correspond to higher levels" "of psychological distress.") ///
		graphregion(margin(r+7)) legend(ring(0) bplacement(nwest))

graph export $graphs/gender_effect.png, replace


** 3.3 "Minority effect" over time
********************************************************************************
coefplot (model1A, label(Conditional estimate) offset(0.07)) ///
		(model1C, label(Unconditional estimate) offset(-0.07)), ///
		keep(*minority_b*) title (Associations between time and minority variable) baselevel vertical ///
		coeflabels(2009.istrtdaty#c.minority_b= "2009" 2010.istrtdaty#c.minority_b= "2010" 2011.istrtdaty#c.minority_b= "2011" 2012.istrtdaty#c.minority_b= "2012" 2013.istrtdaty#c.minority_b= "2013" 2014.istrtdaty#c.minority_b= "2014" 2015.istrtdaty#c.minority_b= "2015" 2016.istrtdaty#c.minority_b= "2016" 2017.istrtdaty#c.minority_b= "2017" 2018.istrtdaty#c.minority_b= "2018" 2019.istrtdaty#c.minority_b= "2019" 2020.istrtdaty#c.minority_b= "2020" 2021.istrtdaty#c.minority_b= "2021", angle(45)) saving("$graphs/minority_effect", replace) note("Plotted category: Minority" "Baseline category: White" "Conditional and unconditional coefficients for the interaction between time and minority variable." "The outcome is mental health as measured by GHQ-12, where higher values correspond to" "higher levels of psychological distress.") ///
graphregion(margin(r+15)) legend(ring(0) bplacement(nwest))

graph export $graphs/minority_effect.png, replace


** 3.4 "Income effect" over time
********************************************************************************
coefplot (model1A, label(Conditional estimate) offset(0.07)) ///
		(model1D, label(Unconditional estimate) offset(-0.07)), ///
		keep(*mon_grs_income*) title (Association between time and income variable) baselevel vertical ///
		coeflabels(2009.istrtdaty#c.mon_grs_income= "2009" 2010.istrtdaty#c.mon_grs_income= "2010" 2011.istrtdaty#c.mon_grs_income= "2011" 2012.istrtdaty#c.mon_grs_income= "2012" 2013.istrtdaty#c.mon_grs_income= "2013" 2014.istrtdaty#c.mon_grs_income= "2014" 2015.istrtdaty#c.mon_grs_income= "2015" 2016.istrtdaty#c.mon_grs_income= "2016" 2017.istrtdaty#c.mon_grs_income= "2017" 2018.istrtdaty#c.mon_grs_income= "2018" 2019.istrtdaty#c.mon_grs_income= "2019" 2020.istrtdaty#c.mon_grs_income= "2020" 2021.istrtdaty#c.mon_grs_income= "2021", ///
angle(45)) saving("$graphs/gross_income_effect", replace) ///
graphregion(margin(r+15)) legend(ring(0) bplacement(swest)) note("Conditional and unconditional coefficients for the interaction between time and monthly" "gross income variable. The outcome is mental health as measured by GHQ-12, where" "higher values correspond to higher levels of psychological distress.")


graph export $graphs/income_effect.png, replace

//eststo clear

********************************************************************************
* 4. ANALYSIS OVER TIME - PARAMETRIC FORM
********************************************************************************
/* In this subsection, we treat the time variable as a continuous variable, in order
to specify a more parametric equation and to test the significance of the associations
over time.*/

// Re-factoring of the year variables
gen year = .
egen min_year = min(istrtdaty)
replace year = istrtdaty - min_year

// Gender - Unconditional
eststo model3A: ///				
reghdfe scghq1_dv_std c.sex##c.year ///
                [pweight = current_weight], ///
				absorb(gor_dv istrtdaty) cluster(pidp)

estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// Minority - Unconditional
eststo model3B: ///				
reghdfe scghq1_dv_std c.minority_b##c.year ///
                [pweight = current_weight], ///
				absorb(gor_dv istrtdaty) cluster(pidp)

estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// Income - Unconditional
eststo model3C: ///				
reghdfe scghq1_dv_std c.mon_grs_income##c.year ///
                [pweight = current_weight], ///
				absorb(gor_dv istrtdaty) cluster(pidp)

estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// Full model
eststo model3D: ///				
reghdfe scghq1_dv_std c.sex##c.year ///
				c.minority_b##c.year /// 
				c.mon_grs_income##c.year ///
				c.unemployed##c.year ///
                c.over_65##c.year ///
                c.in_a_relationship##c.year /// 
                c.own_child_in_house##c.year ///
                c.educ_years##c.year ///
                [pweight = current_weight], ///
				absorb(gor_dv istrtdaty) cluster(pidp)

estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace



// Export to tab
esttab model3* using "$tavole/tab_3.tex", replace ///
	booktabs compress b(3) se(3) nobaselevels nomtitles drop(year _cons) ///
	label scalars("t_fixed Time fixed effects" "u_fixed Unit fixed effects" "N Observations") ///
	sfmt(0 0 0) longtable ///
	title("Regression in parametric form\label{tab3}") ///	
	note() addnotes("Mental Health is measured by the (standardized) GHQ-12. Higher scores correspond to higher levels of distress." "Income is measured in thousands of pounds. Results are weighted to represent the UK population.")

	
// eststo clear	


