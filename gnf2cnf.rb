require_relative './cfg.rb'
require_relative './grammar_symbol.rb'

class GNF2CNF
    # performs conversion from GNF to CNF
    # assumes input grammar to be in GNF
    # produces a new grammar instead of mutating the original
    def self.convert(gnf_grammar)
        new(gnf_grammar).send(:cnf)
    end

    private
        def initialize(input)
            @grammar = input.copy
        end

        def cnf
            post_term_rules = perform_term
            @grammar = CFG.new(post_term_rules, @grammar.start_sym)
            post_bin_rules = perform_bin
            @grammar = CFG.new(post_bin_rules, @grammar.start_sym)
            return @grammar
        end

        def perform_term
            # since input grammar is in GNF, it can be assumed that every RHS
            # features a single terminal and it is the first element of RHS
            curr_size = @grammar.nonterminals.size
            results = []
            @grammar.rules.each_with_index { |rule, i| 
                if rule.rhs.size == 1
                    # rule is: A -> b
                    # no need to increment NT counter
                    results << rule
                    next
                end
                # rule is: A -> b C D E ...
                # each terminal should yield a new rule
                # since original rules are in GNF, only one new rule gets
                # introduced
                old_terminal = rule.rhs[0]
                old_nts = rule.rhs[1..]
                new_nt = GrammarSymbol.new(:nonterminal, curr_size.to_s)
                replacement_rule = GrammarRule.new(rule.lhs, [new_nt] + old_nts)
                new_rule = GrammarRule.new(new_nt, [old_terminal])
                results << replacement_rule
                results << new_rule
                curr_size += 1
            }
            return results
        end

        def perform_bin
            # apply BIN to every rule whose RHS features more than 2 NTs
            # assumes each rule to be in post-TERM form:
            #     A -> b
            #     A -> A B C D ....
            curr_size = @grammar.nonterminals.size
            result = []
            unfolded = []
            unfold = lambda { |rule| 
                return rule if rule.rhs.size <= 2
                new_nt = GrammarSymbol.new(:nonterminal, curr_size.to_s)
                head = rule.rhs[0]
                tail = rule.rhs[1..]
                replacement_rule = GrammarRule.new(rule.lhs, [head, new_nt])
                unfolded << replacement_rule
                curr_size += 1
                new_rule = unfold[GrammarRule.new(new_nt, tail)]
                unfolded << new_rule
                return new_rule
            }
            @grammar.rules.each_with_index { |rule, i| 
                unfolded = []
                if rule.rhs.size <= 2
                    # rule is like: A -> b or A -> BC
                    # append original without modifying it
                    result << rule
                    next
                end
                unfold[rule]
                result += unfolded.flatten
            }
            return result
        end

        def generate_nt
            value = @grammar.nt_count + 1
            return GrammarSymbol.new(:nonterminal, value)
        end
end
