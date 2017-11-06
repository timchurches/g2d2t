This is a front-end for searching ANZCTR clinical trials by genes and diseases, originally developed at HealthHack Sydney 2017.

Very much a work-in-progress.

Projects
================

* frontend - HTML5 client built with React/Redux/Semantic-UI
* webserver - NodeJS server that hosts both a JSON API and the frontend

Data
===============

* webserver/data/anzctr.json - ANZCTR clinic trial records exported from XML to JSON via R
* webserver/data/anzctr_extracted_features.json - terms extracted by the G2D2T R package


Development
================

* Install NodeJS 8 and the yarn package manager (`npm install yarn -g`)
* Open both frontend and webserver in separate editors (e.g. VS Code)
* From the frontend directory:
** Run `yarn` (to install dependencies)
** Run `yarn dev` (serves front-end on port 8000 in development mode - watches for changes, recompiles and refreshes the page)
* From the webserver directory:
** Run `yarn` (to install dependencies)
** Edit src/frontend.js to set developmentMode to true
** Run `yarn watch` (starts webserver on port 3000 and restarts it when a file changes)
** Go to http://localhost:3000

Deployment
=========================
* From the frontend directory:
** Run `yarn` (to install dependencies)
** Run `yarn build` (builds frontend to static files in ../webserver/build)

* From the webserver directory:
** Run `yarn` (to install dependencies)
** Edit src/frontend.js to set developmentMode to false
** Run `yarn start` (starts webserver on port 3000)
** Go to http://localhost:3000 and test it

Once built can be deployed for example onto Google AppEngine:
* `cd webserver`
* `gcloud app deploy --project healthhack2017-cancer-matching`
