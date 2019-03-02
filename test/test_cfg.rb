require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'

# build following grammar:
# A -> x B A | eps
# B -> y B

t_x = GrammarSymbol.new(:terminal, 'x')
t_y = GrammarSymbol.new(:terminal, 'y')

nt_a = GrammarSymbol.new(:nonterminal, 0)
nt_b = GrammarSymbol.new(:nonterminal, 1)

r1 = GrammarRule.new(nt_a, [t_x, nt_b, nt_a])
r2 = GrammarRule.new(nt_b, [t_y, nt_b])

grammar = CFG.new([r1, r2], nt_a)
print grammar

nt_c = GrammarSymbol.new(:nonterminal, 2)
r1_replacement = GrammarRule.new(nt_a, [t_x, nt_b, nt_a, nt_c])
r3 = GrammarRule.new(nt_c, [t_x, nt_c])

grammar.remove_rule(grammar.rules[0])
grammar.add_rule(r1_replacement)
grammar.add_rule(r3)
print grammar
p grammar.nonterminals.size
p "deepcopy:"
print grammar.deepcopy.to_s
p grammar.equal?(grammar.deepcopy)
