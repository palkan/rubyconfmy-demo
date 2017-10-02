var addMessage = function(list, data){
  var node = document.createElement('div');
  node.className = "message";
  node.innerHTML =
    '<div class="tweet">' + highlight(data.text) + '</div>' +
    '<div class="timestamp">' + currentTime() + '</div>';
  list.appendChild(node);
};

var highlight = function(text) {
  return text.replace(/\@\S+/g, function(author) { return '<span class="author">' + author + '</span>' } )
             .replace(/\#\S+/g, function(tag) { return '<span class="tag">' + tag + '</span>' });
}

var toggleConnected = function(badge, connected){
  if(connected){
    badge.classList.add("connected");
  } else {
    badge.classList.remove("connected");
  }
};

var currentTime = function(){
  var d = new Date();
  return _pad(d.getHours()) + ":" + _pad(d.getMinutes()) + ":" + _pad(d.getSeconds()) + "." + _pad(d.getMilliseconds(), 2);
}

var _pad = function(val, offset) {
  offset = offset || 1;
  var n = 10;

  while(offset) {
    if (val < n) val = "0" + val;
    n = n * 10;
    offset--;
  }
  return val;
}
