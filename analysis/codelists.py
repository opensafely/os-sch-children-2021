from cohortextractor import codelist, codelist_from_csv

# OUTCOME CODELISTS
covid_codelist = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)

covid_identification_in_primary_care_case_codes_clinical = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_identification_in_primary_care_case_codes_test = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_identification_in_primary_care_case_codes_seq = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    system="ctv3",
    column="CTV3ID",
)

worms_codes = codelist_from_csv(
    "codelists/opensafely-worms.csv",
    system="ctv3",
    column="CTV3ID",
)

# DEMOGRAPHIC CODELIST
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)

# SMOKING CODELIST
clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

unclear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

# CLINICAL CONDITIONS CODELISTS
chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv", system="ctv3", column="CTV3ID",
)

current_asthma_codes = codelist_from_csv(
    "codelists/opensafely-current-asthma.csv",
    system="ctv3",
    column="CTV3ID",
)

asthma_codes = codelist_from_csv(
    "codelists/opensafely-asthma-diagnosis.csv", system="ctv3", column="CTV3ID"
)

salbutamol_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-salbutamol-medication.csv",
    system="snomed",
    column="id",
)

ics_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv",
    system="snomed",
    column="id",
)

pred_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv",
    system="snomed",
    column="snomed_id",
)

chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

diabetes_t1_codes = codelist_from_csv(
    "codelists/opensafely-type-1-diabetes.csv", system="ctv3", column="CTV3ID"
)

diabetes_t2_codes = codelist_from_csv(
    "codelists/opensafely-type-2-diabetes.csv", system="ctv3", column="CTV3ID"
)

diabetes_unknown_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-unknown-type.csv", system="ctv3", column="CTV3ID"
)

diabetes_t1t2_codes_exeter = codelist_from_csv(
        "codelists/opensafely-diabetes-exeter-group.csv", 
        system="ctv3", 
        column="CTV3ID",
        category_column="Category",
)

oad_med_codes = codelist_from_csv(
    "codelists/opensafely-antidiabetic-drugs.csv",
    system="snomed",
    column="id"
)


insulin_med_codes = codelist_from_csv(
    "codelists/opensafely-insulin-medication.csv", 
    system="snomed", 
    column="id"
)

hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID",
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID",
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID",
)

sickle_cell_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease.csv", system="ctv3", column="CTV3ID",
)

spleen_codes = codelist_from_csv(
    "codelists/opensafely-asplenia.csv", system="ctv3", column="CTV3ID",
)

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID",
)

chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv", system="ctv3", column="CTV3ID"
)

stroke = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv", system="ctv3", column="CTV3ID")

dementia = codelist_from_csv(
    "codelists/opensafely-dementia.csv", system="ctv3", column="CTV3ID")

other_neuro = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions.csv", system="ctv3", column="CTV3ID")

creatinine_codes = codelist(["XE2q5"], system="ctv3")

esrf_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID",
)

kidney_transplant_codes = codelist_from_csv(
    "codelists/opensafely-kidney-transplant.csv", system="ctv3", column="CTV3ID",
)

dialysis_codes = codelist_from_csv(
    "codelists/opensafely-dialysis.csv", system="ctv3", column="CTV3ID",
)

other_transplant_codes = codelist_from_csv(
    "codelists/opensafely-other-organ-transplant.csv", system="ctv3", column="CTV3ID",
)

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID",
)

ra_sle_psoriasis_codes = codelist_from_csv(
    "codelists/opensafely-ra-sle-psoriasis.csv", system="ctv3", column="CTV3ID"
)

systolic_blood_pressure_codes = codelist(["2469."], system="ctv3")
diastolic_blood_pressure_codes = codelist(["246A."], system="ctv3")

epilepsy = codelist_from_csv(
    "codelists/nhsd-primary-care-domain-refsets-epil_cod.csv", system="snomed", column="code",
)

obesity = codelist_from_csv(
    "codelists/nhsd-primary-care-domain-refsets-bmiobese_cod.csv", system="snomed", column="code",
)

myocardial_infarction = codelist_from_csv(
    "codelists/opensafely-myocardial-infarction.csv", system="ctv3", column="CTV3ID",
)

heart_failure = codelist_from_csv(
    "codelists/opensafely-heart-failure.csv", system="ctv3", column="CTV3ID",
)

hypothyroidism = codelist_from_csv(
    "codelists/nhsd-primary-care-domain-refsets-thy_cod.csv", system="snomed", column="code",
)

depression = codelist_from_csv(
    "codelists/opensafely-depression.csv", system="ctv3", column="CTV3Code",
)

# ICD-10 codelists (taken from Simard et al. 2018 Medical Care)

hypertension_sus = codelist(["I10", "I11", "I12", "I13", "I15", "I674"], system = "icd10")

diabetes_sus = codelist(["E10","E11","E13","E14"], system = "icd10")

cancer_sus = codelist(["C0","C1","C2","C3",
                        "C40","C41","C43","C45","C46","C47","C48","C49",
                        "C5","C6",
                        "C70","C71","C72","C73","C74","C75","C76",
                        "C81","C82","C83","C84","C85","C88",
                        "C90", "C902","C96"], system = "icd10")

met_cancer_sus = codelist(["C77","C78","C79","C80"], system = "icd10")

hypothyroid_sus = codelist(["E00","E01","E02","E03","E890"], system = "icd10")

mi_sus = codelist(["I21","I22","I252"], system = "icd10")

hf_sus = codelist(["I099","I110","I130","I132","I255","I420","I425","I426","I427","I428","I429",
                    "I43","I50","P290"], system = "icd10")

obesity_sus = codelist(["E66"], system = "icd10")

dementia_sus = codelist(["F00","F01","F02","F03","F051","G30","G311"], system = "icd10")

stroke_sus = codelist(["G45","G46","I6"], system = "icd10")

depression_sus = codelist(["F204","F313","F314","F315","F32","F33","F341",
                            "F412","F432"], system = "icd10")