require 'httmultiparty'

module Slackbotsy

  class Api
    include HTTMultiParty
    base_uri 'https://slack.com/api'

    def initialize(token)
      @token = token
    end

    ## get a channel, group, im or user list
    def get_objects(method, key)
      self.class.get("/#{method}", query: { token: @token }).tap do |response|
        raise "error retrieving #{key} from #{method}: #{response.fetch('error', 'unknown error')}" unless response['ok']
      end.fetch(key)
    end

    def channels
      @channels ||= get_objects('channels.list', 'channels')
    end

    def groups
      @groups ||= get_objects('groups.list', 'groups')
    end

    def ims
      @ims ||= get_objects('im.list', 'ims')
    end

    def users
      @users ||= get_objects('users.list', 'members')
    end

    ## join a channel, needed to post to channel
    def join(channel)
      self.class.post('/channels.join', body: {name: channel, token: @token}).tap do |response|
        raise "error posting message: #{response.fetch('error', 'unknown error')}" unless response['ok']
      end
    end

    ## send message to one channel as a single post with params text, channel, as_user
    def post_message(params)
      self.class.post('/chat.postMessage', body: params.merge({token: @token})).tap do |response|
        raise "error posting message: #{response.fetch('error', 'unknown error')}" unless response['ok']
      end
    end

    ## upload a file or text snippet, with params file, filename, filetype, title, initial_comment, channels
    def upload(params)
      self.class.post('/files.upload', body: params.merge({token: @token})).tap do |response|
        raise "error uploading file: #{response.fetch('error', 'unknown error')}" unless response['ok']
      end
    end

  end

end
