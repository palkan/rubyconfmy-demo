(function() {
  var messageList = document.getElementById("message_list_action_cable");
  var statusBadge = document.getElementById("status_action_cable")

  addMessage(messageList, { text: "Streaming from ActionCable!" });

  ActionCable.startDebugging();

  var cable = ActionCable.createConsumer();

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
