defmodule MyloansApi.Resource.Patron.Writer do
  alias MyloansApi.Model.Koha
  alias MyloansApi.Resource
  alias MyloansApi.Resource.Patron.PasswordValidation, as: Validate

  def save(id, data) do
    data
    |> nilify_data()
    |> validate()
    |> IO.inspect(label: "save-validated")
    |> case do
        {:ok, data} -> perform_save(id, data)
        {:invalid, state} -> {:invalid, state}
      end
  end

  def perform_save(id, data) do
    IO.inspect({id, data}, label: "perform_save")
    data = reduce_fields(data)
    Koha.Patron.update(id, data) |> IO.inspect(label: "Koha-update")
    if System.get_env("ALLOW_PASSWORD_CHANGE", "false") == "true" do
      if Map.get(data, "password", "") != "" do
        Koha.Pwreset.update(id, data) |> IO.inspect(label: "Koha-Pwreset-update")
      end
    end
    {:ok, data}
  end

  def nilify_data(data) do
    data
    |> Enum.map(fn
      {k, ""} -> {k, nil}
      {k, %{} = v} -> {k, nilify_data(v)}
      {k, v} -> {k, v}
      end)
    |> Map.new()
  end

  def validate(data) do
    {%{}, data}
    |> validate_preference()
    |> validate_firstname()
    |> validate_address(System.get_env("ADDRESS_MANDATORY", "true"))
    |> validate_zipcode(System.get_env("ADDRESS_MANDATORY", "true"))
    |> validate_city(System.get_env("ADDRESS_MANDATORY", "true"))
    |> validate_mobile()
    |> validate_pin(Resource.Patron.patron_has_local_pin(data["categorycode"], data["cardnumber"]))
    |> validate_password(System.get_env("ALLOW_PASSWORD_CHANGE", "false"), Resource.Patron.patron_has_local_password(data["categorycode"], data["cardnumber"]))
    |> reposition_password_matching_error()
    |> finalize_validation()
  end

  def reposition_password_matching_error({%{"password" => password_error_list} = errors, data}) do
    {new_password_error_list, new_password2_error} =
      password_error_list
      |> Enum.member?("dont_match")
      |> case do
        true -> {List.delete(password_error_list, "dont_match"), "dont_match"}
        false -> {password_error_list, nil}
      end
    case {new_password_error_list, new_password2_error} do
      # No "dont_match" in password error list, so leave it as it is
      {[], nil} -> {errors, data}
      # "dont_match" in password error list, so if password is now empty, remove it, and add "dont_match" to password2
      # Leave other errors as they are
      {[], "dont_match"} -> {errors |> Map.delete("password") |> Map.put("password2", "dont_match"), data}
      # Keep both "password" and "password2" in their new state, and also keep other errors
      {_, _} -> {errors |> Map.put("password", new_password_error_list) |> Map.put("password2", new_password2_error), data}
    end
  end
  def reposition_password_matching_error(other), do: other

  def validate_preference({state, %{"message_preference" => "sms", "smsalertnumber" => number} = data}) when is_nil(number),
    do: {Map.put(state, "smsalertnumber", "required"), data}
  def validate_preference({state, %{"message_preference" => "email", "email" => email} = data}) when is_nil(email),
    do: {Map.put(state, "email", "required"), data}
  def validate_preference({state, %{"message_preference" => "email_sms", "smsalertnumber" => number, "email" => email} = data}) do
    state =
      [{"smsalertnumber", number}, {"email", email}]
      |> Enum.reduce(state, fn
        {field, nil}, acc -> Map.put(acc, field, "required")
        {_, _}, acc -> acc
      end)
    {state, data}
  end
  def validate_preference(valid), do: valid

  def validate_firstname({state, %{"firstname" => firstname} = data}) when is_nil(firstname),
    do: {Map.put(state, "firstname", "required"), data}
  def validate_firstname({state, %{"firstname" => firstname} = data}) when is_binary(firstname) do
    case String.trim(firstname) do
      "" -> {Map.put(state, "firstname", "required"), data}
      _ -> {state, data}
    end
  end
  def validate_firstname(valid), do: valid
  def validate_address({state, %{"address" => address} = data}, "true") when is_nil(address),
    do: {Map.put(state, "address", "required"), data}
  def validate_address(valid, _), do: valid
  def validate_zipcode({state, %{"zipcode" => zipcode} = data}, "true") when is_nil(zipcode),
    do: {Map.put(state, "zipcode", "required"), data}
  def validate_zipcode(valid, _), do: valid
  def validate_city({state, %{"city" => city} = data}, "true") when is_nil(city),
    do: {Map.put(state, "city", "required"), data}
  def validate_city(valid, _), do: valid
  def validate_pin({state, data}, true), do: validate_pin({state, data}, :has_local_pin)
  def validate_pin({state, data}, false), do: validate_pin({state, data}, :has_external_pin)
  def validate_pin({state, %{"pin" => pin} = data}, :has_local_pin) when is_nil(pin),
    do: {Map.put(state, "pin", "required"), data}
  def validate_pin({state, %{"pin" => pin} = data}, :has_local_pin) when is_binary(pin) do
    case {String.trim(pin), String.match?(pin, ~r/^\d{4}$/)} do
      {"", _} -> {Map.put(state, "pin", "required"), data}
      {_, true} -> {state, data}
      {_, false} -> {Map.put(state, "pin", "invalid PIN-code"), data}
    end
  end
  def validate_pin(valid, _), do: valid
  def validate_password({state, data}, "true", true), do: validate_password({state, data}, :has_local_password)
  def validate_password(valid, _, _), do: valid
  def validate_password({state, %{"password" => password, "password2" => password2} = data}, :has_local_password) do
    IO.inspect({password, password2}, label: "validate_password")
    case {password, password2} do
      {"", ""} -> {state, data}
      {"", _} -> {Map.put(state, "password", "required"), data}
      {_, ""} -> {Map.put(state, "password2", "required"), data}
      {_, _} -> validate_password_requirements({state, data}, password, password2)
    end
  end
  def validate_password({state, data}, :has_local_password) do
    password = Map.get(data, "password", "")
    password2 = Map.get(data, "password2", "")
    new_map = Map.put(data, "password", password)
    new_map = Map.put(new_map, "password2", password2)
    validate_password({state, new_map}, :has_local_password)
  end
  def validate_password(valid, other) do
    IO.inspect({valid, other}, label: "validate_password-other")
    valid
  end
  def validate_password(valid, _), do: valid

  def validate_password_requirements({state, data}, password, password2) do
    Validate.validate_new_password(password, password2)
    |> case do
      {:ok, _} -> {state, data}
      {:error, error_list} -> {Map.put(state, "password", error_list), data}
    end
  end

  def validate_password_interactive(password, password2) do
    {%{}, %{"password" => password, "password2" => password2}}
    |> validate_password_requirements(password, password2)
    |> reposition_password_matching_error()
    |> finalize_validation()
  end

  # SMS alert number must start with 0, but not 00
  # SMS alert number must be at least 9 digits
  # SMS alert number must contain only digits
  # Empty SMS alert number is allowed here, because requirements are checked in validate_preference
  def validate_mobile({state, %{"smsalertnumber" => number} = data}) when is_nil(number), do: {state, data}
  def validate_mobile({state, %{"smsalertnumber" => "00" <> _} = data}), do: {Map.put(state, "smsalertnumber", "invalid SMS alert number"), data}
  def validate_mobile({state, %{"smsalertnumber" => "0" <> number} = data}) do
    case String.match?("0" <> number, ~r/^\d{9,}$/) do
      true -> {state, data}
      false -> {Map.put(state, "smsalertnumber", "invalid SMS alert number"), data}
    end
  end
  def validate_mobile({state, %{"smsalertnumber" => _} = data}), do: {Map.put(state, "smsalertnumber", "invalid SMS alert number"), data}
  def validate_mobile(valid), do: valid

  def finalize_validation({state, data}) do
    case Enum.empty?(state) do
      true -> {:ok, data}
      false -> {:invalid, state}
    end
  end

  def reduce_fields(map) do
    map
    |> Enum.filter(fn {key, _} -> Enum.member?(valid_fields(), key) end)
    |> Enum.map(&remap_keys/1)
    |> Map.new()
  end

  def valid_fields() do
    [
      "address", "address2", "zipcode", "city",
      "b_address", "b_address2", "b_zipcode", "b_city",
      "message_preference", "email", "phone", "smsalertnumber",
      "pin", "password", "lang", "firstname", "survey_acceptance"
    ]
  end

  defp remap_keys({"b_address", value}), do: {"B_address", value}
  defp remap_keys({"b_address2", value}), do: {"B_address2", value}
  defp remap_keys({"b_zipcode", value}), do: {"B_zipcode", value}
  defp remap_keys({"b_city", value}), do: {"B_city", value}
  defp remap_keys(other), do: other
end
