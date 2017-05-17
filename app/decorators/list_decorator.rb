module ListDecorator
  extend ActiveSupport::Concern

  include ApplicationHelper

  class_methods do
    @@_filter_keys = []
    
    def set_filter_keys(keys)
      @@_filter_keys = keys

      keys.each do |key|
        self.send(:define_method, key) {
          filter_index(key)
        }
      end
    end
  end
  included do
    delegate_all
  end
  def filter_index(key)
    h.link_to_index(model[key], parameters: h.params.permit(@@_filter_keys).merge(key => model[key]))
  end
end
