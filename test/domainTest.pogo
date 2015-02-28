expect = require 'chai'.expect
v = require '../'

describe 'vdollar.extend()'

  it 'allows domain-specific operations'

    numbers = v.extend {
      evens () = self.filter @(item)
        item % 2 == 0
    }
    nums = numbers([1, 2, 3, 4, 6]).slice(0, 10).evens().slice(0, 2)
    expect(nums.get()).to.eql [2, 4]
