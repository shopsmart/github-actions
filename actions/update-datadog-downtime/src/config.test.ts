import * as core from '@actions/core'
import { Config } from './config'

let githubInputs: any = {}

describe('config tests', () => {

  beforeAll(() => {
    // Mock @actions/core getInput()
    jest.spyOn(core, 'getInput').mockImplementation((name: string) => {
      return githubInputs[name]
    })
  })

  beforeEach(() => {
    // Required fields
    githubInputs = {
      'datadog-api-key': 'mock-api-key',
      'datadog-app-key': 'mock-app-key',
      // Since we test the time module independently, we will ignore its functionality be passing in an
      //  already-formatted ISO-8601 date
      'end': '2024-09-09T22:09:27.992Z',
      'scope': 'application:www,environment:staging',
    }
  })

  it('should pull all inputs from core', () => {
    githubInputs = {
      ...githubInputs,
      'start': '2024-09-09T22:09:27.993Z',
      'message': 'Test message',
      // Normally, both monitor id and tags should not be provided; however, we are simply testing
      // that the inputs make it to the proper places and this will not be sent off to datadog.
      'monitor-id': 'id-123456789',
      'monitor-tags': 'one:two,three:four'
    }

    const config = new Config()

    expect(config.apiKey).toEqual("mock-api-key")
    expect(config.appKey).toEqual("mock-app-key")
    expect(config.end).toEqual('2024-09-09T22:09:27.992Z')
    expect(config.start).toEqual('2024-09-09T22:09:27.993Z')
    expect(config.message).toEqual('Test message')
    expect(config.monitorId).toEqual('id-123456789')
    expect(config.monitorTags).toEqual(['one:two', 'three:four'])
  })

  it('should use the monitor id if provided', () => {
    githubInputs = {
      ...githubInputs,
      'monitor-id': 'id-123456789',
      'monitor-tags': 'one:two,three:four'
    }

    const config = new Config()

    expect(config.monitorIdentifier).toEqual({monitor_id: 'id-123456789'})
  })

  it('should use the monitor tags if monitor id is not provided', () => {
    githubInputs = {
      ...githubInputs,
      'monitor-tags': 'one:two,three:four'
    }

    const config = new Config()

    expect(config.monitorIdentifier).toEqual({monitor_tags: ['one:two', 'three:four']})
  })

  const minimalPayload = {
    type: 'downtime',
    data: {
      attributes: {
        monitor_identifier: {
          monitor_tags: []
        },
        schedule: {
          end: '2024-09-09T22:09:27.992Z',
        },
        scope: 'application:www,environment:staging',
        status: 'active'
      }
    }
  }

  it('should output a proper payload', () => {
    const config = new Config()

    expect(config.payload).toEqual(minimalPayload)
  })

  it('should output a proper payload as json', () => {
    const config = new Config()

    expect(config.json).toEqual(JSON.stringify(minimalPayload))
  })
})
