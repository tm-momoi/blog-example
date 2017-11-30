class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :writer
      t.text :contents
      t.boolean :memberOnly
      t.date :created_at
      t.date :updated_at

      t.timestamps
    end
  end
end
