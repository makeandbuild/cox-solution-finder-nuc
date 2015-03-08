'use strict'

var fs = require('fs')
  , settingsDir = 'settings/'
  , settingsFile = settingsDir + 'settings.json';

module.exports = function(app) {
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

  return app;
}
