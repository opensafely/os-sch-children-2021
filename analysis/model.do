*Model do file

*When running in parallel locally use "C:\Program Files\Stata16\StataMP-64.exe"
*When running on server use "c:/program files/stata16/statamp-64.exe"

*Import dataset into STATA
*import delimited `c(pwd)'/output/input.csv, clear

cd  "`c(pwd)'/analysis" /*sets working directory to workspace folder*/
set more off 

***********************HOUSE-KEEPING*******************************************
* Create directories required 
capture mkdir output
capture mkdir logs
capture mkdir tempdata


* Set globals that will print in programs and direct output
global outdir  	  "output" 
global logdir     "logs"
global tempdir    "tempdata"

********************************************************************************


*  Pre-analysis data manipulation  *
do "01_cr_analysis_dataset.do" 



/*  Checks  */
do "02_an_data_checks.do"



*********************************************************************
*IF PARALLEL WORKING - FOLLOWING CAN BE RUN IN ANY ORDER/IN PARALLEL*
*       PROVIDING THE ABOVE CR_ FILE HAS BEEN RUN FIRST				*
*********************************************************************

do "03a_an_descriptive_tables.do" 

do "03b_an_descriptive_table_1.do" 

do "04a_an_descriptive_tables.do" 

do "04b_an_descriptive_table_2.do"

************************************************************
 do "06_univariate_analysis.do"


*MULTIVARIATE MODELS (this fits the models needed for fully adj col of Table 2)
 do "07a_an_multivariable_cox_models_demogADJ.do"  

foreach outcome of any covid_tpp_prob   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "07b_an_multivariable_cox_models_FULL.do" `outcome' 
}

*INTERACTIONS 
*Sex
foreach outcome of any covid_tpp_prob   {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_sex" `outcome'	
}

*Vaccine
foreach outcome of any covid_tpp_prob    {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_vaccine" `outcome'
}

*Sheild
foreach outcome of any covid_tpp_prob    {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10_an_interaction_cox_models_shield" `outcome'
}

*Vaccine strata
foreach outcome of any covid_tpp_prob    {
winexec "C:\Program Files\Stata16\StataMP-64.exe"  do "10a_an_interaction_cox_models_vaccine_sex_shield" `outcome'
}

*Tabulate results
foreach outcome of any  covid_tpp_prob covid_death covid_icu covidadmission   {
	do "08_an_tablecontent_HRtable.do" `outcome'
}

*put results in figure
do "15_anHRfigure_all_outcomes.do"

foreach outcome of any  covid_tpp_prob     {
	do "11_an_interaction_HR_tables_forest.do" 	 `outcome'
}

foreach outcome of any  covid_tpp_prob      {
	do "11_an_interaction_HR_tables_forest_vaccine_analysis.do" 	 `outcome'
}	
