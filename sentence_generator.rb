class SentenceGenerator

    def initialize(grammar, conv_factor)
        @grammar = grammar.freeze
        @convergence = conv_factor.freeze
    end

    def get_random(symbol = @grammar.start_sym, 
                   c = @convergence, 
                   rule_count = Hash.new(0))
        sentence = ''
        weights = []
        applicable_rules = @grammar.rules.filter { |rule| rule.lhs == symbol }
        applicable_rules.each { |rule| 
            if rule_count.key?(rule)
                weights << c ** rule_count[rule]
            else
                weights << 1.0
            end
        }
        rand_rule = applicable_rules[weighted_choice(weights)]
        rule_count[rand_rule] += 1
        rand_rule.rhs.each { |sym| 
            if sym.type == :nonterminal
                sentence << get_random(sym, c, rule_count)
            else
                sentence << "#{sym}"
            end
        }

        # backtrack
        rule_count[rand_rule] -= 1
        return sentence
    end

    private
        def weighted_choice(weights)
            rnd = rand() * weights.reduce(:+)
            weights.each_with_index { |w, i| 
                rnd -= w
                return i if rnd < 0
            }
        end
end
