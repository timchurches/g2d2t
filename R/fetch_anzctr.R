library(xml2)
library(lubridate)

anzctr_xml_to_df <- function(filename) {
  doc <- read_xml(filename)
  # Collapse secondary outcomes
  secondary_outcomes_outcome <- doc %>% xml_find_all("outcomes/secondaryOutcome/outcome") %>% xml_text()
  secondary_outcomes_timepoint <- doc %>% xml_find_all("outcomes/secondaryOutcome/timepoint") %>% xml_text()
  secondary_outcomes <- paste(secondary_outcomes_outcome, "; TIMEPOINT: ", secondary_outcomes_timepoint, sep="", collapse="::::DELIMITER:::")
  # Collapse contacts
  contacts_titles <- doc %>% xml_find_all("contacts/contact/title") %>% xml_text()
  contacts_names <- doc %>% xml_find_all("contacts/contact/name") %>% xml_text()
  contacts_addresses <- doc %>% xml_find_all("contacts/contact/address") %>% xml_text()
  contacts_phones <- doc %>% xml_find_all("contacts/contact/phone") %>% xml_text()
  contacts_faxes <- doc %>% xml_find_all("contacts/contact/fax") %>% xml_text()
  contacts_emails <- doc %>% xml_find_all("contacts/contact/email") %>% xml_text()
  contacts_countries <- doc %>% xml_find_all("contacts/contact/country") %>% xml_text()
  contacts_types <- doc %>% xml_find_all("contacts/contact/type") %>% xml_text()
  contacts <- paste("TYPE: ", contacts_types, "; NAME: ", contacts_titles, " ", contacts_names, 
                    "; ADDRESS: ", contacts_addresses, " ", contacts_countries,
                    "; PHONE: ", contacts_phones, "; FAX: ", contacts_faxes,
                    "; EMAIL: ", contacts_emails, sep="", collapse="::::DELIMITER:::")

  df <- data.frame(
    actrnumber = doc %>% xml_find_all("actrnumber") %>% xml_text(),
    submit_date = doc %>% xml_find_all("submitdate") %>% xml_text() %>% dmy(quiet=TRUE),
    approval_date = doc %>% xml_find_all("approvaldate") %>% xml_text() %>% dmy(quiet=TRUE),
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
    trial_timing = doc %>% xml_find_all("trial_design/timing") %>% xml_text(),
    recruitment_phase = doc %>% xml_find_all("recruitment/phase") %>% xml_text(),
    recruitment_anticipated_start_date = doc %>% xml_find_all("recruitment/anticipatedstartdate") %>% xml_text() %>% dmy(quiet=TRUE),
    recruitment_actual_start_date = doc %>% xml_find_all("recruitment/actualstartdate") %>% xml_text() %>% dmy(quiet=TRUE),
    recruitment_anticipated_end_date = doc %>% xml_find_all("recruitment/anticipatedenddate") %>% xml_text() %>% dmy(quiet=TRUE),
    recruitment_actual_end_date = doc %>% xml_find_all("recruitment/actualenddate") %>% xml_text() %>% dmy(quiet=TRUE),
    recruitment_sample_size = doc %>% xml_find_all("recruitment/samplesize") %>% xml_text() %>% as.numeric(),
    recruitment_status = doc %>% xml_find_all("recruitment/recruitmentstatus") %>% xml_text(),
    recruitment_anticipated_last_visit_date = doc %>% xml_find_all("recruitment/anticipatedlastvisitdate") %>% xml_text() %>% dmy(quiet=TRUE),
    recruitment_data_analysis = doc %>% xml_find_all("recruitment/dataanalysis") %>% xml_text(),
    recruitment_withdrawn_reason = doc %>% xml_find_all("recruitment/withdrawnreason") %>% xml_text(),
    recruitment_withdrawn_reason_other = doc %>% xml_find_all("recruitment/withdrawnreasonother") %>% xml_text(),
    recruitment_country = doc %>% xml_find_all("recruitment/recruitmentcountry") %>% xml_text(),
    recruitment_state = doc %>% xml_find_all("recruitment/recruitmentstate") %>% xml_text(),
    primary_sponsor_type = doc %>% xml_find_all("sponsorship/primarysponsortype") %>% xml_text(),
    primary_sponsor_name = doc %>% xml_find_all("sponsorship/primarysponsorname") %>% xml_text(),
    primary_sponsor_address = doc %>% xml_find_all("sponsorship/primarysponsoraddress") %>% xml_text(),
    primary_sponsor_country = doc %>% xml_find_all("sponsorship/primarysponsorcountry") %>% xml_text(),
    sponsor_funding_source_type = doc %>% xml_find_all("sponsorship/fundingsource/fundingtype") %>% xml_text(),
    sponsor_funding_source_name = doc %>% xml_find_all("sponsorship/fundingsource/fundingname") %>% xml_text(),
    sponsor_funding_source_country = doc %>% xml_find_all("sponsorship/fundingsource/fundingcountry") %>% xml_text(),
    secondary_sponsor_type = doc %>% xml_find_all("sponsorship/secondarysponsor/sponsortype") %>% xml_text(),
    secondary_sponsor_name = doc %>% xml_find_all("sponsorship/secondarysponsor/sponsorname") %>% xml_text(),
    secondary_sponsor_address = doc %>% xml_find_all("sponsorship/secondarysponsor/sponsoraddress") %>% xml_text(),
    secondary_sponsor_country = doc %>% xml_find_all("sponsorship/secondarysponsor/sponsorcountry") %>% xml_text(),
    summary = doc %>% xml_find_all("ethicsAndSummary/summary") %>% xml_text(),
    trial_website = doc %>% xml_find_all("ethicsAndSummary/trialwebsite") %>% xml_text(),
    publication = doc %>% xml_find_all("ethicsAndSummary/publication") %>% xml_text(),
    ethics_review = doc %>% xml_find_all("ethicsAndSummary/ethicsreview") %>% xml_text(),
    public_notes = doc %>% xml_find_all("ethicsAndSummary/publicnotes") %>% xml_text(),
    ethics_committee_name = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicname") %>% xml_text(),
    ethics_committee_address = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicaddress") %>% xml_text(),
    ethics_approval_date = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicapprovaldate") %>% xml_text() %>% dmy(quiet=TRUE),
    hrec = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/hrec") %>% xml_text(),
    ethics_submit_date = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicsubmitdate") %>% xml_text() %>% dmy(quiet=TRUE),
    ethics_country = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethiccountry") %>% xml_text(),
  contacts = contacts
  )
  return(df)  
}

library(progress)
filenames <- list.files(path="playground/anzctr_xml/", pattern=glob2rx("ACTRN*.xml"))

pb <- progress_bar$new(
      format = "Processing ANZCTR record :current of :total (:percent), estimated completion in :eta",
      total = length(filenames), clear = FALSE, width= 60)

for (f in filenames) {
  a <- anzctr_xml_to_df(filename)
  pb$tick()
}
