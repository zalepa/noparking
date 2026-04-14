class AddAssignmentToIssues < ActiveRecord::Migration[8.1]
  def change
    add_reference :issues, :assigned_to, foreign_key: { to_table: :users }
    add_column    :issues, :assigned_at, :datetime
  end
end
