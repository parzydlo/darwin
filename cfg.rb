class CFG
    # This class does not validate a grammar. It is responsibility of the 
    # caller to ensure legality of operations like adding / removing rules.
    # This class does not assume the grammar to be in any particular form.
    # The only assumption about a grammar is that it is valid inbetween
    # modifications.

    attr_reader :rules, :nt_count

    def initialize(rules)
        @rules = rules
        initialize_nt_count
    end

    def add_rule(rule)
        # check whether NT on LHS was already present in the grammar 
        @rules.each_with_index { |old_rule, i| 
            if old_rule.lhs.equal?(rule.lhs)
                # rule does not introduce a new NT
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
            return if old_rule.lhs.equal?(rule.lhs)
        }
        # last occurrence removed
        update_nt_count(-1)
    end

    def deepcopy
        return CFG.new(@rules.map(&:deepcopy))
    end

    def to_s
        @rules.reduce("") { |repr, rule| 
            repr + "#{rule}\n"
        }
    end

    private
        def initialize_nt_count
            # count non-terminals
            counts = Hash.new(0)
            @rules.each { |rule| 
                counts[rule.lhs] += 1
                rule.rhs.each { |rhs_sym| counts[rhs_sym] += 1 if rhs_sym.type == :nonterminal }
            }
            @nt_count = counts.size
        end

        def update_nt_count(delta)
            @nt_count += delta
        end
end
