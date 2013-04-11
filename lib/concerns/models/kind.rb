module Concerns
  module Models
    module Kind
      extend ActiveSupport::Concern

      included do
        scope :casual,       where(:kind => 'Casual')
        scope :competitive,  where(:kind => 'Competitive')
        scope :registered,   where('kind != ?', 'Unregistered')
        scope :unregistered, where('kind  = ?', 'Unregistered')
      end

      def casual?
        kind == 'Casual'
      end

      def competitive?
        kind == 'Competitive'
      end

      def registered?
        kind != 'Unregistered'
      end

      def unregistered?
        not registered?
      end

      def was_unregistered?
        kind_was == 'Unregistered'
      end
    end
  end
end
