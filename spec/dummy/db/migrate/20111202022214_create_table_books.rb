# frozen_string_literal: true

class CreateTableBooks < ActiveRecord::Migration[7.0]
  def up
    create_table :books do |t|
      t.string :name
      t.integer :pages
      t.datetime :published
    end
  end

  def down
    drop_table :books
  end
end
