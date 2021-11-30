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
*					Cox models, with an interaction by vaccine: 
*					b/l group is those without kids in each vaccination group
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
log using "$logdir/10_an_interaction_cox_models_vaccine_`outcome'_stratified", text replace


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
foreach x in 0 1 {

use "$tempdir/cr_create_analysis_dataset_STSET_`outcome'_ageband_`x'.dta", clear

replace covid_vacc_second_dose_date=. if covid_vacc_date>=covid_vacc_second_dose_date
replace covid_vacc_second_dose_date=. if covid_vacc_date==. 
drop if covid_vacc_date<d(20dec2020)
drop if covid_vacc_second_dose_date<d(20dec2020)

*Censor at date of first child being vaccinated in hh
replace stime_`outcome' 	= under18vacc if stime_`outcome'>under18vacc
replace `outcome'=0 if stime_`outcome'<date_`outcome'
*Drop those without any eligible follow-up
drop if enter_date>=stime_`outcome'
*Generate first and second vacc dates	
gen first_vacc_plus_7d=covid_vacc_date+7
gen second_vacc_plus_7d=covid_vacc_second_dose_date+7
format first_vacc_plus_7d second_vacc_plus_7d %td

*Replace vacc date with missing if occur after end follow-up
replace first_vacc_plus_7d=. if first_vacc_plus_7d> stime_`outcome'
replace second_vacc_plus_7d=. if second_vacc_plus_7d> stime_`outcome'

stset stime_`outcome', fail(`outcome') 		///
	id(patient_id) enter(enter_date) origin(enter_date)


stsplit split1, after(first_vacc_plus_7d) at(0)
recode `outcome' .=0 
stsplit split2, after(second_vacc_plus_7d) at(0)
recode `outcome' .=0 

stset
bysort patient_id (_t): gen vaccine=_n
strate vaccine if kids_cat4==0, per(100000)
strate vaccine if kids_cat4==1, per(100000)




foreach int_type in  vaccine  {

*Age interaction for 3-level exposure vars
foreach exposure_type in kids_cat4  {

*Age spline model (not adj ethnicity, interaction)
basemodel, exposure("i.`exposure_type'") age("age1 age2 age3")  ///
interaction(i.`int_type'##i.`exposure_type')
if _rc==0{
*testparm 1.`int_type'#i.`exposure_type'
di _n "`exposure_type' " _n "****************"

lincom 0.`exposure_type' + 1.`int_type'#0.`exposure_type', eform
lincom 1.`exposure_type' + 1.`int_type'#1.`exposure_type', eform
lincom 2.`exposure_type' + 1.`int_type'#2.`exposure_type', eform
lincom 3.`exposure_type' + 1.`int_type'#3.`exposure_type', eform

lincom 0.`exposure_type' + 2.`int_type'#0.`exposure_type', eform
lincom 1.`exposure_type' + 2.`int_type'#1.`exposure_type', eform
lincom 2.`exposure_type' + 2.`int_type'#2.`exposure_type', eform
lincom 3.`exposure_type' + 2.`int_type'#3.`exposure_type', eform

lincom 0.`exposure_type' + 3.`int_type'#0.`exposure_type', eform
lincom 1.`exposure_type' + 3.`int_type'#1.`exposure_type', eform
lincom 2.`exposure_type' + 3.`int_type'#2.`exposure_type', eform
lincom 3.`exposure_type' + 3.`int_type'#3.`exposure_type', eform

estimates save ./output/an_interaction_cox_models_`outcome'_`exposure_type'_`int_type'_`x'_stratified, replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"
}
}
}
log close

exit, clear 
