const randomBytes = require('crypto').randomBytes;

const AWS = require('aws-sdk');
AWS.config.update({ region: "us-west-2" });

const SSM = new AWS.SSM();
const ddb = new AWS.DynamoDB.DocumentClient();

exports.handler = (event, context, callback) => {
    //if (!event.requestContext.authorizer) {
    //  errorResponse('Authorization not configured', context.awsRequestId, callback);
    //  return;
    //}

    const rideId = toUrlString(randomBytes(16));
    console.log('Received event (', rideId, '): ', event);

    // Because we're using a Cognito User Pools authorizer, all of the claims
    // included in the authentication token are provided in the request context.
    // This includes the username as well as other attributes.
    //const username = event.requestContext.authorizer.claims['cognito:username'];

    // The body field of the event in a proxy integration is a raw string.
    // In order to extract meaningful values, we need to first parse this string
    // into an object. A more robust implementation might inspect the Content-Type
    // header first and use a different parsing strategy based on that value.
    const requestBody = JSON.parse(event.body);

    const runcommand = requestBody.Command;
    const instanceid = requestBody.MasterInstanceId;

    const result = findMasterToRun(runcommand,instanceid);

    recordtodb(rideId, runcommand).then(() => {
        // You can use the callback function to provide a return value from your Node.js
        // Lambda functions. The first parameter is used for failed invocations. The
        // second parameter specifies the result data of the invocation.

        // Because this Lambda function is called by an API Gateway proxy integration
        // the result object must use the following structure.
        callback(null, {
            statusCode: 201,
            body: JSON.stringify({
                RideId: rideId,
                Status: result,
                SparkCommand: runcommand,
            }),
            headers: {
                'Access-Control-Allow-Origin': '*',
            },
        });
    }).catch((err) => {
        console.error(err);

        // If there is an error during processing, catch it and return
        // from the Lambda function successfully. Specify a 500 HTTP status
        // code and provide an error message in the body. This will provide a
        // more meaningful error response to the end client.
        errorResponse(err.message, context.awsRequestId, callback)
    });
};

function findMasterToRun(command,instanceIdList) {
    console.log('Runing Spark command ', command, ' on Master ', instanceIdList);
    return new Promise(function(resolve, reject) {
      //const command = 'ls -al';
      const params = {
        InstanceIds: [instanceIdList],
        DocumentName: 'AWS-RunShellScript',
        Parameters: {
          commands: [command],
        },
      };
      SSM.sendCommand(params, function(err, data) {
        if (err) {
          console.log(err);
          reject(err);
        }
        resolve(data);
      });
    });
  }

function recordtodb(rideId, command) {
    return ddb.put({
        TableName: 'CausalityCommand',
        Item: {
            RideId: rideId,
            SparkCommand: command,
            RequestTime: new Date().toISOString(),
        },
    }).promise();
}

function toUrlString(buffer) {
    return buffer.toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

function errorResponse(errorMessage, awsRequestId, callback) {
  callback(null, {
    statusCode: 500,
    body: JSON.stringify({
      Error: errorMessage,
      Reference: awsRequestId,
    }),
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  });
}
