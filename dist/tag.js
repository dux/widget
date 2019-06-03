// Generated by CoffeeScript 2.4.1
// tag 'a', { href: '#'}, 'link name' -> <a href="#">link name</a>
// tag 'a', 'link name'               -> <a>link name</a>
// tag '.a', 'b'                      -> <div class="a">b</div>
// tag '#a.b', ['c','d']              -> <div class="b" id="a">cd</div>
// tag '#a.b', {c:'d'}                -> <div c="d" class="b" id="a"></div>
var tag, tag_events, tag_uid;

tag_events = {};

tag_uid = 0;

tag = function(name, ...args) {
  var data, i, key, len, name_parts, node, old_class, opts, ref, uid, val;
  if (!name) {
    return tag_events;
  }
  // evaluate function if data is function
  args = args.map(function(el) {
    if (typeof el === 'function') {
      return el();
    } else {
      return el;
    }
  });
  // swap args if first option is object
  args[1] || (args[1] = void 0); // fill second value
  [opts, data] = typeof args[0] === 'object' && !Array.isArray(args[0]) ? args : args.reverse();
  // set default values
  opts || (opts = {});
  if (typeof data === 'undefined') {
    data = '';
  }
  if (Array.isArray(data)) {
    data = data.join('');
  }
  // haml style id define
  name = name.replace(/#([\w\-]+)/, function(_, id) {
    opts['id'] = id;
    return '';
  });
  // haml style class add with a dot
  name_parts = name.split('.');
  name = name_parts.shift() || 'div';
  if (name_parts[0]) {
    old_class = opts['class'] ? ' ' + opts['class'] : '';
    opts['class'] = name_parts.join(' ') + old_class;
  }
  node = ['<' + name];
  ref = Object.keys(opts).sort();
  for (i = 0, len = ref.length; i < len; i++) {
    key = ref[i];
    val = opts[key];
    // hide function calls
    if (typeof val === 'function') {
      uid = ++tag_uid;
      tag_events[uid] = val;
      val = `tag()[${uid}](this)`;
    }
    node.push(' ' + key + '="' + val + '"');
  }
  if (['input', 'img'].indexOf(name) > -1) {
    node.push(' />');
  } else {
    node.push('>' + data + '</' + name + '>');
  }
  return node.join('');
};

// # export
// flatten = (arr) ->
//   arr.reduce ((flat, toFlatten) ->
//     flat.concat if Array.isArray(toFlatten) then flatten(toFlatten) else toFlatten
//   ), []

// # for JSX transpilers
// window.React ||=
//   createElement: (name, opts, ...args) ->
//     console.log [name, opts, args]
//     tag name, opts || {}, flatten(args).join('')
export default tag;
