********************************************************************************
*
*	Do-file:		10c_an_interaction_cox_models_vaccine_child_prevacc.do
*
*	Project:		Exposure children and COVID risk
*
*	Programmed by:	TCowling, based on Harriet's files
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file: 10c_an_interaction_cox_models_vaccine_`outcome'_child_prevacc.log
*
********************************************************************************
*
*	Purpose:		This do-file performs multivariable (fully adjusted) 
*					Cox models, with an interaction by vaccine and censoring
*                   when all children aged 12-17 in the household have had
*                   a 2nd vaccine dose (if they all have done)
*					b/l group is unvacc without kids.
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
log using "$logdir/10c_an_interaction_cox_models_vaccine_`outcome'_child_prevacc", text replace


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
/*use "C:\Users\qc18278\OneDrive - University of Bristol\Documents\GitHub\os-sch-children-2021\tempdata\cr_create_analysis_dataset_STSET_covid_death_ageband_0.dta", clear
*sample 20
local outcome covid_death*/

*Tidy vaccination data
replace covid_vacc_second_dose_date = . if ///
	covid_vacc_date == . | ///
	covid_vacc_date >= covid_vacc_second_dose_date
replace covid_vacc_third_dose_date = . if ///
	covid_vacc_date == . | ///
	covid_vacc_second_dose_date == . | ///
	covid_vacc_third_dose_date <= covid_vacc_second_dose_date | ///
	covid_vacc_third_dose_date <= covid_vacc_date
*drop if vacc date occur prior to study start
drop if covid_vacc_date<=d(20dec2020)
drop if covid_vacc_second_dose_date<=d(20dec2020)
drop if covid_vacc_third_dose_date<=d(20dec2020)

*Generate first and second vacc dates	
gen first_vacc_plus_7d=covid_vacc_date+7
gen second_vacc_plus_7d=covid_vacc_second_dose_date+7
gen third_vacc_plus_7d=covid_vacc_third_dose_date+7
format first_vacc_plus_7d second_vacc_plus_7d third_vacc_plus_7d %td

*Censor at date of all children aged 12-17 being vaccinated in hh
replace stime_`outcome' 	= all_under18vacc if stime_`outcome'>all_under18vacc
replace `outcome'=0 if stime_`outcome'<date_`outcome'
replace date_`outcome' = . if (date_`outcome' > stime_`outcome' ) 

*Drop those without any eligible follow-up
drop if enter_date>=stime_`outcome'

*Replace vacc date with missing if occur after end follow-up
replace first_vacc_plus_7d=. if first_vacc_plus_7d>=stime_`outcome'
replace second_vacc_plus_7d=. if second_vacc_plus_7d>=stime_`outcome'
replace third_vacc_plus_7d=. if third_vacc_plus_7d>=stime_`outcome'

stset stime_`outcome', fail(`outcome') 		///
	id(patient_id) enter(enter_date) origin(enter_date)


stsplit split1, after(first_vacc_plus_7d) at(0)
recode `outcome' .=0 
stsplit split2, after(second_vacc_plus_7d) at(0)
recode `outcome' .=0 
stsplit split3, after(third_vacc_plus_7d) at(0)
recode `outcome' .=0 
tab `outcome'

stset
bysort patient_id (_t): gen vaccine=_n


strate kids_cat4 if vaccine==1, per(100000)
strate kids_cat4 if vaccine==2, per(100000)
strate kids_cat4 if vaccine==3, per(100000)
strate kids_cat4 if vaccine==4, per(100000)


/*1st month dates
foreach month in jan feb mar apr may jun jul aug sep oct {
	di d(1`month'2021) 

}
stsplit month_time, at(0(30)300)
recode `outcome' .=0 


*Unadjusted  model (interaction)
streg i.vaccine if kids_cat4==0, dist(exp)
streg i.vaccine i.month_time if kids_cat4==0, dist(exp)

 *if different - add in calendar month variable to streg model, whch will explain how strate is changing over time. 
 stcox i.vaccine##i.kids_cat4

ereturn list
matrix list e(b)

if _rc==0 {
*testparm 1.`int_type'#i.`exposure_type'
di _n "kids_cat4=0 " _n "****************" 
*Must put terms in same order as appear in model
*make sure estimates are as expected in dummy data 
*group kids_cat4 and vaccine variable using egen to cross-check it's doing what expect 

lincom 1.vaccine+0.kids_cat4+ 1.vaccine#0.kids_cat4, eform
lincom 2.vaccine+0.kids_cat4+ 2.vaccine#0.kids_cat4, eform
lincom 3.vaccine+0.kids_cat4+ 3.vaccine#0.kids_cat4, eform

di _n "kids_cat4=1 " _n "****************"
lincom 1.vaccine+1.kids_cat4+ 1.vaccine#1.kids_cat4, eform
lincom 2.vaccine+1.kids_cat4+ 2.vaccine#1.kids_cat4, eform
lincom 3.vaccine+1.kids_cat4+ 3.vaccine#1.kids_cat4, eform


di _n "kids_cat4=2 " _n "****************"
lincom 1.vaccine+2.kids_cat4+ 1.vaccine#2.kids_cat4, eform
lincom 2.vaccine+2.kids_cat4+ 2.vaccine#2.kids_cat4, eform
lincom 3.vaccine+2.kids_cat4+ 3.vaccine#2.kids_cat4, eform

di _n "kids_cat4=3 " _n "****************"
lincom 1.vaccine+3.kids_cat4+ 1.vaccine#3.kids_cat4, eform
lincom 2.vaccine+3.kids_cat4+ 2.vaccine#3.kids_cat4, eform
lincom 3.vaccine+3.kids_cat4+ 3.vaccine#3.kids_cat4, eform

*effect of vaccination among kids_cat4=3 

di _n "kids_cat4=0 " _n "****************"
lincom 1.vaccine +1.vaccine#0.kids_cat4, eform
lincom 2.vaccine +2.vaccine#0.kids_cat4, eform
lincom 3.vaccine +3.vaccine#0.kids_cat4, eform

di _n "kids_cat4=1 " _n "****************"
lincom 1.vaccine +1.vaccine#1.kids_cat4, eform
lincom 2.vaccine +2.vaccine#1.kids_cat4, eform
lincom 3.vaccine +3.vaccine#1.kids_cat4, eform

di _n "kids_cat4=2 " _n "****************"
lincom 1.vaccine +1.vaccine#2.kids_cat4, eform
lincom 2.vaccine +2.vaccine#2.kids_cat4, eform
lincom 3.vaccine +3.vaccine#2.kids_cat4, eform

di _n "kids_cat4=3 " _n "****************"
lincom 1.vaccine +1.vaccine#3.kids_cat4, eform
lincom 2.vaccine +2.vaccine#3.kids_cat4, eform
lincom 3.vaccine +3.vaccine#3.kids_cat4, eform
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"			
*/
**Age spline model (not adj ethnicity, interaction)
stcox 	age1 age2 age3			///
			$demogadjlist	 			  	///
			$comordidadjlist		///
			i.vaccine##i.kids_cat4 ///
			, strata(stp) vce(cluster household_id) 
if _rc==0 {
*testparm 1.`int_type'#i.`exposure_type'
di _n "kids_cat4=0 " _n "****************"
lincom 1.vaccine+0.kids_cat4+ 1.vaccine#0.kids_cat4, eform
lincom 2.vaccine+0.kids_cat4+ 2.vaccine#0.kids_cat4, eform
lincom 3.vaccine+0.kids_cat4+ 3.vaccine#0.kids_cat4, eform
lincom 4.vaccine+0.kids_cat4+ 4.vaccine#0.kids_cat4, eform


di _n "kids_cat4=1 " _n "****************"
lincom 1.vaccine+1.kids_cat4+ 1.vaccine#1.kids_cat4, eform
lincom 2.vaccine+1.kids_cat4+ 2.vaccine#1.kids_cat4, eform
lincom 3.vaccine+1.kids_cat4+ 3.vaccine#1.kids_cat4, eform
lincom 4.vaccine+1.kids_cat4+ 4.vaccine#1.kids_cat4, eform


di _n "kids_cat4=2 " _n "****************"
lincom 1.vaccine+2.kids_cat4+ 1.vaccine#2.kids_cat4, eform
lincom 2.vaccine+2.kids_cat4+ 2.vaccine#2.kids_cat4, eform
lincom 3.vaccine+2.kids_cat4+ 3.vaccine#2.kids_cat4, eform
lincom 4.vaccine+2.kids_cat4+ 4.vaccine#2.kids_cat4, eform

di _n "kids_cat4=3 " _n "****************"
lincom 1.vaccine+3.kids_cat4+ 1.vaccine#3.kids_cat4, eform
lincom 2.vaccine+3.kids_cat4+ 2.vaccine#3.kids_cat4, eform
lincom 3.vaccine+3.kids_cat4+ 3.vaccine#3.kids_cat4, eform
lincom 4.vaccine+3.kids_cat4+ 4.vaccine#3.kids_cat4, eform

*effect of vaccination among kids_cat4=3 

di _n "kids_cat4=0 " _n "****************"
lincom 1.vaccine +1.vaccine#0.kids_cat4, eform
lincom 2.vaccine +2.vaccine#0.kids_cat4, eform
lincom 3.vaccine +3.vaccine#0.kids_cat4, eform
lincom 4.vaccine +4.vaccine#0.kids_cat4, eform

di _n "kids_cat4=1 " _n "****************"
lincom 1.vaccine +1.vaccine#1.kids_cat4, eform
lincom 2.vaccine +2.vaccine#1.kids_cat4, eform
lincom 3.vaccine +3.vaccine#1.kids_cat4, eform
lincom 4.vaccine +4.vaccine#1.kids_cat4, eform

di _n "kids_cat4=2 " _n "****************"
lincom 1.vaccine +1.vaccine#2.kids_cat4, eform
lincom 2.vaccine +2.vaccine#2.kids_cat4, eform
lincom 3.vaccine +3.vaccine#2.kids_cat4, eform
lincom 4.vaccine +4.vaccine#2.kids_cat4, eform

di _n "kids_cat4=3 " _n "****************"
lincom 1.vaccine +1.vaccine#3.kids_cat4, eform
lincom 2.vaccine +2.vaccine#3.kids_cat4, eform
lincom 3.vaccine +3.vaccine#3.kids_cat4, eform
lincom 4.vaccine +4.vaccine#3.kids_cat4, eform
}
estimates save ./output/an_interaction_cox_models_`outcome'_kids_cat4_vaccine_`x'_child_prevacc, replace

}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"
log close

exit, clear 
