module("ui", dependsOn = []) () ->
  def("panel") (classes, header, id = undefined) ->
    cs = classes.join(" ")

    p = $('<div></div>').addClass("panel").addClass(cs)

    h = $('<div></div>').addClass("panel-heading").appendTo(p)
    t = $('<div></div>').addClass("panel-title").append(header)
    t.appendTo(h)
    t.append('<span class="glyphicon glyphicon-question-sign pull-right"><span>')

    b = $('<div></div>').addClass("panel-body")
    b.appendTo(p)

    if id?
      b.attr("id", id)

    p._title = (newTitle) ->
      t.empty()
      t.append(newTitle)
      this

    p._body = b
    p._header = h

    p

  def("table") (classes, header) ->
    cs = classes.join(" ")
    t = $('<table></table>').addClass("table table-hover").addClass(cs)
    h = $('<thead></thead>')
    h.appendTo(t)
    hr = $('<tr></tr>')
    hr.appendTo(h)
    for h in header
      hr.append($("<th>#{h}</th>"))

    b = $("<tbody></tbody>")
    b.appendTo(t)

    t._body = b
    t._add = (elms) ->
      row = $('<tr></tr>')
      row.appendTo(b)
      for elm in elms
        col = $('<td></td>')
        col.append(elm)
        row.append(col)

    t._props = (props) ->
      t._clear()
      for k, v of props
        t._add([k, v])

    t._clear = () ->
      this._body.empty()

    t