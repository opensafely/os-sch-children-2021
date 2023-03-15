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
    population=patients.registered_with_one_practice_between(
        "2020-09-20", "index_date",
    ),
    
    # COMORBIDITIES IN GP DATA
    stroke_gp=patients.with_these_clinical_events(
        stroke,
        on_or_after="index_date - 1 year",
    ),
    lung_cancer_gp = patients.with_these_clinical_events(
        lung_cancer_codes,
        on_or_after="index_date - 1 year",
    ),
    hypertension_gp = patients.with_these_clinical_events(
        hypertension_codes,
        on_or_after="index_date - 1 year",
    ),
    asthma_gp = patients.with_these_clinical_events(
        combine_codelists(current_asthma_codes, asthma_codes),
        on_or_after="index_date - 1 year",
    ),
    epilepsy_gp = patients.with_these_clinical_events(
        epilepsy,
        on_or_after="index_date - 1 year",
    ),

    # COMORBIDITIES IN HOSPITAL DATA
    stroke_hes = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_stroke.csv", system="icd10", column="icd10code",
        ),
        on_or_after="index_date - 1 year",
    ),
    lung_cancer_hes = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_lung_cancer.csv", system="icd10", column="icd10code",
        ),
        on_or_after="index_date - 1 year",
    ),
    hypertension_hes = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_hypertension.csv", system="icd10", column="icd10code",
        ),
        on_or_after="index_date - 1 year",
    ),
    asthma_hes = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_asthma.csv", system="icd10", column="icd10code",
        ),
        on_or_after="index_date - 1 year",
    ),
    epilepsy_hes = patients.admitted_to_hospital(
        with_these_diagnoses=codelist_from_csv(
            "codelists/ccs/icd_epilepsy.csv", system="icd10", column="icd10code",
        ),
        on_or_after="index_date - 1 year",
    ),
)
