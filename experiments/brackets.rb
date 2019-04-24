require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../sentence_generator.rb'
require_relative '../gnf2cnf.rb'
require_relative '../cyk.rb'
require_relative '../genetic_inducer.rb'

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

brackets_source = CFG.new([r0, r1, r2, r3], nt_s)
brackets_cnf = GNF2CNF.convert(brackets_source)

p "Generating examples..."
# generate 100 positive examples
sp = []
pos_gen = SentenceGenerator.new(brackets_source, 0.25)
100.times {
    sp << pos_gen.get_random
}

# generate 100 negative examples
sn = []
100.times {
    postive_sample = pos_gen.get_random
    negative_sample = postive_sample.chars.shuffle.join
    while CYK.parse(brackets_cnf, negative_sample) do
        # keep shuffling until the sample is no longer parsed
        negative_sample = negative_sample.chars.shuffle.join
    end
    sn << negative_sample
}

inducer = GeneticInducer.new(
    brackets_source.terminals.to_a.map { |t| t.value },
    brackets_source.nonterminals.size,
    brackets_source.rules.size,
    4,
    1000,
    0.4,
    50,
    100,
    sp,
    sn
)

p "Inducing..."
hypothesis = inducer.induce
