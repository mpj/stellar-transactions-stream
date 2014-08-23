#!/usr/bin/env node
var debounce = require('mout/function/debounce');
var isFunction = require('mout/lang/isFunction');
var crypto = require('crypto');
var exec = require('child_process').exec
var recursive = require('recursive-readdir');
var uncache = require ('require-uncache') 

require('coffee-script/register');

var specifiedFile = process.argv[2];

 
function runCommandLine(cmd, pipeOutputToConsole, callback) {
  var child = exec(cmd, function (error, outputSuccess, outputError) {
    if (!!error) {
      console.warn(error.stack);
      callback(new Error(outputError))
    } else {
      callback(null, outputSuccess)
    }
  })
 
  if (pipeOutputToConsole) {
    child.stdout.pipe(process.stdout)
    child.stderr.pipe(process.stderr)
  }
}

var ignoreDirectories = [
  'node_modules', '.git', '.c9'
]

 
function getHashOfDirectory(directory, callback) {

  var cmd = '';
  cmd += 'find . ';
  ignoreDirectories.forEach(function(dir) {
    cmd += "-not \\( -path ./" + dir + " -prune \\) ";
  })
  cmd += '-ls ';
  runCommandLine(cmd, false, function(error, output) {
    if (error) return console.warn(error.stack);
    callback(output)
  })
}

function hash(str) {
  return crypto.createHash('md5').update(str).digest('hex');
}

var startTimeMs = (new Date).getTime();
getHashOfDirectory('.', function() {
  var endTimeMs = (new Date).getTime();
  var intervalTime = (endTimeMs - startTimeMs) * 5

  var lastHash = '';
  setInterval(function() {
    getHashOfDirectory('.', function(hash) {
      if (lastHash !== hash) {
        lastHash = hash;
        onDirectoryChanged();
      }
    })
  }, intervalTime);
  
  var runSpecs = function () {
    console.log('Running...')
    
    if (specifiedFile) {
      var path = process.cwd()+'/'+specifiedFile
      try {
        var spec = require(path)
        if (isFunction(spec.exec))
          spec.exec()
      } catch(e) {
        console.warn("Error:", e.stack)
      }
      uncache(path)
      
      
    } else {
      recursive('./', function (err, files) {
        console.log('\033[2J'); // clear
        var cleaned = files
        .filter(function(file) {
          return file.indexOf('spec.coffee') > -1 || file.indexOf('spec.js') > -1
        })
        .filter(function(file) {
          var include = true;
          ignoreDirectories.forEach(function(dir) {
            if(file.indexOf(dir) === 0)
              include = false;
          })
          return include;
        })
        
        cleaned.forEach(function(file) {
          var path = process.cwd()+'/'+file
          var spec = require(path)
          if (isFunction(spec.exec))
            spec.exec()
          uncache(path)
        })
        
      });
    }

  }
  var onDirectoryChanged = debounce(runSpecs, 500)
})
 
