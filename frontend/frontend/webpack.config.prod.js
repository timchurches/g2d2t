'use strict';

var webpack = require('webpack');
var webpackConfig = require('./webpack.config.js');

var commitHash = // idea thanks to https://stackoverflow.com/a/38401256/94078
  require('child_process')
    //.execSync('git rev-parse --short HEAD')
    .execSync('hg id -i')
    .toString().trim();
console.log("building revision", commitHash);

const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const BrotliPlugin = require('brotli-webpack-plugin');
const CompressionPlugin = require("compression-webpack-plugin")

module.exports = function () {
  var myProdConfig = webpackConfig;
  //myProdConfig.output.filename = '[name].[hash].js';

  myProdConfig.plugins = myProdConfig.plugins.concat(
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify('production'),
        'COMMIT_HASH': JSON.stringify(commitHash),
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
    }),

    new BrotliPlugin({
      asset: '[path].br[query]',
      test: /\.(js|css|html|svg)$/,
      threshold: 10240,
      minRatio: 0.8
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.js$|\.css$|\.html$/,
      threshold: 10240,
      minRatio: 0.8
    }),
  );

  return myProdConfig;
};
