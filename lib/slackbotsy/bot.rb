require 'net/http'
require 'net/https'
require 'uri'
require 'json'
require 'set'

module Slackbotsy

  class Bot
    attr_accessor :listeners, :last_description, :api

    def initialize(options, &block)
      @options = options
      @listeners = []
      @options['outgoing_token'] = parse_outgoing_tokens(@options['outgoing_token'])
      setup_incoming_webhook                # http connection for async replies
      setup_web_api                         # setup slack Web API
      instance_eval(&block) if block_given? # run any hear statements in block
    end

    ## use set of tokens for (more or less) O(1) lookup on multiple channels
    def parse_outgoing_tokens(tokens)
      (tokens.respond_to?(:split) ? tokens.split(/[,\s]+/) : Array(tokens)).to_set
    end

    ## setup http connection for sending async incoming webhook messages to slack
    def setup_incoming_webhook
      ## incoming_webhook will be used if provided, otherwise fallback to old-style url with team and token
      url = @options.fetch('incoming_webhook', false) || "https://#{@options['team']}.slack.com/services/hooks/incoming-webhook?token=#{@options['incoming_token']}"
      @uri  = URI.parse(url)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    ## use api_token to setup Web API authentication
    def setup_web_api
      if @options['api_token']
        @api = Api.new(@options['api_token'])
      end
    end

    ## raw post of hash to slack webhook
    def post(options)
      payload = {
        username: @options['name'],
        channel:  @options['channel']
      }.merge(options)
      payload[:channel] = payload[:channel].gsub(/^#?/, '#') #slack api needs leading # on channel
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.set_form_data(payload: payload.to_json)
      @http.request(request)
      return nil # so as not to trigger text in outgoing webhook reply
    end

    ## simple wrapper on post to send text
    def say(text, options = {})
      post({ text: text }.merge(options))
    end

    ## simple wrapper on post to send attachment(s)
    def attach(ary, options = {})
      attachments = ary.is_a?(Array) ? ary : [ ary ] #force first arg to array
      post({ attachments: attachments }.merge(options))
    end

    ## simple wrapper on api.post_message (which calls chat.postMessage)
    def post_message(text, options = {})
      payload = {
        username: @options['name'],
        channel:  @options['channel'],
        text:     text,
        as_user:  true
      }.merge(options)
      payload[:channel] = payload[:channel].gsub(/^#?/, '#') # chat.postMessage needs leading # on channel
      @api.join(payload[:channel])
      @api.post_message(payload)
      return nil # be quiet in webhook reply
    end

    ## simple wrapper on api.upload (which calls files.upload)
    ## pass 'channel' as a csv list of channel names, otherwise same args as files.upload
    def upload(options)
      payload = options
      channels = @api.channels # list of channel objects
      payload[:channels] ||= (options.fetch(:channel, @options['channel'])).split(/[\s,]+/).map do |name|
        channels.find { |c| name.match(/^#?#{c['name']}$/) }.fetch('id') # convert channel id to name
      end.join(',')
      @api.upload(payload)
      return nil # be quiet in webhook reply
    end

    ## record a description of the next hear block, for use in help
    def desc(command, description = nil)
      @last_desc = [ command, description ]
    end

    ## add regex to things to hear
    def hear(regex, &block)
      @listeners << OpenStruct.new(regex: regex, desc: @last_desc, proc: block)
      @last_desc = nil
    end

    ## pass list of files containing hear statements, to be opened and evaled
    def eval_scripts(*files)
      files.flatten.each do |file|
        self.instance_eval File.open(file).read
      end
    end

    ## check message and run blocks for any matches
    def handle_item(msg)
      return nil unless @options['outgoing_token'].include? msg[:token] # ensure messages are for us from slack
      return nil if msg[:user_name] == 'slackbot'  # do not reply to self
      return nil unless msg[:text].is_a?(String) # skip empty messages

      ## loop things to look for and collect immediate responses
      ## rescue everything here so the bot keeps running even with a broken script
      responses = @listeners.map do |hear|
        if mdata = msg[:text].strip.match(hear.regex)
          begin
            Slackbotsy::Message.new(self, msg).instance_exec(mdata, &hear.proc)
          rescue => err
            err
          end
        end
      end

      ## format any replies for http response
      if responses
        { text: responses.compact.join("\n") }.to_json
      end
    end

  end

end
