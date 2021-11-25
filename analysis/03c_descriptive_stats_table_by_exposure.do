*Descriptive stats table

foreach age in 0 1 {
import delimited "./output/03b_an_descriptive_table_1_kids_cat4_ageband`age'.txt", encoding(ISO-8859-2) clear 

gen varcat = v1 + v2 
drop if varcat=="cons==1"


/*
rename v3 "Total cohort, n (%)"	
rename var4 "No children" 	
rename var5 "Only children aged 0-11 years" 	
rename var6 "Only children aged 12-18  years" 
rename var7 "Children aged 0-11 and 12-18 years" */

gen variable=""
replace variable="18-<30" if varcat=="agegroup==1"
replace variable="30-<40" if varcat=="agegroup==2"
replace variable="40-<50" if varcat=="agegroup==3"
replace variable="50-<60" if varcat=="agegroup==4"
replace variable="60-<66" if varcat=="agegroup==5"
replace variable="66-70" if varcat=="agegroup==6"
replace variable="70-80" if varcat=="agegroup==7"
replace variable="80+" if varcat=="agegroup==8"


replace variable="Female" if varcat=="male==0"
replace variable="Male" if varcat=="male==1"

replace variable="<18.5" if varcat=="bmicat==1"
replace variable="18.5-24.9" if varcat=="bmicat==2"
replace variable="25-29.9" if varcat=="bmicat==3"
replace variable="30-34.9" if varcat=="bmicat==4"
replace variable="35-39.9" if varcat=="bmicat==5"
replace variable="≥40" if varcat=="bmicat==6"
replace variable="Missing" if varcat=="bmicat>=."

replace variable="Never" if varcat=="smoke==1"
replace variable="Former" if varcat=="smoke==2"
replace variable="Current" if varcat=="smoke==3"
replace variable="Missing" if varcat=="smoke>=."

replace variable="White" if varcat=="ethnicity==1"
replace variable="Mixed" if varcat=="ethnicity==2"
replace variable="South Asian" if varcat=="ethnicity==3"
replace variable="Black" if varcat=="ethnicity==4"
replace variable="Other" if varcat=="ethnicity==5"

replace variable="1 (least deprived)" if varcat=="imd==1"
replace variable="2" if varcat=="imd==2"
replace variable="3" if varcat=="imd==3"
replace variable="4" if varcat=="imd==4"
replace variable="5 (most deprived)" if varcat=="imd==5"

replace variable="1" if varcat=="tot_adults_hh==1"
replace variable="2" if varcat=="tot_adults_hh==2"
replace variable="3" if varcat=="tot_adults_hh==3"

replace variable="Any comorbidity" if varcat=="anycomorb==1"

drop if variable==""
di "*****1"

if `age'==0 {
drop if varcat=="agegroup==6"
drop if varcat=="agegroup==7"
drop if varcat=="agegroup==8"

}
if `age'==1 {
drop if varcat=="agegroup==1"
drop if varcat=="agegroup==2"
drop if varcat=="agegroup==3"
drop if varcat=="agegroup==4"
drop if varcat=="agegroup==5"
}
di "*****2"
gen littlen=_n
bysort v1 (littlen): gen smalln=_n

sort littlen
expand 2 if smalln==1 /*works to here*/
desc
sort littlen
drop littlen 
drop smalln
gen littlen=_n
di "*****3"
bysort v1 (littlen): gen smalln=_n

foreach var in v3 v4 v5 v6 v7 v8 v9 v10 v11 v12  {
	replace `var'=. if smalln==1
}
foreach var in v1 v2 variable {
	replace `var'="" if smalln==1
}
replace v1="Age group" if v1=="agegroup"
replace v1="" if v1=="anycomorb"
replace v1="BMI" if v1=="bmicat"
replace v1="Ethnicity" if v1=="ethnicity"
replace v1="IMD" if v1=="imd"
replace v1="Sex" if v1=="male"
replace v1="Smoking" if v1=="smoke"
replace v1="Adults in HH" if v1=="tot_adults_hh"

graph hbar v4 v6 v8 v10 v12, nofill ///
over(variable, label(labsize(tiny)) sort(littlen))  ///
over(v1, label(labsize(vsmall)) gap(400))  ///
ysize(15) xsize(10) ///
legend( label(1 "Total cohort, n (%)") label(2 "No children")  label(3 "Only children 0-11 years")  label(4 "Only children 12-18 years") label(5 "Children 0-11 and 12-18 years")) legend(size(tiny) rows(2) symysize(2) symxsize(2) ) saving(output/Descriptive_table1_age`age', replace)
}
graph combine output/Descriptive_table1_age0.gph output/Descriptive_table1_age1.gph,  ///
 graphregion(color(white)) col(2)
graph export "output/Descriptive_figure1.svg", as(svg) replace 

/*
rename v3 ""	
rename var4 "No children" 	
rename var5 "" 	
rename var6 "" 
rename var7 "Children aged 0-11 and 12-18 years" */