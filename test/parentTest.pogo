expect = require 'chai'.expect
v = require '../'

describe 'vdollar().createIterator().parent'

  it 'provides access to the iterator ancestry'

    set = v [1,2].filter(@{ false }).eq(1).skip(2).first()
    greatGreat = set.createIterator().parent.parent.parent.parent
    expect(greatGreat.toString()).to.equal "V$([1, 2])"
