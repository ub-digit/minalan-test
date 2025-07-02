defmodule MyloansApi.Resource.Patron.Remap.Debarments do
  def remap({:error, error}), do: {:error, error}
  def remap({:ok, map}) do
    debarments =
      map["debarments"]
      |> add_fines_exceeded(map)
      |> add_borrower_card_lost(map)
      |> add_borrower_no_address(map)
      |> add_borrower_expired(map)
      |> Enum.map(&remap_manual/1)

    {:ok, Map.put(map, "debarments", debarments)}
  end

  def remap_manual(%{"type" => "MANUAL"} = debarment) do
    new_type = debarment["comment"] |> String.split(",") |> List.first()
    Map.put(debarment, "type", new_type)
  end
  def remap_manual(debarment), do: debarment

  def add_fines_exceeded(list,
    %{"borrower" => %{"borrowernumber" => borrowernumber},
      "flags" => %{"CHARGES" => %{"noissues" => 1} = charges}}) do
    amount = charges["amount"]
    fines_debarment = %{
      "borrowernumber" => borrowernumber,
      "comment" => "FINES_EXCEEDED #{amount} SEK",
      "type" => "FINES_EXCEEDED"
    }
    [fines_debarment | list]
  end
  def add_fines_exceeded(list, _), do: list

  def add_borrower_card_lost(list,
    %{"borrower" => %{
      "lost" => 1,
      "borrowernumber" => borrowernumber
      }}) do
    lost_debarment = %{
      "borrowernumber" => borrowernumber,
      "comment" => "CARD_LOST",
      "type" => "CARD_LOST"
    }
    [lost_debarment | list]
  end
  def add_borrower_card_lost(list, _), do: list

  def add_borrower_no_address(list,
    %{"borrower" => %{
      "gonenoaddress" => 1,
      "borrowernumber" => borrowernumber
      }}) do
    gna_debarment = %{
      "borrowernumber" => borrowernumber,
      "comment" => "NO_ADDRESS",
      "type" => "NO_ADDRESS"
    }
    [gna_debarment | list]
  end
  def add_borrower_no_address(list, _), do: list

  def add_borrower_expired(list,
    %{"borrower" => %{
      "expire_date" => expiration_date,
      "borrowernumber" => borrowernumber
      }}) do
    expiration_date = NaiveDateTime.from_iso8601!(expiration_date <> " 00:00:00")
    now = NaiveDateTime.local_now()
    if NaiveDateTime.diff(expiration_date, now) < 0 do
      expired_debarment = %{
        "borrowernumber" => borrowernumber,
        "comment" => "CARD_EXPIRED",
        "type" => "CARD_EXPIRED"
      }
      [expired_debarment | list]
    else
      list
    end
  end
  def add_borrower_expired(list, _), do: list
end
