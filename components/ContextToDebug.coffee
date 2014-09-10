noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'context',
    datatype: 'object'

  c.outPorts.add 'context',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'context'
    out: 'context'
    forwardGroup: true
  , (context, groups, out) ->
    c.removeListener()
    c.addListener context.runtime, context.graphs?[0]
    out.send context

  c.setRuntimeDebug = (enable) ->
    setTimeout =>
      c.runtime.sendNetwork 'debug',
        graph: @graphId
        enable: enable
    , 1

  graphId = (graph) ->
    id = graph.name or graph.properties.id
    if graph.properties.library
      return "#{graph.properties.library}/#{id}"
    id

  c.addListener = (runtime, graph) ->
    return unless runtime? and graph?
    @runtime = runtime
    @graph = graph
    @graphId = graphId graph
    @listener = (status) =>
      return unless status.online
      c.setRuntimeDebug true
    @runtime.on 'status', c.listener
    @setRuntimeDebug true if @runtime.isConnected()

  c.removeListener = ->
    return unless @listener and @runtime
    # Disable debug on old runtime
    @setRuntimeDebug false if @runtime.isConnected()
    # Stop listening
    @runtime.removeListener 'status', @listener
    delete c.runtime
    delete c.graph

  c
