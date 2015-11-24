var path = require('path');

var srcs = [
  'src[]=bower_components/purescript-*/src/**/*.purs',
  'src[]=src/**/*.purs',
  'src[]=example/**/*.purs'
];

var ffis = [
  'ffi[]=bower_components/purescript-*/src/**/*.js',
  'ffi[]=src/**/*.js',
  'ffi[]=example/**/*.js'
];

var output = 'output';

var modulesDirectories = [
  'node_modules',
  'dist',
  'bower_components/purescript-prelude/src'
];

var config
  = { entry: './entry'
    , output: { path: 'js'
              , pathinfo: true
              , filename: 'example.js'
              }
    , module: { loaders: [ { test: /\.purs$/
                           , loader: 'purs-loader?output=' + output + '&' + srcs.concat(ffis).join('&')
                           } ] }
    , resolve: { modulesDirectories: modulesDirectories
               , extensions: ['', '.js']
               }
    , resolveLoader: { root: path.join(__dirname, 'node_modules') }
    }
    ;

module.exports = config;
