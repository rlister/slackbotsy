# Slackbotsy

Ruby bot library for Slack chat, inspired by
the Campfire bot http://github.com/seejohnrun/botsy.

## Working example

This repo and gem provide a library for implementing slack botsy using
the web framework of your choice. For example, botsy could be embedded
into an existing Rails app to provide access to a database from slack.

For a fully-implemented and ready-to-deploy standalone bot, using
slackbotsy and sinatra, please proceed over to
https://github.com/rlister/slackbotsy_example. You will find full
instructions to configure and deploy your own bot.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slackbotsy'
```

And then bundle:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install slackbotsy
```

## Setup

botsy requires (at least) two webhooks setup in slack:

* outgoing webhook: for slack to send messages out to botsy
* incoming webhook: for botsy `say` and `attach` methods to respond

Set these up at https://your_team.slack.com/services/new and copy
the webhook urls/tokens to botsy's config as below.

## Example usage

```ruby
require 'slackbotsy'
require 'sinatra'
require 'open-uri'

config = {
  'channel'          => '#default',
  'name'             => 'botsy',
  'incoming_webhook' => 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX',
  'outgoing_token'   => 'secret'
}

bot = Slackbotsy::Bot.new(config) do

  hear /echo\s+(.+)/ do |mdata|
    "I heard #{user_name} say '#{mdata[1]}' in #{channel_name}"
  end

  hear /flip out/i do
    open('http://tableflipper.com/gif') do |f|
      "<#{f.read}>"
    end
  end

end

post '/' do
  bot.handle_item(params)
end
```

## Web API

slackbotsy can now post to Slack using the
[Slack Web API](https://api.slack.com/web). It may be used alongside
the incoming webhooks to post.

Create a Slack user in your team for your bot, then create an api
token for that user at https://api.slack.com/web, and set the config
variable `api_token` when you configure botsy. Then you may use the
`post_message` or `upload` convenience methods to post simple messages
or upload files/text-snippets.

```ruby
config = {
  'channel'   => '#default',
  'name'      => 'botsy',
  'api_token' => 'xoxp-0123456789-0123456789-0123456789-d34db33f'
}

bot = Slackbotsy::Bot.new(config) do

  hear /ping/ do
    post_message 'this is a simple posted message', channel: '#general'
  end

  hear /upload/ do
    upload(file: File.new('/tmp/kitten.jpg'), channel: '#general')
  end

end
```
