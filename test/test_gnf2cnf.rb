require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../gnf2cnf.rb'

# create following GNF grammar:
# A -> x B A | eps
# B -> y B

nt_a = GrammarSymbol.new(:nonterminal, 0)
nt_b = GrammarSymbol.new(:nonterminal, 1)
t_x = GrammarSymbol.new(:terminal, 'x')
t_y = GrammarSymbol.new(:terminal, 'y')

r1 = GrammarRule.new(nt_a, [t_x, nt_b, nt_a])
r2 = GrammarRule.new(nt_b, [t_y, nt_b])

gnf_grammar = CFG.new([r1, r2], nt_a)
p gnf_grammar

# call GNF2CNF#convert to obtain CNF grammar

cnf_grammar = GNF2CNF.convert(gnf_grammar)
print cnf_grammar
# desired output:
# A -> C E
# B -> D B
# D -> y
# C -> x
# E -> B A
