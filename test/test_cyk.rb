require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../cyk.rb'

# build following CNF grammar:
# A -> B C | eps
# B -> x
# C -> y

t_x = GrammarSymbol.new(:terminal, 'x')
t_y = GrammarSymbol.new(:terminal, 'y')

nt_a = GrammarSymbol.new(:nonterminal, 'A')
nt_b = GrammarSymbol.new(:nonterminal, 'B')
nt_c = GrammarSymbol.new(:nonterminal, 'C')

r1 = GrammarRule.new(nt_a, [nt_b, nt_c])
r2 = GrammarRule.new(nt_b, [t_x])
r3 = GrammarRule.new(nt_c, [t_y])

grammar = CFG.new([r1, r2, r3], nt_a)

result = CYK.parse(grammar, "xy")
pp result
