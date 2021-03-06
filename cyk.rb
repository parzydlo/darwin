class CYK
    # checks whether a grammar accepts given string
    # assumes input grammar to be in CNF

    def self.parse(grammar, string)
        nonterminals = grammar.nonterminals.to_a
        terminals = grammar.terminals.to_a
        n = string.length
        r = nonterminals.size
        # create n x n x r matrix
        tbl = Array.new(n) { |_| Array.new(n) { |_| Array.new(r, false) } }
        (0...n).each { |s| 
            grammar.rules.each { |rule| 
                # check if rule is unit production: A -> b
                next unless rule.rhs.size == 1
                unit_terminal = rule.rhs[0]
                if unit_terminal.value == string[s]
                    v = nonterminals.index(rule.lhs)
                    tbl[0][s][v] = true
                end
            }
        }
        (2..n).each { |l|
            (0...n - l + 1).each { |s|
                (1..l - 1).each { |p| 
                    grammar.rules.each { |rule|
                        next unless rule.rhs.size == 2
                        a = nonterminals.index(rule.lhs)
                        b = nonterminals.index(rule.rhs[0])
                        c = nonterminals.index(rule.rhs[1])
                        if tbl[p - 1][s][b] and tbl[l - p - 1][s + p][c]
                            tbl[l - 1][s][a] = true
                        end
                    }
                }
            }
        }
        v = nonterminals.index(grammar.start_sym)
        return tbl[n - 1][0][v]
    end
end
