# vdollar

A list traversal utility.

```JavaScript
var vdollar = require('vdollar');
```

Traverse lists:

```JavaScript
vdollar([1, 2, 3, 4]).skip(1).take(2).get(1); // -> 3
```

Add your own traversal operations:

```JavaScript
var numbers = vdollar.extend({
  odds: function() {
    return this.filter(function(n) {
      return n % 2 == 1;
    });
  }
});

numbers([1, 2, 3, 4, 5]).skip(1).odds().take(2).get(1); // -> 5
```
