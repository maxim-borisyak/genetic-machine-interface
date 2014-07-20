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

require = (scripts) ->
  for s in scripts
    moduleName = if typeof(s) is "string" then s else s.module
    file = if typeof(s) is "string" then "#{s}.js" else s.file
    if not root[moduleName]?
      throw "Dependency #{moduleName} (#{file}) is missing"

module = (name, dependsOn = []) -> (defenition) ->
  if not root[name]?
    require(dependsOn)
    root[name] = defenition()

root.utils = utils
root.module = module