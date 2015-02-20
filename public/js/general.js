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
      if(tuits_submitted!=null) {
        for (var tuit in tuits_submitted){
          show_tuit(tuits_submitted[tuit], tuit);
        }
      }
      if(search_payload!=null) {
        show_search_results(search_payload);
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

function show_search_results(payload) {
  addMessage(" > in show_search_results()");
  var number_of_results = 0,
      other_dromes = payload.in_other_dromes,
      in_others = 0;

  for (result in payload.results) number_of_results++;

  $('#search').html('');
  add_search_item(template_query, {query: payload.query});

  if(number_of_results == 0) {
    add_search_item(template_no_results, {query: payload.query});
  }
  else {
    for (var result in payload.results) {
      add_search_item(template_result, {
        tuit: result,
        at: payload.results[result]
      });
    } 
  }

  for (var other in other_dromes)
    in_others += other_dromes[other]['number_of_auidos'];

  if(in_others > 0) {
    add_search_item(template_in_other_dromes, {other_dromes_results: in_others});
    for (other in other_dromes) {
      add_search_item(template_in_other_drome_link, {
        other_drome_name: other,
        other_drome_link: other_dromes[other]['search_url'],
        other_drome_number: other_dromes[other]['number_of_auidos']
      });
    }
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
  template_in_other_drome_link = $('#template_in_other_drome_link').html();

  Mustache.parse(template_query);   // optional, speeds up future uses
  Mustache.parse(template_tuited);
}

$(function() {
  if($("#piido").length == 1) {
    connect();
    piido.focus();
  }
});

