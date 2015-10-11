module ActiveRecord

	module Querying
		delegate :where_either, :preload_on     , to: :all
	end

	module QueryMethods
		#---------------------------------- Add or method to where
		def where_either(*opts)
			spawn.where_either!(*opts)
		end

		def where_either!(*opts_)
			where_vals = opts_.map do |op_|
									 if Hash === op_
										 opts = sanitize_forbidden_attributes(op_)
										 references!(PredicateBuilder.references(op_))
									 end
										 build_where(op_,nil).inject(:and)
									 end.inject(:or)
			self.where_values += [where_vals]
			self
		end

		#---------------------------------- Add or method to where
		def where_sql()
			predicates = self.where_values.map do |where|
				next where if ::Arel::Nodes::Equality === where
				where = Arel.sql(where) if String === where
				Arel::Nodes::Grouping.new(where)
			end

			return if !predicates.present?

			raw_where_string=Arel::Nodes::And.new(predicates).to_sql.split("?")
			bind_values_array=self.bind_values.map{|i_| i_.last}

			raw_where_string.map_with_index do |i_,j_|
				[i_,bind_values_array[j_]]
			end.flatten.join

		end

		#---------------------------------- Add condition to joins
		def join_conditions(args)
			self.join_condition_values=args
			self
		end

		def join_condition_values
			@values[:join_conditions]
		end

		def join_condition_values=(args)
			@values[:join_conditions]=args
		end


		private
		#---------------------------------- build_joins
		#redefining this method allows us to remove the 
		#conflict between joins and egaer load by only allowing
		#String and Arel object if any is present 
		def build_joins(manager, joins)
			buckets = joins.group_by do |join|
				case join
				when String
					:string_join
				when Hash, Symbol, Array
					:association_join
				when ActiveRecord::Associations::JoinDependency
					:stashed_join
				when Arel::Nodes::Join
					:join_node
				else
					raise 'unknown class: %s' % join.class.name
				end
			end

			association_joins         = buckets[:association_join] || []
			stashed_association_joins = buckets[:stashed_join] || []	
			join_nodes                = (buckets[:join_node] || []).uniq
			string_joins              = (buckets[:string_join] || []).map(&:strip).uniq

			join_list = join_nodes + custom_join_ast(manager, string_joins)
			
			#this part builds joins from symbols!
			join_dependency = ActiveRecord::Associations::JoinDependency.new(
				@klass,
				association_joins,
				join_list
				)

			#join_infos elements of the type
			# #<struct ActiveRecord::Associations::JoinDependency
			#											 ::JoinAssociation::JoinInformation
			#each instance has to methods a join and associated bind
			#joins is an array which contains instances of Arel::Nodes::Join
			join_infos = join_dependency.join_constraints stashed_association_joins

			# Ad joins to 
			join_infos.each do |info|
				info.joins.each do  |join| 
					add_conditions_to_arel_join(join)
					manager.from(join)
				end
				manager.bind_values.concat info.binds
			end


			#here we add the joins that comes from Strings and Arel
			manager.join_sources.concat(join_list)

			manager
		end

		#this methods allows to add conditions (AND only) to the joining model
		#sanitation might be required
		def add_conditions_to_arel_join(join)
			_table=join.left
			_conditions=self.join_condition_values.
											 try(:[], _table.name.to_sym)

			Array.wrap(_conditions).map do |k_,v_|
				if k_.kind_of?(Proc)
					join.right=join.right.and(k_.call(_table))
				else
					join.right=join.right.and(_table[k_].eq(v_))
				end
			end if _conditions
		end


	end
end









