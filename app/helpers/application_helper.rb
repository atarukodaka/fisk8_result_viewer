module TableHelper
  def tr_data(header, *data)
    content_tag(:tr) do
      concat(content_tag(:header, (header.class == Symbol) ? header.to_s.humanize : header))
      [data].flatten.map { |t|
        concat(content_tag(:td, t))
      }
    end
  end
end

module ApplicationHelper
  include LinkToHelper, TableHelper, FormHelper
end
