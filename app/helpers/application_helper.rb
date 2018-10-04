module TableHelper
  def tr_data(th, *td)
    content_tag(:tr) do
      concat(content_tag(:th, (th.class == Symbol) ? th.to_s.humanize : th))
      [td].flatten.map { |t|
        concat(content_tag(:td, t))
      }
    end
  end
end

module ApplicationHelper
  include LinkToHelper, TableHelper, FormHelper
end
