const webpack = require('webpack');
const path = require('path');
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const HtmlWebpackHarddiskPlugin = require('html-webpack-harddisk-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

const extractLESS = new ExtractTextPlugin({
  filename: 'stylesheets/[name].[contenthash].css'
  //    disable: process.env.NODE_ENV === "development"
});

function htmlPlugin(filename, chunks, links) {
  return new HtmlWebpackPlugin({
    filename,
    chunks,
    template: require('html-webpack-template'), inject: false,
    title: "Cancer Match",
    appMountId: "react-root",
    alwaysWriteToDisk: true,
    links: [
      "//cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.12/semantic.min.css",
    ],
  })
}

module.exports = {
  entry: {
    app: './src/entrypoints/app.tsx',
  },
  output: {
    filename: '[name].[hash].bundle.js',
    path: path.resolve(__dirname, '..', 'webserver', 'build'),
    publicPath: '/build/',
  },
  devServer: {
    port: 8000,
    publicPath: "http://localhost:8000/build/",
    headers: { "Access-Control-Allow-Origin": "*" }, // for iconmoon fonts
    historyApiFallback: {
      disableDotRule: true,
      verbose: true,
    },
  },
  module: {
    rules: [
      {
        test: /\.less$/i,
        use: extractLESS.extract([ 'css-loader', 'less-loader' ])
        // to disable in dev see https://github.com/webpack-contrib/less-loader
      },
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
       // loader: 'ts-loader',
        // awesome-typescript-loader may be faster? https://github.com/s-panferov/awesome-typescript-loader#differences-between-ts-loader
        use: [
          //{ loader: 'cache-loader' },
          {
            loader: 'thread-loader',
            options: {
              // there should be 1 cpu for the fork-ts-checker-webpack-plugin
              workers: require('os').cpus().length - 1,
            },
          },
          {
            loader: 'ts-loader',
            options: {
              happyPackMode: true // IMPORTANT! use happyPackMode mode to speed-up compilation and reduce errors reported to webpack
            }
          }
        ]
      },
      {
        test: /\.(graphql|gql)$/,
        exclude: /node_modules/,
        loader: 'graphql-tag/loader',
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      }
    ]
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js", "jsx"]
  },
  plugins: [
    new ForkTsCheckerWebpackPlugin({ checkSyntacticErrors: true }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'common' // common bundle's name.
    }),
    extractLESS,
    htmlPlugin("index.html", ["common", "app"]),
    new HtmlWebpackHarddiskPlugin()
  ]
};