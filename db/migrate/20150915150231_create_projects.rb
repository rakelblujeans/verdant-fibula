class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.float :target_amount
			t.references :contributions, index: true
      t.timestamps null: false
    end

    create_table :backers do |t|
      t.string :full_name
      t.references :contributions, index: true
      t.timestamps null: false
    end

    create_table :contributions do |t|
      t.float :amount
      t.integer :credit_card_num
      t.belongs_to :project
      t.belongs_to :backer
      t.timestamps null: false
    end
  end
end
