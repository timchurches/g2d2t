library(xml2)
library(lubridate)

anzctr_xml_to_df <- function(filename) {
  doc <- read_xml(filename)
  secondary_outcomes_outcome <- doc %>% xml_find_all("outcomes/secondaryOutcome/outcome") %>% xml_text()
  secondary_outcomes_timepoint <- doc %>% xml_find_all("outcomes/secondaryOutcome/timepoint") %>% xml_text()
  secondary_outcomes <- paste(secondary_outcomes_outcome, "; TIMEPOINT: ", secondary_outcomes_timepoint, sep="", collapse="::::DELIMITER:::")
  df <- data.frame(
    actrnumber = doc %>% xml_find_all("actrnumber") %>% xml_text(),
    submit_date = doc %>% xml_find_all("submitdate") %>% xml_text() %>% dmy(),
    approval_date = doc %>% xml_find_all("approvaldate") %>% xml_text() %>% dmy(),
    stage = doc %>% xml_find_all("stage") %>% xml_text(),
    utrn = doc %>% xml_find_all("trial_identification/utrn") %>% xml_text(),
    study_title = doc %>% xml_find_all("trial_identification/studytitle") %>% xml_text(),
    scientific_title = doc %>% xml_find_all("trial_identification/scientifictitle") %>% xml_text(),
    trial_acronym = doc %>% xml_find_all("trial_identification/trialacronym") %>% xml_text(),
    secondary_id = doc %>% xml_find_all("trial_identification/secondaryid") %>% xml_text(),
    health_condition = doc %>% xml_find_all("conditions/healthcondition") %>% xml_text(),
    health_condition = doc %>% xml_find_all("conditions/healthcondition") %>% xml_text(),
    health_condition_code1 = doc %>% xml_find_all("conditions/conditioncode/conditioncode1") %>% xml_text(),
    health_condition_code2 = doc %>% xml_find_all("conditions/conditioncode/conditioncode2") %>% xml_text(),
    interventions = doc %>% xml_find_all("interventions/interventions") %>% xml_text(),
    comparator = doc %>% xml_find_all("interventions/comparator") %>% xml_text(),
    control = doc %>% xml_find_all("interventions/control") %>% xml_text(),
    intervention_code = doc %>% xml_find_all("interventions/interventioncode") %>% xml_text(),
    outcome_primary = doc %>% xml_find_all("outcomes/primaryOutcome/outcome") %>% xml_text(),
    outcome_primary_timepoint = doc %>% xml_find_all("outcomes/primaryOutcome/timepoint") %>% xml_text(),
    outcomes_secondary = secondary_outcomes,
    eligibity_inclusive = doc %>% xml_find_all("eligibility/inclusivecriteria") %>% xml_text(),
    eligibity_inclusive_min_age = doc %>% xml_find_all("eligibility/inclusiveminage") %>% xml_text(),
    eligibity_inclusive_min_age_type = doc %>% xml_find_all("eligibility/inclusiveminagetype") %>% xml_text(),
    eligibity_inclusive_max_age = doc %>% xml_find_all("eligibility/inclusivemaxage") %>% xml_text(),
    eligibity_inclusive_max_age_type = doc %>% xml_find_all("eligibility/inclusivemaxagetype") %>% xml_text(),
    eligibity_inclusive_min_age = doc %>% xml_find_all("eligibility/inclusiveminage") %>% xml_text(),
    eligibity_inclusive_gender = doc %>% xml_find_all("eligibility/inclusivegender") %>% xml_text(),
    eligibity_healthy_volunteer = doc %>% xml_find_all("eligibility/healthyvolunteer") %>% xml_text(),
    eligibity_exclusive = doc %>% xml_find_all("eligibility/exclusivecriteria") %>% xml_text(),
    study_type = doc %>% xml_find_all("trial_design/studytype") %>% xml_text(),
    trial_purpose = doc %>% xml_find_all("trial_design/purpose") %>% xml_text(),
    trial_allocation = doc %>% xml_find_all("trial_design/allocation") %>% xml_text(),
    trial_concealment = doc %>% xml_find_all("trial_design/concealment") %>% xml_text(),
    trial_sequence = doc %>% xml_find_all("trial_design/sequence") %>% xml_text(),
    trial_masking = doc %>% xml_find_all("trial_design/masking") %>% xml_text(),
    trial_assignment = doc %>% xml_find_all("trial_design/assignment") %>% xml_text(),
    trial_design_features = doc %>% xml_find_all("trial_design/designfeatures") %>% xml_text(),
    trial_endpoint = doc %>% xml_find_all("trial_design/endpoint") %>% xml_text(),
    trial_statisticalmethods = doc %>% xml_find_all("trial_design/statisticalmethods") %>% xml_text(),
    trial_masking1 = doc %>% xml_find_all("trial_design/masking1") %>% xml_text(),
    trial_masking2 = doc %>% xml_find_all("trial_design/masking2") %>% xml_text(),
    trial_masking3 = doc %>% xml_find_all("trial_design/masking3") %>% xml_text(),
    trial_masking4 = doc %>% xml_find_all("trial_design/masking4") %>% xml_text(),
    trial_patient_registry = doc %>% xml_find_all("trial_design/patientregistry") %>% xml_text(),
    trial_followup = doc %>% xml_find_all("trial_design/followup") %>% xml_text(),
    trial_followup_type = doc %>% xml_find_all("trial_design/followuptype") %>% xml_text(),
    trial_purpose_obs = doc %>% xml_find_all("trial_design/purposeobs") %>% xml_text(),
    trial_duration = doc %>% xml_find_all("trial_design/duration") %>% xml_text(),
    trial_selection = doc %>% xml_find_all("trial_design/selection") %>% xml_text(),
    trial_timing = doc %>% xml_find_all("trial_design/timing") %>% xml_text()
  )
  
  
  return(df)  
}

filename <- "playground/anzctr_xml/ACTRN12617000596303.xml"
anzctr_xml_to_df(filename)
