/**
 * Example lambda function
 */

// Replace this
const VERSION = 'dev'

export async function handler() {
  response = {version: VERSION}
  headers = {"Content-Type": "application/json"}

  return {
    statusCode: 200,
    body: JSON.stringify(response),
    headers: headers,
  }
}
