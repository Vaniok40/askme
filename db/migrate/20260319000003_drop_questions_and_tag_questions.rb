class DropQuestionsAndTagQuestions < ActiveRecord::Migration[6.0]
  def up
    drop_table :tag_questions, if_exists: true
    drop_table :questions,     if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
