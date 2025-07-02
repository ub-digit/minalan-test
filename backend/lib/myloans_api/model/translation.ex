defmodule MyloansApi.Model.Translation do
  def all(filename_prefix \\ "locale", langs \\ ["en", "sv"]) do
    Enum.reduce(langs, %{}, fn lang, translations ->
      translation =
        File.read!("data/#{filename_prefix}_#{lang}.json")
        |> Jason.decode!()

        Map.put(translations, lang, translation)
    end)
  end
end
