*open log file
log using "logs/comorbidity", text replace

*1-year lookback period
import delimited "output/input_comorbidity", clear
tab stroke_gp stroke_hosp, row col
tab mi_gp mi_hosp, row col
tab hf_gp hf_hosp, row col
tab hypertension_gp hypertension_hosp, row col
tab obesity_gp obesity_hosp, row col
tab diabetes_gp diabetes_hosp, row col
tab asthma_gp asthma_hosp, row col
tab lung_cancer_gp lung_cancer_hosp, row col
tab hypothyroidism_gp hypothyroidism_hosp, row col
tab depression_gp depression_hosp, row col
tab epilepsy_gp epilepsy_hosp, row col
tab dementia_gp dementia_hosp, row col

*5-year lookback period
import delimited "output/input_comorbidity_5y", clear
tab stroke_gp stroke_hosp, row col
tab mi_gp mi_hosp, row col
tab hf_gp hf_hosp, row col
tab hypertension_gp hypertension_hosp, row col
tab obesity_gp obesity_hosp, row col
tab diabetes_gp diabetes_hosp, row col
tab asthma_gp asthma_hosp, row col
tab lung_cancer_gp lung_cancer_hosp, row col
tab hypothyroidism_gp hypothyroidism_hosp, row col
tab depression_gp depression_hosp, row col
tab epilepsy_gp epilepsy_hosp, row col
tab dementia_gp dementia_hosp, row col

*close log file
log close