const fs = require('fs');

// read & process result of term extraction peformed by the R code
const features = JSON.parse(fs.readFileSync('data/anzctr_extracted_features.json'))

const termsToTrialIds = new Map()
const trialIdToGenes = new Map()
const trialIdToDrugs = new Map()

for (const [trialId, featureTypes] of Object.entries(features)) {

  for (const [featureType, featureTerms] of Object.entries(featureTypes)) {

    for (const [termId, termContent] of Object.entries(featureTerms)) {
      const terms = Object.keys(termContent).map(str => str.toUpperCase());
      // console.log("found", trialId, terms)
      for (const term of terms) {
        if (termsToTrialIds.has(term)) {
          // console.log("existing", terms, trialId)
          termsToTrialIds.get(term).push(trialId)
        } else {
          // console.log("adding", terms, trialId)
          termsToTrialIds.set(term, [trialId])
        }

        if (termId.startsWith("DB")) {
          if (trialIdToDrugs.has(trialId)) {
            trialIdToDrugs.get(trialId).push(term)
          } else {
            trialIdToDrugs.set(trialId, [term])
          }
        } else {
          if (trialIdToGenes.has(trialId)) {
            trialIdToGenes.get(trialId).push(term)
          } else {
            trialIdToGenes.set(trialId, [term])
          }
        }

      }
    }
  }
}
// console.log(Object.entries(termsToTrialIds));
// console.log(termsToTrialIds);
// console.log("BRCA1", termsToTrialIds.get("BRCA1"))


// read ANZCTR records exported to JSON and annotate them with extracted terms
const allTrialRecords = JSON.parse(fs.readFileSync('data/anzctr.json'));

for (const record of allTrialRecords) {
  const trialId = record.actrnumber;

  const drugs = trialIdToDrugs.get(trialId) || [];
  const genes = trialIdToGenes.get(trialId) || [];
  record["extracted_drugs"] = Array.from(new Set(drugs)).sort();
  record["extracted_genes"] = Array.from(new Set(genes)).sort();
}

// functions for searching

function recordContainsFeature(trial, toSearch) {
  for (feature of toSearch) {
    const trialsMatchingFeature = termsToTrialIds.get(feature) || [];
    if ( trialsMatchingFeature.indexOf(trial.actrnumber) >= 0) {
      return true;
    }
  }
  return false;
}

function recordContainsStrings(trial, toSearch) {
    delete trial.publication;
    for (const value of Object.values(trial)) {

      for (searchValue of toSearch) {
        // console.log(value)
        const strValue = value + '';
        if (strValue.length > 0 && strValue.indexOf(searchValue) >= 0) {
          // console.log("found", value, searchValue)
          return true;
        }
      }
    }
    return false;
}


module.exports = {
    recordContainsFeature,
    recordContainsStrings,
    allTrialRecords
}