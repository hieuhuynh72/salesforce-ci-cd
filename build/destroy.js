require('dotenv').config();
var fs = require('fs');
var path = require('path');
var tools = require('cs-jsforce-metadata-tools');
var hasDestructivePhase = require('./destructivePhase');

//   Options:
//     username [username]          Salesforce username
//     password [password]          Salesforce password (and security token, if available)
//     loginUrl [loginUrl]          Salesforce login url
//     checkOnly                    Whether Apex classes and triggers are saved to the organization as part of the deployment
//     dry-run                      Dry run. Same as --checkOnly
//     testLevel [testLevel]        Specifies which tests are run as part of a deployment (NoTestRun/RunSpecifiedTests/RunLocalTests/RunAllTestsInOrg)
//     runTests [runTests]          A list of Apex tests to run during deployment (comma separated)
//     ignoreWarnings               Indicates whether a warning should allow a deployment to complete successfully (true) or not (false).
//     rollbackOnError              Indicates whether any failure causes a complete rollback (true) or not (false)
//     pollTimeout [pollTimeout]    Polling timeout in millisec (default is 60000ms)
//     pollInterval [pollInterval]  Polling interval in millisec (default is 5000ms)
//     verbose                      Output execution detail log
var options = {
    loginUrl: 'https://login.salesforce.com',
    checkOnly: false,
    testLevel: 'RunLocalTests',
    ignoreWarnings: true,
    pollTimeout: 7200000,
    pollInterval: 15000,
    rollbackOnError: true,
    verbose: true
};

var logger = (function (fs) {
    var buffer = '';
    return {
        log: log,
        flush: flush
    };
    function log(val) {
        buffer += val + '\n';
    }
    function flush() {
        var logFile = path.resolve((process.env.SALESFORCE_ARTIFACTS || '.') + '/DeployStatistics.log');
        fs.appendFileSync(logFile, buffer, 'utf8');
        buffer = '';
    }
})(fs);

var branch = process.env['SF_BRANCH'];
console.info('Branch Name:', branch);

const isProduction = branch === 'master';

if (isProduction) {
    console.info(`On '${branch}' branch represents production. Leaving loginUrl as-is.`);
} else if (branch === 'develop') {
    console.info(`On '${branch}' branch, for productivity, will skip Destroy phase.`);
    return;
} else {
    console.info(`On '${branch}' branch, updating loginUrl for Sandbox.`);
    options.loginUrl = 'https://test.salesforce.com';
}

options.username = process.env[branch.toUpperCase() + '_USERNAME'] || process.env[branch + '_USERNAME'];
options.password = process.env[branch.toUpperCase() + '_PASSWD'] || process.env[branch + '_PASSWD'];

console.info('Username: ', options.username);
console.info('Password: ', 'hidden for your safety');
console.info('LoginUrl: ', options.loginUrl);

hasDestructivePhase()
    .then((fileContent) => {
        if (fileContent) {
            var artifacts = path.resolve((process.env.SALESFORCE_ARTIFACTS || '.') + '/destructiveChanges.xml');
            fs.writeFileSync(artifacts, fileContent);

            console.info('Start to deploy...');
            return tools.deployFromDirectory('./build/destroy', options).then((deployResult) => {
                tools.reportDeployResult(deployResult, logger, options.verbose);
                logger.flush();
                if (
                    !deployResult.success ||
                    deployResult.numberTestErrors > 0 ||
                    deployResult.numberComponentErrors > 0
                ) {
                    console.error('Destructive changes were NOT Successful');
                    return Promise.reject('Destructive changes were NOT Successful');
                } else {
                    console.log('Destructive changes were Successful');
                    fs.writeFileSync('.validationId', deployResult.id);
                    Promise.resolve(true);
                }
            });
        } else {
            console.log('No destroy phase to build. Have some candies yourself.');
            return Promise.resolve(false);
        }
    })
    .catch(function (err) {
        console.error(err.message);
        process.exit(1);
    });
