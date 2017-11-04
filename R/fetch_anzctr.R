library(xml2)
library(lubridate)
library(progress)

anzctr_xml_to_df_row <- function(filename) {
  # print(filename)
  doc <- read_xml(filename)
  compound_delim <- "::||::"
  # Collapse conditions
  health_conditions = doc %>% xml_find_all("conditions/healthcondition") %>% xml_text()
  health_condition_code1s = doc %>% xml_find_all("conditions/conditioncode/conditioncode1") %>% xml_text()
  health_condition_code2s = doc %>% xml_find_all("conditions/conditioncode/conditioncode2") %>% xml_text()
  health_conditions <- paste("CONDITION: ", health_conditions,  
                    "; CODE1: ", health_condition_code1s,
                    "; CODE2: ", health_condition_code2s,
                     sep="", collapse=compound_delim)
  # Collapse intervention code
  intervention_codes <- paste("CODE: ", doc %>% xml_find_all("interventions/interventioncode") %>% xml_text(), sep="", collapse=compound_delim)
  # Collapse primary outcomes
  outcomes_primary <- doc %>% xml_find_all("outcomes/primaryOutcome/outcome") %>% xml_text()
  outcomes_primary_timepoints <- doc %>% xml_find_all("outcomes/primaryOutcome/timepoint") %>% xml_text()
  primary_outcomes <- paste(outcomes_primary, "; TIMEPOINT: ", 
                              outcomes_primary_timepoints, sep="", collapse=compound_delim)
  # Collapse secondary outcomes
  secondary_outcomes_outcome <- doc %>% xml_find_all("outcomes/secondaryOutcome/outcome") %>% xml_text()
  secondary_outcomes_timepoint <- doc %>% xml_find_all("outcomes/secondaryOutcome/timepoint") %>% xml_text()
  secondary_outcomes <- paste(secondary_outcomes_outcome, "; TIMEPOINT: ", 
                              secondary_outcomes_timepoint, sep="", collapse=compound_delim)
  # Collapse ethics committees
    ethics_committees_names <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicname") %>% xml_text()
    ethics_committees_addresses <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicaddress") %>% xml_text()
    ethics_approval_dates <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicapprovaldate") %>% xml_text() %>% dmy(quiet=TRUE)
    hrecs <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/hrec") %>% xml_text()
    ethics_submit_dates = doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicsubmitdate") %>% xml_text() %>% dmy(quiet=TRUE)
    ethics_countries <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethiccountry") %>% xml_text()
  ethics_committees <- paste("NAME: ", ethics_committees_names,  
                    "; ADDRESS: ", ethics_committees_addresses, " ", ethics_countries,
                    "; HREC: ", hrecs, "; SUBMIT DATE: ", ethics_submit_dates,
                    "; APPROVAL DATE: ", ethics_approval_dates, sep="", collapse=compound_delim)
  # Collapse sponsor funding types
  sponsor_funding_source_types <- doc %>% xml_find_all("sponsorship/fundingsource/fundingtype") %>% xml_text()
  sponsor_funding_source_names <- doc %>% xml_find_all("sponsorship/fundingsource/fundingname") %>% xml_text()
  sponsor_funding_source_addresses <- doc %>% xml_find_all("sponsorship/fundingsource/fundingaddress") %>% xml_text()
  sponsor_funding_source_countries <- doc %>% xml_find_all("sponsorship/fundingsource/fundingcountry") %>% xml_text()
  sponsor_funding <- paste("TYPE: ", sponsor_funding_source_types,  
                           "; NAME: ", sponsor_funding_source_names,  
                           "; ADDRESS: ", sponsor_funding_source_addresses, " ", sponsor_funding_source_countries,
                           sep="", collapse=compound_delim)
  secondary_sponsor_types <- doc %>% xml_find_all("sponsorship/secondarysponsor/sponsortype") %>% xml_text()
  secondary_sponsor_names <- doc %>% xml_find_all("sponsorship/secondarysponsor/sponsorname") %>% xml_text()
  secondary_sponsor_addresses <- doc %>% xml_find_all("sponsorship/secondarysponsor/sponsoraddress") %>% xml_text()
  secondary_sponsor_countries <- doc %>% xml_find_all("sponsorship/secondarysponsor/sponsorcountry") %>% xml_text()
  secondary_sponsors <- paste("TYPE: ", secondary_sponsor_types,  
                           "; NAME: ", secondary_sponsor_names,  
                           "; ADDRESS: ", secondary_sponsor_addresses, " ", secondary_sponsor_countries,
                           sep="", collapse=compound_delim)
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
                    "; EMAIL: ", contacts_emails, sep="", collapse=compound_delim)
  # optionals
  secondary_id <- doc %>% xml_find_all("trial_identification/secondaryid") %>% xml_text()
  if (length(secondary_id) == 0) secondary_id <- ""
  recruitment_anticipated_last_visit_date <- doc %>% xml_find_all("recruitment/anticipatedlastvisitdate") %>% xml_text() 
  if (length(recruitment_anticipated_last_visit_date) == 0) {
    recruitment_anticipated_last_visit_date <- NA
  } else {
    recruitment_anticipated_last_visit_date <- dmy(recruitment_anticipated_last_visit_date,quiet=TRUE)
  }
  recruitment_data_analysis <- doc %>% xml_find_all("recruitment/dataanalysis") %>% xml_text()
  if (length(recruitment_data_analysis) == 0) recruitment_data_analysis <- ""
  recruitment_withdrawn_reason <- doc %>% xml_find_all("recruitment/withdrawnreason") %>% xml_text()
  if (length(recruitment_withdrawn_reason) == 0) recruitment_withdrawn_reason <- ""
  recruitment_withdrawn_reason_other <- doc %>% xml_find_all("recruitment/withdrawnreasonother") %>% xml_text()
  if (length(recruitment_withdrawn_reason_other) == 0) recruitment_withdrawn_reason_other <- ""

  df <- data.frame(
    actrnumber = doc %>% xml_find_all("actrnumber") %>% xml_text(),
    submit_date = doc %>% xml_find_all("submitdate") %>% xml_text() %>% dmy(quiet=TRUE),
    approval_date = doc %>% xml_find_all("approvaldate") %>% xml_text() %>% dmy(quiet=TRUE),
    stage = doc %>% xml_find_all("stage") %>% xml_text(),
    utrn = doc %>% xml_find_all("trial_identification/utrn") %>% xml_text(),
    study_title = doc %>% xml_find_all("trial_identification/studytitle") %>% xml_text(),
    scientific_title = doc %>% xml_find_all("trial_identification/scientifictitle") %>% xml_text(),
    trial_acronym = doc %>% xml_find_all("trial_identification/trialacronym") %>% xml_text(),
    seconday_id = secondary_id,
    health_conditions = health_conditions,
    interventions = doc %>% xml_find_all("interventions/interventions") %>% xml_text(),
    comparator = doc %>% xml_find_all("interventions/comparator") %>% xml_text(),
    control = doc %>% xml_find_all("interventions/control") %>% xml_text(),
    intervention_codes = intervention_codes,
    primary_outcomes = primary_outcomes,
    secondary_outcomes = secondary_outcomes,
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
    recruitment_actual_sample_size = doc %>% xml_find_all("recruitment/actualsamplesize") %>% xml_text() %>% as.numeric(),
    recruitment_status = doc %>% xml_find_all("recruitment/recruitmentstatus") %>% xml_text(),
    recruitment_anticipated_last_visit_date = recruitment_anticipated_last_visit_date,
    recruitment_data_analysis = recruitment_data_analysis,
    recruitment_withdrawn_reason = recruitment_withdrawn_reason,
    recruitment_withdrawn_reason_other = recruitment_withdrawn_reason_other,
    recruitment_country = doc %>% xml_find_all("recruitment/recruitmentcountry") %>% xml_text(),
    recruitment_state = doc %>% xml_find_all("recruitment/recruitmentstate") %>% xml_text(),
    primary_sponsor_type = doc %>% xml_find_all("sponsorship/primarysponsortype") %>% xml_text(),
    primary_sponsor_name = doc %>% xml_find_all("sponsorship/primarysponsorname") %>% xml_text(),
    primary_sponsor_address = doc %>% xml_find_all("sponsorship/primarysponsoraddress") %>% xml_text(),
    primary_sponsor_country = doc %>% xml_find_all("sponsorship/primarysponsorcountry") %>% xml_text(),
    sponsor_funding = sponsor_funding,
    secondary_sponsors = secondary_sponsors,
    summary = doc %>% xml_find_all("ethicsAndSummary/summary") %>% xml_text(),
    trial_website = doc %>% xml_find_all("ethicsAndSummary/trialwebsite") %>% xml_text(),
    publication = doc %>% xml_find_all("ethicsAndSummary/publication") %>% xml_text(),
    ethics_review = doc %>% xml_find_all("ethicsAndSummary/ethicsreview") %>% xml_text(),
    public_notes = doc %>% xml_find_all("ethicsAndSummary/publicnotes") %>% xml_text(),
    ethics_committees = ethics_committees,
    contacts = contacts
  )
  return(df)  
}

anzctr_to_df <- function(xmlpath="", pattern="ACTRN*.xml") {
  filenames <- list.files(path=xmlpath, pattern=glob2rx(pattern), full.names = TRUE)
  nfiles <- length(filenames)
  pb <- progress_bar$new(
      format = "Processing ANZCTR record :current of :total (:percent), estimated completion in :eta",
      total = nfiles, clear = FALSE, width= 60)
  fcounter <- 0
  for (f in filenames) {
    fcounter <- fcounter + 1
    if (fcounter == 1) {
      df <- anzctr_xml_to_df_row(f)
    } else {
      df_row <- anzctr_xml_to_df_row(f)
      df %>% bind_rows(df_row) -> df
    }  
    pb$tick()
  }
  return(df)
}

anzctr <- anzctr_to_df(xmlpath="playground/anzctr_xml")

anzctr_output = anzctr[,c("actrnumber", "study_title", "interventions", "intervention_codes", "eligibity_inclusive", "eligibity_exclusive")]

write_csv(anzctr_output, "playground/anzctr_searchable.csv")
