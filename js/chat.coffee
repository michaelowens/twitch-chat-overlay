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

client.addListener 'action', (channel, user, message) ->
    if config.notify.chat
        event = new CustomEvent('message', {'detail': {user: user, message: emoteParse(message), action: true}});
        document.dispatchEvent(event);

client.addListener 'subscription', (channel, user) ->
    if config.notify.subs
        event = new CustomEvent('sub', {'detail': {user: user}});
        document.dispatchEvent(event);

client.addListener 'subanniversary', (channel, user, months) ->
    if config.notify.subanniversary
        event = new CustomEvent('subanniversary', {'detail': {user: user, months: months}});
        document.dispatchEvent(event);

client.addListener 'hosted', (channel, user, viewers) ->
    if config.notify.hosts
        event = new CustomEvent('host', {'detail': {user: user, viewers: viewers}});
        document.dispatchEvent(event);

client.addListener 'connected', (address, port) ->
    event = new CustomEvent('message', {'detail': {user: {username: 'Chat Overlay'}, message: 'Connected to twitch.tv servers!', action: false}});
    document.dispatchEvent(event);

client.addListener 'disconnected', (reason) ->
    event = new CustomEvent('message', {'detail': {user: {username: 'Chat Overlay'}, message: 'You have been disconnected from twitch.tv. (Reason: ' + reason + ').', action: false}});
    document.dispatchEvent(event);

client.addListener 'join', (channel, username) ->
    event = new CustomEvent('message', {'detail': {user: {username: 'Chat Overlay'}, message: 'Joined your channel chatroom (' + channel + ').', action: false}});
    document.dispatchEvent(event);