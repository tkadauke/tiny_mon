class AddAccountIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :account_id, :integer
    
    add_index :comments, :account_id
    add_index :comments, [:account_id, :created_at]
    
    Comment.reset_column_information
    Comment.find(:all, :include => :check_run).each do |comment|
      comment.update_attribute(:account_id, comment.check_run.account_id)
    end
  end

  def self.down
    remove_column :comments, :account_id
  end
end
