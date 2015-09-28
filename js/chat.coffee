config =
    username: getQueryVariable('username')
    notify:
        chat: getQueryVariable('chat') || true
        subs: getQueryVariable('subs') || false
        subanniversary: getQueryVariable('subannv') || false
        hosts: getQueryVariable('hosts') || false
    maxmessages: getQueryVariable('maxmsgs') || 5

client = new irc.client
    options:
        debug: true
    connection:
        random: 'chat'
        reconnect: true
    channels: ['#' + config.username]

client.connect()

client.addListener 'chat', (channel, user, message) ->
    if config.notify.chat
        event = new CustomEvent('message', {'detail': {user: user, message: emoteParse(message), action: false}});
        document.dispatchEvent(event);