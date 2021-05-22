# frozen_string_literal: true

module Operationable
  module Fledgedable
    attr_accessor :callbacks, :result, :serialized, :called

    VALUES = %i(job do_when process delay serialize)
    
    def push_to_queue(arg, after:nil, before:nil)
      callbacks << arg
    end

    module WrpClassMethods
      def push_to_queue(arg, after:nil, before:nil)
        callbacks << arg
      end

      def callbacks
        @callbacks ||= []
      end

      def inherited_callbacks
        ancestors
          .select { |parent| parent.include?(Fledgedable) }
          .reverse
          .flat_map { |parent| parent.instance_variable_get(:@callbacks) }
          .compact
      end

      def new(*arguments, &block)
        instance = allocate
        instance.send(:initialize, *arguments, &block)
        instance_callbacks = instance.instance_variable_get(:@callbacks)
        instance.instance_variable_set(:@callbacks, instance_callbacks.concat(inherited_callbacks).uniq)
        instance
      end

      VALUES.map do |name|
        value = "#{name}_value"

        attr_accessor value
        
        define_method(name) do |arg|
          instance_variable_set("@#{value}", arg)
        end
      end
    end

    def self.included(base)
      base.extend(WrpClassMethods)
    end

    VALUES.map do |name|
      value = "#{name}_value"

      attr_accessor value
    end

    def initialize(data)
      @callbacks = []

      # [*data].map do |k, v|
      #   self.instance_variable_set("@#{k}", v)
      # end

      @data = data
    
      self.class::VALUES.map do |name|
        value = "#{name}_value"

        instance_variable_set("@#{value}", self.class.instance_variable_get("@#{value}") || name)
      end
    end

    def call
      # return false unless method(do_when_value).()

      @result = method(process_value).()
      @serialized = method(serialize_value).()

      @called = run_all_next

      @result
    end

    def serialize
      [@data, @result]
    end

    def process
      @data
    end

    def do_when
      true
    end

    def run_all_next
      callbacks.map { |arg| run_next(arg) }
    end

    def run_next(arg)
      inst = arg.new(@serialized)
      inst.()
      inst
    end
  end
end
# module AsyncFledgedable

# end

# module SchemaFledgedable
  
# end

# class FledgedA
#   include Fledgedable

#   def process
#     puts 'A'
#     {nameA: 'A'}
#   end
# end

# class FledgedB
#   include Fledgedable

#   push_to_queue FledgedA

#   def process
#     puts 'B'
#     {nameB: 'B'}
#   end
# end

# class FledgedC < FledgedB
#   def process
#     puts 'C'
#     {nameC: 'C'}
#   end
# end

# class FledgedD < FledgedB
#   push_to_queue FledgedC

#   def process
#     puts 'D'
#     {nameD: 'D'}
#     super

#     push_to_queue FledgedA
#   end

# end

# r = FledgedD.new({asd: 33})

# r.()

# def rec(op)
#   p op
#   p ''
#   op&.called&.map { |s| rec(s) }
# end

# rec(r)


class Scheme
  scheme do # |args|
    run Job2
    run Job3
    run Job1, before: [Job2], after: [Job3] # , params: {} ?

    jobs_list = args.collection.map do |item|
      run Job5, params: item
    end

    run Job4, after: jobs_list
  end

  # Job2 -> Job1 -> Job3 -> Job4
end

class Job1
  def perform
    params

    result() # pass result to next job or could just return
  end
end


# Scheme could be job too, and should be run in queue. Could or Should??? 
# Should be everytime 