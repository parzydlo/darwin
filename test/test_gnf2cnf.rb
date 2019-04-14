require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../gnf2cnf.rb'

# BRACKETS grammar in GNF:
# S -> ( R
# S -> ( R S
# R -> ( R R
# R -> )

nt_s = GrammarSymbol.new(:nonterminal, 'S')
nt_r = GrammarSymbol.new(:nonterminal, 'R')
t_0 = GrammarSymbol.new(:terminal, '(')
t_1 = GrammarSymbol.new(:terminal, ')')

r0 = GrammarRule.new(nt_s, [t_0, nt_r])
r1 = GrammarRule.new(nt_s, [t_0, nt_r, nt_s])
r2 = GrammarRule.new(nt_r, [t_0, nt_r, nt_r])
r3 = GrammarRule.new(nt_r, [t_1])

gnf_grammar = CFG.new([r0, r1, r2, r3], nt_s)
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
