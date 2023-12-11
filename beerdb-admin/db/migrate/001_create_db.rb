
class CreateDb < ActiveRecord::Migration

  def up
    LogDb.create   # add logs table
    ConfDb.create  # add props table
    TagDb.create   # add tags, taggings table

    WorldDb.create
    BeerDb.create
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
