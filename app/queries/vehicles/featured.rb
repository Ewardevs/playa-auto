module Vehicles
  # Stock the playa wants on the home page. Falls back to the newest vehicles so
  # the section is never empty just because nobody ticked "destacado".
  class Featured
    def self.call(...) = new(...).results

    def initialize(limit: 6, setting: Setting.current)
      @limit = limit
      @scope = Vehicles::Public.call(setting: setting)
    end

    def results
      featured = @scope.featured.with_associations.order(published_at: :desc).limit(@limit).to_a
      return featured if featured.size >= @limit

      filler = @scope.where.not(id: featured.map(&:id))
                     .with_associations
                     .order(published_at: :desc)
                     .limit(@limit - featured.size)

      featured + filler.to_a
    end
  end
end
