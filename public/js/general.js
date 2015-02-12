function pia() {
  var piido = $("#piido");
  try {
    if(piido.val()) {
      var name = piido.val().toUpperCase();
      addMessage(" > pia() "+ name);
      socket.send(name);
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
      for (var tuit in tuits_submitted){
        show_tuit(tuits_submitted[tuit], tuit);
      }
    }

    socket.onclose = function() {
      addMessage("Socket Status: " + socket.readyState + " (closed)");
    }

    socket.onmessage = function(msg) {
      addMessage("Received: " + msg.data);
      show_search_results(JSON.parse(msg.data));
    }
  } catch(exception) {
    addMessage("Error: " + exception);
  }
}

function add_search_item(tmpl, hash) {
  addMessage(" > in add_search_item()");
  var item = Mustache.render(tmpl, hash);
  $('#search').append(item);
}

function show_search_results(message) {
  addMessage(" > in show_search_results()");
  var number_of_results = 0,
      in_others = [];

  for (result in message.results) number_of_results++;

  $('#search').html('');
  add_search_item(template_query, {query: message.query});

  if(number_of_results == 0) {
    add_search_item(template_no_results, {query: message.query});
  }
  else {
    for (result in message.results) {
      add_search_item(template_result, {
        tuit: result,
        at: message.results[result]
      });
    } 
  }

  for (other in message.in_other_dromes)
    in_others.push(other + ' (' + message.in_other_dromes[other] + ') ');

  if(in_others.length > 0) {
    add_search_item(template_in_other_dromes, {other_dromes_results: in_others.join(', ')});
  }
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

$('#property_name').addClass('lowercase');
$('#property_form').submit(function(){
  var property_name = $('#property_name');
  property_name.val(property_name.val().toLowerCase());
});

function initMoustache() {
  addMessage(" > initMoustache()");
  template_query = $('#template_query').html();
  template_result = $('#template_result').html();
  template_no_results = $('#template_no_results').html();
  template_tuited = $('#template_tuited').html();
  template_in_other_dromes = $('#template_in_other_dromes').html();

  Mustache.parse(template_query);   // optional, speeds up future uses
  Mustache.parse(template_tuited);
}

$(function() {
  if($("#piido").length == 1) {
    connect();
    piido.focus();
  }
});

