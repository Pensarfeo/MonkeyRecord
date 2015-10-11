#—————————————————————————————————————————————————————————————————————————————————#
#————                  >>>>>>>>>Preloader::Association<<<<<<<<<               ————#
#—————————————————————————————————————————————————————————————————————————————————#

# We can pass a costum query that can then be attached to a collection of associations
# or proxies

module ActiveRecord
	module Associations
		class Preloader
			class Association

				#adding a user given @preloaded_records allows so that the query will only be
				#lounched if the user did not give such option
				def initialize(klass, owners, reflection, preload_scope)
					@klass         = klass
					@owners        = owners
					@reflection    = reflection
					@preload_scope = preload_scope
					@model         = owners.first && owners.first.class
					@scope         = nil
					@owners_by_key = nil
					@preloaded_records = []
				end

				def records_for(ids)
					case @preload_scope
					when Proc
						custom_query_scope(ids)
					when ActiveRecord::Relation
						@preload_scope
					else
						query_scope(ids)
					end
				end

				private

				def custom_query_scope(ids_)

					#get basic relation conditions, only direct( no through are alowed)
					_base_scope = klass.unscoped
					_base_scope.where_values= Array(reflection_scope.where_values)
					_base_scope.bind_values = reflection_scope.bind_values
					if options[:as]
						scope.where!(klass.table_name => { reflection.type => model.base_class.sti_name })
					end
					klass.instance_exec(&@preload_scope).
								where( association_key.in(ids_) ).
								merge( _base_scope )

				end

			end



		end
	end
end
