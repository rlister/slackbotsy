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

  end

end
