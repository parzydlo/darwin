require_relative '../cfg.rb'
require_relative '../grammar_rule.rb'
require_relative '../grammar_symbol.rb'
require_relative '../sentence_generator.rb'
require_relative '../gnf2cnf.rb'
require_relative '../cyk.rb'
require_relative '../genetic_inducer.rb'

# AB grammar in GNF:
# S -> a B
# S -> b A
# A -> a
# A -> a S
# A -> b A A
# B -> b
# B -> b S
# B -> a B B

nt_s = GrammarSymbol.new(:nonterminal, 'S')
nt_a = GrammarSymbol.new(:nonterminal, 'A')
nt_b = GrammarSymbol.new(:nonterminal, 'B')
t_a = GrammarSymbol.new(:terminal, 'a')
t_b = GrammarSymbol.new(:terminal, 'b')

r0 = GrammarRule.new(nt_s, [t_a, nt_b])
r1 = GrammarRule.new(nt_s, [t_b, nt_a])
r2 = GrammarRule.new(nt_a, [t_a])
r3 = GrammarRule.new(nt_a, [t_a, nt_s])
r4 = GrammarRule.new(nt_a, [t_b, nt_a, nt_a])
r5 = GrammarRule.new(nt_b, [t_b])
r6 = GrammarRule.new(nt_b, [t_b, nt_s])
r7 = GrammarRule.new(nt_b, [t_a, nt_b, nt_b])
rules = [r0, r1, r2, r3, r4, r5, r6, r7]

ab_source = CFG.new(rules, nt_s)
ab_cnf = GNF2CNF.convert(ab_source)

p "Generating examples..."
# generate 100 positive examples
sp = []
pos_gen = SentenceGenerator.new(ab_source, 0.25)
100.times {
    sp << pos_gen.get_random
}

# generate 100 negative examples
sn = []
100.times {
    postive_sample = pos_gen.get_random
    negative_sample = postive_sample.chars.shuffle.join
    while CYK.parse(ab_cnf, negative_sample) do
        # keep shuffling until the sample is no longer parsed
        negative_sample = negative_sample.chars[0...negative_sample.size - 1].join
    end
    sn << negative_sample
}

inducer = GeneticInducer.new(
    ab_source.terminals.to_a.map { |t| t.value },
    ab_source.nonterminals.size,
    ab_source.rules.size,
    3,
    1000,
    0.3,
    50,
    100,
    sp,
    sn
)

p "Inducing grammar..."
best = inducer.induce
