require 'set'

class CFG
    # This class does not validate a grammar. It is responsibility of the 
    # caller to ensure legality of operations like adding / removing rules.
    # This class does not assume the grammar to be in any particular form.
    # The only assumption about a grammar is that it is valid inbetween
    # modifications.

    attr_reader :rules, :start_sym, :nonterminals, :terminals

    def initialize(rules, start)
        @rules = rules
        @start_sym = start
        @terminals = collect_symbols(:terminal)
        @nonterminals = collect_symbols(:nonterminal)
    end

    def add_rule(rule)
        # add all symbols to t/nt sets
        @nonterminals.add(rule.lhs)
        rule.rhs.each { |rhs_sym| 
            rhs_sym.type == :terminal ? @terminals.add(rhs_sym) : @nonterminals.add(rhs_sym)
        }
        @rules << rule
    end

    def remove_rule(rule)
        @rules.delete(rule)
        # check whether NT on LHS is no longer present in the grammar
        @rules.each { |old_rule| 
            if old_rule.lhs == rule.lhs
                # still present
                return
            end
        }
        # last occurrence removed
        @nonterminals.delete(rule.lhs)
    end

    def copy
        return CFG.new(@rules.map(&:copy), @start_sym)
    end

    def to_s
        "Start NT: #{@start_sym}\n" + @rules.reduce("") { |repr, rule| 
            repr + "#{rule}\n"
        }
    end

    private
        def collect_symbols(type=nil)
            symbols = Set.new
            @rules.each { |rule| 
                symbols.add(rule.lhs) if type == :nonterminal or type.nil?
                rule.rhs.each { |rhs_sym| 
                    if rhs_sym.type == type or type.nil?
                        symbols.add(rhs_sym)
                    end
                }
            }
            return symbols
        end
end
