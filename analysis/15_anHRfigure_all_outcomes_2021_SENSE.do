*************************************************************************
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell table containing sensitivity analysis (complete case for BMI and smoking, 
*and ethnicity) 
*
*Requires: final analysis dataset (analysis_dataset.dta)
*
*Coding: HFORBES, based on file from Krishnan Bhaskaran
*
*Date drafted: 30th June 2021
*************************************************************************
global outdir  	  "output" 
global logdir     "logs"
global tempdir    "tempdata"

* Open a log file
capture log close
log using "$logdir/15_an_tablecontents_HRtable_all_outcomes_ANALYSES_SENSE", text replace


***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real)
file write tablecontents_all_outcomes ("sense") _tab ("period") _tab ("age") _tab ("exposure") _tab ("exposure level") ///
_tab ("outcome") _tab ("HR")  _tab ("lci")  _tab ("uci")  _n
foreach period in 0 1 2  {
foreach x in 0 1 {
foreach outcome in  covid_tpp_prob covidadmission covid_death  {
forvalues i=1/3 {
foreach sense in 11thJuneCensor 1stVaccCensor 2ndVaccCensor {
local endwith "_tab"

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents_all_outcomes ("`sense'") _tab ("`period'") _tab ("`x'") _tab ("`variable'") _tab ("`i'") _tab ("`outcome'") _tab

	foreach modeltype of any plus_ethadj {
	
		local noestimatesflag 0 /*reset*/

*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if "`modeltype'"=="plus_ethadj" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY
	
		if "`modeltype'"=="plus_ethadj" {
				 estimates use ./output/an_multivariate_cox_models_`outcome'_`variable'_FULLYADJMODEL_ageband_`x'_timeperiod`period'_`sense'
				if _rc!=0 local noestimatesflag 1
				}
		
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE
		
		if `noestimatesflag'==0 & "`modeltype'"=="plus_ethadj"  {
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents_all_outcomes %4.2f (r(estimate)) _tab %4.2f (r(lb)) _tab %4.2f (r(ub)) _tab (e(N))  `endwith'
				else file write tablecontents_all_outcomes %4.2f ("ERR IN MODEL") `endwith'
			}
			
		*3) Save the estimates for plotting
		if `noestimatesflag'==0{
			if "`modeltype'"=="plus_ethadj"   {
				local hr = r(estimate)
				local lb = r(lb)
				local ub = r(ub)
				post HRestimates_all_outcomes  ("`sense'") ("`period'") ("`x'") ("`outcome'") ("`variable'") (`i') (`hr') (`lb') (`ub') 
				}
		}	
		} /*min adj, full adj*/
	} /*datasets*/
		
} /*variable levels*/
} /*age levels*/
} /*sense levels*/
}
end

*MAIN CODE TO PRODUCE TABLE CONTENTS


cap file close tablecontents_all_outcomes
file open tablecontents_all_outcomes using ./output/15_an_tablecontents_HRtable_all_outcomes_ANALYSES_SENSE.txt, t w replace 

tempfile HRestimates_all_outcomes
cap postutil clear
postfile HRestimates_all_outcomes str10 sense str10 period str10 x str10 outcome str27 variable i hr lci uci using `HRestimates_all_outcomes'


*Primary exposure
outputHRsforvar, variable("kids_cat4") min(1) max(3) 
file write tablecontents_all_outcomes _n

file close tablecontents_all_outcomes

postclose HRestimates_all_outcomes

use `HRestimates_all_outcomes', clear
save ./output/HRestimates_all_outcomes_SENSE, replace

log close
