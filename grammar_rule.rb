class GrammarRule
    attr_reader :lhs, :rhs

    def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
    end

    def to_s
        "#{lhs} -> #{rhs.reduce("") { |rhs_repr, rhs_sym| rhs_repr + "#{rhs_sym} " }}"
    end

    def deepcopy
        return GrammarRule.new(lhs.deepcopy, rhs.map(&:deepcopy))
    end
end
