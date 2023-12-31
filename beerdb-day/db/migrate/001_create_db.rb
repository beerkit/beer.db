
class CreateDb < ActiveRecord::Migration

  def up
    puts "hello from CreateDb#up"

    LogDb.create           # logs table
    ConfDb.create          # props table
    TagDb.create           # tags n taggings tables
    WorldDb.create
    BeerDb.create
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end

