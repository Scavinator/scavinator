module Team::ScavHunt::EventsHelper
  def urgency_css_class(event)
    if event.date < 10.minutes.ago
      "grey"
    elsif event.date < 30.minutes.from_now
      "red"
    else
      "initial"
    end
  end
end
