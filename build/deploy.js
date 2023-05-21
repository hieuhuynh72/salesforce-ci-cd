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
    loginUrl: "https://login.salesforce.com",
    checkOnly: false,
    testLevel: 'RunLocalTests',
    ignoreWarnings : true,
    pollTimeout: 7200000,
    pollInterval: 15000,
    rollbackOnError : true,
    verbose : true
};

var logger = (function (fs) {
    var buffer = '';
    return {
        log: log,
        flush: flush
    };
    function log(val) {
        buffer += (val + '\n');
    }
    function flush() {
        var logFile = path.resolve((process.env.SALESFORCE_ARTIFACTS || '.') + '/DeployStatistics.log');
        fs.appendFileSync(logFile, buffer, 'utf8');
        buffer = '';
    }
} (fs));

//copy the package-xml to artifacts
fs.stat('./src/package.xml', function(err, stat) {
    if(err === null) {
        console.log('Found /src/package.xml');
        var origin = path.resolve('./src/package.xml');
        var artifacts =  path.resolve((process.env.SALESFORCE_ARTIFACTS || '.') + '/package.xml');
        if (fs.statSync(origin).isFile()){
            fs.writeFileSync(artifacts, fs.readFileSync(origin, 'utf8'));
        }
    } else if(err.code == 'ENOENT') {
        console.log('No package.xml found');
    } else {
        console.log('Some other error: ', err.code);
    }
});

var branch = 'master';
console.info('Branch Name:', branch);

const isProduction = branch === 'master';

if (isProduction) {
    // options.checkOnly = true;
    console.info(`On '${branch}' branch represents production. Leaving loginUrl as-is.`);
} else {
    console.info(`On '${branch}' branch, updating loginUrl for Sandbox.`);
    options.loginUrl = 'https://test.salesforce.com'; 
}


// options.username = process.env[branch.toUpperCase() + '_USERNAME'] || process.env[branch + '_USERNAME'];
// options.password = process.env[branch.toUpperCase() + '_PASSWD'] || process.env[branch + '_PASSWD'];
options.username = 'baohieu08@gmail.com';
options.password = 'hjn3ZWR-xbm-ctz-zrq';

console.info('Username: ', options.username);
console.info('Password: ', options.password);
console.info('LoginUrl: ', options.loginUrl);

// hasDestructivePhase()
// .then((destroyFile) => {
//     var deployWithTest = isProduction 
//         || branch === 'develop' 
//         || branch === 'hotfix_sandbox'
//         || !destroyFile;
    
//     if (deployWithTest) {
//         console.info(`On '${branch}' branch. Apex tests will be executed.`);
//     } else {
//         console.info(`On '${branch}' branch. ALL Apex tests are skipped now and executed in destroy phase.`);
//         options.testLevel = 'NoTestRun';
//     }

//     return Promise.resolve(true);
// })
// .then(() => {
//     console.info('Start to deploy...');
//     return tools.deployFromDirectory('./force-app', options);
// })
// .then((deployResult) => {
//     tools.reportDeployResult(deployResult, logger, options.verbose);
//     logger.flush();
    
//     console.log('Deployment Id: ' + deployResult.id);
    
//     if (!deployResult.success || deployResult.numberTestErrors > 0 || deployResult.numberComponentErrors > 0) {
//         console.error('Deploy was NOT Successful');
//         return Promise.reject('Deploy was NOT Successful');
//     } else {
//         console.log('Deploy was Successful');
//         Promise.resolve(true);
//     }
// })
// .then(() => {
//     return Promise.resolve(true);
// })
// .catch(function (err) {
//     console.error(err.message);
//     process.exit(1);
// });
console.info('Start to deploy...');
tools.deployFromDirectory('./force-app', options);
