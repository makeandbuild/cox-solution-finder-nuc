var exec = require('child_process').exec,
    async = require('async'),
    util = require('util');

module.exports = function(app) {
  var STATUS_ERR_MSG = "There was an error gettig the update status.";

  app.get('/heartbeat', function (req, res) {
    res.type("text").send("OK");
  });

  function systemctlStatus(serviceName, callback) {
    exec('systemctl status ' + serviceName + '.service', function (err, stdout, stderr) {
      var data = {},
          titleLine = stdout.match(/- (.+)$/m),
          activeLine = stdout.match(/Active\: (\w+) \((\w+)\).+; (.+)$/m),
          errMsgFull = STATUS_ERR_MSG + "\n\n" + stdout + "\n",
          msg;

      stdout = stdout.trimRight();
      stderr = stderr.trimRight();

      if (stderr.length > 0) {
        errMsgFull = errMsgFull + "\n" + stderr + "\n";
      }

      if (!titleLine) {
        msg = errMsgFull;
        console.error("Invalid title line in status:\n%s", stdout);
      } else if (!activeLine) {
        msg = titleLine[1] + ": " + errMsgFull;
        console.error("Invalid active line in status:\n%s", stdout);
      } else {
        if (activeLine[1] == "inactive") {
          msg = util.format("%s: done - %s\n", titleLine[1], activeLine[3]);
        } else if (activeLine[1] == "active") {
          msg = util.format("%s: %s since %s\n", titleLine[1], activeLine[2], activeLine[3]);
        } else {
          msg = util.format("%s: %s\n\t%s\n\t%j\n\n%s\n", titleLine[1], STATUS_ERR_MSG,
              "Unknown 'active' line state:", activeLine, stdout);
          if (stderr.length > 0) {
            msg = msg + "\n" + stderr + "\n";
          }
          console.error("Unknown active line state in status:\n%s", stdout);
        }
      }
      callback(null, msg);
    });
  }

  app.get('/update', function (req, res) {
    async.parallel([
      function(cb) {
        systemctlStatus("sfv2-sync", cb);
      },
      function(cb) {
        systemctlStatus("sfv2-update", cb);
      }
    ], function(err, results) {
      var output = results.join("\n\n");
      if (err) {
        console.error(err);
        res.type("text").status(500).send('Error: '+err.message+"\n\n"+output);
      } else {
        res.type("text").send(output);
      }
    });
  });

  return app;
};
