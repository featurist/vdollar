expect = require 'chai'.expect
V$ = require '../'

expressions = [
  'V$([])'
  'V$([1])'
  'V$([3, 2, 1])'
  'V$([]).eq(0)'
  'V$([]).first()'
  'V$([]).last()'
  'V$([]).last(2)'
  'V$([]).skip(66)'
  'V$([]).slice(1, 2)'
  'V$([]).take(1)'
]

expressions.forEach @(expression)
  describe (expression + '.toString()')
    it "returns #(expression)"
      set = eval(expression)
      expect(set.toString()).to.equal(expression)

describe '.filter(fn).toString()'
  it 'returns .filter(<fn>)'
    set = V$ [1,2].filter(@{ false })
    expect(set.toString()).to.equal "V$([1, 2]).filter(<fn>)"

describe '.filter(fn, name).toString()'
  it 'returns .name'
    set = V$ [1,2].filter(@{ false }, @(p) @{ "#(p).blah!" })
    expect(set.toString()).to.equal "V$([1, 2]).blah!"
