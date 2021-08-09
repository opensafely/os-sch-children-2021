********************************************************************************
*
*	Do-file:		10_an_interaction_cox_models_sex.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	Hforbes, based on files from Fizz & Krishnan
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file:  10_an_interaction_cox_models.log
*
********************************************************************************
*
*	Purpose:		This do-file performs multivariable (fully adjusted) 
*					Cox models, with an interaction by sex.
*  
********************************************************************************
*	
*	Stata routines needed:	stbrier	  
*
********************************************************************************


* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "logs"
global tempdir    "tempdata"
global demogadjlist  age1 age2 age3 i.male i.ethnicity	i.obese4cat i.smoke_nomiss i.imd i.tot_adults_hh
global comordidadjlist  i.htdiag_or_highbp				///
			i.chronic_respiratory_disease 	///
			i.asthma						///
			i.chronic_cardiac_disease 		///
			i.diabcat						///
			i.cancer_exhaem_cat	 			///
			i.cancer_haem_cat  				///
			i.chronic_liver_disease 		///
			i.stroke_dementia		 		///
			i.other_neuro					///
			i.reduced_kidney_function_cat	///
			i.esrd							///
			i.other_transplant 				///
			i.asplenia 						///
			i.ra_sle_psoriasis  			///
			i.other_immuno		
local outcome `1' 
 


************************************************************************************
*First clean up all old saved estimates for this outcome
*This is to guard against accidentally displaying left-behind results from old runs
************************************************************************************
cap erase ./output/an_interaction_cox_models_`outcome'_`exposure_type'_male_FULLYADJMODEL_agespline_bmicat_noeth_ageband_0.ster
cap erase ./output/an_interaction_cox_models_`outcome'_`exposure_type'_male_FULLYADJMODEL_agespline_bmicat_noeth_ageband_1.ster


cap log close
log using "$logdir/10_an_interaction_cox_models_vaccine_`outcome'", text replace


*PROG TO DEFINE THE BASIC COX MODEL WITH OPTIONS FOR HANDLING OF AGE, BMI, ETHNICITY:
cap prog drop basemodel
prog define basemodel
	syntax , exposure(string)  age(string) [ethnicity(real 0) interaction(string)] 
timer clear
timer on 1
stcox 	`exposure'  								///
			$demogadjlist							///
			$comordidadjlist						///
			`interaction'							///
			, strata(stp) vce(cluster household_id)
	timer off 1
timer list
end
*************************************************************************************

* Open dataset and fit specified model(s)
foreach x in 0 {
forvalues period=0/2 {

use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear
gen first_vacc_plus_14d=covid_vacc_date+14
gen second_vacc_plus_14d=covid_vacc_second_dose_date+14
format first_vacc_plus_14d second_vacc_plus_14d %td

stsplit vaccine, after(first_vacc_plus_14d) at(0)
replace vaccine = vaccine +1
stsplit vaccine2, after(second_vacc_plus_14d) at(2)
replace vaccine2 = vaccine2 +1
replace vaccine=2 if vaccine2==2

bysort patient: replace vaccine=0 if _N==1
sort patient vaccine
bysort patient: replace vaccine=2 if _N==3 & vaccine2==3

recode `outcome' .=0 
tab vaccine
tab vaccine `outcome'
recode vaccine 1=0 2=1

foreach int_type in  vaccine  {

*Age interaction for 3-level exposure vars
foreach exposure_type in kids_cat4  {

*Age spline model (not adj ethnicity, no interaction)
basemodel, exposure("i.`exposure_type'") age("age1 age2 age3")  

*Age spline model (not adj ethnicity, interaction)
basemodel, exposure("i.`exposure_type'") age("age1 age2 age3")  ///
interaction(1.`int_type'#1.`exposure_type' 1.`int_type'#2.`exposure_type' 1.`int_type'#3.`exposure_type')
if _rc==0{
testparm 1.`int_type'#i.`exposure_type'
di _n "`exposure_type' " _n "****************"
lincom 1.`exposure_type' + 1.`int_type'#1.`exposure_type', eform
di "`exposure_type'" _n "****************"
lincom 2.`exposure_type' + 1.`int_type'#2.`exposure_type', eform
di "`exposure_type'" _n "****************"
lincom 3.`exposure_type' + 1.`int_type'#3.`exposure_type', eform
estimates save ./output/an_interaction_cox_models_`outcome'_`exposure_type'_`int_type'_`x'_timeperiod`period', replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"
}
}
}
}
log close

exit, clear 
