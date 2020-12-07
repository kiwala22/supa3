RSpec.shared_context 'Create Draws' do

    before :each do
      create_draws
    end


    def create_draws
      time = "2020-11-24 07:00:00 +0300"
      time2 = "2020-11-24 08:00:00 +0300"
      minutes = [0, 10, 20, 30, 40]

      for t in minutes do
        draw_time = time.to_datetime + t.minutes
        win = rand(100..999)
        Draw.create(draw_time: draw_time, winning_number: win, game: "Supa3")
      end

      for t in minutes do
        draw_time = time.to_datetime + t.minutes
        win = rand(10000..99999)
        Draw.create(draw_time: draw_time, winning_number: win, game: "Supa5")
      end

      for t in minutes do
        draw_time = time2.to_datetime + t.minutes
        win = rand(100..999)
        Draw.create(draw_time: draw_time, winning_number: win, game: "Supa3")
      end

      for t in minutes do
        draw_time = time2.to_datetime + t.minutes
        win = rand(10000..99999)
        Draw.create(draw_time: draw_time, winning_number: win, game: "Supa5")
      end

    end

  end
