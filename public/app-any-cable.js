(function() {
  var messageList = document.getElementById("message_list_any_cable");
  var statusBadge = document.getElementById("status_any_cable")

  addMessage(messageList, { text: "Streaming from AnyCable!" });

  ActionCable.startDebugging();

  var url = statusBadge.getAttribute('cable-url')
  var cable = ActionCable.createConsumer(url);

  var chatChannel = cable.subscriptions.create(
    'DemoChannel',
    {
      connected: function(){
        toggleConnected(statusBadge, true);
      },

      disconnected: function(){
        toggleConnected(statusBadge, false);
      },

      received: function(data){
        addMessage(messageList, data);
      }
    }
  );
})();
