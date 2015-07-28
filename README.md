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

botsy requires some or all of the following integrations setup in slack:

* outgoing webhook: for slack to send free-format messages out to botsy
* slash command: for slack to send messages prefixed with a slash
  command, for example `/botsy`
* incoming webhook: for botsy `say` and `attach` methods to respond

Set these up at https://your_team.slack.com/services/new and copy
the webhook urls/tokens to botsy's config as below.

## Sending messages to botsy

You have three choices of how to send messages to botsy. It is fine to
mix and match these to listen to different kinds of messages.

### Global outgoing webhook

This sends all messages from all channels to botsy, but requires a
trigger word (e.g. `botsy`). This word must be included in
`hear`-block regexes. The return from the hear block is posted
publically to the sending channel. Alternatively, return `nil` and use
`say` or `attach` to craft an asynchronous response.

Requires you to set the `outgoing_token` config variable.

### Per-channel outgoing webhooks

These do not require any trigger word or magic prefix, but you must
setup a webhook for every channel in which you want botsy to
respond. This is useful to give your botsy a little personality, by
seeming to respond to users' comments without being prompted.

As with global webhooks, `hear` block returns public responses, or use
`say` or `attach`.

Add all required channel tokens to the `outgoing_token` array.

### Slash commands

You can define one or more slash integrations that send any messages
with a slash trigger prefix (for example `/botsy`). A major advantage
is that messages can be triggered from all channels, groups and
private chats.

The return value of the `hear`-block is sent as a _private_ response
to the user (like communication from the built-in `slackbot`). This
can be useful for requesting verbose bot information without spamming
channels. To respond _publically_ from a `hear`-block, post direct to
the channel using `say` or `attach`.

The slash trigger itself is used in the `hear`-block regex match, so
you may setup as many slash integrations as you like with different
triggers, and respond appropriately.

Add all slash integration tokens to config `slash_token`.

## Sending messages to slack

There are four methods of sending data to slack in response to
matching a `hear` block. These may be mixed as necessary.

### Simple response in return

The return value from a `hear`-block is returned to slack in the http
response to the sent message. This is a lightweight synchronous
response to the same channel, and is sufficient for many needs.

Note: responses to outgoing webhooks are posted publically, responses
to slash commands are private to the requesting user (and appear to
come from `slackbot`).

### Post simple text to an incoming webhook with `say()`

Asynchronous plain-text responses may be sent with the `say()` method
from inside a `hear`-block. This is useful for multiple replies or to
pass extra arguments, such as `channel`, to post response to a
specific channel. It is also useful when botsy is expanded to be a
general API for slack integration with third-party applications.

Set the value of the `incoming_webhook` config variable to the URL
given in your slack Incoming Webhook integration.

### Post attachments to an incoming webook with `attach()`

Works exactly like `say()`, except you may post JSON containing
complex attachment information.

### Upload data directly to slack using the API

Call `post_message()` to get full access to the Slack Web API
`/chat.postMessage` call. Argument is a hash containing the same
variables described in the Web API docs. This allows uploading of text
snippets and binary data.

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
