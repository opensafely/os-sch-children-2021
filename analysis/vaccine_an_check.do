cap drop vaccine_kids_cat4 
gen vaccine_kids_cat4=1 if kids_cat4==0 & vaccine==1
replace vaccine_kids_cat4=2 if kids_cat4==0 & vaccine==2
replace vaccine_kids_cat4=3 if kids_cat4==0 & vaccine==3

replace vaccine_kids_cat4=4 if kids_cat4==1 & vaccine==1
replace vaccine_kids_cat4=5 if kids_cat4==1 & vaccine==2
replace vaccine_kids_cat4=6 if kids_cat4==1 & vaccine==3

replace vaccine_kids_cat4=7 if kids_cat4==2 & vaccine==1
replace vaccine_kids_cat4=8 if kids_cat4==2 & vaccine==2
replace vaccine_kids_cat4=9 if kids_cat4==2 & vaccine==3

replace vaccine_kids_cat4=10 if kids_cat4==3 & vaccine==1
replace vaccine_kids_cat4=11 if kids_cat4==3 & vaccine==2
replace vaccine_kids_cat4=12 if kids_cat4==3 & vaccine==3


stcox i.vaccine_kids_cat4 ///
			, strata(stp) vce(cluster household_id) 

