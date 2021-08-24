********************************************************************************
*
*	Do-file:		06_univariate_analysis.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	Hforbes, based on files from Fizz & Krishnan
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file: an_univariable_cox_models.log 
*
********************************************************************************
*
*	Purpose:		Fit age/sex adjusted Cox models, stratified by STP and 
*with hh size as random effect
*  
********************************************************************************

* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "logs"
global tempdir    "tempdata"

* Open a log file
capture log close
log using "$logdir/06_univariate_analysis", replace t

* Open dataset and fit specified model(s)
foreach outcome in covid_tpp_prob  covidadmission  covid_death  {
forvalues x=0/1 {
use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear
forvalues period=0/3 {


*Split data by time of study period: 
*-School closure: 20th December 2020 (previous analysis up to 19th December 2020) 
*-alpha variant 15th March 2021 
*-delta variant 24th May 2021 

if "`outcome'"=="covid_tpp_prob" {
stsplit cat_time, at(0,85,154,400)
recode cat_time 85=1 154=2 400=3
recode `outcome' .=0 
tab cat_time
tab cat_time `outcome'
}

*-School closure: 20th December 2020 (previous analysis up to 19th December 2020) 
*-alpha variant 22nd March 2021 
*-delta variant 31st May 2021 
if "`outcome'"=="covidadmission" | "`outcome'"=="covid_death" {
stsplit cat_time, at(0,92,161,400)
recode cat_time 92=1 161=2 400=3
recode `outcome' .=0 
tab cat_time
tab cat_time `outcome'
}


foreach exposure_type in kids_cat4  {

	*Fit and save model
	capture stcox i.`exposure_type' age1 age2 age3 i.male if cat_time==`period', strata(stp) vce(cluster household_id)
	if _rc==0 {
		estimates
		estimates save ./output/an_univariable_cox_models_`exposure_type'_`outcome'_AGESEX_ageband_`x'_timeperiod`period'.ster, replace
		}
	else di "WARNING - `var' vs `outcome' MODEL DID NOT SUCCESSFULLY FIT"

}
drop cat_time
}
}
}
* Close log file
log close

exit, clear 
