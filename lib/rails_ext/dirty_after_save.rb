module DirtyAfterSave
  DIRTY_AFTER_SAVE_SUFFIXES = ['_changed_before_save?', '_change_before_save']
  
  def self.included(base)
    base.class_eval do
      attr_accessor :changed_attributes_before_save
      before_save { |build| build.changed_attributes_before_save = build.changes }
      
      attribute_method_suffix *DIRTY_AFTER_SAVE_SUFFIXES
    end
  end

private
  def attribute_changed_before_save?(attr)
    changed_attributes_before_save.include?(attr)
  end
  
  def attribute_change_before_save(attr)
    [changed_attributes_before_save[attr], __send__(attr)] if attribute_changed_before_save?(attr)
  end
end

ActiveRecord::Base.send :include, DirtyAfterSave
