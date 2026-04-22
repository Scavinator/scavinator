module Team::ScavHunt::EventsHelper
  def urgency_css_class(event)
    if event.date < 15.minutes.ago
      "grey"
    elsif event.date < 10.minutes.from_now
      "red"
    elsif event.date < 30.minutes.from_now
      "yellow"
    else
      "initial"
    end
  end
end
