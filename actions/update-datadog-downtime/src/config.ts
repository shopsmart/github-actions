import * as core from '@actions/core'
import moment from 'moment'
import { parseTime } from './time'

export class Config {
  private _moment: moment.Moment

  apiKey: string
  appKey: string
  message: string | null
  monitorId: string | null
  monitorTags: Array<string>
  start: string | undefined
  end: string

  constructor() {
    this._moment = moment()

    this.apiKey = core.getInput('datadog-api-key')
    this.appKey = core.getInput('datadog-app-key')
    this.message = core.getInput('message')
    this.monitorId = core.getInput('monitor-id')
    this.monitorTags = core.getInput('monitor-tags')?.split(',') || []
    this.start = parseTime(this._moment, core.getInput('start'))
    this.end = parseTime(this._moment, core.getInput('end'))!
  }

  get monitorIdentifier(): any {
    if (this.monitorId) {
      return {monitor_id: this.monitorId}
    }
    return {monitor_tags: this.monitorTags}
  }

  get payload(): any {
    return {
      type: 'downtime',
      data: {
        attributes: {
          message: this.message,
          monitor_identifier: this.monitorIdentifier,
          schedule: {
            end: this.end,
            start: this.start,
          },
          status: 'active',
        },
      },
    }
  }

  get json(): string {
    return JSON.stringify(this.payload)
  }
}
