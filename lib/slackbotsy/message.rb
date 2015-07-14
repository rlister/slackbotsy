module Slackbotsy

  class Message < Hash
    include Helper              # mixin client helper methods

    ## convert message from a Hash obj to a Message obj
    def initialize(caller, msg)
      super()
      self.update(msg)
      @caller = caller          # bot object
      @bot    = caller          # alias for bot object
    end

    ## convenience wrapper in message scope, so we can call it without @caller
    ## and set default channel to same as received message
    def post(options)
      @caller.post({ channel: self['channel_name'] }.merge(options))
    end

    def say(text, options = {})
      @caller.say(text, { channel: self['channel_name'] }.merge(options))
    end

    def attach(attachments, options = {})
      @caller.attach(attachments, { channel: self['channel_name'] }.merge(options))
    end

    def post_message(text, options = {})
      @caller.post_message(text, { channel: self['channel_name'] }.merge(options))
    end

    def upload(options = {})
      @caller.upload({ channel: self['channel_name'] }.merge(options))
    end

    ## convenience getter methods for message properties
    %w[ token team_id channel_id channel_name timestamp user_id user_name text ].each do |method|
      define_method(method) do
        self.fetch(method, nil)
      end
    end

  end

end
