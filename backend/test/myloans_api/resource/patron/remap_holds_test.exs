defmodule MyloansApi.Resource.Patron.Remap.HoldsTest do
  use ExUnit.Case
  alias MyloansApi.Resource.Patron.Remap.Holds

  test "valid status (WAITING)" do
    output = Holds.remap_hold(%{"found" => "W"})
    assert output["status"] == "WAITING"
  end

  test "valid status (TRANSIT)" do
    output = Holds.remap_hold(%{"found" => "T"})
    assert output["status"] == "TRANSIT"
  end

  test "valid status (PROCESSING)" do
    output = Holds.remap_hold(%{"found" => "P"})
    assert output["status"] == "PROCESSING"
  end

  test "valid status (REQUESTED)" do
    output = Holds.remap_hold(%{"itemnumber" => "12345", "onloan" => false})
    assert output["status"] == "REQUESTED"
  end

  test "valid status (UNFILLED)" do
    output = Holds.remap_hold(%{"itemnumber" => nil, "onloan" => false})
    assert output["status"] == "UNFILLED"
    output = Holds.remap_hold(%{"itemnumber" => "12345", "onloan" => true})
    assert output["status"] == "UNFILLED"
    output = Holds.remap_hold(%{"itemnumber" => nil, "onloan" => true})
    assert output["status"] == "UNFILLED"
    output = Holds.remap_hold(%{"found" => nil})
    assert output["status"] == "UNFILLED"
  end

  test "full title" do
    output = Holds.remap_hold(%{"title" => "Main title", "subtitle" => "Subtitle"})
    assert output["full_title"] == "Main title Subtitle"
    output = Holds.remap_hold(%{"title" => nil, "subtitle" => "Subtitle"})
    assert output["full_title"] == "Subtitle"
    output = Holds.remap_hold(%{"title" => "Main title", "subtitle" => nil})
    assert output["full_title"] == "Main title"
    output = Holds.remap_hold(%{"title" => "", "subtitle" => "Subtitle"})
    assert output["full_title"] == "Subtitle"
    output = Holds.remap_hold(%{"title" => "Main title", "subtitle" => ""})
    assert output["full_title"] == "Main title"
  end

  test "item data" do
    output = Holds.remap_hold(%{"item_data" => %{"onloan" => "2021-10-10"}})
    assert output["onloan"] == true
    assert Map.has_key?(output, "item_data") == false
    output = Holds.remap_hold(%{"item_data" => %{"onloan" => nil}})
    assert output["onloan"] == false
    assert Map.has_key?(output, "item_data") == false
  end

  test "biblio data" do
    output = Holds.remap_hold(%{"biblio_data" => %{"title" => "Main title", "subtitle" => "Subtitle", "author" => "Main author"}})
    assert output["title"] == "Main title"
    assert output["subtitle"] == "Subtitle"
    assert output["author"] == "Main author"
    assert Map.has_key?(output, "biblio_data") == false
  end

  test "retained fields" do
    output = Holds.remap_hold(%{"suspend" => "0", "branchcode" => "44"})
    assert Map.has_key?(output, "suspend") == false
    assert Map.has_key?(output, "branchcode") == true
  end
end
