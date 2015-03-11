'use strict'

var exec = require('child_process').exec,
    util = require('util');

module.exports = function(app) {
  var STATUS_ERR_MSG = "There was an error gettig the update status.";

  app.get('/heartbeat', function (req, res) {
    res.type("text").send("OK");
  });

  app.get('/update', function (req, res) {
    exec('systemctl status sfv2-update.service', function (err, stdout, stderr) {
      var data = {},
          titleLine = stdout.match(/- (.+)$/m),
          activeLine = stdout.match(/Active\: (\w+) \((\w+)\).+; (.+)$/m),
          msg;
      if (!titleLine) {
        msg = util.format("%s\n\n%s\n\n%s\n", STATUS_ERR_MSG, stdout, stderr);
        res.type("text").status(500).send(msg);
      } else if (!activeLine) {
        msg = util.format("%s: %s\n\n%s\n", titleLine[1], STATUS_ERR_MSG, stdout);
        res.type("text").status(500).send(msg);
      } else {
        if (activeLine[1] == "inactive") {
          msg = util.format("%s: done - %s\n", titleLine[1], activeLine[3]);
        } else if (activeLine[1] == "active") {
          msg = util.format("%s: %s since %s\n", titleLine[1], activeLine[2], activeLine[3]);
        } else {
          msg = util.format("%s: %s\n\t%s\n\t%j\n\n%s\n", titleLine[1], STATUS_ERR_MSG,
              "Unknown 'active' line state:", activeLine, stdout);
        }
        res.type("text").send(msg);
      }
    });
  });

  return app;
}
