module Fisk8ResultViewer
  module Adaptor
    class ScoreAdaptor
      def initialize(hash)
        score = ::Score.new(hash.except(:elements, :components))
        score.skater_name = ::Skater.correct_name(score.skater_name)
        cr = score.competition.category_results.find_by(skater_name: score.skater_name) || raise
        score.skater = cr.skater
        score.skater_name = score.skater.name

        ActiveRecord::Base.transaction {
          cr.skater.scores << score
          cr.scores << score
          score.competition.scores << score

          hash[:elements].map {|e| score.elements.create(e)}
          hash[:components].map {|e| score.components.create(e)}
          score.save!                    
        }
        @model = score
      end
      def to_model
        @model
      end
    end
  end
end

