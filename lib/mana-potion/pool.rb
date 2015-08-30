module ManaPotion
  module Pool
    def self.included(other)
      other.extend ClassMethods
    end

    module ClassMethods
      def mana_pool_for(association, limit: 1, period: 1.day)
        before_validation do
          limit = instance_exec &limit if limit.respond_to?(:call)
          period = instance_exec &period if period.respond_to?(:call)

          owner = send(association)
          other_side_association = owner
          .class
          .reflect_on_all_associations
          .detect { |r| r.class_name == self.class.name }

          count = owner
          .send(other_side_association.name)
          .where(created_at: period.ago..Time.current)
          .count

          if count >= limit
            errors.add(association, :limit, limit: limit, count: count)
          end
        end
      end
    end
  end
end
