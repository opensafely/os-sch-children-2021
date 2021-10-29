*************************************************************************
*Do file: 08_an_tablecontent_HRtable
*
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell table containing minimally and fully-adjusted HRs for risk factors
* of interest, across 2 outcomes 
*
*Requires: final analysis period (analysis_period.dta)
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
log using "$logdir/08_an_tablecontent_HRtable_`outcome'", text replace


***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real) outcome(string)
file write tablecontents ("Exposure") _tab ("exposure_level") _tab ("time_period") _tab ("events") _tab ("person_years") _tab ("rate") _tab ("age_sex_adj_hr") _tab ("demog_adj_hr") _tab ("full_adj_hr") _n
foreach period in 0 1 2 3 4  {
forvalues x=0/1 {
file write tablecontents ("age") ("`x'") _n
forvalues i=`min'/`max'{
local endwith "_tab"


use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear

*-School closure: 20th December 2020 (previous analysis up to 19th December 2020) 
*-School opening +7 days (alpha variant): 15th March 2021 
*-Schools open delta variant (+7 days): 24th May 2021 
*Summer holidays +7 days: 24th July 2021
*Winter term +7 days: 9th September 2021

if "`outcome'"=="covid_tpp_prob" {
stsplit cat_time, at(0,85,154, 216, 263, 400)
recode cat_time 85=1 154=2 216=3 263=4 
recode `outcome' .=0 
tab cat_time
tab cat_time `outcome'
}

*-School closure: 20th December 2020 (previous analysis up to 19th December 2020) 
*School opening +14 days (alpha variant): 22nd March 2021 
*Schools open delta variant (+14 days): 31st May 2021 
*Summer holidays +14 days: 30th July 2021
*Winter term +14 days: 16th September 2021

if "`outcome'"=="covidadmission" {
stsplit cat_time, at(0,92,161,222,270, 400)
recode cat_time 92=1 161=2 222=3 270=4
recode `outcome' .=0 
tab cat_time
tab cat_time `outcome'
}

if  "`outcome'"=="covid_death" {
stsplit cat_time, at(0,92,161,222,270, 400)
recode cat_time 92=1 161=2 222=3 270=4
recode `outcome' .=0 
tab cat_time
tab cat_time `outcome'
}

keep if cat_time==`period'

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents ("`variable'") _tab ("`i'") _tab ("`period'") _tab 
	
	*put total N, PYFU and Rate in table
	cou if `variable' == `i' & _d == 1 
	local event = r(N)
    bysort `variable': egen total_follow_up = total(_t)
	su total_follow_up if `variable' == `i'
	local person_days = r(mean)
	local person_years=`person_days'/365.25
	local rate = 100000*(`event'/`person_years')
	
	file write tablecontents (`event') _tab %10.0f (`person_years') _tab %3.2f (`rate') _tab
	drop total_follow_up
	
	
	*models
	foreach modeltype of any minadj demogadj fulladj  {
	
		local noestimatesflag 0 /*reset*/

*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if "`modeltype'"=="fulladj" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY
		
		if "`modeltype'"=="minadj" {
			cap estimates use ./output/an_univariable_cox_models_`variable'_`outcome'_AGESEX_ageband_`x'_timeperiod`period'
			if _rc!=0 local noestimatesflag 1
			}
		if "`modeltype'"=="demogadj" {
			cap estimates use ./output/an_multivariate_cox_models_`outcome'_`variable'_DEMOGADJ_ageband_`x'_timeperiod`period'
			if _rc!=0 local noestimatesflag 1
			}
		if "`modeltype'"=="fulladj" {
			cap estimates use ./output/an_multivariate_cox_models_`outcome'_`variable'_FULLYADJMODEL_ageband_`x'_timeperiod`period' 
			if _rc!=0 local noestimatesflag 1
			}
		
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE
		
		if `noestimatesflag'==0{
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents %4.2f (r(estimate)) (" (") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") `endwith'
				else file write tablecontents %4.2f ("ERR IN MODEL") `endwith'
			}
			else file write tablecontents %4.2f ("DID NOT FIT") `endwith' 
			
		*3) Save the estimates for plotting
		if `noestimatesflag'==0{
			if "`modeltype'"=="fulladj" {
				local hr = r(estimate)
				local lb = r(lb)
				local ub = r(ub)
				cap gen `variable'=.
				testparm i.`variable'
				*drop `variable'
				}
		}	
		} /*min adj, full adj*/
		
} /*variable levels*/

} /*agebands*/

} /*Waves*/
end
***********************************************************************************************************************
/*Generic code to write a full row of "ref category" to the output file
cap prog drop refline
prog define refline
file write tablecontents _tab _tab ("1.00 (ref)") _tab ("1.00 (ref)")  _n
end*/
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS

cap file close tablecontents
file open tablecontents using ./output/an_tablecontents_HRtable_`outcome'.txt, t w replace 

*Primary exposure
outputHRsforvar, variable("kids_cat4") min(0) max(3) outcome(`outcome')
file write tablecontents _n

file close tablecontents


log close
