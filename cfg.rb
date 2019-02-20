class CFG
    # grammar is represented as a list of rules
    # each rule is stored as a hash (k, v), where:
    # k - GrammarSymbol (non-terminal)
    # v - list of GrammarSymbols (any)
    #
    # nt_count - keeps track of the number of NTs
    #
    # This class does not validate a grammar. It is responsibility of the 
    # caller to ensure legality of operations like adding / removing rules.

    attr_reader :rules, :nt_count

    def initialize(rules)
        @rules = rules
        initialize_nt_count
    end

    def add_rule(rule)
        # check whether NT on LHS was already present in the grammar 
        @rules.each { |old_rule| 
            if old_rule.key == rule.key
                # rule does not feature a new NT
                @rules << rule
                return
            end
        }
        # rule features a new NT
        @rules << rule
        update_nt_count(1)
    end

    def remove_rule(rule)
        @rules.delete(rule)
        # check whether NT on LHS is no longer present in the grammar
        @rules.each { |old_rule| 
            # still present
            return if old_rule.key == rule.key
        }
        # last occurrence removed
        update_nt_count(-1)
    end

    def copy
        Marshal.load(Marshal.dump(self))
    end

    private
        def initialize_nt_count
            # count non-terminals
            @nt_count = @rules.keys.reduce { |memo, nt| nt.value > memo.value ? nt : memo }
        end

        def update_nt_count(delta)
            @nt_count += delta
        end
end
