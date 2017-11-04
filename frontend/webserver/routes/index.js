var fs = require('fs');
var express = require('express');
var fetch = require('node-fetch');
var request = require('request');
var router = express.Router();

function sendDevServerFrontendFile(path, res) {
    const devUrl = `http://localhost:8000` + path;
    console.log({devUrl});
    request(devUrl)
        .on('error', (err) => {
            console.error({err, devUrl}, 'sendDevServerFrontendFile failed to pipe to dev server');
        })
        .pipe(res);
}

function sendHTMLPage(page, res) {
    sendDevServerFrontendFile(`/build/${page}.html`, res);
}

router.get("/build/:webpackFile", (req, res) => {
    sendDevServerFrontendFile(`/build/${req.params.webpackFile}`, res);
});

/* GET home page. */
router.get('/', function(req, res, next) {
  sendHTMLPage("index", res);
});


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
console.log("BRCA1", termsToTrialIds.get("BRCA1"))

const dataJson = fs.readFileSync('data/anzctr.json');
const data = JSON.parse(dataJson);
for (const record of data) {
  const trialId = record.actrnumber;

  const drugs = trialIdToDrugs.get(trialId) || [];
  const genes = trialIdToGenes.get(trialId) || [];
  record["extracted_drugs"] = Array.from(new Set(drugs)).sort();
  record["extracted_genes"] = Array.from(new Set(genes)).sort();
}

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

router.get('/searchTrials', async function(req, res, next) {

    const genes = req.query.genes.split(' ').map(str => str.trim()).filter(str => str);
    const disease = req.query.disease || "";

    // validate genes
    for (const gene in genes) {
      const body = JSON.stringify([gene]);
      const headers = { 'Content-Type': 'application/json' };
      // fetch('http://www.cbioportal.org/api/genes/fetch?geneIdType=HUGO_GENE_SYMBOL',
      //     { method: 'POST', body, headers })
      // .then(res => res.text())
      // .then(json => console.log(json));
    }

    const matchesGenes = data.filter(trial => {
      return recordContainsFeature(trial, genes);
      // return recordContainsStrings(trial, genes);
    });


    const withDisease = [];
    const withoutDisease = [];

    for (const trial of matchesGenes) {
      if (!disease) {
        withoutDisease.push(trial);
      } else {
        console.log("disease", disease);
        if (recordContainsStrings(trial, [disease])) {
          console.log("found", disease);
          withDisease.push(trial);
        } else {
          console.log("not found", disease);
          withoutDisease.push(trial);
        }
      }
    }

    const reply =  {
      success: true,
      errors: [],
      withDiseaseCount: withDisease.length,
      withoutDiseaseCount: withoutDisease.length,
      withDisease,
      withoutDisease
    }

  res.json(reply)
});

module.exports = router;
