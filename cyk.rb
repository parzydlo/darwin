class CYK
    # checks whether a grammar accepts given string
    # assumes input grammar to be in CNF

    def self.parse(grammar, string)
        n = string.length
        r = grammar.nonterminals.size
        # create n x n x r matrix
        tbl = Array.new(n, Array.new(n, Array.new(r, false)))
        (0...n).each { |s| 
            grammar.rules.each { |rule| 
                # check if rule is unit production: A -> b
                next unless rule.rhs.size == 1
                unit_terminal = rule.rhs[0]
                if unit_terminal.value == string[s]
                    v = grammar.nonterminals.index(rule.lhs)
                    tbl[0][s][v] = true
                end
            }
        }
        (1...n).each { |l| 
            (0...n - l + 1).each { |s| 
                (0..l - 1).each { |p| 
                    # enumerate over A -> B C rules, where A, B and C are
                    # indices in array of NTs
                    grammar.rules.each { |rule| 
                        next unless rule.rhs.size == 2
                        a = grammar.nonterminals.index(rule.lhs)
                        b = grammar.nonterminals.index(rule.rhs[0])
                        c = grammar.nonterminals.index(rule.rhs[1])
                        if tbl[p][s][b] and tbl[l - p][s + p][c]
                            tbl[l][s][a] = true
                        end
                    }
                }
            }
        }
        return tbl[n - 1][0][0]
    end
end
