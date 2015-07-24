"use strict";

var CronJob   = require('cron').CronJob,

  // Get the name of our user-provided credential service.
  cf_creds  = process.env.CF_CREDS,

  // Use cfenv to grab our credentials from the credential service.
  cfenv     = require("cfenv"),
  appEnv    = cfenv.getAppEnv(),
  creds     = appEnv.getServiceCreds(cf_creds),

  // For reading crontab.json
  fs        = require('fs'),

  // For running all of our jobs.
  spawn     = require('child_process').spawn,

  // YAML to parse the crontab.
  YAML      = require('yamljs');

// Does the parameter look like the name of a service credential.
function credEval(cred) {
  if (cred.split(".")[0] === 'creds') {
    // Is there a better way do this? Evaluating single strings
    // doesn't seem terrible.
    return eval(cred);
  }
  return cred;
}

// Clean up parameters and check if they're service credentials.
function evalJob(job) {
  var comma = ',';
  job = job.split(comma);
  job = job.map(Function.prototype.call, String.prototype.trim);
  job = job.map(credEval);
  return job;
}

// Make a new cronjob.
function makeJob(entry) {

  // Say something about which job we're on.
  console.log('Creating Job: ' + entry.name);

  // Set the timezone null if not provided.
  if (!entry.hasOwnProperty('tz')) {
      entry.tz = null;
    }

  // Create a new cronjob.
  new CronJob(entry.schedule, function () {
  // Carve up the prep job into command and params.
    var job = evalJob(entry.command),
      job_run;

    if (job.length > 1) {
      job_run = spawn(job[0], job.slice(1));
    } else {
      job_run = spawn(job[0]);
    }

    // Handle and label job output.
    job_run.stdout.on('data', function (data) {
      console.log('Job: ' + entry.name + ' - Out: ' + data);
    });

    job_run.stderr.on('data', function (data) {
      console.log('Job: ' + entry.name + ' - Err: ' + data);
    });

    job_run.on('close', function (code) {
      console.log('Job: ' + entry.name + ' - Exit: ' + code);
    });
  }, 
  null, 
  true,
  entry.tz);
}

// Make a new prep job.
function makePrep(entry) {
  // Say something about the job in progress.
  console.log('Preparing for: ' + entry.name + ' with ' + entry.prep.name);

  // Run our prep commands.
  var spawn = require('child_process').spawn,
    prep = evalJob(entry.prep.command),
    prep_run;

  // Carve up the prep job into command and params.
  if (prep.length > 1) {
    prep_run = spawn(prep[0], prep.slice(1));
  } else {
    prep_run = spawn(prep[0]);
  }

  // Handle and label job output.
  prep_run.stdout.on('data', function (data) {
    console.log('Prep: ' + entry.prep.name + ' - Out: ' + data);
  });

  prep_run.stderr.on('data', function (data) {
    console.log('Prep: ' + entry.prep.name + ' - Err: ' + data);
  });

  prep_run.on('close', function (code) {
    console.log('Prep: ' + entry.prep.name + ' - Exit: ' + code);

    // Set up cron and run the job.
    console.log('Finished: ' + entry.prep.name);
    if (code === 0) {
      // Now run the job.
      makeJob(entry);
    } else {
      console.log('Prep job failed. Stopping.');
      process.exit();
    }
  });
}

// Look for a crontab. Try yaml then json.  
var crontab;

try {
  crontab = YAML.parse(fs.readFileSync('crontab.yml', 'utf8'));
  console.log('Found crontab.yml.');
} catch (e) {
  try {
    crontab = JSON.parse(fs.readFileSync('crontab.json', 'utf8'));
    console.log('Found crontab.json.');
  } catch (e) {
    console.log('No crontabs found.');
    console.log('Please add crontab.yml or crontab.json.');
    console.log('The error was: ' + e);
    process.exit();
  }
}

// Lets begin.
console.log("cf-cron started...");

// Summarize the crontab.
console.log('Found ' + crontab.jobs.length + ' jobs.');
crontab.jobs.forEach(function (item, index) {
  console.log(index + ':' + item.name);
});

// Run jobs.
crontab.jobs.forEach(function (item, index) {
  if (item.hasOwnProperty('prep')) {
    makePrep(item);
  } else {
    makeJob(item);
  }
});