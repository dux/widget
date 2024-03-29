Widget = (name, object) ->
  if object.constructor == Object
    Widget.register name, object
  else if !object
    Widget.get name
  else
    Widget.bind name, object

Object.assign Widget,
  inst_id_name: 'widget_id'
  namespace:    'w'
  registered:   {}
  count:        0

  # overload with custom on register fuction
  on_register: (name) -> console.log("Widget #{name} registered")

  # #consent.w.toggle ...
  # w.get('#consent').activate()
  # w.get('#consent').set('foo','bar') -> set state and call @render()
  get: (node) ->
    if typeof node == 'string'
      node.split('#', 2)[1] if node[0] == '#'
      node = document.getElementById(node)

    return unless node
    @bind node

  # register widget, trigger once method, insert css if present
  register: (name, widget) ->
    return if Widget.registered[name]

    @registered[name] = widget

    if widget.once
      widget.once()
      delete widget.once

    if widget.css
      data = if typeof(widget.css) == 'function' then widget.css() else widget.css
      document.head.innerHTML += """<style id="widget_#{name}_css">#{data}</style>"""
      delete widget.css

    # create custom HTML element
    CustomElement.define "#{@namespace}-#{name}", (node, opts) ->
      Widget.bind(name, node, opts)

  # runtime apply registered widget to dom node
  bind: (widget_name, dom_node, state) ->
    dom_node = document.getElementById(dom_node) if typeof(dom_node) == 'string'

    return if dom_node.classList.contains('mounted')
    dom_node.classList.add('mounted')

    unless dom_node.getAttribute('id')
      dom_node.setAttribute('id', "widget_#{++@count}")

    # return if widget is not defined
    widget_opts = @registered[widget_name]
    return console.error("Widget #{widget_name} is not registred") unless widget_opts

    # define widget instance
    widget = {...widget_opts}

    # bind widget to node
    dom_node.widget = widget

    # bind root to root
    widget.node  = dom_node
    widget.id    = dom_node.id
    widget.ref   = "document.getElementById('#{widget.node.id}').widget"

    # set widget state, copy all date-attributes to state
    if state
      if state['data-json']
        widget.state = JSON.parse state['data-json']
      else
        widget.state = state
    else
      json         = dom_node.getAttribute('data-json') || '{}'
      json         = JSON.parse(json)
      widget.state = {...json, ...dom_node.dataset}

    delete widget.state.json

    # shortcut
    widget.attr ||= (name) ->
      @node.getAttribute(name)

    # create set method unless defined
    widget.set ||= (name, value) ->
      if typeof name == 'string'
        @state[name] = value
      else
        Object.assign @state, name

    # set html to current node
    widget.html ||= (data, root) ->
      data = data.join('') if typeof data != 'string'
      data = data.replace(/\$\$\./g, widget.ref+'.')
      (root || @node).innerHTML = data

    # redefine render method to insert html to widget if return is a string
    widget.render ||= -> false
    widget.$$render = widget.render
    widget.render = ->
      data = widget.$$render()

      if typeof data == 'string'
        @html data
      else
        null

    # init and render
    widget.init() if widget.init
    widget.render()

    # return widget instance
    widget

  # is node a binded widget
  isWidget: (node) ->
    !!node.widget

  # get dom node child nodes as a list of objects
  childNodes: (root, node_name) ->
    list = []
    i    = 0

    root.childNodes.forEach (node) ->
      return unless node.attributes
      return if node_name && node_name.toUpperCase() != node.nodeName
      o = {}
      o.HTML = node.innerHTML
      o.NODE = node
      o.ID   = i++

      for a in node.attributes
        o[a.name] = a.value

      list.push o

    list

export default Widget