*************************************************************************
*Purpose: Create content that is ready to paste into a pre-formatted Word
* shell table containing HRs for interaction analyses.  Also output forest
*plot of results as SVG file.
*
*Requires: final analysis dataset (analysis_dataset.dta)
*
*Coding: HFORBES, based on file from Krishnan Bhaskaran
*
*Date drafted: 30th June 2020
*************************************************************************
global outdir  	  "output"
global logdir     "logs"
global tempdir    "tempdata"

local outcome `1'

* Open a log file
capture log close
log using "$logdir/11_an_interaction_HR_tables_forest_`outcome'_vaccine_main.log", text replace

***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real) outcome(string)
file write tablecontents_int ("age") _tab ("exposure") _tab ("exposure level") ///
_tab ("outcome") _tab ("int_type") _tab ("int_level") ///
_tab ("events") _tab ("person_years") _tab ("rate") ///
_tab ("HR")  _tab ("lci")  _tab ("uci") _tab ("pval") _n
foreach x in 0 1 {
forvalues i=`min'/`max'{
foreach int_type in vaccine {

foreach int_level in  1 2 3 {

local endwith "_tab"

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents_int ("`x'") _tab ("`variable'") _tab ("`i'") _tab ("`outcome'") _tab ("`int_type'") _tab ("`int_level'") _tab
 
 use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear


replace covid_vacc_second_dose_date=. if covid_vacc_date>=covid_vacc_second_dose_date
replace covid_vacc_second_dose_date=. if covid_vacc_date==. 
drop if covid_vacc_date<d(20dec2020)
drop if covid_vacc_second_dose_date<d(20dec2020)

*Censor at date of first child being vaccinated in hh
replace stime_`outcome' 	= under18vacc if stime_`outcome'>under18vacc
replace `outcome'=0 if stime_`outcome'<date_`outcome'
stset stime_`outcome', fail(`outcome') 		///
	id(patient_id) enter(enter_date) origin(enter_date)

*Drop those without any eligible follow-up
drop if enter_date>=stime_`outcome'
	
*Generate first and second vacc dates	
gen first_vacc_plus_7d=covid_vacc_date+7
gen second_vacc_plus_7d=covid_vacc_second_dose_date+7
format first_vacc_plus_7d second_vacc_plus_7d %td

*Replace vacc date with missing if occur after end follow-up
replace first_vacc_plus_7d=. if first_vacc_plus_7d> stime_`outcome'
replace second_vacc_plus_7d=. if second_vacc_plus_7d> stime_`outcome'

stsplit split1, after(first_vacc_plus_7d) at(0)
recode `outcome' .=0 
stsplit split2, after(second_vacc_plus_7d) at(0)
recode `outcome' .=0 
bysort patient_id: gen vaccine=_n
tab vaccine, miss
	
	
	keep if vaccine==`int_level'
*put total N, PYFU and Rate in table
	cou if `variable' == `i' & _d == 1 
	local event = r(N)
	gen fup=_t-_t0
    bysort `variable': egen total_follow_up = total(fup)
	su total_follow_up if `variable' == `i'
	local person_days = r(mean)
	local person_years=`person_days'/365.25
	local rate = 100000*(`event'/`person_years')
	
	file write tablecontents_int (`event') _tab %10.0f (`person_years') _tab %3.2f (`rate') _tab
	drop total_follow_up
 
	foreach modeltype of any fulladj {

		local noestimatesflag 0 /*reset*/

*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if "`modeltype'"=="fulladj" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY

		if "`modeltype'"=="fulladj" {
				cap estimates use ./output/an_interaction_cox_models_`outcome'_kids_cat4_`int_type'_`x'
				if _rc!=0 local noestimatesflag 1
				}
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE

		if `noestimatesflag'==0{
			if `int_level'==1 {
			test 1.`int_type'#`i'.`variable'
			*overall p-value for interaction: test 1.`int_type'#1.`variable' test 1.`int_type'#2.`variable'
			local pval=r(p)
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents_int %4.2f (r(estimate)) _tab %4.2f (r(lb)) _tab %4.2f (r(ub)) _tab %4.2f (`pval') `endwith'

				else file write tablecontents_int %4.2f ("ERR IN MODEL") `endwith'
				}
			if `int_level'==2 {
			cap lincom `i'.`variable'+ 2.`int_type'#`i'.`variable', eform
			if _rc==0 file write tablecontents_int %4.2f (r(estimate)) _tab %4.2f (r(lb)) _tab %4.2f (r(ub)) _tab  `endwith'
				else file write tablecontents_int %4.2f ("ERR IN MODEL") `endwith'
				}
			
			if `int_level'==3 {
			cap lincom `i'.`variable'+ 3.`int_type'#`i'.`variable', eform
			if _rc==0 file write tablecontents_int %4.2f (r(estimate)) _tab %4.2f (r(lb)) _tab %4.2f (r(ub)) _tab  `endwith'
				else file write tablecontents_int %4.2f ("ERR IN MODEL") `endwith'
				}
			}
			
			else file write tablecontents_int %4.2f ("DID NOT FIT") `endwith'

		*3) Save the estimates for plotting
		if `noestimatesflag'==0{
			if "`modeltype'"=="fulladj" {
				local hr = r(estimate)
				local lb = r(lb)
				local ub = r(ub)
				cap gen `variable'=.
				test 1.`int_type'#2.`variable' 1.`int_type'#1.`variable'
				local pval=r(p)
				post HRestimates_int ("`x'") ("`outcome'") ("`variable'") ("`int_type'") (`i') (`int_level') (`hr') (`lb') (`ub') (`pval')
				drop `variable'
				}
		}
		}
		} /*int_level*/
		} /*full adj*/

} /*variable levels*/
}
end
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS
cap file close tablecontents_int
file open tablecontents_int using ./output/11_an_int_tab_contents_HRtable_`outcome'_vaccine_main.txt, t w replace

tempfile HRestimates_int
cap postutil clear
postfile HRestimates_int str10 x str10 outcome str27 variable str27 int_type level int_level hr lci uci pval using `HRestimates_int'

*Primary exposure
outputHRsforvar, variable("kids_cat4") min(0) max(3) outcome(`outcome')
file write tablecontents_int _n

file close tablecontents_int

postclose HRestimates_int

log close
