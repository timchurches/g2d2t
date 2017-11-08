const express = require('express');
var request = require('request');

const {
  recordContainsFeature,
  recordContainsStrings,
  allTrialRecords,
} = require('./data');

var router = express.Router();

router.get('/searchTrials', async function(req, res, next) {

    const genes = req.query.genes.split(' ').map(str => str.trim()).filter(str => str);
    const disease = req.query.disease || "";

    const searchByExtractedFeatures = true;
    const matchesGenes = allTrialRecords.filter(trial => {

      if (searchByExtractedFeatures) {
        // search based on features extracted via the R library
        return recordContainsFeature(trial, genes);
      } else {
        // very simplistic free-text search
        return recordContainsStrings(trial, genes);
      }
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
