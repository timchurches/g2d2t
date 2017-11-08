var fs = require('fs');
var path = require('path');
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


/* GET home page. */

const developmentMode = false;

if (developmentMode) {
    // use webpack-dev-webserver running on port 800
    router.get('/', function(req, res, next) {
        sendHTMLPage("index", res);
    });

    router.get("/build/:webpackFile", (req, res) => {
        sendDevServerFrontendFile(`/build/${req.params.webpackFile}`, res);
    });
} else {
    // use statically built files
    router.get("/", (req, res) => {
        console.log(__dirname);
        res.sendFile('build/index.html', { root: path.join(__dirname, "..") });
    });

    router.use("/build", express.static(path.join(__dirname,"..", "build")));
}



module.exports = router;