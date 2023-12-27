/* Amplify Params - DO NOT EDIT
	
Amplify Params - DO NOT EDIT */

const {DynamoDBClient, ScanCommand, BatchWriteItemCommand} = require("@aws-sdk/client-dynamodb");
const dynamoDBClient = new DynamoDBClient({region: "eu-west-2"});

exports.handler = async (event) => {

    const tableName = process.env.API_TRACKERAPP_ROUTINETABLE_NAME;

    let scanInput = {
        TableName: tableName,
        FilterExpression: 'userID = :value',
        ExpressionAttributeValues: {
            ":value": {"S": event.identity.claims.username},
        }
    }

    try {
        const command = new ScanCommand(scanInput);
        const result = await dynamoDBClient.send(command);
        const items = result.Items;
        if (items.length > 0) {
            console.log(`Routines to be deleted: ${items.length}`);
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
        return true;
    } catch (err) {
        console.log(err);
    }
    return false; // this means the user data was cleaned up
};