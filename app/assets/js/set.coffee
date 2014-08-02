module("set", dependsOn=[]) () ->
  def("empty") () -> {}

  def("Set") (xs) ->
    obj = {}
    for x in xs
      obj[x] = true
    obj

  def("union") (xs, ys) ->
    zs = {}
    for x of xs
      zs[x] = true
    for y of ys
      zs[y] = true
    zs

  def("pure") (xs) ->
    acc = []
    for x of xs
      acc.push(x)
    acc

  def("difference") (xs, ys) ->
    obj = {}
    for x of ys
      if not ys[x]?
        obj[x] = true
    obj

  def("without") (xs, ys) ->
    for y of ys
      if xs[y]?
        delete xs[y]
    xs

  def("isEmpty") (xs) ->
    (k for k of xs).length == 0