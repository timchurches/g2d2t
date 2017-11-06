'use strict';

var webpack = require('webpack');
var webpackConfig = require('./webpack.config.js');

const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

module.exports = function () {
  var myProdConfig = webpackConfig;
  //myProdConfig.output.filename = '[name].[hash].js';

  myProdConfig.plugins = myProdConfig.plugins.concat(
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('production'),
      }
    }),
    // new webpack.optimize.CommonsChunkPlugin({ name: 'vendor', filename: 'vendor.[hash].js' }),
    // new webpack.optimize.UglifyJsPlugin({
    new UglifyJsPlugin({
      uglifyOptions: {
        ecma: 8
      },
      // compress: {
      //   warnings: true
      // }
    })
  );

  return myProdConfig;
};
