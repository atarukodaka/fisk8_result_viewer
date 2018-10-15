class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ## utils
  def slice_common_attributes(hash)
    hash.slice(*self.class.column_names.map(&:to_sym) & hash.keys)
  end

  def update_common_attributes(hash)
    update(slice_common_attributes(hash))
  end
end
