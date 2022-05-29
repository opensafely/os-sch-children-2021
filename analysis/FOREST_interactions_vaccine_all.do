
*******************************************************************************
*1. graph for interaction type
*******************************************************************************/

*Figure 3 - main results

*int_level
foreach outcome in covid_tpp_prob covidadmission covid_death {
foreach level in 0 1 {
import delimited using "output/11_an_int_tab_contents_HRtable_`outcome'_vaccine_main.txt", clear
keep if age==`level'

tostring pval, gen(pval_new) force
replace pval_new="" if pval_new=="."
replace pval_new =substr(pval_new,1,4)
replace pval_new="<.001" if pval_new=="0"

list
destring hr, replace
gen log_est = log(hr)
gen log_lci = log(lci)
gen log_uci = log(uci)

lab define exposurelevel 0 "No children" ///
1 "Only children aged 0-11 years" ///
2 "Only children aged ≥12 years" ///
3 "Children aged 0-11 and ≥12 years"

lab val exposurelevel exposurelevel

encode outcome, gen(outcome_new)  
lab drop outcome_new
lab define outcome_new 1 "Reported SARS-CoV-2 infection"  ///
2 "COVID-19 hospital admission" ///
3 "COVID-19 death" 
lab val outcome_new outcome_new
tab outcome outcome_new
lab var outcome_new "Outcome"

lab val outcome_new outcome_new
tab outcome outcome_new
lab var outcome_new "Outcome"
lab var exposurelevel "Exposure"

sort outcome_new exposurelevel  int_level
list

gen obsorder=_n
expand 2 if outcome!=outcome[_n-1], gen(expanded)
gsort obsorder -expanded

drop obsorder
gen obsorder=_n

replace outcome_new=. if expanded==0
 list
replace exposurelevel=. if int_level!=1

foreach var in exposurelevel hr lci uci log_est log_lci log_uci  {
replace `var'=. if expanded==1
}
foreach var in pval_new {
replace `var'="" if expanded==1
}

gen displayhrci = string(hr, "%3.2f") + " (" + string(lci, "%3.2f") + "-" + string(uci, "%3.2f") + ")"
replace displayhrci="" if hr==.
list display

drop obsorder

gen obsorder=_n
gsort -obsorder
gen graphorder = _n
sort graphorder
list graphorder outcome hr  lci uci

gen hrtitle="HR (95% CI)        P-value" if graphorder == 17

gen bf_hrtitle = "{bf:" + hrtitle + "}"

gen varx = 0.012
gen levelx = 0.12
gen intx=0.09
gen lowerlimit = 0.15
gen disx=4
gen disx2=12

replace hr=. if hr==0
replace lci=. if lci==0
replace uci=. if uci==0

scatter graphorder hr if int_level==1, mcol(green)	msize(small)		///										///
	|| rcap lci uci graphorder if int_level==1, hor mcol(green)	lcol(green)			///
	|| scatter graphorder hr if int_level==2, mcol(blue)	msize(small)	///										
	|| rcap lci uci graphorder if int_level==2, hor mcol(blue)	lcol(blue)			///
	|| scatter graphorder hr if int_level==3, mcol(purple)	msize(small)	///										
	|| rcap lci uci graphorder if int_level==3, hor mcol(purple)	lcol(purple)			///
	|| scatter graphorder hr if int_level==4, mcol(black)	msize(small)	///										
	|| rcap lci uci graphorder if int_level==4, hor mcol(black)	lcol(black)			///
	|| scatter graphorder varx , m(i) mlab(exposurelevel) mlabsize(medsmall) mlabcol(black) 	///
	|| scatter graphorder disx, m(i) mlab(displayhrci) mlabsize(small) mlabcol(black) ///
	|| scatter graphorder disx, m(i) mlab(bf_hrtitle) mlabsize(small) mlabcol(black) ///
	|| scatter graphorder disx2 , m(i) mlab(pval_new) mlabsize(small) mlabcol(black) 	///
		xline(1,lp(solid)) 															///
		xscale(log range(0.01 20)) xlab(0.5 1 2, labsize(small)) xtitle("")  ///
		ylab(none) ytitle("")		yscale( lcolor(white))					///
		graphregion(color(white))  legend(off)  ysize(3) ///
		text(-2 0.2 "Lower risk in those living with children", place(e) size(tiny)) ///
		text(-2 1.5 "Higher risk in those living with children", place(e) size(tiny))
		
graph export "output/an_vaccine_main_`outcome'_age`level'.svg", as(svg) replace
sort obsorder
 list
	}
}
