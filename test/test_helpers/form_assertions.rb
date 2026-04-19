module FormAssertions
  def assert_select_has_value(name, v)
    assert assert_dom(%{select[name="#{name}"] option}).any? do |e|
      e.attributes["value"] == v
    end
  end
end
