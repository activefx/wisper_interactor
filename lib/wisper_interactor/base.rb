require 'interactor'
require 'wisper'

module WisperInteractor
  class Base
    include Interactor
    include Wisper::Publisher

    def self.on_success(&blk)
      self.on_success_callback = blk
    end

    def self.on_failure(&blk)
      self.on_failure_callback = blk
    end

    def self.perform(&blk)
      self.instructions = blk
    end

    def self.on_success_callback=(value)
      @on_success_callback = value
    end

    def self.on_success_callback
      @on_success_callback
    end

    def self.on_failure_callback=(value)
      @on_failure_callback = value
    end

    def self.on_failure_callback
      @on_failure_callback
    end

    def self.instructions=(value)
      @instructions = value
    end

    def self.instructions
      @instructions
    end

    def self.subscribers
      @subscribers ||= []
    end

    def self.subscribe(subscriber, **options)
      self.subscribers << [ subscriber, options ]
    end

    # Override Interactor#run!
    #
    def run!
      subscribe_listeners
      perform_instructions
    end

    def call
      execute :instructions
    end

    private

    def subscribe_listeners
      self.class.subscribers.each do |subscriber|
        self.subscribe(*subscriber)
      end
    end

    def perform_instructions
      begin
        with_hooks do
          call
          context.called!(self)
        end
        execute :on_success_callback
      rescue
        execute :on_failure_callback
        context.rollback!
        raise
      end
    end

    def execute(key)
      if blk = self.class.send(key)
        instance_exec &blk
      end
    end

  end
end
