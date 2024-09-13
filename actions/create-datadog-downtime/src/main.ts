/**
 * An action to update a Datadog downtime.
 */

import * as core from '@actions/core'
import * as httpm from '@actions/http-client'
import { Config } from './config'

const DowntimeURL = "https://api.datadoghq.com/api/v2/downtime"
const Headers = {
  ApiKey: "DD-API-KEY",
  AppKey: "DD-APPLICATION-KEY",
}

/**
 * The main runtime
 */
async function run() {
  const config = new Config()

  core.debug(`Payload to be sent to datadog: ${config.json}`)

  const req = new httpm.HttpClient()
  req.requestOptions = {
    headers: {
      [httpm.Headers.ContentType]: httpm.MediaTypes.ApplicationJson,
      [httpm.Headers.Accept]: httpm.MediaTypes.ApplicationJson,
      [Headers.ApiKey]: config.apiKey,
      [Headers.AppKey]: config.appKey,
    }
  }

  const resp = await req.post(DowntimeURL, config.json())

  const statusCode = resp.message.statusCode
  const body = await resp.readBody()

  core.setOutput("status-code", statusCode)
  core.setOutput("body", body)

  if (resp.message.statusCode != httpm.HttpCodes.OK) {
    core.setFailed(`The request to the Datadog Downtime API failed with status code: ${statusCode}\nErrors: ${body}`)
  }
}

run()
