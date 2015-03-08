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
  'V$([1, 2, 3]).last(2)'
  'V$([]).skip(66)'
  'V$([]).slice(1, 2)'
  'V$([]).take(1)'
  'V$([1]).slice(1)'
  'V$([1]).slice(1).slice(2, 3).skip(7)'
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

describe '.last().toString()'
  it 'does not iterate'
    throws () = throw (new (Error ".last().toString() iterated!"))
    set = V$ ([1, 2]).filter(throws).last()
    expect(set.toString()).to.equal "V$([1, 2]).filter(<fn>).last()"

describe '.slice(0, 1).toString()'
  it 'does not iterate'
    throws () = throw (new (Error ".slice(0, 1).toString() iterated!"))
    set = V$ ([1, 2]).filter(throws).slice(0, 1)
    expect(set.toString()).to.equal "V$([1, 2]).filter(<fn>).slice(0, 1)"
