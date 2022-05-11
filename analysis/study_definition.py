# IMPORT STATEMENTS
# This imports the cohort extractor package. This can be downloaded via pip
from cohortextractor import (StudyDefinition, codelist, codelist_from_csv,
                             combine_codelists, filter_codes_by_category,
                             patients)

# IMPORT CODELIST DEFINITIONS FROM CODELIST.PY (WHICH PULLS THEM FROM
# CODELIST FOLDER
from codelists import *

# STUDY DEFINITION
# Defines both the study population and points to the important covariates and outcomes
study = StudyDefinition(
    index_date="2020-12-20",
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },
    # STUDY POPULATION
    population=patients.registered_with_one_practice_between(
        "2020-09-20", "index_date"
    ),
    dereg_date=patients.date_deregistered_from_all_supported_practices(
    on_or_after="index_date", date_format="YYYY-MM",
    ),
    # FOLLOW UP
    has_12_m_follow_up=patients.registered_with_one_practice_between(
        "2019-12-19", "index_date", ### 12 months prior to 20th Dec 2020
        return_expectations={
            "incidence": 0.95,
        },
    ),
    # OUTCOMES
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_after="index_date",
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.6},
    ),
    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_after="index_date",
        match_only_underlying_cause=True,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.6},
    ),
    died_date_ons=patients.died_from_any_cause(
        on_or_after="index_date",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.8}
    ),
    covid_tpp_probable=patients.with_these_clinical_events(
        combine_codelists(
            covid_identification_in_primary_care_case_codes_clinical,
            covid_identification_in_primary_care_case_codes_test,
            covid_identification_in_primary_care_case_codes_seq,
        ),
        return_first_date_in_period=True,
        include_day=True,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.95},
    ), 

   covid_tpp_codes_clinical=patients.with_these_clinical_events(
        combine_codelists(covid_identification_in_primary_care_case_codes_clinical),
        return_first_date_in_period=True,
        include_day=True,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.5},
    ), 

   covid_tpp_codes_test=patients.with_these_clinical_events(
        combine_codelists(covid_identification_in_primary_care_case_codes_test),
        return_first_date_in_period=True,
        include_day=True,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.5},
    ), 

   covid_tpp_codes_seq=patients.with_these_clinical_events(
        combine_codelists(covid_identification_in_primary_care_case_codes_seq),
        return_first_date_in_period=True,
        include_day=True,
        return_expectations={"date": {"earliest": "index_date"}, "incidence" : 0.5},
    ), 
  
    covid_admission_date=patients.admitted_to_hospital(
        returning="date_admitted",  # defaults to "binary_flag"
        with_these_diagnoses=covid_codelist,  # optional
        on_or_after="index_date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD",  
        return_expectations={"date": {"earliest": "2020-11-20"}, "incidence" : 0.5},
   ),
	covid_admission_primary_diagnosis=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=covid_codelist,  # optional
        on_or_after="index_date",
        find_first_match_in_period=True,  
        date_format="YYYY-MM-DD", 
        return_expectations={"date": {"earliest": "2020-11-20"},"incidence" : 0.5,
            "category": {"ratios": {"U071":0.5, "U072":0.5}},
        },
    ),
    positive_covid_test_ever=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date"},
            "rate": "exponential_increase",
        },
    ),
    covid_test_ever=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="any",
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date"},
            "rate": "exponential_increase",
        },
    ),
    sgtf=patients.with_test_result_in_sgss(
       pathogen="SARS-CoV-2",
       test_result="positive",
       find_first_match_in_period=True,
       on_or_after="index_date",
       returning="s_gene_target_failure",
       return_expectations={
            "rate": "universal",
            "category": {"ratios": {"0": 0.4, "1": 0.4, "9": 0.1, "": 0.1}},
        },
    ),
    lft_pcr=patients.with_test_result_in_sgss(
       pathogen="SARS-CoV-2",
       test_result="positive",
       find_first_match_in_period=True,
       on_or_after="index_date",
       returning="case_category",
       return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {"LFT_Only": 0.4, "PCR_Only": 0.4, "LFT_WithPCR": 0.2}
            },
        },
    ),
    ###############################################################################
    # COVID VACCINATION
    ###############################################################################
    # any COVID vaccination (first dose)
    covid_vacc_date=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="2020-12-01",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-12-08",  # first vaccine administered on the 8/12
                "latest": "2021-07-01",    # artificial to improve dose sequencing
            },
            "incidence": 0.99,
        },
    ),
    # SECOND DOSE COVID VACCINATION
    covid_vacc_second_dose_date=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="covid_vacc_date + 21 days",  
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2021-06-01",  # artificial dates to improve dose sequencing
                "latest": "2021-10-01",
            },
            "incidence": 0.98,
        },
    ),
    # THIRD DOSE COVID VACCINATION
    covid_vacc_third_dose_date=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="covid_vacc_second_dose_date + 21 days",  
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2021-09-01",  # date JCVI recommended 3rd dose for immunosuppressed
                "latest": "2022-04-01",
            },
            "incidence": 0.95,  # too high but useful for dummy data
        },
    ),
    ## DEMOGRAPHIC COVARIATES
    # AGE
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    # SEX
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    # DEPRIVIATION
    imd=patients.address_as_of(
        "index_date",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    # GEOGRAPHIC REGION CALLED STP
    stp=patients.registered_practice_as_of(
        "index_date",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "STP1": 0.1,
                    "STP2": 0.1,
                    "STP3": 0.1,
                    "STP4": 0.1,
                    "STP5": 0.1,
                    "STP6": 0.1,
                    "STP7": 0.1,
                    "STP8": 0.1,
                    "STP9": 0.1,
                    "STP10": 0.1,
                }
            },
        },
    ),
    # ETHNICITY IN 6 CATEGORIES
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.9,
        },
    ),
    # HOUSEHOLD INFORMATION
    household_id=patients.household_as_of(
        "2020-02-01",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 1000, "stddev": 200},
            "incidence": 1,
        },
    ),
    household_size=patients.household_as_of(
        "2020-02-01",
        returning="household_size",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),

        care_home_type=patients.care_home_status_as_of(
        "index_date",
        categorised_as={
            "PC": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='Y'
              AND LocationRequiresNursing='N'
            """,
            "PN": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='N'
              AND LocationRequiresNursing='Y'
            """,
            "PS": "IsPotentialCareHome",
            "U": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "PC": 0.01,
                    "PN": 0.01,
                    "PS": 0.01,
                    "U": 0.97,
                },
            },
        },
    ),
    # CONTINUOUS MEASURED COVARIATES
    bmi=patients.most_recent_bmi(
        on_or_after="2010-02-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2015-01-31"},
            "float": {"distribution": "normal", "mean": 25, "stddev": 10},
            "incidence": 0.95,
        },
    ),
    # Blood pressure
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="index_date",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            "date": {"latest": "2020-12-19"},
            "incidence": 0.95,
        },
    ),
    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="index_date",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            "date": {"latest": "2020-12-19"},
            "incidence": 0.95,
        },
    ),
    # # Creatinine
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before="index_date",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"earliest": "2019-02-28", "latest": "2020-12-19"},
            "incidence": 0.95,
        },
    ),
    # COVARIATES
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                 most_recent_smoking_code = 'E' OR (
                   most_recent_smoking_code = 'N' AND ever_smoked
                 )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="index_date",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="index_date",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="index_date",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-12-19"},
            "incidence": 0.95,
        },
    ),
    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    # DIABETES TYPE
    type1_diabetes=patients.with_these_clinical_events(
        diabetes_t1_codes,
        on_or_before="index_date",
        return_first_date_in_period=True,
        include_month=True,
    ),
    type2_diabetes=patients.with_these_clinical_events(
        diabetes_t2_codes,
        on_or_before="index_date",
        return_first_date_in_period=True,
        include_month=True,
    ),
    unknown_diabetes=patients.with_these_clinical_events(
        diabetes_unknown_codes,
        on_or_before="index_date",
        return_first_date_in_period=True,
        include_month=True,
    ),
    diabetes_type=patients.categorised_as(
        {
            "T1DM": """
                        (type1_diabetes AND NOT
                        type2_diabetes) 
                    OR
                        (((type1_diabetes AND type2_diabetes) OR 
                        (type1_diabetes AND unknown_diabetes AND NOT type2_diabetes) OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes))
                        AND 
                        (insulin_lastyear_meds > 0 AND NOT
                        oad_lastyear_meds > 0))
                """,
            "T2DM": """
                        (type2_diabetes AND NOT
                        type1_diabetes)
                    OR
                        (((type1_diabetes AND type2_diabetes) OR 
                        (type2_diabetes AND unknown_diabetes AND NOT type1_diabetes) OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes))
                        AND 
                        (oad_lastyear_meds > 0))
                """,
            "UNKNOWN_DM": """
                        ((unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes) AND NOT
                        oad_lastyear_meds AND NOT
                        insulin_lastyear_meds) 
                """,
            "NO_DM": "DEFAULT",
        },
        return_expectations={
            "category": {
                "ratios": {"T1DM": 0.03, "T2DM": 0.2, "UNKNOWN_DM": 0.02, "NO_DM": 0.75}
            },
            "rate": "universal",
        },
        oad_lastyear_meds=patients.with_these_medications(
            oad_med_codes, 
            between=["2019-12-20", "index_date"],
            returning="number_of_matches_in_period",
        ),
        insulin_lastyear_meds=patients.with_these_medications(
            insulin_med_codes,
            between=["2019-12-20", "index_date"],
            returning="number_of_matches_in_period",
        ),
    ),
    ## HBA1C
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before="index_date",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before="index_date",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),
    # CANCER - 3 TYPES
    cancer_haem=patients.with_these_clinical_events(
        haem_cancer_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    cancer_nonhaem=patients.with_these_clinical_events(
        combine_codelists(lung_cancer_codes, other_cancer_codes),
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    #### PERMANENT
    permanent_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(hiv_codes, permanent_immune_codes, sickle_cell_codes),
        on_or_before="2020-12-19",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    asplenia=patients.with_these_clinical_events(
        spleen_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    ### TEMPROARY IMMUNE
    temporary_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(temp_immune_codes, aplastic_codes),
        between=["2020-12-19", "2019-12-20"],  ## THIS IS RESTRICTED TO LAST YEAR
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-12-20", "latest": "2020-12-19"}
        },
    ),
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    stroke_dementia=patients.with_these_clinical_events(
        combine_codelists(stroke, dementia),
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    other_neuro=patients.with_these_clinical_events(
        other_neuro,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    # END STAGE RENAL DISEASE - DIALYSIS, TRANSPLANT OR END STAGE RENAL DISEASE
    esrf=patients.with_these_clinical_events(
        esrf_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    # Dialysis
    dialysis=patients.with_these_clinical_events(
        dialysis_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    # Kidney transplant
    kidney_transplant=patients.with_these_clinical_events(
        kidney_transplant_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    # Other organ transplant
    other_transplant=patients.with_these_clinical_events(
        other_transplant_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),
    # hypertension
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        return_first_date_in_period=True,
        include_month=True,
    ),
    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-12-19"}},
    ),

    # asthma
    asthma=patients.categorised_as(
        {
            "0": "DEFAULT",
            "1": """
                (
                  recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                  )
                ) AND (
                  prednisolone_last_year = 0 OR 
                  prednisolone_last_year > 4
                )
            """,
            "2": """
                (
                  recent_asthma_code OR (
                    asthma_code_ever AND NOT
                    copd_code_ever
                  )
                ) AND
                prednisolone_last_year > 0 AND
                prednisolone_last_year < 5
                
            """,
        },
        return_expectations={"category": {"ratios": {"0": 0.6, "1": 0.1, "2": 0.3}}},
        recent_asthma_code=patients.with_these_clinical_events(
            asthma_codes, between=["2017-12-20", "index_date"], 
        ),
        asthma_code_ever=patients.with_these_clinical_events(asthma_codes),
        copd_code_ever=patients.with_these_clinical_events(
            chronic_respiratory_disease_codes
        ),
        prednisolone_last_year=patients.with_these_medications(
            pred_codes,
            between=["2019-12-20", "index_date"],
            returning="number_of_matches_in_period",
        ),
    ),
)
