defmodule MyloansApi.Resource.Patron.PasswordValidation do
  @password_min_length 8
  @password_max_length 16
  @password_require_digit true
  @password_require_uppercase true
  @password_require_lowercase true
  @password_require_special true
  @password_special_chars "!#%/(){}[]=*><@$_-.,;:"
  @password_require_only_valid_chars true
  @password_valid_chars "abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789!#%/(){}[]=*><@$_-.,;:"

  # Codes: too_short, too_long, require_upper, require_lower, require_digit, require_special, contains_invalid, dont_match

  # Function to convert special char string to a valid regex, escaping any special chars and placing "-" at the end to avoid escaping
  def charlist_string_to_regex(charlist_string) do
    escaped_chars = "/\\(){}[]*.$"
    must_come_last = "-"
    # Loop over each char in the charlist_string
    # Apply escaping to any special chars
    # Concatenate the escaped char to the result string
    # Concatenate the must_come_last char to the result string if it is included in the charlist_string
    charlist_string
    |> String.graphemes()
    |> Enum.reduce("", fn char, acc ->
      case {char, String.contains?(escaped_chars, char)} do
        {c, true} -> acc <> "\\" <> c
        {c, _} when c == must_come_last -> acc # Special handling separately
        {c, _} -> acc <> c
      end
    end)
    # If the must_come_last char is included in the charlist_string, concatenate it to the result string
    |> then(fn result ->
      case {result, String.contains?(charlist_string, must_come_last)} do
        {r, true} -> r <> must_come_last
        {r, _} -> r
      end
    end)
    # Surround the result string with [] and convert to a regex
    |> then(fn result -> ~r/[#{result}]/ end)
  end

  def validate_new_password(password, password2) when not(is_binary(password)), do: validate_new_password("", password2)
  def validate_new_password(password, password2) when not(is_binary(password2)), do: validate_new_password(password, "")
  def validate_new_password(password, password2) do
    {:validation, password, []}
    |> validate_password_min_length(@password_min_length)
    |> validate_password_max_length(@password_max_length)
    |> validate_password_require_digit(@password_require_digit)
    |> validate_password_require_uppercase(@password_require_uppercase)
    |> validate_password_require_lowercase(@password_require_lowercase)
    |> validate_password_require_special(@password_require_special, charlist_string_to_regex(@password_special_chars))
    |> validate_password_require_only_valid_chars(@password_require_only_valid_chars, charlist_string_to_regex(@password_valid_chars))
    |> validate_passwords_match(password2)
    |> case do
      {:validation, _, []} -> {:ok, "Password is valid"}
      {:validation, _, error_list} -> {:error, error_list |> Enum.reverse()}
    end
    |> consolidate_validation_reasons()
  end

  def consolidate_validation_reasons({:ok, _} = state), do: state
  # Combine "too_short, too_long, contain_invalid" into "invalid_basic"
  # However, keep the original errors as well, so "too_short" and "invalid_basic" should both be present
  def consolidate_validation_reasons({:error, error_list}) do
    # IO.inspect(error_list, label: "consolidate_validation_reasons")
    error_list
    |> Enum.reduce([], fn error, acc ->
      case error do
        # Keep both "too_short" the new "invalid_basic"
        "too_short" -> [["too_short", "invalid_basic"] | acc] |> List.flatten()
        "too_long" -> [["too_long", "invalid_basic"] | acc] |> List.flatten()
        "contains_invalid" -> [["contains_invalid", "invalid_basic"] | acc] |> List.flatten()
        _ -> [error | acc]
      end
    end)
    # We can now have multiple "invalid_basic" errors, remove duplicates
    |> Enum.uniq()
    |> then(fn errors -> {:error, errors} end)
  end

  def validate_password_min_length({:validation, password, error_list}, min_length) do
    # IO.inspect(password, label: "validate_password_length")
    case String.length(password) do
      len when len < min_length -> {:validation, password, ["too_short" | error_list]}
      _ -> {:validation, password, error_list}
    end
  end

  def validate_password_max_length({:validation, password, error_list}, max_length) do
    # IO.inspect(password, label: "validate_password_length")
    case String.length(password) do
      len when len > max_length -> {:validation, password, ["too_long" | error_list]}
      _ -> {:validation, password, error_list}
    end
  end

  def validate_password_require_digit({:validation, password, error_list}, _require_digit = true) do
    # IO.inspect(password, label: "validate_password_digit")
    case String.match?(password, ~r/\d/) do
      true -> {:validation, password, error_list}
      false -> {:validation, password, ["require_digit" | error_list]}
    end
  end
  def validate_password_require_digit(validation, _), do: validation

  def validate_password_require_uppercase({:validation, password, error_list}, _require_uppercase = true) do
    # IO.inspect(password, label: "validate_password_uppercase")
    case String.match?(password, ~r/[A-ZÅÄÖ]/) do
      true -> {:validation, password, error_list}
      false -> {:validation, password, ["require_upper" | error_list]}
    end
  end
  def validate_password_require_uppercase(validation, _), do: validation

  def validate_password_require_lowercase({:validation, password, error_list}, _require_lowercase = true) do
    # IO.inspect(password, label: "validate_password_lowercase")
    case String.match?(password, ~r/[a-zåäö]/) do
      true -> {:validation, password, error_list}
      false -> {:validation, password, ["require_lower" | error_list]}
    end
  end
  def validate_password_require_lowercase(validation, _), do: validation

  def validate_password_require_special({:validation, password, error_list}, _require_special = true, special_chars) do
    # IO.inspect(password, label: "validate_password_special")
    case String.match?(password, special_chars) do
      true -> {:validation, password, error_list}
      false -> {:validation, password, ["require_special" | error_list]}
    end
  end
  def validate_password_require_special(validation, _, _), do: validation

  def validate_password_require_only_valid_chars({:validation, password, error_list}, _require_only_valid_chars = true, valid_chars) do
    # Check that password only contains valid chars and no other chars
    # Remove all chars that are valid from the password
    # If the password is empty, it only contains valid chars
    # If the password is not empty, it contains invalid chars
    case String.replace(password, valid_chars, "") do
      "" -> {:validation, password, error_list}
      _ -> {:validation, password, ["contains_invalid" | error_list]}
    end
  end
  def validate_password_require_only_valid_chars(validation, _, _), do: validation

  def validate_passwords_match({:validation, password, error_list}, password), do: {:validation, password, error_list}
  def validate_passwords_match({:validation, password, error_list}, _password2), do: {:validation, password, ["dont_match" | error_list]}
  def validate_passwords_match(validation, _), do: validation
end
