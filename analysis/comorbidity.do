log using "logs/comorbidity", text replace
import delimited "output/input_comorbidity", clear
tab stroke_gp stroke_hes, row col
tab lung_cancer_gp lung_cancer_hes, row col
tab hypertension_gp hypertension_hes, row col
tab asthma_gp asthma_hes, row col
tab epilepsy_gp epilepsy_hes, row col
log close