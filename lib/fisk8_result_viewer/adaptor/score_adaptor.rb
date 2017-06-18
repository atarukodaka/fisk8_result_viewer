module Fisk8ResultViewer
  module Adaptor
    class ScoreAdaptor
      def find_relevant_category_result(category_results, skater_name, segment, ranking)
        ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
        category_results.find_by(skater_name: skater_name) || 
          category_results.where(ranking_type => ranking).first
      end
                                        
      def initialize(hash)
        score = ::Score.new(hash.except(:elements, :components))
        score.skater_name = ::Skater.correct_name(score.skater_name)
        cr = find_relevant_category_result(score.competition.category_results, score.skater_name, hash[:segment], hash[:ranking]) ||  raise('cannot find relevant category results')
        score.skater = cr.skater
        score.skater_name = score.skater.name

        cr.skater.scores << score
        cr.scores << score
        score.competition.scores << score
        
        hash[:elements].map {|e| score.elements.new(e)}
        hash[:components].map {|e| score.components.new(e)}
        @model = score
      end
      def to_model
        @model
      end
    end
  end
end

