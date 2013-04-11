class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new

    can :read, :all

    can :manage, Comment do |comment|
      comment.editable_by? user
    end

    can :manage, Game do |game|
      game.manageable_by? user
    end

    can :manage, User do |profile|
      profile.manageable_by? user
    end
  end
end
