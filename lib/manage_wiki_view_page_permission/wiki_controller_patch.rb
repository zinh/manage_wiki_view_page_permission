module ManageWikiViewPagePermission
  module WikiControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :validate_permission_for_protected_pages, :only=>:show
        alias_method_chain :load_pages_for_index, :protected
        private

        def validate_permission_for_protected_pages
          deny_access and return if @page.protected? and !User.current.allowed_to?(:view_protected_pages, @project)
        end
      end
    end

    module InstanceMethods
      def load_pages_for_index_with_protected
        @pages = if User.current.allowed_to?(:view_protected_pages, @project)
                   @wiki.pages.with_updated_on.
                     reorder("#{WikiPage.table_name}.title").
                     includes(:wiki => :project).
                     includes(:parent).
                     to_a
                 else
                   @wiki.pages.with_updated_on.
                     where(protected: false).
                     reorder("#{WikiPage.table_name}.title").
                     includes(:wiki => :project).
                     includes(:parent).
                     to_a
                 end
      end
    end
  end
end
