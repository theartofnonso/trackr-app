/* Amplify Params - DO NOT EDIT
	API_TRACKERAPP_GRAPHQLAPIENDPOINTOUTPUT
	API_TRACKERAPP_GRAPHQLAPIIDOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

import crypto from '@aws-crypto/sha256-js';
import {defaultProvider} from '@aws-sdk/credential-provider-node';
import {SignatureV4} from '@aws-sdk/signature-v4';
import {HttpRequest} from '@aws-sdk/protocol-http';
import {default as fetch, Request} from 'node-fetch';

const GRAPHQL_ENDPOINT = process.env.API_TRACKERAPP_GRAPHQLAPIENDPOINTOUTPUT;
const AWS_REGION = process.env.AWS_REGION || 'eu-west-2';
const {Sha256} = crypto;

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

export const handler = async (event) => {

    const endpoint = new URL(GRAPHQL_ENDPOINT);

    const startDate = event.queryStringParameters["start"];
    const endDate = event.queryStringParameters["end"];

    const query = `query LIST_ROUTINELOGS {
    listRoutineLogs(filter: {createdAt: {le: "${endDate}", ge: "${startDate}"}}) {
      items {
        id
        owner
        data
        createdAt
        updatedAt
      }
    }
  }
`;

    const signer = new SignatureV4({
        credentials: defaultProvider(),
        region: AWS_REGION,
        service: 'appsync',
        sha256: Sha256
    });

    const requestToBeSigned = new HttpRequest({
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            host: endpoint.host
        },
        hostname: endpoint.host,
        body: JSON.stringify({query}),
        path: endpoint.pathname
    });

    const signed = await signer.sign(requestToBeSigned);
    const request = new Request(endpoint, signed);

    let statusCode = 200;
    let body;
    let response;

    try {
        response = await fetch(request);
        body = await response.json();
        if (body.errors) statusCode = 400;
    } catch (error) {
        statusCode = 500;
        body = {
            errors: [
                {
                    message: error.message
                }
            ]
        };
    }

    return {
        statusCode,
        //  Uncomment below to enable CORS requests
        // headers: {
        //   "Access-Control-Allow-Origin": "*",
        //   "Access-Control-Allow-Headers": "*"
        // },
        body: JSON.stringify(body)
    };
};