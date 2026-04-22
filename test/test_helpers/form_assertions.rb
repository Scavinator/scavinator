module FormAssertions
  def assert_form_params(params)
    params.to_query.split('&').map { |i| i.split('=').map { |e| CGI.unescapeURIComponent e } }.each do |k, v|
      matching_form_elements = assert_dom(%{[name="#{k}"]})
      elements_have_value = matching_form_elements.any? do |ele|
        if ele.name == "input"
          if ele["type"] == "radio" || ele["type"] == "checkbox"
            ele["value"] == v
          else
            true
          end
        elsif ele.name == "select"
          assert_dom ele, %{option[value="#{v}"]}
        elsif ele.name == "textarea"
          true
        end
      end
      assert elements_have_value, "Form element #{k} to exist with value=#{v} in collection #{matching_form_elements}"
    end
  end

  def assert_form(action:, method: nil)
    if method.nil?
      assert_dom %{form[action="#{action}"]}
    elsif %w[get post].include? method.to_s
      assert_dom %{form[action="#{action}"][method="#{method.to_s}"]}
    else
      assert_dom %{form[action="#{action}"][method="post"] input[type="hidden"][name="_method"][value="#{method.to_s}"]}
    end
  end

  def assert_scavvie_params(team, req, params, scavvie_user: nil)
    noncaptain_user = scavvie_user || team.team_users.find_by(captain: false).user
    reset!
    host! [team.prefix, Rails.configuration.scavinator_domain].join(".")
    create_team_test_session team, noncaptain_user
    req.call
    assert_response :success
    assert_form_params params
  end
end
