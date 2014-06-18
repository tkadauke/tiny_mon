require 'lhm'
class CleanupAfterLhm1 < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      Lhm.cleanup(true)
    end
  end

  def down
  end
end
