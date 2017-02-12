
  def self.rnd  # find random beer  - fix: use "generic" activerecord helper and include/extend class
    rnd_offset = rand( Beer.count )   ## NB: call "global" std lib rand
    Beer.offset( rnd_offset ).limit( 1 )
  end


