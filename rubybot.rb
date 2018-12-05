require 'discordrb'
require 'discordrb/webhooks'

bot = Discordrb::Commands::CommandBot.new token: "TOKEN", prefix: 'rb:'

bot.ready do |event|
    bot.game = "программиста на Ruby"
  end

  MESSAGE_LIMIT = 5000
  messages = {}
  keys = []

  bot.message do |event|
    next if event.message.author.bot_account?
  
    id = event.message.id
    messages[id] = event.message
    keys << id
    if (keys.length > MESSAGE_LIMIT)
      oldest = keys.shift
      messages.delete(oldest)
    end
  end

bot.command(:eval) do |event, *code|
  break unless event.user.id == YOUR_ID

  begin
    x = eval code.join(' ')
    event.respond("```rb\n#{x}\n```")
  rescue StandardError
    'Ошибка :/'
  end
end

bot.message_delete do |event|
  logs = event.channel.server.channels.find do |channel|
    channel.name == 'logs'
  end

  message = messages[event.id]

  logs.send_embed do |embed|
    embed.title = 'СООБЩЕНИЕ УДАЛЕНО'
    embed.add_field(name: "Пользователь", value: message.author.mention)
    embed.add_field(name: "В канале", value: "#{message.channel.mention}")
    embed.add_field(name: "Сообщение", value: message.content)
    embed.timestamp = Time.now
    embed.color = "#363940"
  end
end

bot.run
