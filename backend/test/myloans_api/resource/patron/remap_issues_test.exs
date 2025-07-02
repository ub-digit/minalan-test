defmodule MyloansApi.Resource.Patron.Remap.IssuesTest do
  use ExUnit.Case
  alias MyloansApi.Resource.Patron.Remap.Issues

  test "can not be renewed (too soon)" do
    output = Issues.remap_issue(%{"too_soon" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "too_soon"
    assert Map.has_key?(output["renew_status"], "timestamp") == true
  end

  test "can not be renewed (item denied renewal)" do
    output = Issues.remap_issue(%{"item_denied_renewal" => 1, "itemlost" => "1"})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "item_lost"
  end

  test "can not be renewed (on_reserve)" do
    output = Issues.remap_issue(%{"on_reserve" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "on_reserve"
  end

  test "can not be renewed (norenew_overdue)" do
    output = Issues.remap_issue(%{"norenew_overdue" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "norenew_overdue"
  end

  test "can not be renewed (auto_renew)" do
    output = Issues.remap_issue(%{"auto_renew" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "auto_renew"
  end

  test "can not be renewed (auto_too_soon)" do
    output = Issues.remap_issue(%{"auto_too_soon" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "auto_too_soon"
  end

  test "can not be renewed (auto_too_late)" do
    output = Issues.remap_issue(%{"auto_too_late" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "auto_too_late"
  end

  test "can not be renewed (auto_too_much_oweing)" do
    output = Issues.remap_issue(%{"auto_too_much_oweing" => 1})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "auto_too_much_oweing"
  end

  test "can not be renewed (no_renewals_available)" do
    output = Issues.remap_issue(%{"auto_renew" => "0", "renewsleft" => 0, "renewsallowed" => "0"})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "no_renewals_available"
  end

  test "can not be renewed (no_renewals_left)" do
    output = Issues.remap_issue(%{"auto_renew" => "0", "renewsleft" => 0})
    assert output["can_be_renewed"] == false
    assert output["renew_status"]["reason"] == "no_renewals_left"
  end

  test "can be renewed" do
    output = Issues.remap_issue(%{"auto_too_much_oweing" => 0})
    assert output["can_be_renewed"] == true
    output = Issues.remap_issue(%{"auto_too_late" => 0})
    assert output["can_be_renewed"] == true
    output = Issues.remap_issue(%{"item_denied_renewal" => 0, "itemlost" => "1"})
    assert output["can_be_renewed"] == true
    output = Issues.remap_issue(%{"item_denied_renewal" => 1, "itemlost" => "0"})
    assert output["can_be_renewed"] == true
    output = Issues.remap_issue(%{"item_denied_renewal" => 1, "itemlost" => nil})
    assert output["can_be_renewed"] == true
  end

  test "date_due date only" do
    output = Issues.remap_issue(%{"date_due" => "2021-10-10 23:59"})
    assert output["date_due"] == "2021-10-10"
  end

  test "readable description for itemtypes" do
    output = Issues.remap_issue(%{"itemtype_data" => %{"description" => "Described itemtype"}})
    assert output["itemtype_description"] == "Described itemtype"
  end

  test "full title" do
    output = Issues.remap_issue(%{"title" => "Main title", "subtitle" => "Subtitle"})
    assert output["full_title"] == "Main title Subtitle"
    output = Issues.remap_issue(%{"title" => nil, "subtitle" => "Subtitle"})
    assert output["full_title"] == "Subtitle"
    output = Issues.remap_issue(%{"title" => "Main title", "subtitle" => nil})
    assert output["full_title"] == "Main title"
    output = Issues.remap_issue(%{"title" => "", "subtitle" => "Subtitle"})
    assert output["full_title"] == "Subtitle"
    output = Issues.remap_issue(%{"title" => "Main title", "subtitle" => ""})
    assert output["full_title"] == "Main title"
  end

  test "retained fields" do
    output = Issues.remap_issue(%{"booksellerid" => 1, "itemnumber" => "44"})
    assert Map.has_key?(output, "booksellerid") == false
    assert Map.has_key?(output, "itemnumber") == true
  end
end
