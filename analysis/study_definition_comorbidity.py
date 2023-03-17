# IMPORT STATEMENTS
# This imports the cohort extractor package. This can be downloaded via pip
from cohortextractor import (StudyDefinition, codelist, codelist_from_csv,
                             combine_codelists, filter_codes_by_category,
                             patients)

# IMPORT CODELIST DEFINITIONS FROM CODELIST.PY (WHICH PULLS THEM FROM
# CODELIST FOLDER
from codelists import *

# STUDY DEFINITION
study = StudyDefinition(
    index_date="2020-12-20",
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },
    
    # STUDY POPULATION
    population=patients.satisfying(
        "one_practice AND age >= 18",
        one_practice=patients.registered_with_one_practice_between(
            "2020-09-20", "index_date",
        ),
        age=patients.age_as_of(
            "index_date",
        ),
    ),
    
    # COMORBIDITIES IN GP DATA
    stroke_gp=patients.with_these_clinical_events(
        stroke,
        between=["index_date - 1 year", "index_date"],
    ),
    mi_gp = patients.with_these_clinical_events(
        myocardial_infarction,
        between=["index_date - 1 year", "index_date"],
    ),
    hf_gp = patients.with_these_clinical_events(
        heart_failure,
        between=["index_date - 1 year", "index_date"],
    ),
    hypertension_gp = patients.with_these_clinical_events(
        hypertension_codes,
        between=["index_date - 1 year", "index_date"],
    ),
    obesity_gp = patients.with_these_clinical_events(
        obesity,
        between=["index_date - 1 year", "index_date"],
    ),
    diabetes_gp = patients.with_these_clinical_events(
        combine_codelists(diabetes_t1_codes, diabetes_t2_codes, diabetes_unknown_codes),
        between=["index_date - 1 year", "index_date"],
    ),
    asthma_gp = patients.with_these_clinical_events(
        combine_codelists(current_asthma_codes, asthma_codes),
        between=["index_date - 1 year", "index_date"],
    ),
    lung_cancer_gp = patients.with_these_clinical_events(
        lung_cancer_codes,
        between=["index_date - 1 year", "index_date"],
    ),
    hypothyroidism_gp = patients.with_these_clinical_events(
        hypothyroidism,
        between=["index_date - 1 year", "index_date"],
    ),
    depression_gp = patients.with_these_clinical_events(
        depression,
        between=["index_date - 1 year", "index_date"],
    ),
    epilepsy_gp = patients.with_these_clinical_events(
        epilepsy,
        between=["index_date - 1 year", "index_date"],
    ),
    dementia_gp = patients.with_these_clinical_events(
        dementia,
        between=["index_date - 1 year", "index_date"],
    ),

    
    # COMORBIDITIES IN HOSPITAL DATA
    stroke_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_stroke.csv", system="icd10", column="icd10code",
        ),
        between=["index_date - 1 year", "index_date"],
    ),
    mi_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=mi_sus,
        between=["index_date - 1 year", "index_date"],
    ),
    hf_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=hf_sus,
        between=["index_date - 1 year", "index_date"],
    ),
    hypertension_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_hypertension.csv", system="icd10", column="icd10code",
        ),
        between=["index_date - 1 year", "index_date"],
    ),
    obesity_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=obesity_sus,
        between=["index_date - 1 year", "index_date"],
    ),
    diabetes_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=diabetes_sus,
        between=["index_date - 1 year", "index_date"],
    ),
    asthma_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_asthma.csv", system="icd10", column="icd10code",
        ),
        between=["index_date - 1 year", "index_date"],
    ),
    lung_cancer_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_lung_cancer.csv", system="icd10", column="icd10code",
        ),
        between=["index_date - 1 year", "index_date"],
    ),
    hypothyroidism_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=hypothyroid_sus,
        between=["index_date - 1 year", "index_date"],
    ),
    depression_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=depression_sus,
        between=["index_date - 1 year", "index_date"],
    ),
    epilepsy_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_epilepsy.csv", system="icd10", column="icd10code",
        ),
        between=["index_date - 1 year", "index_date"],
    ),
    dementia_hosp = patients.admitted_to_hospital(
        with_these_diagnoses=dementia_sus,
        between=["index_date - 1 year", "index_date"],
    ),
)
