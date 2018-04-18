module EventCrapper
  class Context
    getter stdout : IO

    def initialize(args)
      @stdout = STDOUT
    end
  end

  module Coordinator
    class_getter events = Hash(Symbol, Proc(Context, Nil)).new

    def on(name : Symbol, &block : Context ->)
      @@events[name] = block
    end

    def fire(name : Symbol, *args)
      @@events[name]?.try do |proc|
        context = Context.new(args)
        proc.call(context)
      end
    end
  end
end

###############################

class Thing
  include EventCrapper::Coordinator
end

my_events = Thing.new

my_events.on :hello do |context|
  context.stdout.puts "hello world"
end

if Random.new.next_bool
  my_events.on :maybe_exists do |context|
    context.stdout.puts "I exist!"
  end
end

my_events.fire :hello
my_events.fire :maybe_exists
