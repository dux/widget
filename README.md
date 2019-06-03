# HTML Widgets

Micro Widget/Component lib

Super simple component lib for use with server side rendered templates

if you need someting similar but more widely adopted, use https://stimulusjs.org/


## Init interface

```js
// to register a widget
Widget(name, { init: ..., render: ... })

// to bind widget to DOM node
Widget(name, HTMLElement)

// to get reference to binded node
Widget('#id' || HTMLElement)
```

## instance public interface

### methdods
```js
// called only once on widget register
this.once()

// called on wiget init
this.init()

// will add css to document head if present
this.css()

// if it returns string, renders data to container
this.render()

// generate HTML tag
this.tag(name, otps, innerHTML)

// set @state[k]=v to v and call render() if render
this.set(key, value)defined

// set innerHTML to current node, auto call helpers. replaces $$ with current node reference
this.html(data, node?)

// binded DOM HTML Element
this.node      -

// this pointer as a string
this.refstring

// data-json="{...}" -> @state + all data-attributes are translated to state
this.state
```

# Example code

Coffee script

```coffee
Widget 'yes_no',
  css: """
    .w.yes_no button { margin: 0; }
  """

  init: ->
    @state.yes ||= 'yes'
    @state.no  ||= 'no'

  render: ->
    data  = @render_button(@state.yes, 1)
    data += @render_button(@state.no, 0)

    tag 'div.btn-group', data

  render_button: (name, state) ->
    klass = if parseInt(@state.state) == state then 'primary' else 'defaut'

    tag 'button.btn.btn-sm', name,
      class:   "btn-#{klass}"
      onclick: => @update_state(state)

  update_state: (state) ->
    url = "#{@state.object}/#{@state.id}/update?#{@state.field}="+state

    Api(url).done =>
      @state.state = state
      @render()
      Pjax.refresh()
```

```html
<w-yes_no data-filed="yes" data-object="pools" data-id="3"></w-yes_no>
```

