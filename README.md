# Slackbotsy

Ruby bot for Slack chat, inspired by http://github.com/seejohnrun/botsy.

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

  hear /echo\s+(.+)/ do |data, mdata|
    "I heard #{data['user_name']} say '#{mdata[1]}' in #{data['channel_name']}"
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
