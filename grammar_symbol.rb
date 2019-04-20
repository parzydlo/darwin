class GrammarSymbol
    # represents a symbol in a grammar
    # type - :terminal / :nonterminal
    # value - actual value of the symbol
    #         character (terminal)
    #         number (non-terminal)

    attr_accessor :type, :value

    def initialize(type, value)
        if [:terminal, :nonterminal].include? type
            @type = type
        else
            raise "#{type} is not a legal symbol type"
        end
        if value.class == String
            @value = value
        else
            raise "NT value needs to be of type String"
        end
    end

    def to_s
        case @type
        when :terminal
            "#{@value}"
        when :nonterminal
            "NT#{@value}"
        end
    end

    def eql?(other)
        other.instance_of?(self.class) && other.value == @value && other.type == @type
    end

    def deepcopy
        return GrammarSymbol.new(@type, @value)
    end
end
