# frozen_string_literal: true

module PagesCore
  class CreateUserService
    attr_reader :attributes, :invite

    def initialize(attributes, invite: nil)
      @attributes = attributes
      @invite = invite
    end

    class << self
      def call(attrs, invite: nil)
        new(attrs, invite:).call
      end
    end

    def call
      User.transaction do
        user = User.create(attributes.merge(invite_attributes))
        if user.valid?
          PagesCore::PubSub.publish(:create_user, user:, invite:)
          invite&.destroy
        end
        user
      end
    end

    private

    def invite_attributes
      return {} unless invite

      { role_names: invite.role_names,
        creator: invite.user,
        activated: true }
    end
  end
end
