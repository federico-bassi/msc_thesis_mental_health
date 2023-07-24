********************************************************************************
** GHQ-DIMENSIONS
********************************************************************************
/* This code contains the regressions for each of the 12 dimensions of the GHQ.
To correctly execute the code, I assume that the dataset is contained in the "data" global.
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
* 3. MINORITIES - EXPLORATORY ANALYSIS
********************************************************************************
foreach lett in a b c d e f g h i j k l {
	eststo model1`lett': ///
	reghdfe scghq`lett' i.sex i.age ///
			i.minority_c ///
			mon_grs_income  ///
			unemployed ///
			i.highest_qualification ///
			i.in_a_relationship_b own_child_in_house ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	
	estadd local controls "Yes", replace
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace
}

// Table
esttab model1* using "$tavole/tab_4.tex", replace ///
	se(3) compress nobaselevels ///
	label scalars("controls Controls " "t_fixed Time F.E." ///
	"u_fixed Unit F.E." "N Observations") sfmt(0 0 0 0) ///
	title("GHQ dimensions\label{tab4}") ///
	mtitles("\shortstack{Con-\\centra-\\tion}" "\shortstack{Loss\\of\\sleep}" "\shortstack{Playing\\a useful\\role}" "\shortstack{Capable\\of ma-\\king deci-\\sions}" ///
	"\shortstack{Con-\\stantly\\under\\strain}" "\shortstack{Problem\\over-\\coming\\difficulties}" "\shortstack{Enjoy\\day-to\\-day acti-\\vities}" ///
	"\shortstack{Ability\\to face\\pro-\\blems}" "\shortstack{Un-\\happy\\ or de-\\pressed}" "\shortstack{Losing\\confi-\\dence}" "\shortstack{Believe\\worth-\\less}" ///
	"\shortstack{General\\happi-\\ness}") ///
	note("Years: 1991-2022") keep(*minority_c *sex) booktabs substitute("\begin{table}" "\begin{sidewaystable}" "\end{table}" "\end{sidewaystable}") varwidth(15) drop(7.minority_c)
	
// Plot	
coefplot model1a, bylabel("Concentration") keep(*minority_c) ///
	|| model1b, bylabel("Loss of sleep") keep(*minority_c) ///
	|| model1c, bylabel("Playing a useful role") keep(*minority_c) ///
	|| model1d, bylabel("Capable of making decisions") keep(*minority_c) ///
	|| model1e, bylabel("Constantly under strain") keep(*minority_c) ///
	|| model1f, bylabel("Problem overcoming difficulties") keep(*minority_c) ///
	|| model1g, bylabel("Enjoy day-to-day activities") keep(*minority_c) ///
	|| model1h, bylabel("Ability to face problems") keep(*minority_c) ///
	|| model1i, bylabel("Unhappy or depressed") keep(*minority_c) ///
	|| model1j, bylabel("Losing confidence") keep(*minority_c) ///
	|| model1k, bylabel("Believe worthless") keep(*minority_c) ///
	|| model1l, bylabel("General happiness") keep(*minority_c) ///
	||, xline(0) byopts(compact cols(2) title("Psychological distress by ethnic group" "and dimension of the GHQ") note("Years: 2009-2021" "The graph reports the coefficients associated with each ethnic minority group" "in a regression for each of the components of the GHQ. In all the components," "higher scores represent higher levels of psychological distress." "Regressions have been run using weights to represent UK population.") graphregion(margin(r+5))) drop(7.minority_c) xsize(10) ysize(14) xline(0, lcolor(red)) ///
	xlabel(-0.1 `" " "Low distress"' -0.1 "-0.1" ///
	0.1 `" " "High distress"' 0.1 "0.1", add labsize(small)) baselevels scheme(plottig)
	
graph export $graphs/dimensions_minorities.png, replace


********************************************************************************
* 4. GENDER - EXPLORATORY ANALYSIS
********************************************************************************
coefplot model1a, bylabel("Concentration") keep(*sex) ///
	|| model1b, bylabel("Loss of sleep") keep(*sex) ///
	|| model1c, bylabel("Playing a useful role") keep(*sex) ///
	|| model1d, bylabel("Capable of making decisions") keep(*sex) ///
	|| model1e, bylabel("Constantly under strain") keep(*sex) ///
	|| model1f, bylabel("Problem overcoming difficulties") keep(*sex) ///
	|| model1g, bylabel("Enjoy day-to-day activities") keep(*sex) ///
	|| model1h, bylabel("Ability to face problems") keep(*sex) ///
	|| model1i, bylabel("Unhappy or depressed") keep(*sex) ///
	|| model1j, bylabel("Losing confidence") keep(*sex) ///
	|| model1k, bylabel("Believe worthless") keep(*sex) ///
	|| model1l, bylabel("General happiness") keep(*sex) ///
	||, xline(0) byopts(compact cols(2) title("Psychological distress by gender" "and dimension of the GHQ") note("Years: 2009-2021" "The graph reports the coefficients associated with gender in a regression for" "each of the components of the GHQ. In all the components, higher scores" "represent higher levels of psychological distress." "Regressions have been run using weights to represent UK population.") graphregion(margin(r+5))) xsize(10) ysize(14) xline(0, lcolor(red)) baselevels ///
	xlabel(-0.1 -0.05 `" " "Low distress"' -0.05 "-0.05" ///
	0.15 `" " "High distress"' 0.15 "0.15", add labsize(small))  scheme(plottig)

graph export $graphs/dimensions_gender.png, replace
	
	
eststo clear
