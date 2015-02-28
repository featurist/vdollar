expect = require 'chai'.expect
v = require '../'

describe 'vdollar(array)'

  it 'yields elements from the array'
    (v [1, 2, 3]) yields [1, 2, 3]
    (v [1]) yields [1]
    (v []) yields []

describe 'vdollar(fn<array>)'

  it 'yields elements from the array'
    (v @{ [1, 2, 3] }) yields [1, 2, 3]
    (v @{ [1] }) yields [1]
    (v @{ [] }) yields []

describe 'eq(0)'

  it 'yields the first element'
    (v [1, 2].eq(0)) yields [1]
    (v [1].eq(0)) yields [1]

describe 'eq(1)'

  it 'yields the second element'
    (v [1, 2, 3].eq(1)) yields [2]
    (v [1, 2].eq(1)) yields [2]

describe 'eq(0).eq(0)'

  it 'yields the first element'
    (v [1, 2].eq(0).eq(0)) yields [1]
    (v [1].eq(0).eq(0)) yields [1]

describe 'eq(-1)'

  it 'yields nothing'
    (v [1, 2, 3].eq(-1)) yields []
    (v [].eq(-1)) yields []

describe 'eq(> max)'

  it 'yields nothing'
    (v [1, 2].eq(2)) yields []
    (v [].eq(0)) yields []

describe 'filter(predicate)'

  it 'yields elements that match the predicate'
    predicate (x) = x > 1
    (v [1, 2, 2].filter(predicate)) yields [2, 2]
    (v [2].filter(predicate)) yields [2]
    (v [].filter(predicate)) yields []

describe 'first()'

  it 'yields one element'
    (v [1, 2].first()) yields [1]
    (v [1].first()) yields [1]
    (v [].first()) yields []

describe 'get()'

  it 'yields the whole list'
    array = v [1, 2, 3].get()
    expect (array).to.eql([1, 2, 3])

describe 'get(1)'

  it 'yields the whole list'
    array = v [1, 2, 3].get(1)
    expect (array).to.eql(2)

describe 'last()'

  it 'yields the last element'
    (v [1, 2, 3].last()) yields [3]
    (v [].last()) yields []

describe 'last(2)'

  it 'yields the last 2 elements'
    (v [1, 2, 3].last(2)) yields [2, 3]
    (v [].last()) yields []

describe 'slice(0, 2)'

  it 'yields the first two elements'
    (v [1, 2, 3].slice(0, 2)) yields [1, 2]
    (v [1, 2].slice(0, 2)) yields [1, 2]
    (v [1].slice(0, 2)) yields [1]

describe 'slice(0, 2).slice(0,  2)'

  it 'yields the first two elements'
    (v [1, 2, 3].slice(0, 2).slice(0, 2)) yields [1, 2]
    (v [1].slice(0, 2).slice(0, 2)) yields [1]

describe 'slice(0, > max)'

  it 'yields all the elements'
    (v [1, 2, 3].slice(0, 10)) yields [1, 2, 3]
    (v [].slice(0, 10)) yields []

describe 'slice(-1, > max)'

  it 'yields all the elements'
    (v [1, 2, 3].slice(-1, 10)) yields [1, 2, 3]
    (v [].slice(-1, 10)) yields []

describe 'skip(1)'

  it 'yields the last two elements'
    (v [1, 2, 3].skip(1)) yields [2, 3]
    (v [1, 2].skip(1)) yields [2]


describe 'take(2)'

  it 'yields two elements'
    (v [1, 2, 3].take(2)) yields [1, 2]
    (v [1].take(2)) yields [1]



(v) yields (expected) =
  iter = v.createIterator ()

  for (i = 0, i < expected.length, i := i + 1)
    expect(iter.hasNext()).to.equal(
      true
      "Expected .hasNext() to return true at index #(i)"
    )
    expect(iter.next()).to.equal(
      expected.(i)
      "Expected .next() to return #(expected.(i)) at index #(i)"
    )

  expect(iter.hasNext()).to.equal(
    false
    "Expected .hasNext() to return false at index #(expected.length)"
  )
  expect(iter.next()).to.equal(
    nil
    "Expected .next() to return nil at index #(expected.length)"
  )
