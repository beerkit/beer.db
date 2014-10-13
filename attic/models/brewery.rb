
  def self.rnd  # find random beer  - fix: use "generic" activerecord helper and include/extend class
    rnd_offset = rand( Brewery.count )   ## NB: call "global" std lib rand
    Brewery.offset( rnd_offset ).limit( 1 )
  end


