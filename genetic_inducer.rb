# HYPERPARAMETERS:
# nt_count -> number of nonterminals
# rule_count -> number of rules
# max_rhs_list_len -> maximal number of nonterminals on the RHS of a rule
# population_size -> number of chromosomes in population at any time
# generations -> number of iterations after which search is terminated

class GeneticInducer

    def initialize(alphabet, nt_count, rule_count, max_rhs_list_len, population_size, generations)
        @alphabet = alphabet.freeze
        @nt_count = nt_count.freeze
        @rule_count = rule_count.freeze
        @max_rhs_list_len = max_rhs_list_len.freeze
        @population_size = population_size.freeze
        @generations = generations.freeze
    end

    def induce
        @population_table = generate_population
        curr_generation = 0
        loop {
            break if curr_generation >= @generations
            # reproduction and mutation should be responsible for updating
            # fitness scores when neccessary
            perform_reproduction
            perform_mutation
            perform_natural_selection
            top_fit = @population_table.max_by { |_, fitness| fitness }
        }
        return top_fit
    end

    def score_population
        scores = @population.reduce({}) { |memo, chromosome| 
            memo[chromosome] = fitness(chromosome)
        }
    end

    def perform_natural_selection
        # keeps population size fixed by getting rid of least fit chromosomes
        delta = @population_size - @population_table.size
        scores = @population_table.values.sort
        threshold = scores[-delta]
        @population_table = @population_table.filter { |_, fitness| fitness > threshold }
    end

    def generate_population
        # return a collection of CFGs of size @population_size
        # each CFG should have @rule_count rules, @nt_count nonterminals
        # and at most @max_rhs_list_len RHS variables
        population = []
        nonterminals = []
        # generate pool of nonterminals
        (0..@nt_count).each { |nt_num| 
            nt = GrammarSymbol.new(:nonterminal, nt_num)
            nonterminals << nt
        }
        # generate pool of terminals
        terminals = []
        @alphabet.each { |chr| 
            term = GrammarSymbol.new(:terminal, chr)
            terminals << term
        }
        @population_size.times {
            # generate @rule_count rules, where:
            #  rule is in GNF
            #  one of nonterminals is randomly chosen as LHS
            #  one of terminals is randomly chosen as RHS[0]
            #  0..max_rhs_list_len nonterminals are randomly chosen for the
            #  rest of RHS
            rules = []
            start_sym = nil
            @rule_count.times {
                lhs = nonterminals.sample
                start_sym = lhs if start_sym.nil?
                term = terminals.sample
                rhs = [term] + nonterminals.sample(rand(@max_rhs_list_len))
                rules << GrammarRule.new(lhs, rhs)
            }
            grammar = CFG.new(rules, start_sym)
            @population_table[grammar] = fitness(grammar)
        }
    end

    def fitness(chromosome)
        # the fitness of a chromosome is the score accumulated by parsing
        # positive and negative samples
        cnf_repr = GNF2CNF.convert(chromosome)
        score = 0
        @samples.each { |input_string, label| 
            if CYK.parse(cnf_repr, input_string)
                label ? score += 1 : score -= 1
            else
                !label ? score += 1 : score -= 1
            end
        }
        return score
    end

    def perform_mutation
        # mutation does not rely on fitness scores
        @population_table.each { |grammar, fitness| 
            # mutate each production rule with probability 1/200
            grammar.rules.each { |rule| 
                if rand(200) == 0
                    # swap one of the symbols on RHS
                    index = rand(rule.rhs.size)
                    if index == 0
                        replacement = terminals.remove(rule.rhs[index]).sample
                        new_rhs = [replacement] + rule.rhs[1..]
                    elsif index == rule.rhs.size - 1
                        replacement = nonterminals.remove(rule.rhs[index]).sample
                        new_rhs = rule.rhs[0..rule.rhs.size - 1] + [replacement]
                    else
                        replacement = nonterminals.remove(rule.rhs[index]).sample
                        new_rhs = rule.rhs[0..index] + [replacement] + rule.rhs[index + 1..]
                    end
                    mutated_rule = GrammarRule.new(rule.lhs, new_rhs)
                    grammar.remove_rule(rule)
                    grammar.add_rule(mutated_rule)
                    # update fitness of mutated chromosome
                    @population_table[grammar] = fitness(grammar)
                end
            }
        }
    end

    def perform_reproduction
        crossover = lambda { |p1, p2| 
            outer_pivot_limit = [p1.rules.size, p2.rules.size].min
            outer_pivot = rand(outer_pivot_limit)
            # count possible cuts (before pivot rule, between LHS and RHS, length of RHS - 1)
            inner_pivot_limit = 1 + [p1.rules[pivot].rhs.size, p2.rules[pivot].rhs.size].min
            inner_pivot = rand(inner_pivot_limit)
            case inner_pivot
            when 0
                # cut before rule
                rules1 = p1.rules[0..outer_pivot] + p2.rules[outer_pivot..]
                rules2 = p2.rules[0..outer_pivot] + p1.rules[outer_pivot..]
            when 1
                # cut between LHS and RHS of rule
                pivot_rule1 = GrammarRule.new(p1.rules[outer_pivot].lhs,
                                              p2.rules[outer_pivot].rhs)
                pivot_rule2 = GrammarRule.new(p2.rules[outer_pivot].lhs,
                                              p1.rules[outer_pivot].rhs)
                rules1 = p1.rules[0..outer_pivot] + [pivot_rule1] + p2.rules[outer_pivot+1..]
                rules2 = p2.rules[0..outer_pivot] + [pivot_rule2] + p1.rules[outer_pivot+1..]
            else
                # cut after RHS[inner_pivot - 2]
                pivot_rule1 = GrammarRule.new(p1.rules[outer_pivot].lhs,
                                              p1.rules[outer_pivot].rhs[0..inner_pivot-2])
            end
        }
        # fetch fittest 10% of population and apply one-point crossover
        # to produce 2 offspring per pair
        n = (@population_size / 10).floor
        n += 1 if n % 2 == 1
        fittest_pool = @population_table.sort_by { |_, fitness| fitness }[0..n].to_h.keys.shuffle
        (0..n - 1).step(2) { |i| 
            parent1 = fittest[i]
            parent2 = fittest[i + 1]
            child1, child2 = crossover[parent1, parent2]
            @population_table[child1] = fitness(child1)
            @population_table[child2] = fitness(child2)
        }
    end
end
