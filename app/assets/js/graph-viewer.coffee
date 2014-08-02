module("viewer", dependsOn=["DFF", "sigmagraph"]) () ->
  def("show") (dff, view) ->
    sigmagraph.SigmaView(dff, DFF.bfsLayout, view)
