# encoding: utf-8


class CreateExtras < ActiveRecord::Migration

  def up
    puts "hello from CreateExtras#up"

## store beer of days

create_table :days do |t|
  t.date       :date,  null: false
  t.references :beer,  null: false

  t.timestamps
end

  end


  def down
    raise ActiveRecord::IrreversibleMigration
  end

end # class CreateExtras

