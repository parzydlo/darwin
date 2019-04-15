require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../sentence_generator.rb'

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

brackets = CFG.new([r0, r1, r2, r3], nt_s)

brackets_gen = SentenceGenerator.new(brackets, 0.50)
10.times {
    p brackets_gen.get_random
}
