library(xml2)
library(tidyverse)
library(lubridate)
library(DBI)
stopifnot("MonetDBLite" %in% rownames(installed.packages()))
  
missing_string <- "Not in record"

get_text_xpath <- function(doc, xpath) {
  # print(xpath)
  val <- doc %>% xml_find_all(xpath) %>% xml_text() 
  if (length(val) == 0) {
    val <- missing_string
    # message(paste(xpath, "not found!"))
  }
  return(val)
}

get_date_xpath <- function(doc, xpath) {
  # print(xpath)
  val <- doc %>% xml_find_all(xpath) %>% xml_text() 
  if (length(val) == 0) {
    val <- NA
  } else {
    val <- dmy(val, quiet = TRUE)
  }
  return(val)
}

# Date vector helper function
datevec <- function(length = 0) {
   newDate = numeric(length)
   class(newDate) = "Date"
   return(newDate)
}

# update progress indicator helper
update_progress <- function(step_n, n_steps, progress_obj) {
  if (!is.null(progress_obj)) {
    progress_obj$set(value=(10000*step_n/n_steps), 
                     message=paste("Creating ANZCTR data frame", step_n, "of", n_steps))
  }
}

anzctr_to_dfs <- function(xmlpath="", progress_obj=NULL) {
  if (!is.null(progress_obj)) {
    progress_obj$set(value = NULL, message = "Preparing to process ANZCTR XML files...", detail = NULL)
  }
  fpattern <- "ACTRN*.xml"
  a_filenames <- list.files(path=xmlpath, pattern=glob2rx(fpattern), full.names = FALSE)
  fpattern <- "NCT*.xml"
  n_filenames <- list.files(path=xmlpath, pattern=glob2rx(fpattern), full.names = FALSE)
  filenames <- c(a_filenames, n_filenames)
  nfiles <- length(filenames)
  # create emtpy vectors to hold the columns of data
  trial_number = character(0)
  trial_registration_type = character(0)
  submit_date = datevec(0)
  approval_date = datevec(0)
  stage = character(0)
  utrn = character(0)
  study_title = character(0)
  scientific_title = character(0)
  trial_acronym = character(0)
  interventions = character(0)
  comparator = character(0)
  control = character(0)
  eligibity_inclusive = character(0)
  eligibity_inclusive_min_age = character(0)
  eligibity_inclusive_min_age_type = character(0)
  eligibity_inclusive_max_age = character(0)
  eligibity_inclusive_max_age_type = character(0)
  eligibity_inclusive_gender = character(0)
  eligibity_healthy_volunteer = character(0)
  eligibity_exclusive = character(0)
  study_type = character(0)
  trial_purpose = character(0)
  trial_allocation = character(0)
  trial_concealment = character(0)
  trial_sequence = character(0)
  trial_masking = character(0)
  trial_assignment = character(0)
  trial_design_features = character(0)
  trial_endpoint = character(0)
  trial_statisticalmethods = character(0)
  trial_masking1 = character(0)
  trial_masking2 = character(0)
  trial_masking3 = character(0)
  trial_masking4 = character(0)
  trial_patient_registry = character(0)
  trial_followup = character(0)
  trial_followup_type = character(0)
  trial_purpose_obs = character(0)
  trial_duration = character(0)
  trial_selection = character(0)
  trial_timing = character(0)
  recruitment_phase = character(0)
  recruitment_anticipated_start_date = datevec(0)
  recruitment_actual_start_date = datevec(0)
  recruitment_anticipated_end_date = datevec(0)
  recruitment_actual_end_date = datevec(0)
  recruitment_sample_size = numeric(0)
  recruitment_actual_sample_size = numeric(0)
  recruitment_status = character(0)
  recruitment_anticipated_last_visit_date = datevec(0)
  recruitment_actual_last_visit_date = datevec(0)
  recruitment_data_analysis = character(0)
  recruitment_withdrawn_reason = character(0)
  recruitment_withdrawn_reason_other = character(0)
  recruitment_country = character(0)
  recruitment_state = character(0)
  primary_sponsor_type = character(0)
  primary_sponsor_name = character(0)
  primary_sponsor_address = character(0)
  primary_sponsor_country = character(0)
  sponsor_funding = character(0)
  summary = character(0)
  trial_website = character(0)
  publication = character(0)
  ethics_review = character(0)
  public_notes = character(0)
  # repeating data
  secondary_id_trial_numbers <- character(0)
  secondary_ids_orders_vec <- integer(0)
  secondary_ids_vec <- character(0)
  health_conditions_trial_numbers <- character(0)
  health_conditions_orders_vec <- integer(0)
  health_conditions_vec <- character(0)
  health_conditions_codes_trial_numbers <- character(0)
  health_conditions_codes_orders_vec <- integer(0)
  health_conditions_code1s_vec <- character(0)
  health_conditions_code2s_vec <- character(0)
  interventions_codes_trial_numbers <- character(0)
  interventions_codes_vec <- character(0)
  interventions_codes_orders_vec <- integer(0)
  primary_outcomes_trial_numbers<- character(0)
  primary_outcomes_orders_vec <- integer(0)
  primary_outcomes_vec <- character(0)
  primary_outcomes_timepoints_vec <- character(0)
  secondary_outcomes_trial_numbers<- character(0)
  secondary_outcomes_orders_vec <- integer(0)
  secondary_outcomes_vec <- character(0)
  secondary_outcomes_timepoints_vec <- character(0)
  sponsor_funding_sources_trial_numbers <- character(0)
  sponsor_funding_sources_orders_vec <- integer(0)
  sponsor_funding_sources_types_vec <- character(0)
  sponsor_funding_sources_names_vec <- character(0)
  sponsor_funding_sources_addresses_vec <- character(0)
  sponsor_funding_sources_countries_vec <- character(0)
  secondary_sponsor_trial_numbers <- character(0)
  secondary_sponsor_orders_vec <- integer(0)
  secondary_sponsor_types_vec <- character(0)
  secondary_sponsor_names_vec <- character(0)
  secondary_sponsor_addresses_vec <- character(0)
  secondary_sponsor_countries_vec <- character(0)
  ethics_committees_trial_numbers <- character(0)
  ethics_committees_names_vec <- character(0)
  ethics_committees_orders_vec <- integer(0)
  ethics_committees_addresses_vec <- character(0)
  ethics_approval_dates_vec <- datevec(0)
  hrecs_vec <- character(0)
  ethics_submit_dates_vec <- datevec(0)
  ethics_countries_vec <- character(0)
  contacts_trial_numbers <- character(0)
  contacts_orders_vec <- integer(0)
  contacts_names_vec <- character(0)
  contacts_titles_vec <- character(0)
  contacts_addresses_vec <- character(0)
  contacts_phones_vec <- character(0)
  contacts_faxes_vec <- character(0)
  contacts_emails_vec <- character(0)
  contacts_countries_vec <- character(0)
  contacts_types_vec <- character(0)
  recruitment_hospitals_trial_numbers <- character(0)
  recruitment_hospitals_orders_vec <- integer(0)
  recruitment_hospitals_vec <- character(0)
  recruitment_other_countries_trial_numbers <- character(0)
  recruitment_other_countries_orders_vec <- integer(0)
  recruitment_other_countries_vec <- character(0)
  recruitment_other_countries_states_vec <- character(0)
  
  fc <- 0
  for (f in filenames) {
    fc <- fc + 1
    if (!is.null(progress_obj)) {
      progress_obj$set(value=(10000*fc/nfiles), 
                     message=paste("Processing ANZCTR XML file", fc, "of", nfiles))
    }
    doc <- read_xml(paste(xmlpath,f,sep="/"))
    if (stringr::str_sub(f,1,5) == "ACTRN") {
      current_trial_number <- get_text_xpath(doc, "actrnumber")
      trial_number[[fc]] <- current_trial_number
      trial_registration_type[[fc]] <- "ANZCTR"
    } else if (stringr::str_sub(f,1,3) == "NCT") {
      current_trial_number <- get_text_xpath(doc, "nctid") 
      trial_number[[fc]] <- current_trial_number
      trial_registration_type[[fc]] <- "NCT"
    } else {
      stop("Invalid XML filename prefix, must be ACTRN or NCT")
    }
    submit_date[[fc]] <- get_date_xpath(doc, "submitdate")
    approval_date[[fc]] <- get_date_xpath(doc, "approvaldate")
    stage[[fc]] <- get_text_xpath(doc, "stage")
    utrn[[fc]] <- get_text_xpath(doc, "trial_identification/utrn")
    study_title[[fc]] <- get_text_xpath(doc, "trial_identification/studytitle")
    scientific_title[[fc]] <- get_text_xpath(doc, "trial_identification/scientifictitle")
    trial_acronym[[fc]] <- get_text_xpath(doc, "trial_identification/trialacronym")
    interventions[[fc]] <- get_text_xpath(doc, "interventions/interventions")
    comparator[[fc]] <- get_text_xpath(doc, "interventions/comparator")
    control[[fc]] <- get_text_xpath(doc, "interventions/control")
    eligibity_inclusive[[fc]] <- get_text_xpath(doc, "eligibility/inclusivecriteria")
    eligibity_inclusive_min_age[[fc]] <- get_text_xpath(doc, "eligibility/inclusiveminage")
    eligibity_inclusive_min_age_type[[fc]] <- get_text_xpath(doc, "eligibility/inclusiveminagetype")
    eligibity_inclusive_max_age[[fc]] <- get_text_xpath(doc, "eligibility/inclusivemaxage")
    eligibity_inclusive_max_age_type[[fc]] <- get_text_xpath(doc, "eligibility/inclusivemaxagetype")
    eligibity_inclusive_gender[[fc]] <- get_text_xpath(doc, "eligibility/inclusivegender")
    eligibity_healthy_volunteer[[fc]] <- get_text_xpath(doc, "eligibility/healthyvolunteer")
    eligibity_exclusive[[fc]] <- get_text_xpath(doc, "eligibility/exclusivecriteria")
    study_type[[fc]] <- get_text_xpath(doc, "trial_design/studytype")
    trial_purpose[[fc]] <- get_text_xpath(doc, "trial_design/purpose")
    trial_allocation[[fc]] <- get_text_xpath(doc, "trial_design/allocation")
    trial_concealment[[fc]] <- get_text_xpath(doc, "trial_design/concealment")
    trial_sequence[[fc]] <- get_text_xpath(doc, "trial_design/sequence")
    trial_masking[[fc]] <- get_text_xpath(doc, "trial_design/masking")
    trial_assignment[[fc]] <- get_text_xpath(doc, "trial_design/assignment")
    trial_design_features[[fc]] <- get_text_xpath(doc, "trial_design/designfeatures")
    trial_endpoint[[fc]] <- get_text_xpath(doc, "trial_design/endpoint")
    trial_statisticalmethods[[fc]] <- get_text_xpath(doc, "trial_design/statisticalmethods")
    trial_masking1[[fc]] <- get_text_xpath(doc, "trial_design/masking1")
    trial_masking2[[fc]] <- get_text_xpath(doc, "trial_design/masking2")
    trial_masking3[[fc]] <- get_text_xpath(doc, "trial_design/masking3")
    trial_masking4[[fc]] <- get_text_xpath(doc, "trial_design/masking4")
    trial_patient_registry[[fc]] <- get_text_xpath(doc, "trial_design/patientregistry")
    trial_followup[[fc]] <- get_text_xpath(doc, "trial_design/followup")
    trial_followup_type[[fc]] <- get_text_xpath(doc, "trial_design/followuptype")
    trial_purpose_obs[[fc]] <- get_text_xpath(doc, "trial_design/purposeobs")
    trial_duration[[fc]] <- get_text_xpath(doc, "trial_design/duration")
    trial_selection[[fc]] <- get_text_xpath(doc, "trial_design/selection")
    trial_timing[[fc]] <- get_text_xpath(doc, "trial_design/timing")
    recruitment_phase[[fc]] <- get_text_xpath(doc, "recruitment/phase")
    recruitment_anticipated_start_date[[fc]] <- get_date_xpath(doc, "recruitment/anticipatedstartdate")
    recruitment_actual_start_date[[fc]] <- get_date_xpath(doc, "recruitment/actualstartdate")
    recruitment_anticipated_end_date[[fc]] <- get_date_xpath(doc, "recruitment/anticipatedenddate")
    recruitment_actual_end_date[[fc]] <- get_date_xpath(doc, "recruitment/actualenddate")
    recruitment_sample_size[[fc]] <- as.numeric(get_text_xpath(doc, "recruitment/samplesize"))
    recruitment_actual_sample_size[[fc]] <- as.numeric(get_text_xpath(doc, "recruitment/actualsamplesize"))
    recruitment_status[[fc]] <- get_text_xpath(doc, "recruitment/recruitmentstatus")
    recruitment_anticipated_last_visit_date[[fc]] <- get_date_xpath(doc, "recruitment/anticipatedlastvisitdate")
    recruitment_actual_last_visit_date[[fc]] <- get_date_xpath(doc, "recruitment/actuallastvisitdate")
    recruitment_data_analysis[[fc]] <- get_text_xpath(doc, "recruitment/dataanalysis")
    recruitment_withdrawn_reason[[fc]] <- get_text_xpath(doc, "recruitment/withdrawnreason")
    recruitment_withdrawn_reason_other[[fc]] <- get_text_xpath(doc, "recruitment/withdrawnreasonother")
    recruitment_country[[fc]] <- get_text_xpath(doc, "recruitment/recruitmentcountry")
    recruitment_state[[fc]] <- get_text_xpath(doc, "recruitment/recruitmentstate")
    primary_sponsor_type[[fc]] <- get_text_xpath(doc, "sponsorship/primarysponsortype")
    primary_sponsor_name[[fc]] <- get_text_xpath(doc, "sponsorship/primarysponsorname")
    primary_sponsor_address[[fc]] <- get_text_xpath(doc, "sponsorship/primarysponsoraddress")
    primary_sponsor_country[[fc]] <- get_text_xpath(doc, "sponsorship/primarysponsorcountry")
    summary[[fc]] <- get_text_xpath(doc, "ethicsAndSummary/summary")
    trial_website[[fc]] <- get_text_xpath(doc, "ethicsAndSummary/trialwebsite")
    publication[[fc]] <- get_text_xpath(doc, "ethicsAndSummary/publication")
    ethics_review[[fc]] <- get_text_xpath(doc, "ethicsAndSummary/ethicsreview")
    public_notes[[fc]] <- get_text_xpath(doc, "ethicsAndSummary/publicnotes")
    # repeating values
    ## secondary IDs
    secondary_ids <- get_text_xpath(doc, "trial_identification/secondaryid")
    for (c in seq_along(secondary_ids)) {
      l <- length(secondary_id_trial_numbers) + 1
      secondary_id_trial_numbers[[l]] <- current_trial_number
      secondary_ids_orders_vec[[l]] <- c
      secondary_ids_vec[[l]] <- secondary_ids[c]
    }
    ## health conditions
    health_conditions <- get_text_xpath(doc, "conditions/healthcondition")
    for (c in seq_along(health_conditions)) {
      l <- length(health_conditions_trial_numbers) + 1
      health_conditions_trial_numbers[[l]] <- current_trial_number
      health_conditions_orders_vec[[l]] <- c
      health_conditions_vec[[l]] <- health_conditions[c]
    }
    ## health condition codes
    health_conditions_code1s <- get_text_xpath(doc, "conditions/conditioncode/conditioncode1")
    health_conditions_code2s <- get_text_xpath(doc, "conditions/conditioncode/conditioncode2")
    stopifnot(length(health_conditions_code1s) == length(health_conditions_code2s))
    for (c in seq_along(health_conditions_code1s)) {
      l <- length(health_conditions_codes_trial_numbers) + 1
      health_conditions_codes_trial_numbers[[l]] <- current_trial_number
      health_conditions_codes_orders_vec[[l]] <- c
      health_conditions_code1s_vec[[l]] <- health_conditions_code1s[c]
      health_conditions_code2s_vec[[l]] <- health_conditions_code2s[c]
    }
    ## intervention codes
    interventions_codes <- get_text_xpath(doc, "interventions/interventioncode")
    for (c in seq_along(interventions_codes)) {
      l <- length(interventions_codes_trial_numbers) + 1
      interventions_codes_trial_numbers[[l]] <- current_trial_number
      interventions_codes_orders_vec[[l]] <- c
      interventions_codes_vec[[l]] <- interventions_codes[c]
    }
    ## primary outcomes
    primary_outcomes <- get_text_xpath(doc, "outcomes/primaryOutcome/outcome")
    primary_outcomes_timepoints <- get_text_xpath(doc, "outcomes/primaryOutcome/timepoint")
    stopifnot(length(primary_outcomes) == length(primary_outcomes_timepoints))
    for (c in seq_along(primary_outcomes)) {
      l <- length(primary_outcomes_trial_numbers) + 1
      primary_outcomes_trial_numbers[[l]] <- current_trial_number
      primary_outcomes_orders_vec[[l]] <- l
      primary_outcomes_vec[[l]] <- primary_outcomes[c]
      primary_outcomes_timepoints_vec[[l]] <- primary_outcomes_timepoints[c]
    }
    ## secondary outcomes
    secondary_outcomes <- get_text_xpath(doc, "outcomes/secondaryOutcome/outcome")
    secondary_outcomes_timepoints <- get_text_xpath(doc, "outcomes/secondaryOutcome/timepoint")
    stopifnot(length(secondary_outcomes) == length(secondary_outcomes_timepoints))
    for (c in seq_along(secondary_outcomes)) {
      l <- length(secondary_outcomes_trial_numbers) + 1
      secondary_outcomes_trial_numbers[[l]] <- current_trial_number
      secondary_outcomes_orders_vec[[l]] <- c
      secondary_outcomes_vec[[l]] <- secondary_outcomes[c]
      secondary_outcomes_timepoints_vec[[l]] <- secondary_outcomes_timepoints[c]
    }
    ## recruitment hospitals
    recruitment_hospitals <- get_text_xpath(doc, "recruitment/hospital")
    # omit hospital postcodes for now, is malformed
    # recruitment_hospital_postcodes <- get_text_xpath(doc, "recruitment/postcode")
    for (c in seq_along(recruitment_hospitals)) {
      l <- length(recruitment_hospitals_trial_numbers) + 1
      recruitment_hospitals_trial_numbers[[l]] <- current_trial_number
      recruitment_hospitals_orders_vec <- c
      recruitment_hospitals_vec[[l]] <- recruitment_hospitals[c]
    }
    ## recruitment countries
    recruitment_other_countries <- get_text_xpath(doc, "recruitment/countryoutsideaustralia/country")
    recruitment_other_countries_states <- get_text_xpath(doc, "recruitment/countryoutsideaustralia/state")
    stopifnot(length(recruitment_other_countries) == length(recruitment_other_countries_states))
    for (c in seq_along(recruitment_other_countries)) {
      l <- length(recruitment_other_countries_trial_numbers) + 1
      recruitment_other_countries_trial_numbers[[l]] <- current_trial_number
      recruitment_other_countries_orders_vec[[l]] <- c
      recruitment_other_countries_vec[[l]] <- recruitment_other_countries[c]
      recruitment_other_countries_states_vec[[l]] <- recruitment_other_countries_states[c]
    }
    ## sponsor funding sources
    sponsor_funding_sources_types <- get_text_xpath(doc, "sponsorship/fundingsource/fundingtype")
    sponsor_funding_sources_names <- get_text_xpath(doc, "sponsorship/fundingsource/fundingname")
    sponsor_funding_sources_addresses <- get_text_xpath(doc, "sponsorship/fundingsource/fundingaddress")
    sponsor_funding_sources_countries <- get_text_xpath(doc, "sponsorship/fundingsource/fundingcountry")
    stopifnot(length(sponsor_funding_sources_names) == length(sponsor_funding_sources_types))
    stopifnot(length(sponsor_funding_sources_names) == length(sponsor_funding_sources_addresses))
    stopifnot(length(sponsor_funding_sources_names) == length(sponsor_funding_sources_countries))
    for (c in seq_along(sponsor_funding_sources_names)) {
      l <- length(sponsor_funding_sources_trial_numbers) + 1
      sponsor_funding_sources_trial_numbers[[l]] <- current_trial_number
      sponsor_funding_sources_orders_vec <- c
      sponsor_funding_sources_types_vec[[l]] <- sponsor_funding_sources_types[c]
      sponsor_funding_sources_names_vec[[l]] <- sponsor_funding_sources_names[c]
      sponsor_funding_sources_addresses_vec[[l]] <- sponsor_funding_sources_addresses[c]
      sponsor_funding_sources_countries_vec[[l]] <- sponsor_funding_sources_countries[c]
    }
    ## secondary sponsors
    secondary_sponsor_types <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsortype")
    secondary_sponsor_names <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsorname")
    secondary_sponsor_addresses <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsoraddress")
    secondary_sponsor_countries <- get_text_xpath(doc, "sponsorship/secondarysponsor/sponsorcountry")
    stopifnot(length(secondary_sponsor_names) == length(secondary_sponsor_types))
    stopifnot(length(secondary_sponsor_names) == length(secondary_sponsor_addresses))
    stopifnot(length(secondary_sponsor_names) == length(secondary_sponsor_countries))
    for (c in seq_along(secondary_sponsor_names)) {
      l <- length(secondary_sponsor_trial_numbers) + 1
      secondary_sponsor_trial_numbers[[l]] <- current_trial_number
      secondary_sponsor_orders_vec[[l]] <- c
      secondary_sponsor_types_vec[[l]] <- secondary_sponsor_types[c]
      secondary_sponsor_names_vec[[l]] <- secondary_sponsor_names[c]
      secondary_sponsor_addresses_vec[[l]] <- secondary_sponsor_addresses[c]
      secondary_sponsor_countries_vec[[l]] <- secondary_sponsor_countries[c]
    }
    ## ethics committees
    ethics_committees_names <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/ethicname")
    ethics_committees_addresses <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/ethicaddress")
    ethics_approval_dates <- get_date_xpath(doc, "ethicsAndSummary/ethicscommitee/ethicapprovaldate")
    hrecs <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/hrec")
    ethics_submit_dates <- get_date_xpath(doc, "ethicsAndSummary/ethicscommitee/ethicsubmitdate")
    ethics_countries <- get_text_xpath(doc, "ethicsAndSummary/ethicscommitee/ethiccountry")
    stopifnot(length(ethics_committees_names) == length(ethics_committees_addresses))
    stopifnot(length(ethics_committees_names) == length(ethics_approval_dates))
    stopifnot(length(ethics_committees_names) == length(hrecs))
    stopifnot(length(ethics_committees_names) == length(ethics_submit_dates))
    stopifnot(length(ethics_committees_names) == length(ethics_countries))
    for (c in seq_along(ethics_committees_names)) {
      l <- length(ethics_committees_trial_numbers) + 1
      ethics_committees_trial_numbers[[l]] <- current_trial_number
      ethics_committees_orders_vec[[l]] <- c
      ethics_committees_names_vec[[l]] <- ethics_committees_names[c]
      ethics_committees_addresses_vec[[l]] <- ethics_committees_addresses[c]
      ethics_approval_dates_vec[[l]] <- ethics_approval_dates[c]
      hrecs_vec[[l]] <- hrecs[c]
      ethics_submit_dates_vec[[l]] <- ethics_submit_dates[c]
      ethics_countries_vec[[l]] <- ethics_countries[c]
    }
    ## contacts
    contacts_titles <- get_text_xpath(doc, "contacts/contact/title")
    contacts_names <- get_text_xpath(doc, "contacts/contact/name")
    contacts_addresses <- get_text_xpath(doc, "contacts/contact/address")
    contacts_phones <- get_text_xpath(doc, "contacts/contact/phone")
    contacts_faxes <- get_text_xpath(doc, "contacts/contact/fax")
    contacts_emails <- get_text_xpath(doc, "contacts/contact/email")
    contacts_countries <- get_text_xpath(doc, "contacts/contact/country")
    contacts_types <- get_text_xpath(doc, "contacts/contact/type")
    stopifnot(length(contacts_names) == length(contacts_titles))
    stopifnot(length(contacts_names) == length(contacts_addresses))
    stopifnot(length(contacts_names) == length(contacts_phones))
    stopifnot(length(contacts_names) == length(contacts_faxes))
    stopifnot(length(contacts_names) == length(contacts_emails))
    stopifnot(length(contacts_names) == length(contacts_countries))
    stopifnot(length(contacts_names) == length(contacts_types))
    for (c in seq_along(contacts_names)) {
      l <- length(contacts_trial_numbers) + 1
      contacts_trial_numbers[[l]] <- current_trial_number
      contacts_orders_vec[[l]] <- c
      contacts_names_vec[[l]] <- contacts_names[c]
      contacts_titles_vec[[l]] <- contacts_titles[c]
      contacts_addresses_vec[[l]] <- contacts_addresses[c]
      contacts_phones_vec[[l]] <- contacts_phones[c]
      contacts_faxes_vec[[l]] <- contacts_faxes[c]
      contacts_emails_vec[[l]] <- contacts_emails[c]
      contacts_countries_vec[[l]] <- contacts_countries[c]
      contacts_types_vec[[l]] <- contacts_types[c]
    }
  }
  # assemble the core tibble
  update_progress(1, 13, progress_obj)
  df <- tibble(
    trial_number = trial_number,
    trial_registration_type = trial_registration_type,
    submit_date = submit_date,
    approval_date = approval_date,
    stage = stage,
    utrn = utrn,
    study_title = study_title,
    scientific_title = scientific_title,
    trial_acronym = trial_acronym,
    interventions = interventions,
    comparator = comparator,
    control = control,
    # see also primary_outcomes tbl
    # see also secondary_outcomes tble
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
    # see also recruitment_hospitals tbl
    # see also recruitment_other_countries tbl
    primary_sponsor_type = primary_sponsor_type,
    primary_sponsor_name = primary_sponsor_name,
    primary_sponsor_address = primary_sponsor_address,
    primary_sponsor_country = primary_sponsor_country,
    # see sponsor_funding tbl
    # see secondary_sponsors tbl
    summary = summary,
    trial_website = trial_website,
    publication = publication,
    ethics_review = ethics_review,
    public_notes = public_notes,
    # see ethics_committees tbl 
    # see contacts tbl
  )
  # assemble the repeating data tibbles, trial_number is the foreign key in each.
  update_progress(2, 13, progress_obj)
  secondary_ids_df <- tibble(trial_number=secondary_id_trial_numbers,
                             secondary_id_order=secondary_ids_orders_vec,
                             secondary_id=secondary_ids_vec)
  update_progress(3, 13, progress_obj)
  health_conditions_df <- tibble(trial_number=health_conditions_trial_numbers,
                                 health_condition_order=health_conditions_orders_vec,
                                  health_condition=health_conditions_vec)
  update_progress(4, 13, progress_obj)
  health_conditions_codes_df <- tibble(trial_number=health_conditions_codes_trial_numbers,
                                       health_condition_code_order=health_conditions_codes_orders_vec,
                                  health_condition_code1=health_conditions_code1s_vec,
                                  health_condition_code2=health_conditions_code2s_vec)
  update_progress(5, 13, progress_obj)
  interventions_codes_df <- tibble(trial_number=interventions_codes_trial_numbers,
                                   intervention_order=interventions_codes_orders_vec,
                                  intervention_code=interventions_codes_vec) %>% filter(intervention_code != missing_string)
  update_progress(6, 13, progress_obj)
  primary_outcomes_df <- tibble(trial_number=primary_outcomes_trial_numbers,
                                  primary_outcome_order=primary_outcomes_orders_vec,
                                  primary_outcome=primary_outcomes_vec,
                                  primary_outcome_timepoint=primary_outcomes_timepoints_vec) %>% filter(primary_outcome != missing_string, primary_outcome_timepoint != missing_string)
  update_progress(7, 13, progress_obj)
  secondary_outcomes_df <- tibble(trial_number=secondary_outcomes_trial_numbers,
                                  secondary_outcome_order=secondary_outcomes_orders_vec,
                                  secondary_outcome=secondary_outcomes_vec,
                                  secondary_outcome_timepoint=secondary_outcomes_timepoints_vec) %>% filter(secondary_outcome != missing_string, secondary_outcome_timepoint != missing_string)
  update_progress(8, 13, progress_obj)
  recruitment_hospitals_df <- tibble(trial_number=recruitment_hospitals_trial_numbers,
                                     recruitment_hospital_order=recruitment_hospitals_orders_vec,
                                  recruitment_hospital=recruitment_hospitals_vec) %>% filter(recruitment_hospital != missing_string)
  update_progress(9, 13, progress_obj)
  recruitment_other_countries_df <- tibble(trial_number=recruitment_other_countries_trial_numbers,
                                  recruitment_other_country_order=recruitment_other_countries_orders_vec,
                                  recruitment_other_country=recruitment_other_countries_vec,
                                  recruitment_other_country_state=recruitment_other_countries_states_vec) %>% filter(recruitment_other_country != missing_string, recruitment_other_country_state != missing_string)
  update_progress(10, 13, progress_obj)
  sponsor_funding_sources_df <- tibble(trial_number=sponsor_funding_sources_trial_numbers,
                                  sponsor_funding_source_order=sponsor_funding_sources_orders_vec,     
                                  sponsor_funding_source_type=sponsor_funding_sources_types_vec,
                                  sponsor_funding_source_name=sponsor_funding_sources_names_vec,
                                  sponsor_funding_source_address=sponsor_funding_sources_addresses_vec,
                                  sponsor_funding_source_country=sponsor_funding_sources_countries_vec
                                  ) %>% filter(sponsor_funding_source_type != missing_string, sponsor_funding_source_name != missing_string, sponsor_funding_source_address != missing_string, sponsor_funding_source_country != missing_string)
  update_progress(11, 13, progress_obj)
  secondary_sponsors_df <- tibble(trial_number=secondary_sponsor_trial_numbers,
                                  secondary_sponsor_order=secondary_sponsor_orders_vec,
                                  secondary_sponsor_type=secondary_sponsor_types_vec,
                                  secondary_sponsor_name=secondary_sponsor_names_vec,
                                  secondary_sponsor_address=secondary_sponsor_addresses_vec,
                                  secondary_sponsor_country=secondary_sponsor_countries_vec
                                  ) %>% filter(secondary_sponsor_type != missing_string, secondary_sponsor_name != missing_string, secondary_sponsor_address != missing_string, secondary_sponsor_country != missing_string)

  update_progress(12, 13, progress_obj)
  ethics_committees_df <- tibble(trial_number=ethics_committees_trial_numbers,
                                  ethics_committee_order=ethics_committees_orders_vec,
                                  ethics_committee_name=ethics_committees_names_vec,
                                  ethics_committee_address=ethics_committees_addresses_vec,
                                  ethics_approval_date=ethics_approval_dates_vec,
                                  hrec=hrecs_vec,
                                  ethics_submit_date=ethics_submit_dates_vec,
                                  ethics_country=ethics_countries_vec)
  update_progress(13, 13, progress_obj)
  contacts_df <- tibble(trial_number=contacts_trial_numbers,
                                  contact_order=contacts_orders_vec,
                                  contact_title=contacts_titles_vec,
                                  contact_name=contacts_names_vec,
                                  contact_address=contacts_addresses_vec,
                                  contact_phone=contacts_phones_vec,
                                  contact_fax=contacts_faxes_vec,
                                  contact_email=contacts_emails_vec,
                                  contact_country=contacts_countries_vec,
                                  contact_type=contacts_types_vec)
  # return a named list of tibbles (data frames)
  if (!is.null(progress_obj)) {
    progress_obj$set(value=NULL, 
                     message="Storing ANZCTR data frames")
  }
  return(list("core"=df, 
              "secondary_ids"=secondary_ids_df, 
              "health_conditions"=health_conditions_df,
              "health_conditions_codes"=health_conditions_codes_df,
              "interventions_codes"=interventions_codes_df,
              "primary_outcomes"=primary_outcomes_df,
              "secondary_outcomes"=secondary_outcomes_df,
              "recruitment_hospitals"=recruitment_hospitals_df,
              "recruitment_other_countries"=recruitment_other_countries_df,
              "sponsor_funding_sources"=sponsor_funding_sources_df,
              "secondary_sponsors"=secondary_sponsors_df,
              "ethics_committees"=ethics_committees_df,
              "contacts"=contacts_df
              ))  
  if (!is.null(progress_obj)) {
    progress_obj$set(value=NULL, 
                     message="XML processing completed")
  }
}

store_anzctr_dfs <- function(df_suffix, df_list, dbcon) {
  df_name <- paste("anzctr_", df_suffix, sep="")
  # store in database
  dbWriteTable(dbcon, df_name, df_list[[df_suffix]], overwrite=TRUE)
  message(paste("Stored", df_name, "tbl containing", nrow(df_list[[df_suffix]]), "rows into MonetDB database."))
  invisible(NULL)
}

assign_anzctr_dfs <- function(df_suffix, df_list, envir, dbcon) {
  df_name <- paste("anzctr_", df_suffix, sep="")
  # assign to the calling environment
  df <- as.tibble(dbReadTable(con, df_name))
  assign(df_name, df, envir=envir)
  message(paste("Loaded", df_name, "tbl containing", nrow(df), "rows."))
  invisible(NULL)
}

ingest_anzctr_xml <- function(xmlpath="", dbcon=NULL, progress_obj=NULL) {
  anzctr_dfs <- anzctr_to_dfs(xmlpath=xmlpath, progress_obj=progress_obj)
  if (!is.null(progress_obj)) {
    progress_obj$set(value=NULL, 
                     message="Storing processed ANZCTR data in database")
  }
  store_anzctr_dfs("core", anzctr_dfs, dbcon)
  store_anzctr_dfs("secondary_ids", anzctr_dfs, dbcon)
  store_anzctr_dfs("health_conditions", anzctr_dfs, dbcon)
  store_anzctr_dfs("health_conditions_codes", anzctr_dfs, dbcon)
  store_anzctr_dfs("interventions_codes", anzctr_dfs, dbcon)
  store_anzctr_dfs("primary_outcomes", anzctr_dfs, dbcon)
  store_anzctr_dfs("secondary_outcomes", anzctr_dfs, dbcon)
  store_anzctr_dfs("recruitment_hospitals", anzctr_dfs, dbcon)
  store_anzctr_dfs("sponsor_funding_sources", anzctr_dfs, dbcon)
  store_anzctr_dfs("secondary_sponsors", anzctr_dfs, dbcon)
  store_anzctr_dfs("ethics_committees", anzctr_dfs, dbcon)
  store_anzctr_dfs("contacts", anzctr_dfs, dbcon)
  invisible(NULL)
}

load_anzctr_dfs <- function(dbcon=NULL) {
  assign_anzctr_dfs("core", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("secondary_ids", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("health_conditions", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("health_conditions_codes", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("interventions_codes", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("primary_outcomes", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("secondary_outcomes", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("recruitment_hospitals", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("sponsor_funding_sources", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("secondary_sponsors", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("ethics_committees", anzctr_dfs, parent.frame(), dbcon)
  assign_anzctr_dfs("contacts", anzctr_dfs, parent.frame(), dbcon)
  invisible(NULL)
}

