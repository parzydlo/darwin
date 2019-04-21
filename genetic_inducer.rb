# HYPERPARAMETERS:
# nt_count -> number of nonterminals
# rule_count -> number of rules
# max_rhs_list_len -> maximal number of nonterminals on the RHS of a rule
# population_size -> number of chromosomes in population at any time
# generations -> number of iterations after which search is terminated

class GeneticInducer

    def initialize(alphabet, nt_count, rule_count, max_rhs_list_len, mutation_prob, reproduction_fact, population_size, generations, sp, sn)
        @alphabet = alphabet.freeze
        @nt_count = nt_count.freeze
        @rule_count = rule_count.freeze
        @max_rhs_list_len = max_rhs_list_len.freeze
        @mutation_probability = mutation_prob.freeze
        @reproduction_factor = reproduction_fact.freeze
        @population_size = population_size.freeze
        @generations = generations.freeze
        @sp = sp.freeze
        @sn = sn.freeze
    end

    def induce
        @population_table = generate_population
        curr_generation = 0
        while curr_generation != @generations do
            # reproduction and mutation should be responsible for updating
            # fitness scores when neccessary
            perform_reproduction
            perform_mutation
            perform_natural_selection
            top_fit = @population_table.max_by { |_, fitness| fitness }
            p "Generation: #{curr_generation} --- Top fitness: #{top_fit[1]}"
            curr_generation += 1
        end
        return top_fit
    end

    def score_population
        scores = @population.reduce({}) { |memo, chromosome| 
            memo[chromosome] = fitness(chromosome)
        }
    end

    def perform_natural_selection
        # keeps population size fixed by getting rid of least fit chromosomes
        @population_table = @population_table.sort_by { |_, fitness| -fitness }[0...@population_size].to_h
    end

    def generate_population
        # return a collection of CFGs of size @population_size
        # each CFG should have @rule_count rules, @nt_count nonterminals
        # and at most @max_rhs_list_len RHS variables
        p "Generating initial population..."
        population = Hash.new
        curr_pop_size = 0
        nonterminals = []
        # generate pool of nonterminals
        (0..@nt_count).each { |nt_num| 
            nt = GrammarSymbol.new(:nonterminal, nt_num.to_s)
            nonterminals << nt
        }
        # generate pool of terminals
        terminals = []
        @alphabet.each { |chr| 
            term = GrammarSymbol.new(:terminal, chr)
            terminals << term
        }
        while curr_pop_size != @population_size do
            # generate @rule_count rules, where:
            #  rule is in GNF
            #  one of nonterminals is randomly chosen as LHS
            #  one of terminals is randomly chosen as RHS[0]
            #  0..max_rhs_list_len nonterminals are randomly chosen for the
            #  rest of RHS
            begin
                rules = []
                start_sym = nil
                @rule_count.times {
                    lhs = nonterminals.sample
                    start_sym ||= lhs
                    term = terminals.sample
                    rhs = [term] + nonterminals.sample(rand(@max_rhs_list_len))
                    rules << GrammarRule.new(lhs, rhs)
                }
                grammar = CFG.new(rules, start_sym)
                fitness_value = fitness(grammar)
            rescue
                p "!!! invalid grammar generated - dropping chromosome !!!"
            else
                population[grammar] = fitness_value
                curr_pop_size += 1
            end
        end
        p "Done generating population."
        return population
    end

    def fitness(chromosome)
        # the fitness of a chromosome is the score accumulated by parsing
        # positive and negative samples
        cnf_repr = GNF2CNF.convert(chromosome)
        score = 0
        @sp.each { |input_string| 
            begin
                if CYK.parse(cnf_repr, input_string)
                    score += 1
                else
                    score -= 1
                end
            rescue
                p "!!! failed parsing #{input_string} using following grammar: !!!"
                print "#{cnf_repr}"
                score -= 100
            end
        }
        @sn.each { |input_string| 
            begin
                if !CYK.parse(cnf_repr, input_string)
                    score += 1
                else
                    score -= 1
                end
            rescue
                p "!!! failed parsing #{input_string} using following grammar: !!!"
                print "#{cnf_repr}"
                score -= 100
            end
        }
        return score
    end

    def perform_mutation
        # mutation does not rely on fitness scores
        @population_table.each { |grammar, fitness| 
            # mutate each production rule with probability 1/200
            terminals = grammar.terminals.to_a
            nonterminals = grammar.nonterminals.to_a
            grammar.rules.each { |rule| 
                if rand(@mutation_probability) == 0
                    # swap one of the symbols on RHS
                    index = rand(rule.rhs.size)
                    if rule.rhs[index].type == :terminal
                        rule.rhs[index] = terminals.sample
                    else
                        rule.rhs[index] = nonterminals.sample
                    end
                end
            }
            @population_table[grammar] = fitness(grammar)
        }
    end

    def perform_reproduction
        crossover = lambda { |p1, p2| 
            # choose rule before which the cut is made
            rule_pivot_lim = [p1.rules.size, p2.rules.size].min
            rule_pivot = rand(rule_pivot_lim)
            # count possible cuts:
            #  before rule_pivot, between LHS and RHS of rule_pivot,
            #  between any of the symbols on RHS of pivot_rule
            #  (if the shorter RHS has k symbols, there are k - 1 cuts)
            inner_pivot_lim = 2 + [p1.rules[rule_pivot].rhs.size, p2.rules[rule_pivot].rhs.size].min - 1
            inner_pivot = rand(inner_pivot_lim)
            case inner_pivot
            when 0
                # cut before rule at rule_pivot
                rules1 = p1.rules[0...rule_pivot] + p2.rules[rule_pivot..]
                rules2 = p2.rules[0...rule_pivot] + p1.rules[rule_pivot..]
            when 1
                # cut between LHS and RHS of rule at rule_pivot
                # first child
                head1 = p1.rules[0...rule_pivot]
                head1 ||= []
                split_rule1 = GrammarRule.new(
                    p1.rules[rule_pivot].lhs,
                    p2.rules[rule_pivot].rhs
                )
                tail1 = p2.rules[rule_pivot + 1..]
                tail1 ||= []
                # second child
                head2 = p2.rules[0...rule_pivot]
                head2 ||= []
                split_rule2 = GrammarRule.new(
                    p2.rules[rule_pivot].lhs,
                    p1.rules[rule_pivot].rhs
                )
                tail2 = p1.rules[rule_pivot + 1..]
                tail2 ||= []
                rules1 = head1 + [split_rule1] + tail1
                rules2 = head2 + [split_rule2] + tail2
            else
                # cut between symbols on RHS of rule at rule_pivot
                rhs_pivot = inner_pivot - 2
                # first child
                head1 = p1.rules[0...rule_pivot]
                head1 ||= []
                rhs_head1 = p1.rules[rule_pivot].rhs[0...rhs_pivot]
                rhs_head1 ||= []
                rhs_tail1 = p2.rules[rule_pivot].rhs[rhs_pivot..]
                rhs_tail1 ||= []
                split_rule1 = GrammarRule.new(
                    p1.rules[rule_pivot].lhs,
                    rhs_head1 + rhs_tail1
                )
                tail1 = p2.rules[rule_pivot + 1..]
                tail1 ||= []
                # second child
                head2 = p2.rules[0...rule_pivot]
                head2 ||= []
                rhs_head2 = p2.rules[rule_pivot].rhs[0...rhs_pivot]
                rhs_head2 ||= []
                rhs_tail2 = p1.rules[rule_pivot].rhs[rhs_pivot..]
                rhs_tail2 ||= []
                split_rule2 = GrammarRule.new(
                    p2.rules[rule_pivot].lhs,
                    rhs_head2 + rhs_tail2
                )
                tail2 = p1.rules[rule_pivot + 1..]
                tail2 ||= []
                rules1 = head1 + [split_rule1] + tail1
                rules2 = head2 + [split_rule2] + tail2
            end
            start1 = rules1[0].lhs
            start2 = rules2[0].lhs
            c1 = CFG.new(rules1, start1)
            c2 = CFG.new(rules2, start2)
            return c1, c2
        }
        # fetch fittest subset of population and apply one-point crossover
        # to produce 2 offspring per pair
        n = (@population_size * @reproduction_factor).floor
        n += 1 if n % 2 == 1
        fittest_pool = @population_table.sort_by { |_, fitness| -fitness }[0...n].to_h.keys
        (0...n).step(2) { |i| 
            parent1 = fittest_pool[i]
            parent2 = fittest_pool[i + 1]
            child1, child2 = crossover[parent1, parent2]
            @population_table[child1] = fitness(child1)
            @population_table[child2] = fitness(child2)
        }
    end
end
