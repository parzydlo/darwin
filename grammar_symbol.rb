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
        @value = value
    end
end
