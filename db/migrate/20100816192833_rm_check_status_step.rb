class RmCheckStatusStep < ActiveRecord::Migration
  def self.up
    # inject class into main namespace while not polluting it when other migrations run
    Object.const_set(:CheckStatusStep, Class.new(Step))

    CheckStatusStep.destroy_all
  end

  def self.down
  end
end
