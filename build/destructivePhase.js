var fs = require('fs');
var path = require('path');
var xml2js = require('xml2js');
var isEmpty = require('lodash.isempty');

function hasDestructivePhase () {
    var theFile = './build/destroy/destructiveChanges.xml';
    return new Promise((resolve, reject) => {
        if(fs.existsSync(theFile)){
            var origin = path.resolve(theFile);
            if (fs.statSync(origin).isFile()){
                console.log('Parsing content of ' + theFile);
                var parser = new xml2js.Parser();
                var fileContent = fs.readFileSync(origin, 'utf8');                        
                parser.parseString(fileContent, (error, data) => {
                    if (error) { 
                        console.log(error);
                        reject('Failed to parse ' + theFile + ' with error.');
                    } else if (data && data.Package && !isEmpty(data.Package.types)) {
                        console.log('Found ' + data.Package.types.length + ' types to destroy.');                            
                        resolve(data);
                    } else {
                        console.log('No destructive entries found.');
                        resolve(null);
                    }
                });  
            } else {
                reject(theFile + ' is not a file');
            }     
        } else {
            reject(theFile + 'does not exist');
        }
    });
    
};

module.exports = hasDestructivePhase;