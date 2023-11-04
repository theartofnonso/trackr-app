/* Amplify Params - DO NOT EDIT
	API_TRACKERAPP_GRAPHQLAPIIDOUTPUT
	API_TRACKERAPP_USERTABLE_ARN
	API_TRACKERAPP_USERTABLE_NAME
	ENV
	REGION
Amplify Params - DO NOT EDIT */

const {DynamoDBClient, PutItemCommand} = require("@aws-sdk/client-dynamodb");
const dynamoDBClient = new DynamoDBClient({region: "eu-west-2"});

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {

    if (event.request.userAttributes.sub) {

        let input = {
            Item: {
                'id': {S: event.request.userAttributes.sub},
                'email': {S: event.request.userAttributes.email},
                '__typename': {S: 'User'},
            },
            TableName: process.env.API_TRACKERAPP_USERTABLE_NAME
        };

        const command = new PutItemCommand(input);
        await dynamoDBClient.send(command);
    }

    return event;
};
