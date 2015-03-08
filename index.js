(function() {
    var self = this;
    var V, createArrayIterator, createSliceIterator, createLastIterator, createFilterIterator, createDollar, vdollar;
    V = function(createIterator) {
        this.createIterator = createIterator;
        return this;
    };
    V.prototype.eq = function(index) {
        var self = this;
        return self.slice(index, 1, function(p) {
            return p + ".eq(" + index + ")";
        });
    };
    V.prototype.filter = function(predicate, toString) {
        var self = this;
        return self.mutate(createFilterIterator(self, predicate, toString || function(p) {
            return p + ".filter(<fn>)";
        }));
    };
    V.prototype.first = function() {
        var self = this;
        return self.slice(0, 1, function(p) {
            return p + ".first()";
        });
    };
    V.prototype.get = function(n) {
        var self = this;
        var iter, result;
        if (typeof n === "number") {
            return self.eq(n).createIterator().next();
        } else {
            iter = self.createIterator();
            result = [];
            while (iter.hasNext()) {
                result.push(iter.next());
            }
            return result;
        }
    };
    V.prototype.last = function(n) {
        var self = this;
        return self.mutate(createLastIterator(self, n));
    };
    V.prototype.mutate = function(createIterator) {
        var self = this;
        return new V(createIterator);
    };
    V.prototype.skip = function(count) {
        var self = this;
        return self.slice(count, undefined, function(p) {
            return p + ".skip(" + count + ")";
        });
    };
    V.prototype.slice = function(start, count, toString) {
        var self = this;
        return self.mutate(createSliceIterator(self, start, count, toString || function(p) {
            if (count > 0) {
                return p + ".slice(" + start + ", " + count + ")";
            } else {
                return p + ".slice(" + start + ")";
            }
        }));
    };
    V.prototype.take = function(count) {
        var self = this;
        return self.slice(0, count, function(p) {
            return p + ".take(" + count + ")";
        });
    };
    V.prototype.toString = function() {
        var self = this;
        return self.createIterator().toString();
    };
    createArrayIterator = function(array) {
        return function() {
            var index;
            index = 0;
            return {
                op: "array",
                next: function() {
                    var self = this;
                    var item;
                    if (self.hasNext()) {
                        item = array[index];
                        index = index + 1;
                        return item;
                    } else {
                        return void 0;
                    }
                },
                hasNext: function() {
                    var self = this;
                    return index < array.length;
                },
                toString: function() {
                    var self = this;
                    var args;
                    args = array.map(function(element) {
                        return JSON.stringify(element);
                    });
                    return "V$([" + args.join(", ") + "])";
                }
            };
        };
    };
    createSliceIterator = function(prev, start, count, toString) {
        return function() {
            var iter, index;
            iter = prev.createIterator();
            index = 0;
            return {
                op: "slice",
                parent: iter,
                next: function() {
                    var self = this;
                    var n;
                    if (self.hasNext()) {
                        n = iter.next();
                        index = index + 1;
                        return n;
                    } else {
                        return void 0;
                    }
                },
                hasNext: function() {
                    var self = this;
                    while (index < start) {
                        iter.next();
                        index = index + 1;
                    }
                    return iter.hasNext() && function() {
                        if (count === undefined) {
                            return index >= start;
                        } else {
                            return index < start + count;
                        }
                    }();
                },
                toString: function() {
                    var self = this;
                    return toString(prev.toString());
                }
            };
        };
    };
    createLastIterator = function(prev, n) {
        return function() {
            var array, last, iter;
            array = prev.get();
            last = array.slice(array.length - (n || 1));
            iter = createArrayIterator(last)();
            return {
                op: "last",
                parent: prev.createIterator(),
                next: function() {
                    var self = this;
                    return iter.next();
                },
                hasNext: function() {
                    var self = this;
                    return iter.hasNext();
                },
                toString: function() {
                    var self = this;
                    return prev.createIterator().toString() + ".last(" + (n || "") + ")";
                }
            };
        };
    };
    createFilterIterator = function(prev, predicate, toString) {
        return function() {
            var iter, next, step;
            iter = prev.createIterator();
            next = void 0;
            step = function() {
                var c;
                if (next === void 0) {
                    next = void 0;
                    while (iter.hasNext()) {
                        c = iter.next();
                        if (predicate(c)) {
                            next = c;
                            return;
                        }
                    }
                    return void 0;
                }
            };
            return {
                op: "filter",
                parent: iter,
                next: function() {
                    var self = this;
                    var c;
                    step();
                    c = next;
                    next = void 0;
                    return c;
                },
                hasNext: function() {
                    var self = this;
                    step();
                    return next !== void 0;
                },
                toString: function() {
                    var self = this;
                    return toString(iter.toString());
                }
            };
        };
    };
    createDollar = function(V) {
        var dollar;
        return dollar = function(x) {
            if (x instanceof Array) {
                return new V(createArrayIterator(x));
            } else if (x instanceof Function) {
                return new V(function() {
                    return createArrayIterator(x())();
                });
            } else {
                throw new Error("Expected array or function (got " + x + ")");
            }
        };
    };
    vdollar = createDollar(V);
    vdollar.extend = function(extensions) {
        var self = this;
        var E, gen1_items, gen2_i, extension;
        E = function(createIterator) {
            return V.call(this, createIterator);
        };
        E.prototype = new V();
        E.prototype.mutate = function(createIterator) {
            var self = this;
            return new E(createIterator);
        };
        gen1_items = Object.keys(extensions);
        for (gen2_i = 0; gen2_i < gen1_items.length; ++gen2_i) {
            extension = gen1_items[gen2_i];
            E.prototype[extension] = extensions[extension];
        }
        E.prototype.constructor = V;
        return createDollar(E);
    };
    module.exports = vdollar;
}).call(this);