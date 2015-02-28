'use strict'

require('dotenv').load();

var async = require('async')
  , express = require('express')
  , bodyParser = require('body-parser')
  , app = express()
  , fs = require('fs')
  , mkdirp = require('mkdirp')
  , dataDir = 'data/'
  , archiveDir = 'archive/'

var port = process.env.PORT;

// for parsing application/json
app.use(bodyParser.json())

app.get('/_status_/heartbeat', function (req, res) {
  res.type("text").send("OK");
});

// record json
app.post('/', function(req, res) {
  var json = req.body
    , name = (new Date).getTime()

  fs.writeFile(dataDir + name + '.json', json , function(err){
    if (err) {
      res.json({ status: 'error', message: err })
    } else {
      res.json({ status: 'success', data: json })
    }
  })
})

// Ensure port is set
function ensurePort(callback) {
  console.log("Ensuring port")
  if (! port){
    callback(new Error("Port not set"))
  }

  callback()
}

// Ensure dataDir exists
function ensureDataDir(callback) {
  console.log("Ensuring data/")
  mkdirp(dataDir, function(err){
    if (err){
      callback(err)
    }
    callback()
  })
}

// Ensure archiveDir exists
function ensureArchiveDir(callback) {
  console.log("Ensuring archive/")
  mkdirp(archiveDir, function(err){
    if (err){
      callback(err)
    }
    callback()
  })
}

async.waterfall([
  ensurePort,
  ensureDataDir,
  ensureArchiveDir
],function(err){
  if (err){
    console.log(err)
    exit(1)
  }
  app.listen(port)
})

