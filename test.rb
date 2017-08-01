#!/usr/bin/env ruby
require_relative 'lib/slackbotsy/bot'
require_relative 'lib/slackbotsy/helper'
require_relative 'lib/slackbotsy/message'
require 'sinatra'

config = {
  'channel'          => '#default',
  'name'             => 'botsy',
  # 'incoming_webhook' => 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX',
  'outgoing_token'   => '123',
  'slash_token'      => '123',
}

bot = Slackbotsy::Bot.new(config) do

  hear /ping/i do
    'pong'
  end

  hear /botsy ping/i do
    'pang'
  end

  hear /test (.+)/ do |mdata, str|
    "mdata: #{mdata}, str: #{str}"
  end

  hear /echo\s+(.+)/ do |_, str|
    "I heard #{user_name} say '#{str}' in #{channel_name}"
  end

end

post '/' do
  if params[:command]
    bot.handle_slash_command(params)
  else
    bot.handle_outgoing_webhook(params)
  end
end
