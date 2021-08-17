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
log using "$logdir/11_an_interaction_HR_tables_forest_vaccine_`outcome'.log", text replace

***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real) outcome(string)
file write tablecontents_int _tab ("exposure") _tab ("exposure level") _tab ("vaccine") ///
_tab ("outcome") _tab ("strata") _tab ("strata_level") ///
_tab ("HR")  _tab ("lci")  _tab ("uci") _tab ("pval") _n
foreach vaccine in 0 1 {
forvalues i=`min'/`max'{
foreach strata in male shield {

forvalues level=0/1 {

local endwith "_tab"

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents_int  _tab ("`variable'") _tab ("`i'") _tab ("`vaccine'") _tab ("`outcome'") _tab ("`strata'") _tab ("`level'") _tab

	foreach modeltype of any fulladj {

		local noestimatesflag 0 /*reset*/

*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if "`modeltype'"=="fulladj" local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY

		if "`modeltype'"=="fulladj" {
				cap estimates use ./output/an_interaction_cox_models_`outcome'_kids_cat4_vaccine_0`strata'`level'
				if _rc!=0 local noestimatesflag 1
				}
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE

		if `noestimatesflag'==0{
			if `vaccine'==0 {
			test 1.vaccine#`i'.`variable'
			*overall p-value for interaction: test 1.vaccine#1.`variable' test 1.`vaccine'#2.`variable'
			local pval=r(p)
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents_int %4.2f (r(estimate)) _tab %4.2f (r(lb)) _tab %4.2f (r(ub)) _tab %4.2f (`pval') `endwith'

				else file write tablecontents_int %4.2f ("ERR IN MODEL") `endwith'
				}
			if `vaccine'==1 {
			cap lincom `i'.`variable'+ 1.vaccine#`i'.`variable', eform
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
				test 1.vaccine#2.`variable' 1.vaccine#1.`variable'
				local pval=r(p)
				post HRestimates_int ("`vaccine'") ("`outcome'") ("`variable'") ("`strata'") (`i') (`level') (`hr') (`lb') (`ub') (`pval')
				drop `variable'
			}
		}
		}
		} /*level*/
		} /*full adj*/

} /*variable levels*/
} /*agebands*/
end
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS
cap file close tablecontents_int
file open tablecontents_int using ./output/11_an_int_tab_contents_HRtable_`outcome'_vaccine_strat.txt, t w replace

tempfile HRestimates_int
cap postutil clear
postfile HRestimates_int str10 vaccine str10 outcome str27 variable str27 strata i level hr lci uci pval using `HRestimates_int'

*Primary exposure
outputHRsforvar, variable("kids_cat4") min(1) max(3) outcome(`outcome')
file write tablecontents_int _n

file close tablecontents_int

postclose HRestimates_int

log close
