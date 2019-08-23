class ScoresController < IndexController
  def elements_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.elements)
      .columns([:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.components)
      .columns([:number, :name, :factor, :judges, :value])
  end

  def data_to_show
    score = Score.find_by!(name: params[:name])
    {
      score: score,
      elements: elements_datatable(score).update_settings(paging: false, info: false)
        .default_orders([[:number, :asc]]),
      components: components_datatable(score).update_settings(paging: false, info: false)
        .default_orders([[:number, :asc]]),
    }
  end
  def show
    begin
      super
    rescue ActionController::UnknownFormat
      respond_to do |format|
        format.xml {
          doc = Nokogiri::XML::Document.new

          Nokogiri::XML::Builder.with(doc) do |xml|
            score = Score.find_by!(name: params[:name])

            xml.score {
              xml.competition(name: score.competition.name)
              xml.category { xml.text score.category.name }
              xml.segment { xml.text score.segment.name }
              xml.skater(isu_number: score.skater.isu_number, nation: score.skater.nation) {
                xml.text score.skater.name
              }

              xml.ranking { xml.text score.ranking }
              xml.tss { xml.text score.tss }
              xml.tes { xml.text score.tes }
              xml.pcs { xml.text score.pcs }
              xml.deductions { xml.text score.deductions }

              xml.elements {
                score.elements.each.with_index(1) do |element, i|
                  xml.element(element.slice(:name, :base_value, :info, :credit).merge(number: i, judge_details: element[:judges]).compact){
                    xml.text element.value
                  }
                end
              }
              xml.components {
                score.components.each.with_index(1) do |component, i|
                  xml.component(component.slice(:name, :factor).merge(number: i, judge_details: component[:judges]).compact) {
                    xml.text component.value
                  }
                end
              }
            }
          end
          render xml: doc
        }
      end
    end
  end
end
