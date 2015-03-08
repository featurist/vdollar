expect = require 'chai'.expect
v = require '../'

describe 'vdollar(string)'

  it 'throws a useful error'
    call () = v "zomg"
    expect(call).to.throw 'Expected array or function (got zomg)'

describe 'vdollar(fn<!array>).toString()'

  it 'throws a useful error'
    fn () = "a string"
    call () = v (fn).toString()
    expect(call).to.throw 'Expected to iterate an array, got a string'
