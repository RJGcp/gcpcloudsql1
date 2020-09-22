const { google } = require('googleapis')

const { auth } = require('google-auth-library')

let sqlAdmin = google.sqladmin('v1beta4')
exports.backup = async (event, context) => {

        const pubsubMessage = JSON.parse(Buffer.from(event.data, 'base64').toString())
        const authRes = await auth.getApplicationDefault()

        let authClient = authRes.credential;

        console.log("Project = " + pubsubMessage['project']);

        console.log("Project1 = " + pubsubMessage['project1']);

        console.log("DB instance = " + pubsubMessage['database']);

        console.log("DB instance1 = " + pubsubMessage['database1']);

        console.log("backupRetention = " + pubsubMessage['backupRetention']);
       
        console.log("stagBackupRetention = " + pubsubMessage['stagBackupRetention']);


        let project = pubsubMessage['project']

        let project1 = pubsubMessage['project1']

        let instance = pubsubMessage['database']

        let instance1 = pubsubMessage['database1']
        
        let backupRetention = pubsubMessage['backupRetention']

        let stagBackupRetention = pubsubMessage['stagBackupRetention']
/*
        exports.prdBkp = (req, res) => {
        // Sends '30' as response
        res.send(process.env.backupRetention);
        };

        exports.stagBkp = (req, res) => {
        // Sends '2' as response
        res.send(process.env.stagBackupRetention);
        };
        
        exports.project1 = (req, res) => {
        // Sends 'rjbakup1' as response
        res.send(process.env.PROJECT_ID);
        };
        exports.project2 = (req, res) => {
        // Sends 'omega-ether-256603' as response
        res.send(process.env.PROJECT_ID_1);
        };
        
 */

        let request = {

                project: project,

                project1: project1,

                instance: instance,

                instance1: instance1,

                stagBackupRetention: stagBackupRetention,

                backupRetention: backupRetention,

                auth: authClient

        };

     if ( request.project = "omega-ether-256603") {
         
        sqlAdmin.backupRuns.list(request, function(err, response) {
                if (err) {
                        console.error("Error at list:" + err);
                return;
                }   
                let referenceDate = new Date();

                referenceDate.setDate(referenceDate.getDate() - request.backupRetention);
                let toBeDeleted = response.data.items.filter(function (el) {

                        console.log("Item found: " + el.id + " with date " + el.endTime)

                        return el.type === "ON_DEMAND" && new Date(el.endTime) < new Date(referenceDate)
                });
                toBeDeleted.forEach(element => {
                        console.log("To be deleted: " + element);
                        request.id = element.id
                        sqlAdmin.backupRuns.delete(request, function(err, response) {
                                if (err) {
                                        console.error("Error at delete:" + err);
                                return;
                                }
                                console.log("Delete response: " + JSON.stringify(response, null, 2));
                        });
                });
        });
     
        sqlAdmin.backupRuns.insert(request, function(err, response) {

                if (err) {

                        console.error("Error at insert: " + err);

                return;

                }

                console.log("Trigger manual backup response: " + JSON.stringify(response.data, null, 2));

        });
        
} 
// const sleep = (waitTimeInMs) => new Promise(resolve => setTimeout(resolve, waitTimeInMs));
// sleep(10000).then(() => {
if (request.project1 = "rjbackup1") {
        
        sqlAdmin.backupRuns.list(request, function(err, response) {

 

                if (err) {

                        console.error("Error at list:" + err);

                return;

                }   

                let referenceDate = new Date();

                referenceDate.setDate(referenceDate.getDate() - request.stagBackupRetention );
                let toBeDeleted = response.data.items.filter(function (el) {

                        console.log("Item found: " + el.id + " with date " + el.endTime)

                        return el.type === "ON_DEMAND" && new Date(el.endTime) < new Date(referenceDate)
                });
                toBeDeleted.forEach(element => {
                        console.log("To be deleted: " + element);
                        request.id = element.id
                        sqlAdmin.backupRuns.delete(request, function(err, response) {
                                if (err) {
                                        console.error("Error at delete:" + err);
                                return;
                                }
                                console.log("Delete response: " + JSON.stringify(response, null, 2));
                        });
                });
        });
     
        sqlAdmin.backupRuns.insert(request, function(err, response) {

                if (err) {
                        console.error("Error at insert: " + err);
                return;
                }

                console.log("Trigger manual backup response: " + JSON.stringify(response.data, null, 2));

        });
    
}

    else {
        console.log("Please verify the project name and try again !!!")
        }
//    });
}
