class CFG
    # This class does not validate a grammar. It is responsibility of the 
    # caller to ensure legality of operations like adding / removing rules.

    attr_reader :rules, :nt_count

    def initialize(rules)
        @rules = rules
        rules.nil? ? @nt_count = 0 : initialize_nt_count
    end

    def add_rule(rule)
        # check whether NT on LHS was already present in the grammar 
        @rules.each { |old_rule| 
            if old_rule.lhs == rule.lhs
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
            return if old_rule.lhs == rule.lhs
        }
        # last occurrence removed
        update_nt_count(-1)
    end

    def copy
        Marshal.load(Marshal.dump(self))
    end

    def to_s
        @rules.reduce("") { |repr, rule| 
            repr + "#{rule}\n"
        }
    end

    private
        def initialize_nt_count
            # count non-terminals
            @nt_count = @rules.reduce(0) { |memo, rule| rule.lhs.value + memo }
        end

        def update_nt_count(delta)
            @nt_count += delta
        end
end
