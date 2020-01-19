class Ability
   include CanCan::Ability

   def initialize(user)
      user ||= User.new
      can :manage, Broadcast
      can :manage, Ticket
      can :manage, Gamer

      if user.admin?
        can :manage, :revenue
        can :manage, :jackpot
        can :manage, ApiUser
        can :manage, :disbursement
        can :manage, :collection
        can :manage, :draw_offer
      end
   end
end
