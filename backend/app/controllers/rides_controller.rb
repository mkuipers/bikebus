class RidesController < ApplicationController
  def index
    rides = Ride.includes(:route, :leader_claim)

    rides = rides.where(route_id: params[:route_id]) if params[:route_id].present?
    rides = rides.where("scheduled_start_at >= ?", params[:from]) if params[:from].present?
    rides = rides.where("scheduled_start_at <= ?", params[:to]) if params[:to].present?

    render json: rides.order(:scheduled_start_at).as_json(
      include: { leader_claim: { only: [:user_id, :claimed_at, :last_ping_at] } },
      methods: [:needs_leader?]
    )
  end

  def show
    render json: find_ride.as_json(
      include: {
        route: { include: :stops },
        leader_claim: { only: [:user_id, :claimed_at, :last_ping_at] }
      },
      methods: [:needs_leader?]
    )
  end

  def claim_leader
    ride = find_ride
    ActiveRecord::Base.transaction do
      # Release any stale existing claim
      existing = ride.all_leader_claims.active.first
      if existing&.stale?
        existing.update!(released_at: Time.current)
      elsif existing
        return render json: { error: "Ride already has an active leader" }, status: :conflict
      end
      claim = ride.all_leader_claims.create!(user: current_user, claimed_at: Time.current)
      render json: claim, status: :created
    end
  end

  def release_leader
    claim = LeaderClaim.active.find_by!(ride_id: params[:id], user: current_user)
    claim.update!(released_at: Time.current)
    render json: { message: "Leader released" }
  end

  def complete
    ride = find_ride
    ride.update!(status: "completed", ended_at: Time.current)
    # Release leader claim if active
    ride.all_leader_claims.active.first&.update!(released_at: Time.current)
    render json: ride
  end

  private

  def find_ride
    Ride.find(params[:id])
  end
end
