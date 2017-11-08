library(xml2)
library(lubridate)
library(progress)

get_text_xpath <- function(doc, xpath) {
  # print(xpath)
  val <- doc %>% xml_find_all(xpath) %>% xml_text() 
  if (length(val) == 0) {
    val <- "Missing from record"
    # message(paste(xpath, "not found!"))
  }
  return(val)
}

anzctr_xml_to_df_row <- function(filename, rectype="") {
  # print(filename)
  # read the XML document
  doc <- read_xml(filename)
  # print(xml_structure(doc))
  # variable for file type
  if (rectype == "ANZCTR") {
      trial_number <-doc %>% xml_find_all("actrnumber") %>% xml_text()
  } else if (rectype == "NCT") {
      trial_number <- doc %>% xml_find_all("nctid") %>% xml_text()
  } else {
    stop("Invalid rectype, must be ANZCTR or NCT")
  }
  # print(trial_number)
  secondary_ids <- list(tibble(secondary_id = get_text_xpath(doc, "trial_identification/secondaryid")))
  submit_date <- doc %>% xml_find_all("submitdate") %>% xml_text() %>% dmy(quiet=TRUE)
  approval_date <- doc %>% xml_find_all("approvaldate") %>% xml_text() %>% dmy(quiet=TRUE)
  stage <- get_text_xpath(doc, "stage")
  utrn <- get_text_xpath(doc, "trial_identification/utrn")
  study_title <- get_text_xpath(doc, "trial_identification/studytitle")
  scientific_title <- get_text_xpath(doc, "trial_identification/scientifictitle")
  trial_acronym <- get_text_xpath(doc, "trial_identification/trialacronym")
  # Collapse conditions
  health_conditions <- get_text_xpath(doc, "conditions/healthcondition")
  health_condition_code1s <- get_text_xpath(doc, "conditions/conditioncode/conditioncode1")
  health_condition_code2s <- get_text_xpath(doc, "conditions/conditioncode/conditioncode2")
  health_conditions <- list(tibble(health_condition = health_conditions))
  health_condition_codes <- list(tibble(health_condition_code = 
                                        c(rbind(health_condition_code1s,health_condition_code2s))))
  interventions <- get_text_xpath(doc, "interventions/interventions")
  comparator <- get_text_xpath(doc, "interventions/comparator")
  control <- get_text_xpath(doc, "interventions/control")
  # Collapse intervention code
  intervention_codes <- list(tibble(intervention_code = doc %>% xml_find_all("interventions/interventioncode") %>% xml_text()))
  # Collapse primary outcomes
  outcomes_primary <- get_text_xpath(doc, "outcomes/primaryOutcome/outcome")
  outcomes_primary_timepoints <- get_text_xpath(doc, "outcomes/primaryOutcome/timepoint")
  primary_outcomes <- list(tibble(primary_outcome = outcomes_primary, 
                              primary_outcome_timepoints = outcomes_primary_timepoints))
  # Collapse secondary outcomes
  secondary_outcomes_outcome <- get_text_xpath(doc, "outcomes/secondaryOutcome/outcome")
  secondary_outcomes_timepoint <- get_text_xpath(doc, "outcomes/secondaryOutcome/timepoint")
  secondary_outcomes <- list(tibble(seconday_outcome = secondary_outcomes_outcome,
                              secondary_outcome_timepoint = secondary_outcomes_timepoint))
  eligibity_inclusive <- get_text_xpath(doc, "eligibility/inclusivecriteria")
  eligibity_inclusive_min_age <- get_text_xpath(doc, "eligibility/inclusiveminage")
  eligibity_inclusive_min_age_type <- get_text_xpath(doc, "eligibility/inclusiveminagetype")
  eligibity_inclusive_max_age <- get_text_xpath(doc, "eligibility/inclusivemaxage")
  eligibity_inclusive_max_age_type <- get_text_xpath(doc, "eligibility/inclusivemaxagetype")
  eligibity_inclusive_gender <- get_text_xpath(doc, "eligibility/inclusivegender")
  eligibity_healthy_volunteer <- get_text_xpath(doc, "eligibility/healthyvolunteer")
  eligibity_exclusive <- get_text_xpath(doc, "eligibility/exclusivecriteria")
  study_type <- get_text_xpath(doc, "trial_design/studytype")
  trial_purpose <- get_text_xpath(doc, "trial_design/purpose")
  trial_allocation <- get_text_xpath(doc, "trial_design/allocation")
  trial_concealment <- get_text_xpath(doc, "trial_design/concealment")
  trial_sequence <- get_text_xpath(doc, "trial_design/sequence")
  trial_masking <- get_text_xpath(doc, "trial_design/masking")
  trial_assignment <- get_text_xpath(doc, "trial_design/assignment")
  trial_design_features <- get_text_xpath(doc, "trial_design/designfeatures")
  trial_endpoint <- get_text_xpath(doc, "trial_design/endpoint")
  trial_statisticalmethods <- get_text_xpath(doc, "trial_design/statisticalmethods")
  trial_masking1 <- get_text_xpath(doc, "trial_design/masking1")
  trial_masking2 <- get_text_xpath(doc, "trial_design/masking2")
  trial_masking3 <- get_text_xpath(doc, "trial_design/masking3")
  trial_masking4 <- get_text_xpath(doc, "trial_design/masking4")
  trial_patient_registry <- get_text_xpath(doc, "trial_design/patientregistry")
  trial_followup <- get_text_xpath(doc, "trial_design/followup")
  trial_followup_type <- get_text_xpath(doc, "trial_design/followuptype")
  trial_purpose_obs <- get_text_xpath(doc, "trial_design/purposeobs")
  trial_duration <- get_text_xpath(doc, "trial_design/duration")
  trial_selection <- get_text_xpath(doc, "trial_design/selection")
  trial_timing <- get_text_xpath(doc, "trial_design/timing")
  recruitment_phase <- get_text_xpath(doc, "recruitment/phase")
  recruitment_anticipated_start_date <- doc %>% xml_find_all("recruitment/anticipatedstartdate") %>% xml_text() %>% dmy(quiet=TRUE)
  recruitment_actual_start_date <- doc %>% xml_find_all("recruitment/actualstartdate") %>% xml_text() %>% dmy(quiet=TRUE)
  recruitment_anticipated_end_date <- doc %>% xml_find_all("recruitment/anticipatedenddate") %>% xml_text() %>% dmy(quiet=TRUE)
  recruitment_actual_end_date <- doc %>% xml_find_all("recruitment/actualenddate") %>% xml_text() %>% dmy(quiet=TRUE)
  recruitment_sample_size <- doc %>% xml_find_all("recruitment/samplesize") %>% xml_text() %>% as.numeric()
  recruitment_actual_sample_size <- doc %>% xml_find_all("recruitment/actualsamplesize") %>% xml_text() %>% as.numeric()
  recruitment_status <- get_text_xpath(doc, "recruitment/recruitmentstatus")
  recruitment_anticipated_last_visit_date <- doc %>% xml_find_all("recruitment/anticipatedlastvisitdate") %>% xml_text() 
  if (length(recruitment_anticipated_last_visit_date) == 0) {
    recruitment_anticipated_last_visit_date <- NA
  } else {
    recruitment_anticipated_last_visit_date <- dmy(recruitment_anticipated_last_visit_date,quiet=TRUE)
  }
  recruitment_actual_last_visit_date <- doc %>% xml_find_all("recruitment/actuallastvisitdate") %>% xml_text() 
  if (length(recruitment_actual_last_visit_date) == 0) {
    recruitment_actual_last_visit_date <- NA
  } else {
    recruitment_actual_last_visit_date <- dmy(recruitment_actual_last_visit_date,quiet=TRUE)
  }
  recruitment_data_analysis <- get_text_xpath(doc, "recruitment/dataanalysis")
  recruitment_withdrawn_reason <- get_text_xpath(doc, "recruitment/withdrawnreason")
  recruitment_withdrawn_reason_other <- get_text_xpath(doc, "recruitment/withdrawnreasonother")
  recruitment_country <- get_text_xpath(doc, "recruitment/recruitmentcountry")
  recruitment_state <- get_text_xpath(doc, "recruitment/recruitmentstate")
  recruitment_hospital <- get_text_xpath(doc, "recruitment/hospital")
  recruitment_hospital_postcodes <- get_text_xpath(doc, "recruitment/postcode")
  recruitment_other_countries <- get_text_xpath(doc, "recruitment/countryoutsideaustralia/country")
  recruitment_other_countries_states <- get_text_xpath(doc, "recruitment/countryoutsideaustralia/state")
  recruitment_hospitals <- list(tibble(recruitment_hospital=recruitment_hospital))
  # omit hospital postcodes for now due to malformed XML...                                   
  # recruitment_hospital_postcode=recruitment_hospital_postcodes))
  recruitment_other_countries <- list(tibble(recruitment_other_country=recruitment_other_countries,
                                             recruitment_other_country_state=recruitment_other_countries_states))
  primary_sponsor_type <- get_text_xpath(doc, "sponsorship/primarysponsortype")
  primary_sponsor_name <- get_text_xpath(doc, "sponsorship/primarysponsorname")
  primary_sponsor_address <- get_text_xpath(doc, "sponsorship/primarysponsoraddress")
  primary_sponsor_country <- get_text_xpath(doc, "sponsorship/primarysponsorcountry")
  # Collapse sponsor funding types
  sponsor_funding_source_types <- get_text_xpath(doc, "sponsorship/fundingsource/fundingtype")
  sponsor_funding_source_names <- get_text_xpath(doc, "sponsorship/fundingsource/fundingname")
  sponsor_funding_source_addresses <- get_text_xpath(doc, "sponsorship/fundingsource/fundingaddress")
  sponsor_funding_source_countries <- get_text_xpath(doc, "sponsorship/fundingsource/fundingcountry")
  sponsor_funding <- list(tibble(sponsor_funding_source_type = sponsor_funding_source_types,  
                            sponsor_funding_source_name = sponsor_funding_source_names,  
                            sponsor_funding_source_address = sponsor_funding_source_addresses,
                            sponsor_funding_source_country = sponsor_funding_source_countries))
  secondary_sponsor_types <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsortype")
  secondary_sponsor_names <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsorname")
  secondary_sponsor_addresses <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsoraddress")
  secondary_sponsor_countries <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsorcountry")
  secondary_sponsors <- list(tibble(secondary_sponsor_type = secondary_sponsor_types,  
                                secondary_sponsor_name = secondary_sponsor_names,  
                                secondary_sponsor_address = secondary_sponsor_addresses,
                                secondary_sponsor_country = secondary_sponsor_countries))
  summary <- get_text_xpath(doc, "ethicsAndSummary/summary")
  trial_website <- get_text_xpath(doc, "ethicsAndSummary/trialwebsite")
  publication <- get_text_xpath(doc, "ethicsAndSummary/publication")
  ethics_review <- get_text_xpath(doc, "ethicsAndSummary/ethicsreview")
  public_notes <- get_text_xpath(doc, "ethicsAndSummary/publicnotes")
  # Collapse ethics committees
  ethics_committees_names <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/ethicname")
  ethics_committees_addresses <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/ethicaddress")
  ethics_approval_dates <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicapprovaldate") %>% xml_text() %>% dmy(quiet=TRUE)
  hrecs <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/hrec")
  ethics_submit_dates <- doc %>% xml_find_all("ethicsAndSummary/ethicscommitee/ethicsubmitdate") %>% xml_text() %>% dmy(quiet=TRUE)
  ethics_countries <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/ethiccountry")
  ethics_committees <- list(tibble(ethics_committee_name = ethics_committees_names,  
                              ethics_commitee_address = ethics_committees_addresses,
                              ethics_committee_country = ethics_countries,
                              hrec = hrecs,
                              ethics_submission_date= ethics_submit_dates,
                              ethics_approval_date = ethics_approval_dates))
  # Collapse contacts
  contacts_titles <- get_text_xpath(doc, "contacts/contact/title")
  contacts_names <- get_text_xpath(doc, "contacts/contact/name")
  contacts_addresses <- get_text_xpath(doc, "contacts/contact/address")
  contacts_phones <- get_text_xpath(doc, "contacts/contact/phone")
  contacts_faxes <- get_text_xpath(doc, "contacts/contact/fax")
  contacts_emails <- get_text_xpath(doc, "contacts/contact/email")
  contacts_countries <- get_text_xpath(doc, "contacts/contact/country")
  contacts_types <- get_text_xpath(doc, "contacts/contact/type")
  contacts <- list(tibble(contacts_type = contacts_types,
                     contact_title = contacts_titles,
                     contact_name = contacts_names, 
                     contact_address = contacts_addresses,
                     contact_country = contacts_countries,
                     contact_phone = contacts_phones,
                     contact_fax = contacts_faxes,
                     contact_email = contacts_emails))
  # optionals
  secondary_id <- get_text_xpath(doc, "trial_identification/secondaryid")

  df <- tibble(
    trial_registration_type = rectype,
    trial_number = trial_number,
    submit_date = submit_date,
    approval_date = approval_date,
    stage = stage,
    utrn = utrn,
    study_title = study_title,
    scientific_title = scientific_title,
    trial_acronym = trial_acronym,
    seconday_id = secondary_id,
    health_conditions = health_conditions,
    interventions = interventions,
    comparator = comparator,
    control = control,
    intervention_codes = intervention_codes,
    primary_outcomes = primary_outcomes,
    secondary_outcomes = secondary_outcomes,
    eligibity_inclusive = eligibity_inclusive,
    eligibity_inclusive_min_age = eligibity_inclusive_min_age,
    eligibity_inclusive_min_age_type = eligibity_inclusive_min_age_type,
    eligibity_inclusive_max_age = eligibity_inclusive_max_age,
    eligibity_inclusive_max_age_type = eligibity_inclusive_max_age_type,
    eligibity_inclusive_gender = eligibity_inclusive_gender,
    eligibity_healthy_volunteer = eligibity_healthy_volunteer,
    eligibity_exclusive = eligibity_exclusive,
    study_type = study_type,
    trial_purpose = trial_purpose,
    trial_allocation = trial_allocation,
    trial_concealment = trial_concealment,
    trial_sequence = trial_sequence,
    trial_masking = trial_masking,
    trial_assignment = trial_assignment,
    trial_design_features = trial_design_features,
    trial_endpoint = trial_endpoint,
    trial_statisticalmethods = trial_statisticalmethods,
    trial_masking1 = trial_masking1,
    trial_masking2 = trial_masking2,
    trial_masking3 = trial_masking3,
    trial_masking4 = trial_masking4,
    trial_patient_registry = trial_patient_registry,
    trial_followup = trial_followup,
    trial_followup_type = trial_followup_type,
    trial_purpose_obs = trial_purpose_obs,
    trial_duration = trial_duration,
    trial_selection = trial_selection,
    trial_timing = trial_timing,
    recruitment_phase = recruitment_phase,
    recruitment_anticipated_start_date = recruitment_anticipated_start_date,
    recruitment_actual_start_date = recruitment_actual_start_date,
    recruitment_anticipated_end_date = recruitment_anticipated_end_date,
    recruitment_actual_end_date = recruitment_actual_end_date,
    recruitment_sample_size = recruitment_sample_size,
    recruitment_actual_sample_size = recruitment_actual_sample_size,
    recruitment_status = recruitment_status,
    recruitment_anticipated_last_visit_date = recruitment_anticipated_last_visit_date,
    recruitment_actual_last_visit_date = recruitment_actual_last_visit_date,
    recruitment_data_analysis = recruitment_data_analysis,
    recruitment_withdrawn_reason = recruitment_withdrawn_reason,
    recruitment_withdrawn_reason_other = recruitment_withdrawn_reason_other,
    recruitment_country = recruitment_country,
    recruitment_state = recruitment_state,
    recruitment_hospitals = recruitment_hospitals,
    recruitment_other_countries = recruitment_other_countries,
    primary_sponsor_type = primary_sponsor_type,
    primary_sponsor_name = primary_sponsor_name,
    primary_sponsor_address = primary_sponsor_address,
    primary_sponsor_country = primary_sponsor_country,
    sponsor_funding = sponsor_funding,
    secondary_sponsors = secondary_sponsors,
    summary = summary,
    trial_website = trial_website,
    publication = publication,
    ethics_review = ethics_review,
    public_notes = public_notes,
    ethics_committees = ethics_committees,
    contacts = contacts
  )
  return(df)  
}

anzctr_to_df <- function(xmlpath="", rectype="") {
  if (rectype == "ANZCTR") {
    pattern="ACTRN*.xml"
  } else if (rectype == "NCT") {
    pattern="NCT*.xml"
  } else {
    stop("Invalid rectype, must be ANZCTR or NCT only") 
  }
  filenames <- list.files(path=xmlpath, pattern=glob2rx(pattern), full.names = TRUE)
  nfiles <- length(filenames)
  pb <- progress_bar$new(
      format = "Processing ANZCTR record :current of :total (:percent), estimated completion in :eta",
      total = nfiles, clear = FALSE, width= 60)
  fcounter <- 0
  for (f in filenames) {
    fcounter <- fcounter + 1
    if (fcounter == 1) {
      df <- anzctr_xml_to_df_row(f, rectype=rectype)
    } else {
      df_row <- anzctr_xml_to_df_row(f, rectype=rectype)
      df %>% bind_rows(df_row) -> df
    }  
    pb$tick()
  }
  return(df)
}

# Deprecated - needs revision:
# anzctr <- anzctr_to_df(xmlpath="playground/anzctr_xml")

# anzctr_output = anzctr[,c("actrnumber", "study_title", "interventions", "intervention_codes", "eligibity_inclusive", "eligibity_exclusive")]

# write_csv(anzctr_output, "playground/anzctr_searchable.csv")
