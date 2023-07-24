	********************************************************************************
	** Regression - Cross-sectional analysis
	********************************************************************************
	/* This code contains the regression estimations. To correctly execute the code, 
	I assume that the dataset is contained in the "data" global.
	*/

	version 12
	clear all
	set more off 
	capture log close
	set scheme plotplain
	eststo clear


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
	svyset psu [pweight = current_weight], strata(strata) singleunit(scaled)

	 
	********************************************************************************
	* 2. TABLE 1: ANALYSIS 1991-2022, TREATING THE PANEL AS A REPEATED CROSS-SECTION
	********************************************************************************

	** 2.1 Dependent variable: scghq1_dv, using total monthly income gross
	********************************************************************************
	// Baseline regression: sex and age
	eststo model1A: ///
	reghdfe scghq1_dv_std i.sex ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "No", replace 
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace

	// Add minority
	eststo model1B: ///
	reghdfe scghq1_dv_std ///
			i.minority_b ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "No", replace 
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace

	// Add income
	eststo model1C: ///
	reghdfe scghq1_dv_std ///
			mon_grs_income ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "No", replace 
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace

	// Add employment status
	eststo model1D: ///
	reghdfe scghq1_dv_std ///
			i.lab_force_status ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "No", replace 
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace

	// Add education		
	eststo model1E: ///
	reghdfe scghq1_dv_std ///
			i.highest_qualification ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "No", replace 
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace
	
	// Add marital status and children in household
	eststo model1F: ///
	reghdfe scghq1_dv_std  ///
			i.in_a_relationship i.own_child_in_house ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "No", replace 
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace


	// Complete model
	eststo model1G: ///
	reghdfe scghq1_dv_std i.sex i.age ///
			i.minority_b ///
			mon_grs_income ///
			i.lab_force_status ///
			i.highest_qualification ///
			i.in_a_relationship i.own_child_in_house ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
	estadd local age "Yes", replace
	estadd local other_controls "Yes", replace
	estadd local t_fixed "Yes" , replace
	estadd local u_fixed "Yes" , replace

	// Export to tab
	esttab model1* using "$tavole/tab_1.tex", replace compress ///
		nobaselevels nomtitles drop(*.age* _cons) se(3) ///
		label scalars("age Controls for age" "t_fixed Time fixed effects" ///
		"u_fixed Unit fixed effects" "N Observations") sfmt(0 0 0 0) ///
		title("Mental Health Determinants,Outcome: GHQ-12 Likert Scale - Psychological distress\label{tab1}") ///
		nonotes postfoot( ///
		\hline\hline ///
		\end{tabular} ///
		{ ///
		\caption*{\begin{scriptsize} ///
		$\ast p< 0.05; \ast\ast p < 0.01; \ast\ast\ast p < 0.001$. ///
		Standard Errors in parentesis.\newline Years: 1991-2022\newline The table reports estimated 		coefficients for ///
		unconditional and conditional regressions of mental health on socio-economic determinants. ///
		Mental Health is measured by the GHQ-12. The variable has been standardized. ///
		Higher scores correspond to higher levels of distress. Income is measured in thousands of pounds. Results are weighted to represent the UK population. ///
		\end{scriptsize}}} ///
		\end{table} ///
		) ///
		substitute("\begin{tabular}" "\resizebox{0.99\textwidth}{!}{\begin{tabular}" "\end{tabular}" "\end{tabular}}")

		


// Unconditional for age
eststo model1H: ///
reghdfe scghq1_dv_std i.age ///
			[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)

estadd local other_controls "No", replace
estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace
	
// Export to tab - Age categories
esttab model1H model1G using "$tavole/tab_5.tex", replace compress ///
	booktabs nobaselevels keep(*.age*) se(3) ///
	label scalars("other_controls Controls for other observables" "t_fixed Time fixed effects" ///
	"u_fixed Unit fixed effects" "N Observations") sfmt(0 0 0 0) ///
	title("Coefficients associated with age categories,Outcome: GHQ-12 Likert Scale - Psychological distress\label{tab5}") ///
	mtitles("Unconditional estimates" "Conditional estimates") ///
	nonotes postfoot( ///
	\hline\hline ///
	\end{tabular} ///
	{ ///
	\caption*{\begin{scriptsize} ///
	$\ast p< 0.05; \ast\ast p < 0.01; \ast\ast\ast p < 0.001$. ///
	Standard Errors in parentesis.\newline Years: 1991-2022\newline The table reports estimated coefficients for ///
	the unconditional and conditional regression of mental health on age. ///
	Mental Health is measured by the GHQ-12. The variable has been standardized. ///
	Higher scores correspond to higher levels of distress. Results are weighted to represent the UK population. ///
	\end{scriptsize}}} ///
	\end{table} ///
	) ///
	substitute("\begin{tabular}" "\resizebox{!}{0.7\textwidth}{\begin{tabular}" "\end{tabular}" "\end{tabular}}")


	
coefplot (model1G, label(Conditional estimates) offset(0.07)) ///
		(model1H, label(Unconditional estimate) offset(-0.07)), ///
		keep(*age*) baselevels vertical ///
		yline(0, lcolor(red)) title("Age trends in Psychological Distress") ///
		saving("$graphs/age_trends_ghq", replace) xlabel(, angle(vertical)) ///
		note("Years: 1991-2021" "The graph displays the coefficients associated with each age category in the regression of" "mental health on age. In the uncoditional case, we do not control for other variables, while" "in the conditional case we control for all the other observables (cfr. Tab.2-Col.7). Mental" "health is measured by GHQ: higher values represent higher levels of psychological distress.") ///
		graphregion(margin(r+15)) legend(ring(0) bplacement(swest)) scheme(plottigblind)
		 
graph export "$graphs/age_trends_ghq.png", as(png) replace

	
eststo clear

********************************************************************************
* 3. TABLE 2: ANALYSIS 1991-2022, COMPARISON OF DIFFERENT OUTCOMES
********************************************************************************
// GHQ-12 Likert
eststo model2A: ///
reghdfe scghq1_dv_std i.sex i.age ///
		i.minority_b ///
		mon_grs_income ///
		i.lab_force_status ///
		i.highest_qualification ///
		i.in_a_relationship i.own_child_in_house ///
		[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
estadd local age "Yes", replace 
estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// GHQ-12 Caseness
eststo model2B: ///
reghdfe scghq2_dv_std i.sex i.age ///
		i.minority_b ///
		mon_grs_income ///
		i.lab_force_status ///
		i.highest_qualification ///
		i.in_a_relationship i.own_child_in_house ///
		[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
estadd local age "Yes", replace 
estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// SF-12 Mental
eststo model2C: ///
reghdfe sf12mcs_dv_std i.sex i.age ///
		i.minority_b ///
		mon_grs_income ///
		i.lab_force_status ///
		i.highest_qualification ///
		i.in_a_relationship i.own_child_in_house ///
		[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
estadd local age "Yes", replace 
estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// Life Satisfaction
eststo model2D: ///
reghdfe life_satisfaction_std i.sex i.age ///
		i.minority_b ///
		mon_grs_income ///
		i.lab_force_status ///
		i.highest_qualification ///
		i.in_a_relationship i.own_child_in_house ///
		[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
estadd local age "Yes", replace 
estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace

// SF-12 Physical
eststo model2E: ///
reghdfe sf12pcs_dv_std i.sex i.age ///
		i.minority_b ///
		mon_grs_income ///
		i.lab_force_status ///
		i.highest_qualification ///
		i.in_a_relationship i.own_child_in_house ///
		[pweight = current_weight], absorb(gor_dv istrtdaty) cluster(pidp)
estadd local age "Yes", replace 
estadd local t_fixed "Yes" , replace
estadd local u_fixed "Yes" , replace


// Export to tab
esttab model2* using "$tavole/tab_2.tex", replace ///
	booktabs se(3) compress nobaselevels ///
	label scalars("age Controls for age" "t_fixed Time fixed effects" "u_fixed Unit fixed effects" "N Observations") sfmt(0 0 0) ///
	title("Determinants of Mental health, Well-being and Physical Health\label{tab2}") /// 
	note("Years: 1991-2022") drop(*.age* _cons) ///
	mtitles("GHQ Likert" "GHQ Caseness" "SF-12 Mental" "Life sat." "SF-12 Physical") ///
	nonotes postfoot( ///
	\hline\hline ///
	\end{tabular} ///
	{ ///
	\caption*{\begin{scriptsize} ///
	$\ast p< 0.05; \ast\ast p < 0.01; \ast\ast\ast p < 0.001$. ///
	Standard Errors in parentesis.\newline Estimated coefficients for the regression /// 
	of mental health (GHQ-12 Likert and Caseness scale, SF-12 Questionnaire ///
	Mental Component), Life Satisfaction and Physical health (SF-12 Questionnaire ///
	Physical Component) on socio-economic determinants. ///
	All the outcomes have been standardized. Higher scores for GHQ represent higher ////
	levels of distress, while higher scores for SF-12 represent ///
	higher mental or physical health functioning. Higher scores for life satisfaction ///
	correspond to higher life satisfaction. Income is measured in thousands of pounds. ///
	Results are weighted to represent the UK population. ///
	\end{scriptsize}}} ///
	\end{table} ///
	) ///
	substitute("\begin{tabular}" "\resizebox{!}{0.65\textwidth}{\begin{tabular}" "\end{tabular}" "\end{tabular}}")
	
	
esttab model2* using "$tavole/tab_6.tex", replace ///
	booktabs se(3) compress nobaselevels ///
	label scalars("t_fixed Time fixed effects" "u_fixed Unit fixed effects" "N Observations") sfmt(0 0 0) ///
	title("Coefficients associated with age categories. Outcomes:Mental health,Well-being, Physical Health\label{tab6}") /// 
	note("Years: 1991-2022") keep(*.age* ) ///
	mtitles("GHQ Likert" "GHQ Caseness" "SF-12 Mental" "Life sat." "SF-12 Physical") ///
	nonotes postfoot( ///
	\hline\hline ///
	\end{tabular} ///
	{ ///
	\caption*{\begin{scriptsize} ///
	$\ast p< 0.05; \ast\ast p < 0.01; \ast\ast\ast p < 0.001$. ///
	Standard Errors in parentesis.\newline Estimated coefficients for the regression /// 
	of mental health (GHQ-12 Likert and Caseness scale, SF-12 Questionnaire ///
	Mental Component), Life Satisfaction and Physical health (SF-12 Questionnaire ///
	Physical Component) on socio-economic determinants, keeping only the coefficients associated with the age categories. ///
	All the outcomes have been standardized. Higher scores for GHQ represent higher ////
	levels of distress, while higher scores for SF-12 represent ///
	higher mental or physical health functioning. Higher scores for life satisfaction ///
	correspond to higher life satisfaction. Results are weighted to represent the UK population. ///
	\end{scriptsize}}} ///
	\end{table} ///
	)
	
	
// Coefplot for the age variable
coefplot (model2C, label("Mental Health")) ///
         (model2E, label("Physical Health")), ///
		 keep(*age*) baselevels vertical yline(0, lcolor(red)) title("Age trends in Mental vs Physical Health") ///
		 saving("$graphs/age_trends", replace) xlabel(, angle(vertical)) ///
		 note("Years: 1991-2021" "The graph displays the coefficients associated with each age category in the regression of mental" "and physical health on age, controlling for all the other observables. Mental and physical health" "are measured by the SF-12 Questionnaire: higher values represent higher mental and physical" "functioning.") nooffsets ///
		 graphregion(margin(r+10)) legend(ring(0) bplacement(swest)) scheme(plottigblind)

graph export "$graphs/age_trends.png", as(png) replace
		
eststo clear	


