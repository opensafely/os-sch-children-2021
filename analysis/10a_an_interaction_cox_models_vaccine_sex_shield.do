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
cap erase ./output/an_interaction_cox_models_`outcome'_kids_cat4_male_FULLYADJMODEL_agespline_bmicat_noeth_ageband_0.ster
cap erase ./output/an_interaction_cox_models_`outcome'_kids_cat4_male_FULLYADJMODEL_agespline_bmicat_noeth_ageband_1.ster


cap log close
log using "$logdir/10_an_interaction_cox_models_vaccine_`outcome'_sex_shield", text replace

*************************************************************************************

* Open dataset and fit specified model(s)
foreach x in 0 1 {

use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear

*Censor at date of first child being vaccinated in hh
replace stime_`outcome' 	= under18vacc if stime_`outcome'>under18vacc
stset stime_`outcome', fail(`outcome') 		///
	id(patient_id) enter(enter_date) origin(enter_date)

gen first_vacc_plus_7d=covid_vacc_date+7
gen second_vacc_plus_7d=covid_vacc_second_dose_date+7
format first_vacc_plus_7d second_vacc_plus_7d %td
 
stsplit vaccine, after(first_vacc_plus_7d) at(0)
replace vaccine = vaccine +1
stsplit vaccine2, after(second_vacc_plus_7d) at(0)
replace vaccine=2 if vaccine==1 &vaccine2==0 & second_vacc_plus_7d!=.
recode `outcome' .=0 

tab vaccine
tab vaccine `outcome'
foreach strata in male shield {

foreach level in 0 1 {	

*Age spline model (not adj ethnicity, interaction)
stcox 	i.kids_cat4  	age1 age2 age3					///
			$demogadjlist							///
			$comordidadjlist						///
			1.vaccine#0.kids_cat4 1.vaccine#1.kids_cat4 1.vaccine#2.kids_cat4 1.vaccine#3.kids_cat4 2.vaccine#0.kids_cat4 2.vaccine#1.kids_cat4 2.vaccine#2.kids_cat4 2.vaccine#3.kids_cat4	if `strata'==`level'				///
			, strata(stp) vce(cluster household_id)
if _rc==0 	{
di _n "kids_cat4 " _n "****************"
lincom 1.kids_cat4 + 1.vaccine#1.kids_cat4, eform
di "kids_cat4" _n "****************"
lincom 2.kids_cat4 + 1.vaccine#2.kids_cat4, eform
di "kids_cat4" _n "****************"
lincom 3.kids_cat4 + 1.vaccine#3.kids_cat4, eform
di _n "kids_cat4 " _n "****************"
lincom 1.kids_cat4 + 2.vaccine#1.kids_cat4, eform
di "kids_cat4" _n "****************"
lincom 2.kids_cat4 + 2.vaccine#2.kids_cat4, eform
di "kids_cat4" _n "****************"
lincom 3.kids_cat4 + 2.vaccine#3.kids_cat4, eform
estimates save ./output/an_interaction_cox_models_`outcome'_kids_cat4_vaccine_`x'`strata'`level', replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"
}
}
}
log close

exit, clear 
