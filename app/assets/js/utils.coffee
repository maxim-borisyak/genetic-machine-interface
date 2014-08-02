root = this

utils =
  getQueryParams: () ->
    qstr = window.location.search.substring(1)
    qs = qstr.split("&")
    kvs = (qs.map (q) -> q.split("=")).filter (kv) -> kv.length == 2
    paramsObj = { }
    kvs.forEach (kv) ->
      k = kv[0]
      v = kv[1]
      paramsObj[k] = v

    paramsObj

  # cyclic dependencies...
  showError: (reason, e) ->
    p = ui.panel(["panel-danger"], "Error")
    p._body.append('<strong>' + reason + '</strong>: ' + e)
    $("#content").append(p)

require = (scripts) ->
  for s in scripts
    moduleName = if typeof(s) is "string" then s else s.module
    file = if typeof(s) is "string" then "#{s}.js" else s.file
    if not root[moduleName]?
      throw "Dependency #{moduleName} (#{file}) is missing"

def = (name) -> (defenition) ->
  root.utils.currentModule[name] = defenition

module = (name, dependsOn = []) -> (defenition) ->
  if not root[name]?
    require(dependsOn)
    root[name] = {}
    root.utils.currentModule = root[name]
    defenition()
    root.utils.currentModule = null


root.utils = utils
root.module = module
root.def = def