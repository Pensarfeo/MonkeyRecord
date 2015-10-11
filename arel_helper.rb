#Original source
#https://github.com/camertron/arel-helpers

module ArelHelpers
	module ArelTable
		extend ActiveSupport::Concern
		module ClassMethods
			def [](name)
				arel_table[name]
			end
		end
	end
end


module ActiveRecord
	module Associations
		class CollectionProxy < Relation
			def [](index)
				to_a[index]
			end
		end
	end
end