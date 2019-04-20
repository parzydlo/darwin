require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../cyk.rb'

# BRACKETS grammar in CNF:
# NTS -> NT9 NTR
# NT9 -> (
# NTS -> NT10 NT12
# NT12 -> NTR NTS
# NT10 -> (
# NTR -> NT11 NT13
# NT13 -> NTR NTR
# NT11 -> (
# NTR -> )

nt_s = GrammarSymbol.new(:nonterminal, "S")
nt_r = GrammarSymbol.new(:nonterminal, "R")
nt_9 = GrammarSymbol.new(:nonterminal, "9")
nt_10 = GrammarSymbol.new(:nonterminal, "10")
nt_11 = GrammarSymbol.new(:nonterminal, "11")
nt_12 = GrammarSymbol.new(:nonterminal, "12")
nt_13 = GrammarSymbol.new(:nonterminal, "13")
t_0 = GrammarSymbol.new(:terminal, "(")
t_1 = GrammarSymbol.new(:terminal, ")")

r_0 = GrammarRule.new(nt_s, [nt_9, nt_r])
r_1 = GrammarRule.new(nt_9, [t_0])
r_2 = GrammarRule.new(nt_s, [nt_10, nt_12])
r_3 = GrammarRule.new(nt_12, [nt_r, nt_s])
r_4 = GrammarRule.new(nt_10, [t_0])
r_5 = GrammarRule.new(nt_r, [nt_11, nt_13])
r_6 = GrammarRule.new(nt_13, [nt_r, nt_r])
r_7 = GrammarRule.new(nt_11, [t_0])
r_8 = GrammarRule.new(nt_r, [t_1])

grammar = CFG.new([r_0, r_1, r_2, r_3, r_4, r_5, r_6, r_7, r_8], nt_s)

result = CYK.parse(grammar, "(())()")
pp result
