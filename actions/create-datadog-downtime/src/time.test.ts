import moment from 'moment'
import { parseTime } from './time'

describe('time tests', () => {
  const now = new Date()

  it('should return null if the input is undefined', () => {
    let t = parseTime(now, undefined)

    expect(t).toBeNull
  })

  it('should ignore non-custom formated datetimes', () => {
    const provided = '2024-09-09T22:09:27.992Z'

    let t = parseTime(now, provided)

    expect(t).toEqual(provided)
  })

  it('should add hours to now', () => {
    const expected = moment(now).add(4, 'hours').toDate().toISOString()

    let t = parseTime(now, '4h')

    expect(t).toEqual(expected)
  })

  it('should add minutes to now', () => {
    const expected = moment(now).add(4, 'minutes').toDate().toISOString()

    let t = parseTime(now, '4m')

    expect(t).toEqual(expected)
  })

  it('should add seconds to now', () => {
    const expected = moment(now).add(4, 'seconds').toDate().toISOString()

    let t = parseTime(now, '4s')

    expect(t).toEqual(expected)
  })

  it('should add hours and minutes to now', () => {
    const expected = moment(now).add(4, 'hours').add(6, 'minutes').toDate().toISOString()

    let t = parseTime(now, '4h 6m')

    expect(t).toEqual(expected)
  })

  it('should add hours and seconds to now', () => {
    const expected = moment(now).add(4, 'hours').add(6, 'seconds').toDate().toISOString()

    let t = parseTime(now, '4h 6s')

    expect(t).toEqual(expected)
  })

  it('should add minutes and seconds to now', () => {
    const expected = moment(now).add(4, 'minutes').add(6, 'seconds').toDate().toISOString()

    let t = parseTime(now, '4m 6s')

    expect(t).toEqual(expected)
  })

  it('should add hours, minutes, and seconds to now', () => {
    const expected = moment(now).add(2, 'hours').add(4, 'minutes').add(6, 'seconds').toDate().toISOString()

    let t = parseTime(now, '2h 4m 6s')

    expect(t).toEqual(expected)
  })

  it('should return what was provided if the format does not match our custom time format', () => {
    const expected = 'unknown format'

    let t = parseTime(now, expected)

    expect(t).toEqual(expected)
  })
})
