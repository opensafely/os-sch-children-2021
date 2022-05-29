
*******************************************************************************
*>> HOUSEKEEPING
*******************************************************************************/

foreach x in 0 1 {

import delimited "./output/15_an_tablecontents_HRtable_all_outcomes_ANALYSES.txt", clear
keep if age==`x'

gen log_est = log(hr)
gen log_lci = log(lci)
gen log_uci = log(uci)
lab define  age 0 "Age <=65 years" 1 "Age>65 years"
lab values age age

recode exposurelevel .=4
lab define exposurelevel_new 1 "Only children aged 0-11 years" ///
2 "Only children aged ≥12 years" ///
3 "Children aged 0-11 and ≥12 years" 4 " "
lab val exposurelevel exposurelevel_new


gen period_text= "Period 1 - Schools closed" if period==0
replace period_text= "Period 2 - Schools open - Alpha" if period==1
replace period_text= "Period 3 - Schools open - Delta" if period==2
replace period_text= "Period 4 - School holidays" if period==3
replace period_text= "Period 5 - Schools open - Autumn/Winter" if period==4
replace period_text= "Period 6 - Omicron dominant" if period==5

drop if outcome == "covid_test_ever"
encode outcome, gen(outcome_new)  


recode outcome_new 3=2 2=1 1=3
lab drop outcome_new
lab define outcome_new 1 "Reported SARS-CoV-2 infection"  ///
2 "COVID-19 hospital admission" ///
3 "COVID-19 death"
lab val outcome_new outcome_new
tab outcome outcome_new
lab var outcome_new "Outcome"

sort outcome_new exposurelevel period_text
list

gen obsorder=_n
expand 2 if outcome!=outcome[_n-1], gen(expanded)
gsort obsorder -expanded

drop obsorder
gen obsorder=_n

replace outcome_new=. if expanded==0
foreach var in age  hr lci uci log_est log_lci log_uci  {
replace `var'=. if expanded==1
}

replace exposurelevel=. if period_text=="2"
 

drop expanded
expand 2 if exposurelevel!=exposurelevel[_n-1], gen(expanded)
gsort obsorder -expanded

drop if expanded==1 & obsorder==1

foreach var in age   hr lci uci log_est log_lci log_uci  {
replace `var'=. if expanded==1 & period_text=="Period 1 - Schools closed"
}

replace exposurelevel=. if hr==. & period_text=="Period 1 - Schools closed"
replace period_text="" if hr==. 
 
replace outcome_new=. if expanded==1

foreach var in age  hr lci uci log_est log_lci log_uci  {
replace `var'=. if outcome_new!=.
}

replace exposurelevel=. if outcome_new!=.

*tidy
drop obsorder

gen obsorder=_n
gsort -obsorder
gen graphorder = _n
sort graphorder
list graphorder outcome hr  lci uci

gen hrtitle="Hazard Ratio (95% CI)" if graphorder == 65

gen bf_hrtitle = "{bf:" + hrtitle + "}"

gen varx = 0.001
gen levelx = 0.017
gen intx=0.5
gen lowerlimit = 0.15
gen disx=15
gen disx2=20

replace exposurelevel=. if expanded==1
gen displayhrci = string(hr, "%3.2f") + " (" + string(lci, "%3.2f") + "-" + string(uci, "%3.2f") + ")"
replace displayhrci="" if hr==.
list display

replace log_est=. if log_est==0
replace hr=. if hr==0
replace hr=. if hr==1

replace exposurelevel=. if period_text!="Period 1 - Schools closed"


scatter graphorder hr if period_text=="Period 1 - Schools closed", mcol(gs0)	msize(small)		///										///
	|| rcap lci uci graphorder if period_text=="Period 1 - Schools closed", hor mcol(gs0)	lcol(gs0)			///
	|| scatter graphorder hr if period_text=="Period 2 - Schools open - Alpha", mcol(gs3)	msize(small)		///										///
	|| rcap lci uci graphorder if period_text=="Period 2 - Schools open - Alpha", hor mcol(gs3)	lcol(gs3)			///
	|| scatter graphorder hr if period_text=="Period 3 - Schools open - Delta", mcol(gs6)	msize(small)		///										///
	|| rcap lci uci graphorder if period_text=="Period 3 - Schools open - Delta", hor mcol(gs6)	lcol(gs6)			///
	|| scatter graphorder hr if period_text=="Period 4 - School holidays", mcol(gs9)	msize(small)		///										///
	|| rcap lci uci graphorder if period_text=="Period 4 - School holidays", hor mcol(gs9)	lcol(gs9)			///
	|| scatter graphorder hr if period_text=="Period 5 - Schools open - Autumn/Winter", mcol(gs12)	msize(small) ///								///
	|| rcap lci uci graphorder if period_text=="Period 5 - Schools open - Autumn/Winter", hor mcol(gs12)	lcol(gs12)			///
	|| scatter graphorder hr if period_text=="Period 6 - Omicron dominant", mcol(gs14)	msize(small) ///								///
	|| rcap lci uci graphorder if period_text=="Period 6 - Omicron dominant", hor mcol(gs14)	lcol(gs14)			///
		|| scatter graphorder varx , m(i) mlab(outcome_new) mlabsize(vsmall) mlabcol(black) 	///
	|| scatter graphorder levelx, m(i) mlab(period_text) mlabsize(tiny) mlabcol(black) 	///
	|| scatter graphorder varx , m(i) mlab(exposurelevel) mlabsize(tiny) mlabcol(black) 	///
	|| scatter graphorder disx, m(i) mlab(displayhrci) mlabsize(tiny) mlabcol(black) ///
	|| scatter graphorder disx, m(i) mlab(bf_hrtitle) mlabsize(tiny) mlabcol(black) ///
		xline(1,lp(solid)) 															///
		xscale(log range(0.1 70)) xlab(0.5 1 2 4 8, labsize(tiny)) xtitle("")  ///
		ylab(none) ytitle("")		yscale( lcolor(white))					///
		graphregion(color(white))  legend(off)  ysize(8) ///
		text(-3 0.01 "Lower risk in those living with children", place(e) size(tiny)) ///
		text(-3 2.0 "Higher risk in those living with children", place(e) size(tiny))
		
		
graph export "output/forest_main_results_age`x'.svg", as(svg) replace
		
}