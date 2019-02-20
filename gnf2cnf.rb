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
            perform_term
            perform_bin
            return @grammar
        end

        def perform_term
            # since input grammar is in GNF, it can be assumed that every RHS
            # features a single terminal and it is the first element of RHS
            @grammar.rules.each { |rule| term(rule) }
        end

        def term(rule)
            # input rule: A0 -> a A1 A2 ... AN
            old_terminal = rule.values[0]
            # 1. replace terminal with new non-terminal
            new_nt = generate_nt
            rule.values[0] = new_nt
            # 2. create new rule
            new_rule = {new_nt => [old_terminal]}
            # 3. append new rule to grammar
            @grammar.add_rule(new_rule)
        end

        def perform_bin
            # apply BIN to every rule whose RHS features more than 2 NTs
            @grammar.rules.each { |rule| 
                if rule.values.size > 2
                    bin(rule)
                end
            }
        end

        def bin(rule)
            # input rule: A0 -> A1 A2 ... AN | n > 3
            # 1. create new NT
            new_nt = generate_nt
            # 2. replace A2 ... AN with new NT
            tail = rule.values[1..]
            rule.values = [rule.values[0], new_nt]
            # 3. create new rule: B -> A2 ... AN
            new_rule = {new_nt => tail}
            @grammar.add_rule(new_rule)
        end

        def generate_nt
            value = @grammar.nt_count + 1
            return GrammarSymbol.new(:nonterminal, value)
        end
end
