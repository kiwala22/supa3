class Ability
   include CanCan::Ability

   def initialize(user)
      user ||= User.new
      can :read, Ticket
      can :manage, Broadcast
      can :manage, PushPayBroadcast
      can :read, Gamer
      can :read, ApiUser


      if user.role == "manager"
         can :manage, Jackpot
         can :manage, Ticket
         can :manage, DrawOffer
         can :manage, Gamer
         can :manage, Draw
         can :manage, Report
         can [:read, :create], Payment
      end

      can :manage, :all if user.role == "admin"

   end
end
