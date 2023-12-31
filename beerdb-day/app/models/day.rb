# encoding: utf-8

class Day < ActiveRecord::Base

  self.table_name = 'days'

  belongs_to :beer, :class_name => 'BeerDb::Model::Beer', :foreign_key => 'beer_id'



end # class Day
