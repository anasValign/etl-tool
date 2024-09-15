class CreateApiRepositories < ActiveRecord::Migration[7.1]
  def change
    create_table :api_repositories do |t|
      t.string :api_name, null: false
      t.string :base_url, null: false
      t.string :data_center

      t.timestamps
    end
  end
end
