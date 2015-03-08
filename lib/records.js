'use strict'

var async = require('async')
  , fs = require('fs')
  , dataDir = 'data/'
  , archiveDir = 'archive/'
  , settingsFile = 'settings/settings.json';

module.exports = function(app) {
  // Get records
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
  });

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
  });

  return app;
}
