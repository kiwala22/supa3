class Ability
   include CanCan::Ability

   def initialize(user)
      can :manage, Broadcast
      can :manage, Ticket
      can :manage, Gamer

      if user.admin?
        can :manage, :revenue
      end
   end
end
