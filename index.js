'use strict'

require('dotenv').load();

var async = require('async')
  , express = require('express')
  , bodyParser = require('body-parser')
  , app = express()
  , fs = require('fs')
  , mkdirp = require('mkdirp')
  , _ = require('lodash')
  , dataDir = 'data/'
  , archiveDir = 'archive/'
  , settingsDir = 'settings/'
  , settingsFile = settingsDir + 'settings.json'
  , server = require('http').Server(app)
  , io = require('socket.io').listen(server);

var port = process.env.PORT;

// for parsing application/json
app.use(bodyParser.json())

app.get('/_status_/heartbeat', function (req, res) {
  res.type("text").send("OK");
});

// get settings json
app.get('/settings.json', function(req, res) {
  fs.readFile(settingsFile, {encoding: 'utf8'}, function(err, content){
    if (err) {
      res.json({ status: 'error', message: err })
    } else {
      res.json({ status: 'success', data: content })
    }
  })
})

// write settings json
app.post('/settings.json', function(req, res) {
  var json = req.body

  fs.writeFile(settingsFile, JSON.stringify(json), function(err){
    if (err) {
      res.json({ status: 'error', message: err })
    } else {
      res.json({ status: 'success', data: json })
    }
  })
})

// record json
app.post('/record.json', function(req, res) {
  var json = req.body
    , name = (new Date).getTime()

  // Add id to test for duplicates during processing
  json._id = name;

  fs.writeFile(dataDir + name + '.json', JSON.stringify(json), function(err){
    if (err) {
      res.json({ status: 'error', message: err })
    } else {
      res.json({ status: 'success', data: json })
    }
  })
})

app.get('/records.json', function(req, res) {
  var data = []

	// First try to read the settings file
  fs.readFile(settingsFile, {encoding: 'utf8'}, function(err, content){
    if (! err) {
      data.push(content)
    }

		// Now read all the great data
		fs.readdir(dataDir, function(err, files){
			if (err) {
				return res.json({ status: 'error', message: err })
			}


			function readFile(ndx, callback) {
				if (ndx < files.length){
					fs.readFile(dataDir + files[ndx], {encoding: 'utf8'}, function(err, content){
						if (err) {
							callback(err)
						} else {
							data.push(content)
							readFile(ndx + 1, callback)
						}
					})
				} else {
					callback()
				}
			}

			function moveFile(ndx, callback) {
				if (ndx < files.length) {
					fs.rename(dataDir + files[ndx], archiveDir + files[ndx], function(err){
							if (err) {
								callback(err)
							} else {
								moveFile(ndx + 1, callback)
							}
					})
				} else {
					callback()
				}
			}

			async.waterfall([
				function(callback){
					readFile(0, callback)
				},
				function(callback){
					moveFile(0, callback)
				},
			],function(err){
					if (err) {
						res.json({ status: 'error', message: err })
					}else{
						res.json({ status: 'success', data: data })
					}
			})

		})
  })
})

io.on('connection', function(socket){
  console.log('it is working?');
  socket.on('chat request', function(msg){
    console.log('heard you');
    io.emit('chat request', msg);
  });

  socket.on('chat response', function(msg){
    console.log('heard you');
    io.emit('chat response', msg);
  });  
});

app.get('/touch', function(req, res){
    res.sendFile(__dirname + '/touch.html');
});

app.get('/tablet', function(req, res){
    res.sendFile(__dirname + '/tablet.html');
});


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

// Ensure settingsDir exists
function ensureSettingsDir(callback) {
  console.log("Ensuring settings/")
  mkdirp(settingsDir, function(err){
    if (err){
      callback(err)
    }
    callback()
  })
}

async.waterfall([
  ensurePort,
  ensureDataDir,
  ensureArchiveDir,
  ensureSettingsDir
],function(err){
  if (err){
    console.log(err)
    exit(1)
  }
  server.listen(port, function(){ console.log('Server listening now on : ' + port); } );
})

