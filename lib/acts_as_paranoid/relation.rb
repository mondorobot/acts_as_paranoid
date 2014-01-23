module ActsAsParanoid
  module Relation
    def self.included(base)
      base.class_eval do
        def paranoid?
          klass.try(:paranoid?) ? true : false
        end
        
        def paranoid_deletion_attributes
          { klass.paranoid_column => klass.delete_now_value }
        end

        alias_method :orig_delete_all, :delete_all
        def delete_all!(conditions = nil)
          if conditions
            where(conditions).delete_all!
          else
            orig_delete_all
          end
        end
        
        def delete_all(conditions = nil)
          if paranoid?
            # ORIGINAL UPDATE CALL
            #update_all(paranoid_deletion_attributes, conditions)

            # MODIFIED UPDATE CALL
            rs = @klass.where(scope_for_create)

            rs.each do |child_rec|
              child_rec.update_attributes paranoid_deletion_attributes
            end

            rs.length
          else
            delete_all!(conditions)
          end
        end

        def destroy!(id_or_array)
          where(primary_key => id_or_array).orig_delete_all
        end
      end
    end
  end
end
