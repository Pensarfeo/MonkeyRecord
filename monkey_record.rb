module MonkeyRecord
	module Preload
		#Allows you to load on a activeRecord Relation
		def store_associations(*args_)
				return if args_.blank?
				ActiveRecord::Associations::Preloader.new.preload(self, *args_)
		end
		alias_method :store_on, :store_associations
	end
end