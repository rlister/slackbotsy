module Slackbotsy

  class Message < Hash
    include Helper              # mixin client helper methods
    
    ## convert message from a Hash obj to a Message obj
    def initialize(caller, msg)
      super()
      self.update(msg)
      @caller = caller          # bot object
    end

    ## call say without bot object
    def say(text, options = {})
      options[:channel] ||= self['channel_name'] # default to same channel as msg
      @caller.say(text, options)
    end

    ## convenience getter methods for message properties
    %w[ token team_id channel_id channel_name timestamp user_id user_name text ].each do |method|
      define_method(method) do
        self.fetch(method, nil)
      end
    end
    
  end

end
