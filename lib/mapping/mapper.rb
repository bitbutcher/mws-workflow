module Mapping

  class Mapper

    def initialize(strategies=[])
      @strategies = strategies
    end

    def <<(strategy)
      @strategies << strategy
    end

    def map(source)
      strategy = @strategies.find { |it| it[:selector].call source }
      self.class.map(source, strategy[:rules]) unless strategy.nil?
    end

    def self.map(source, rules=nil, &rules_block)
      result = {}
      rules ||= rules_block if block_given?
      raise 'Mapping requires a rules Proc or block' if rules.nil?
      Target.new(source, result).instance_exec &rules 
      result
    end

    class Target

      def initialize(source, target, context=[])
        @source = source
        @target = target
        @context = context
      end

      def method_missing(method, *args, &block)
        return apply_value context, method, args[0] unless args.empty?
        target = self.class.new @source, @target, [ @context, method ].compact.flatten
        return target unless block_given?

        retriever = Retriever.new(@source)
        retriever.instance_exec &block
        
        apply_value context, method, retriever.get    
      end

      private 

      def apply_value(context, name, value)
        parent = @target
        @context.each do | param |
          parent = parent.include?(param) ? parent[param] : (parent[param] = {})
        end
        parent[name] = value
      end

    end

    class Retriever

      def initialize(source)
        @source = source
      end

      def get
        return @child.get unless @child.nil?
        @source
      end

      def method_missing(method, *args, &block)
        raise "Invalid parameter '#{method}' in context '#{@source}'" unless @source.include? method.to_s
        value = @source[method.to_s]
        @child = value.kind_of?(Array) ? ArrayRetriever.new(value) : Retriever.new(value)
      end

    end

    class ArrayRetriever

      def initialize(source)
        @source = source
      end

      def get
        return  @children.map do | child |
          child.get
        end unless @children.nil?
        return @child.get unless @child.nil?
        @source
      end

      def method_missing(method, *args, &block)
        unless args.empty?
          child = @source.find { | child | child[method.to_s] == args[0] }
          raise "Invalid parameter '#{method}' in context '#{child}'" if child.nil?
          @child = SearchRetriever.new(child,  method.to_s)
        else 
          @children = []
          @source.each do | child |
            raise "Invalid parameter '#{method}' in context '#{child}'" unless child.include? method.to_s
            @children << Retriever.new(child[method.to_s])
          end
        end
      end

    end

  end

end