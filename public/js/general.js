function pia() {
  var piido = $("#piido");
  try {
    if(piido.val()) {
      var name = piido.val().toUpperCase();
      addMessage(" > pia() "+ name);
      socket.send(name);
      localStorage.setItem(name, new Date().getTime());
      piido.val('');
    }
  } catch(exception) {
    addMessage("Failed To Send")
  }
}

function connect() {
  initMoustache();
  try {
    socket = new WebSocket(wshost);

    socket.onopen = function() {
      addMessage("Socket Status: " + socket.readyState + " (open)");
      /* Read local auidos and tuits (server tuits could overwrite local auidos) */
      addMessage("Reading auidos in localStorage ("+localStorage.length+")");
      for ( var i = 0, len = localStorage.length; i < len; ++i ) {
        var key = localStorage.key(i),
            auido = localStorage.getItem(key);
        addMessage("  -> " + key);
        if(key.length > 13) /* GREAT! Good bye bad luck... ;) */
          show_tuit(auido, key);
        else
          show_self_piido(key);
      }
    }

    socket.onclose = function() {
      addMessage("Socket Status: " + socket.readyState + " (closed)");
    }

    socket.onmessage = function(msg) {
      addMessage("Received: " + msg.data);
      show_piido(msg.data);
    }
  } catch(exception) {
    addMessage("Error: " + exception);
  }
}

function show_piido(text, timestamp) {
  addMessage(" > show_piido() "+ text);
  var rendered = Mustache.render(template_piado, {auido: text, at: text});
  $('#content').prepend(rendered);
}

function show_self_piido(text, timestamp) {
  addMessage(" > show_self_piido() "+ text);
  var rendered = Mustache.render(template_piado_by_us, {auido: text, at:text});
  $('#content').prepend(rendered);
}

function show_tuit(text, at) {
  addMessage(" > show_tuit() "+ text);
  var rendered = Mustache.render(template_tuited, {tuit: text, at: at});
  $('#content').prepend(rendered);
}

function addMessage(msg) {
  console.log(msg);
}

$("#disconnect").click(function() {
  socket.close()
});

$("#piar").submit(function(){
  pia();
  return false;
});
$("#piar button").click(function(){
  pia();
});
$("#tuitear button").click(function(){
  var piido = $("#piido");
  if(piido.val()) {
    var tuitear = $("#tuitear");
    var target = $("#host").val();
    tuitear.append(piido.val(piido.val().toUpperCase()));
    if(target) {
      target = target + tuitear.attr('action');
      tuitear.attr('action', target);
    }
    return $("#tuitear").submit();
  }
});

$( document ).on("click", "a.remove", function(){
  localStorage.removeItem($(this).data('key'));
  $(this).closest('.status').remove();
  return(false);
});

function initMoustache() {
  addMessage(" > initMoustache()");
  template_piado = $('#template_piado').html();
  template_piado_by_us = $('#template_piado_by_us').html();
  template_tuited = $('#template_tuited').html();
  Mustache.parse(template_piado);   // optional, speeds up future uses
  Mustache.parse(template_piado_by_us);
  Mustache.parse(template_tuited);
}

// TODO: some kind of order in all these JS stuff... :(
$(function() {
  connect();
  $("#piido").focus();
});

