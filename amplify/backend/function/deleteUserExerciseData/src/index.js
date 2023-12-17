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

    print(event);

    const tableName = process.env.API_TRACKERAPP_EXERCISETABLE_NAME;

    const ownerField = 'owner'; // owner is default value but if you specified ownerField on auth rule, that must be specified here
    const identityClaim = 'username'; // username is default value but if you specified identityField on auth rule, that must be specified here
    const condition = {}
    condition[ownerField] = {
        ComparisonOperator: 'EQ'
    }

    condition[ownerField]['AttributeValueList'] = [event.identity.claims[identityClaim]];

    await new Promise(async (res) => {
        let LastEvaluatedKey;

        do {
            let scanInput = {
                TableName: tableName,
                ScanFilter: condition,
                AttributesToGet: ['id', ownerField],
                ExclusiveStartKey: LastEvaluatedKey
            }

            let items = [];

            try {
                const command = new ScanCommand(scanInput);
                const result = await dynamoDBClient.send(command);
                LastEvaluatedKey = result.LastEvaluatedKey;
                items = result.Items;
            } catch (err) {
                console.log({error: 'Could not load items: ' + err});
                items = [];
            }

            if (items.length > 0) {
                console.log(`records to be deleted: ${items.length}`);
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

        } while (LastEvaluatedKey)

        res();
    });

    return true; // this means the user data was cleaned up
};