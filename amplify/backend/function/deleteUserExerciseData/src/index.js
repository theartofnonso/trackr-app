/* Amplify Params - DO NOT EDIT
	API_TRACKERAPP_EXERCISETABLE_ARN
	API_TRACKERAPP_EXERCISETABLE_NAME
	API_TRACKERAPP_GRAPHQLAPIIDOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

const {DynamoDBClient, ScanCommand, BatchWriteItemCommand} = require("@aws-sdk/client-dynamodb");
const dynamoDBClient = new DynamoDBClient({region: "eu-west-2"});

exports.handler = async (event) => {

    const tableName = process.env.API_TRACKERAPP_EXERCISETABLE_NAME;

    let scanInput = {
        TableName: tableName,
        FilterExpression: 'userId = :value',
        ExpressionAttributeValues: {
            ":value": {"S": event.identity.claims.username},
        }
    }

    try {
        const command = new ScanCommand(scanInput);
        const result = await dynamoDBClient.send(command);
        const items = result.Items;
        if (items.length > 0) {
            console.log(`Exercises to be deleted: ${items.length}`);
            let batchWriteInput = {
                RequestItems: {
                    [tableName]: items.map(item => {
                        return {
                            DeleteRequest: {
                                Key: {id: item.id}
                            }
                        }
                    })
                }
            }
            const command = new BatchWriteItemCommand(batchWriteInput);
            await dynamoDBClient.send(command);
        }
    } catch (err) {
        console.log(err);
        return false;
    }
    return true; // this means the user data was cleaned up
};