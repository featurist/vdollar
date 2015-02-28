V(createIterator) =
  this.createIterator = createIterator
  this

V.prototype.eq (index) =
  self.slice (index, 1, ".eq(#(index))")

V.prototype.filter (predicate) =
  self.mutate (createFilterIterator(self, predicate))

V.prototype.first () =
  self.slice (0, 1, ".first()")

V.prototype.get (n) =
  if (n :: Number)
    self.eq(n).createIterator().next()
  else
    iter = self.createIterator()
    result = []
    while (iter.hasNext())
      result.push(iter.next())

    result

V.prototype.last () =
  self.mutate (createLastIterator(self))

V.prototype.mutate (createIterator) =
  @new (V (createIterator))

V.prototype.skip (count) =
  self.slice (count, undefined, ".skip(#(count))")

V.prototype.slice (start, count, name) =
  self.mutate (createSliceIterator(self, start, count, name || ".slice(#(start), #(count))"))

V.prototype.take (count) =
  self.slice (0, count, ".take(#(count))")

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

createSliceIterator (prev, start, count, name) =
  @ ()
    iter = prev.createIterator()
    index = 0
    {
      op = 'slice'

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
        "#(prev.toString())" + name
    }

createLastIterator (prev) =
  @ ()
    iter = prev.createIterator()
    index = 0
    {
      op = 'last'

      next () =
        last = nil
        while (iter.hasNext ())
          last := iter.next ()
          index := index + 1

        last

      hasNext () =
        iter.hasNext ()

      toString () = "#(iter.toString()).last()"
    }

createFilterIterator (prev, filter, name) =
  @ ()
    iter = prev.createIterator()

    next = nil

    step () =
      if (next == nil)
        next := nil
        while (iter.hasNext())
          c = iter.next()
          if (filter(c))
            next := c
            return

    {
      op = 'filter'

      next () =
        step ()
        c = next
        next := nil
        c

      hasNext () =
        step ()
        next != nil

      toString () =
        (name || iter.toString()) + ".filter(<fn>)"
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
