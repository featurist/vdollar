V(createIterator) =
  this.createIterator = createIterator
  this

V.prototype.eq (index) =
  self.slice (index, 1, @(p) @{ "#(p).eq(#(index))" })

V.prototype.filter (predicate, toString) =
  self.mutate (createFilterIterator(self, predicate, toString || @(p) @{ "#(p).filter(<fn>)" }))

V.prototype.first () =
  self.slice (0, 1, @(p) @{ "#(p).first()" })

V.prototype.get (n) =
  if (n :: Number)
    self.eq(n).createIterator().next()
  else
    iter = self.createIterator()
    result = []
    while (iter.hasNext())
      result.push(iter.next())

    result

V.prototype.last (n) =
  self.mutate (createLastIterator(self, n))

V.prototype.mutate (createIterator) =
  @new (V (createIterator))

V.prototype.skip (count) =
  self.slice (count, undefined, @(p) @{ "#(p).skip(#(count))" })

V.prototype.slice (start, count, toString) =
  self.mutate (createSliceIterator(self, start, count, toString || @(p) @{
    if (count > 0)
      "#(p).slice(#(start), #(count))"
    else
      "#(p).slice(#(start))"
  }))

V.prototype.take (count) =
  self.slice (0, count, @(p) @{ "#(p).take(#(count))" })

V.prototype.toString () =
  self.createIterator().toString()

createArrayIterator (array) =
  @ ()
    index = 0
    {
      op = 'array'

      next () =
        if (self.hasNext())
          item = array.(index)
          index := index + 1
          item
        else
          nil

      hasNext () =
        index < array.length

      toString () =
        args = array.map @(element) @{ JSON.stringify(element) }
        "V$([#(args.join(', '))])"
    }

createSliceIterator (prev, start, count, toString) =
  @ ()
    iter = prev.createIterator()
    index = 0
    {
      op = 'slice'

      parent = iter

      next () =
        if (self.hasNext())
          n = iter.next()
          index := index + 1
          n
        else
          nil

      hasNext () =
        while (index < start)
          iter.next()
          index := index + 1

        iter.hasNext() && (
          if (count == undefined)
            index >= start
          else
            index < (start + count)
        )

      toString () =
        toString(prev.toString())
    }

createLastIterator (prev, n) =
  @ ()
    array = prev.get()
    last = array.slice(array.length - (n || 1))
    iter = (createArrayIterator (last))()
    {
      op = 'last'

      parent = prev.createIterator()

      next () =
        iter.next ()

      hasNext () =
        iter.hasNext ()

      toString () = "#(prev.createIterator().toString()).last(#(n || ''))"
    }

createFilterIterator (prev, predicate, toString) =
  @ ()
    iter = prev.createIterator()

    next = nil

    step () =
      if (next == nil)
        next := nil
        while (iter.hasNext())
          c = iter.next()
          if (predicate(c))
            next := c
            return

    {
      op = 'filter'

      parent = iter

      next () =
        step ()
        c = next
        next := nil
        c

      hasNext () =
        step ()
        next != nil

      toString () =
        toString(iter.toString())
    }

createDollar (V) =
  dollar (x) =
    if (x :: Array)
      @new (V (createArrayIterator(x)))
    else if (x :: Function)
      @new (V (@ { (createArrayIterator(x()))() }))
    else
      throw (@new Error "Expected array or function (got #(x))")

vdollar = createDollar (V)

vdollar.extend (extensions) =
  E (createIterator) = V.call(this, createIterator)
  E.prototype = @new (V)
  E.prototype.mutate (createIterator) =
    @new (E (createIterator))

  for each @(extension) in (Object.keys(extensions))
    E.prototype.(extension) = extensions.(extension)

  E.prototype.constructor = V
  createDollar (E)

module.exports = vdollar
