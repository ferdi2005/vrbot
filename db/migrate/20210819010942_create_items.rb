class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :title
      t.string :url
      t.decimal :lat
      t.decimal :long

      t.timestamps
    end
  end
end
