class Ability
   include CanCan::Ability

   def initialize(user)
      user ||= User.new
      can :manage, Broadcast
      can :manage, Ticket
      can :manage, Gamer

      if user.admin?
        can :manage, :revenue
        can :manage, ApiUser
      end
   end
end
