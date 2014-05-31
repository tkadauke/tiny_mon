require 'lhm'

class CleanupAfterLhm1 < ActiveRecord::Migration
  def up
    Lhm.cleanup(true)
  end

  def down
  end
end
