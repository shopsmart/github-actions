import * as core from '@actions/core'
import moment from 'moment'

// We accept a custom format to add time from now, such as: 4h 5m 30s
const CustomTimeRegex = /^([0-9]+\ *h\ *)?([0-9]+\ *m\ *)?([0-9]+\ *s\ *)?$/

/**
 * Parses out our custom format or sends back what was provided
 *
 * @param now The time to add to.  This is passed in as a parameter for testing and also to make sure that both start and end times are taken from the same time.
 * @param provided The provided time string.  If not in the custom format, it should be an ISO-8601 format, but this function will not check.
 * @returns The datetime in ISO-8601 format.  If the provided datetime does not match the custom format, it will return what was provided
 */
export function parseTime(now: moment.Moment, provided: string|undefined): string|undefined {
  // If provided is undefined, we get an error attempting to match
  if (!provided) {
    return undefined
  }

  const matches = provided.match(CustomTimeRegex)
  // 0 = the whole match (since everything is optional)
  // 1 = hours
  // 2 = minutes
  // 3 = seconds
  if (provided == '' || matches == null || matches[0] == '') {
    core.debug('Time provided does not match custom format')
    return provided
  }

  core.debug(`Adding ${matches[1]} hours ${matches[2]} minutes ${matches[3]} seconds to ${now.toDate().toISOString()}`)

  // If any of the matches are undefined, moment adds nothing
  return now
    .add(matches[1], 'hours')
    .add(matches[2], 'minutes')
    .add(matches[3], 'seconds')
    .toDate()
    .toISOString()
}
