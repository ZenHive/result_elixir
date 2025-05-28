defmodule Result do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- Result Module Doc Separator !-->")
             |> Enum.fetch!(1)

  @type ok :: any()
  @type new_ok :: any()
  @type err :: any()
  @type new_err :: any()

  @doc """
  Returns true if the result is ok

  ## Examples
      iex> Result.is_ok?({:ok, 42})
      true

      iex> Result.is_ok?({:error, "error"})
      false

      iex> Result.is_ok?(:ok)
      true

      iex> Result.is_ok?(:error)
      false
  """
  @spec is_ok?({:ok, ok} | {:error, err} | :ok | :error) :: boolean
  def is_ok?({:ok, _}), do: true
  def is_ok?(:ok), do: true
  def is_ok?({:error, _}), do: false
  def is_ok?(:error), do: false

  @doc """
  Returns true if the result is ok and the value inside of it matches a predicate.

  ## Examples
      iex> Result.is_ok_and?({:ok, 42}, &(&1 == 42))
      true

      iex> Result.is_ok_and?({:ok, 40}, &(&1 == 42))
      false

      iex> Result.is_ok_and?({:error, 42}, &(&1 == 42))
      false

      iex> Result.is_ok_and?(:ok, &(&1 == nil))
      true

      iex> Result.is_ok_and?(:ok, &(&1 == 42))
      false

      iex> Result.is_ok_and?(:error, &(&1 == nil))
      false
  """
  @spec is_ok_and?({:ok, ok} | {:error, err} | :ok | :error, (ok -> boolean)) :: boolean
  def is_ok_and?({:ok, value}, f), do: f.(value)
  def is_ok_and?(:ok, f), do: f.(nil)
  def is_ok_and?({:error, _}, _f), do: false
  def is_ok_and?(:error, _f), do: false

  @doc """
  Returns true if the result is an error

  ## Examples
      iex> Result.is_err?({:ok, 42})
      false

      iex> Result.is_err?({:error, "error"})
      true

      iex> Result.is_err?(:ok)
      false

      iex> Result.is_err?(:error)
      true
  """
  @spec is_err?({:ok, ok} | {:error, err} | :ok | :error) :: boolean
  def is_err?({:error, _}), do: true
  def is_err?(:error), do: true
  def is_err?({:ok, _}), do: false
  def is_err?(:ok), do: false

  @doc """
  Returns true if the result is an error and the value inside of it matches a predicate.

  ## Examples
      iex> Result.is_err_and?({:error, "msg"}, &(&1 == "msg"))
      true

      iex> Result.is_err_and?({:error, "another msg"}, &(&1 == "msg"))
      false

      iex> Result.is_err_and?({:ok, "msg"}, &(&1 == "msg"))
      false

      iex> Result.is_err_and?(:error, &(&1 == nil))
      true

      iex> Result.is_err_and?(:error, &(&1 == "msg"))
      false

      iex> Result.is_err_and?(:ok, &(&1 == nil))
      false
  """
  @spec is_err_and?({:ok, ok} | {:error, err} | :ok | :error, (err -> boolean)) :: boolean
  def is_err_and?({:error, err}, f), do: f.(err)
  def is_err_and?(:error, f), do: f.(nil)
  def is_err_and?({:ok, _}, _f), do: false
  def is_err_and?(:ok, _f), do: false

  @doc """
  Maps a Result.t(ok, err) to Result.t(new_ok, err) by applying a function to a contained Ok value, leaving an Err value untouched.

  ## Examples
      iex> Result.map({:ok, 42}, &(&1 + 1))
      {:ok, 43}

      iex> Result.map({:error, "error"}, &(&1 + 1))
      {:error, "error"}

      iex> Result.map(:ok, fn nil -> 1 end)
      {:ok, 1}

      iex> Result.map(:error, fn _ -> 1 end)
      :error
  """
  @spec map({:ok, ok} | {:error, err} | :ok | :error, (ok -> new_ok)) :: {:ok, new_ok} | {:error, err} | :ok | :error
  def map({:ok, value}, f), do: {:ok, f.(value)}
  def map(:ok, f), do: {:ok, f.(nil)}
  def map({:error, _} = result, _f), do: result
  def map(:error = result, _f), do: result

  @doc """
  Returns the provided default (if Err), or applies a function to the contained value (if Ok).

  Arguments passed to map_or are eagerly evaluated; if you are passing the result of a function call, it is recommended to use map_or_else, which is lazily evaluated.

  ## Examples
      iex> Result.map_or({:ok, 42}, 0, &(&1 + 1))
      43

      iex> Result.map_or({:error, "error"}, 0, &(&1 + 1))
      0

      iex> Result.map_or(:ok, 0, fn nil -> 1 end)
      1

      iex> Result.map_or(:error, 0, fn _ -> 1 end)
      0
  """
  @spec map_or({:ok, ok} | {:error, err} | :ok | :error, new_ok, (ok -> new_ok)) :: new_ok
  def map_or({:ok, value}, _default, f), do: f.(value)
  def map_or(:ok, _default, f), do: f.(nil)
  def map_or({:error, _}, default, _f), do: default
  def map_or(:error, default, _f), do: default

  @doc """
  Maps a Result.t(ok, err) to new_ok() by applying fallback function default to a contained Err value, or function f to a contained Ok value.

  ## Examples
      iex> Result.map_or_else({:ok, 42}, fn _err -> 42 end, &(&1 + 2))
      44

      iex> Result.map_or_else({:error, "error"}, fn _err -> 42 end, &(&1 + 2))
      42

      iex> Result.map_or_else(:ok, fn _err -> 0 end, fn nil -> 42 end)
      42

      iex> Result.map_or_else(:error, fn nil -> 0 end, fn _ -> 42 end)
      0
  """
  @spec map_or_else({:ok, ok} | {:error, err} | :ok | :error, (err -> new_ok), (ok -> new_ok)) :: new_ok
  def map_or_else({:ok, value}, _f_default, f), do: f.(value)
  def map_or_else(:ok, _f_default, f), do: f.(nil)
  def map_or_else({:error, err}, f_default, _f), do: f_default.(err)
  def map_or_else(:error, f_default, _f), do: f_default.(nil)

  @doc """
  Maps a Result.t(ok, err) to Result.t(ok, new_err) by applying a function to a contained Err value, leaving an Ok value untouched.

  ## Examples
      iex> Result.map_err({:ok, 42}, &(&1 + 1))
      {:ok, 42}

      iex> Result.map_err({:error, 42}, &(&1 + 1))
      {:error, 43}

      iex> Result.map_err(:ok, fn _ -> 42 end)
      :ok

      iex> Result.map_err(:error, fn nil -> 43 end)
      {:error, 43}
  """
  @spec map_err({:ok, ok} | {:error, err} | :ok | :error, (err -> new_err)) :: {:ok, ok} | {:error, new_err} | :ok | :error
  def map_err({:error, err}, f), do: {:error, f.(err)}
  def map_err(:error, f), do: {:error, f.(nil)}
  def map_err({:ok, _} = result, _f), do: result
  def map_err(:ok = result, _f), do: result

  @doc """
  Calls a function with the contained value if Ok.

  Returns the original result.

  ## Examples
      iex> Result.inspect({:ok, 42}, &(IO.inspect(&1)))
      {:ok, 42}
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect({:ok, 42}, &(IO.inspect(&1))) end)
      "42\\n"

      iex> Result.inspect({:error, 42}, &(IO.inspect(&1)))
      {:error, 42}
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect({:error, 42}, &(IO.inspect(&1))) end)
      ""

      iex> Result.inspect(:ok, &(IO.inspect(&1)))
      :ok
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect(:ok, &(IO.inspect(&1))) end)
      "nil\\n"

      iex> Result.inspect(:error, &(IO.inspect(&1)))
      :error
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect(:error, &(IO.inspect(&1))) end)
      ""
  """
  @spec inspect({:ok, ok} | {:error, err} | :ok | :error, (ok -> any)) :: {:ok, ok} | {:error, err} | :ok | :error
  def inspect({:ok, value} = result, f) do
    f.(value)
    result
  end

  def inspect(:ok = result, f) do
    f.(nil)
    result
  end

  def inspect({:error, _} = result, _f), do: result
  def inspect(:error = result, _f), do: result

  @doc """
  Calls a function with the contained value if Err.

  Returns the original result.

  ## Examples
      iex> Result.inspect_err({:ok, 42}, &(IO.inspect(&1)))
      {:ok, 42}
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect_err({:ok, 42}, &(IO.inspect(&1))) end)
      ""

      iex> Result.inspect_err({:error, 42}, &(IO.inspect(&1)))
      {:error, 42}
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect_err({:error, 42}, &(IO.inspect(&1))) end)
      "42\\n"

      iex> Result.inspect_err(:ok, &(IO.inspect(&1)))
      :ok
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect_err(:ok, &(IO.inspect(&1))) end)
      ""

      iex> Result.inspect_err(:error, &(IO.inspect(&1)))
      :error
      iex> ExUnit.CaptureIO.capture_io(fn -> Result.inspect_err(:error, &(IO.inspect(&1))) end)
      "nil\\n"
  """
  @spec inspect_err({:ok, ok} | {:error, err} | :ok | :error, (err -> any)) :: {:ok, ok} | {:error, err} | :ok | :error
  def inspect_err({:error, err} = result, f) do
    f.(err)
    result
  end

  def inspect_err(:error = result, f) do
    f.(nil)
    result
  end

  def inspect_err({:ok, _} = result, _f), do: result
  def inspect_err(:ok = result, _f), do: result

  @doc """
  Returns the contained Ok value or raise msg

  ## Examples
      iex> Result.expect!({:ok, 42}, "Foo")
      42

      iex> Result.expect!({:error, 42}, "Foo")
      ** (RuntimeError) Foo: 42

      iex> Result.expect!(:ok, "Foo")
      nil

      iex> Result.expect!(:error, "Foo")
      ** (RuntimeError) Foo: nil
  """
  @spec expect!({:ok, ok} | {:error, err} | :ok | :error, String.t()) :: ok
  def expect!({:ok, value}, _msg), do: value
  def expect!(:ok, _msg), do: nil
  def expect!({:error, err}, msg), do: raise("#{msg}: #{inspect(err)}")
  def expect!(:error, msg), do: raise("#{msg}: #{inspect(nil)}")

  @doc """
  Returns the contained Ok value or raises an error

  ## Examples
      iex> Result.unwrap!({:ok, 42})
      42

      iex> Result.unwrap!({:error, 42})
      ** (RuntimeError) Result.unwrap!() called with result {:error, 42}

      iex> Result.unwrap!(:ok)
      nil

      iex> Result.unwrap!(:error)
      ** (RuntimeError) Result.unwrap!() called with result :error
  """
  @spec unwrap!({:ok, ok} | {:error, err} | :ok | :error) :: ok
  def unwrap!({:ok, value}), do: value
  def unwrap!(:ok), do: nil

  def unwrap!({:error, _} = result),
    do: raise("Result.unwrap!() called with result #{inspect(result)}")

  def unwrap!(:error = result),
    do: raise("Result.unwrap!() called with result #{inspect(result)}")

  @doc """
  Returns the contained Err value or raise msg

  ## Examples
      iex> Result.expect_err!({:error, 42}, "Foo")
      42

      iex> Result.expect_err!({:ok, 42}, "Foo")
      ** (RuntimeError) Foo: 42

      iex> Result.expect_err!(:error, "Foo")
      nil

      iex> Result.expect_err!(:ok, "Foo")
      ** (RuntimeError) Foo: nil
  """
  @spec expect_err!({:ok, ok} | {:error, err} | :ok | :error, String.t()) :: err
  def expect_err!({:error, err}, _msg), do: err
  def expect_err!(:error, _msg), do: nil
  def expect_err!({:ok, value}, msg), do: raise("#{msg}: #{inspect(value)}")
  def expect_err!(:ok, msg), do: raise("#{msg}: #{inspect(nil)}")

  @doc """
  Returns the contained Err value or raises an error

  ## Examples
      iex> Result.unwrap_err!({:error, 42})
      42

      iex> Result.unwrap_err!({:ok, 42})
      ** (RuntimeError) Result.unwrap_err!() called with result {:ok, 42}

      iex> Result.unwrap_err!(:error)
      nil

      iex> Result.unwrap_err!(:ok)
      ** (RuntimeError) Result.unwrap_err!() called with result :ok
  """
  @spec unwrap_err!({:ok, ok} | {:error, err} | :ok | :error) :: err
  def unwrap_err!({:error, err}), do: err
  def unwrap_err!(:error), do: nil

  def unwrap_err!({:ok, _} = result),
    do: raise("Result.unwrap_err!() called with result #{inspect(result)}")

  def unwrap_err!(:ok = result),
    do: raise("Result.unwrap_err!() called with result #{inspect(result)}")

  @doc """
  Returns the result of applying a function to the contained value if Ok.
  Returns the original result if Err.

  ## Examples
      iex> Result.and_then({:ok, 42}, &({:ok, &1 + 1}))
      {:ok, 43}

      iex> Result.and_then({:ok, 42}, &({:error, &1 + 1}))
      {:error, 43}

      iex> Result.and_then({:error, 42}, &({:ok, &1 + 1}))
      {:error, 42}

      iex> Result.and_then(:ok, fn nil -> {:ok, 42} end)
      {:ok, 42}

      iex> Result.and_then(:ok, fn nil -> {:error, 0} end)
      {:error, 0}

      iex> Result.and_then(:error, &({:ok, &1 + 1}))
      :error
  """
  @spec and_then({:ok, ok} | {:error, err} | :ok | :error, (ok -> {:ok, new_ok} | {:error, new_err} | :ok | :error)) :: {:ok, new_ok} | {:error, new_err} | :ok | :error
  def and_then({:ok, value}, f), do: f.(value)
  def and_then(:ok, f), do: f.(nil)
  def and_then({:error, _} = result, _f), do: result
  def and_then(:error = result, _f), do: result

  @doc """
  Returns the result of applying a function to the contained value if Err.
  Returns the original result if Ok.

  ## Examples
      iex> Result.or_else({:error, 42}, &({:error, &1 + 1}))
      {:error, 43}

      iex> Result.or_else({:error, 42}, &({:ok, &1 + 1}))
      {:ok, 43}

      iex> Result.or_else({:ok, 42}, &({:error, &1 + 1}))
      {:ok, 42}

      iex> Result.or_else(:error, fn nil -> {:error, 42} end)
      {:error, 42}

      iex> Result.or_else(:error, fn nil -> {:ok, 0} end)
      {:ok, 0}

      iex> Result.or_else(:ok, &({:error, &1 + 1}))
      :ok
  """
  @spec or_else({:ok, ok} | {:error, err} | :ok | :error, (err -> {:ok, new_ok} | {:error, new_err} | :ok | :error)) :: {:ok, new_ok} | {:error, new_err} | :ok | :error
  def or_else({:error, value}, f), do: f.(value)
  def or_else(:error, f), do: f.(nil)
  def or_else({:ok, _} = result, _f), do: result
  def or_else(:ok = result, _f), do: result

  @doc """
  Returns the contained Ok value or a default

  Arguments passed to unwrap_or are eagerly evaluated; if you are passing the result of a function call, it is recommended to use unwrap_or_else, which is lazily evaluated.

  ## Examples
      iex> Result.unwrap_or({:ok, 42}, 0)
      42

      iex> Result.unwrap_or({:error, 42}, 0)
      0

      iex> Result.unwrap_or(:ok, 0)
      nil

      iex> Result.unwrap_or(:error, 0)
      0
  """
  @spec unwrap_or({:ok, ok} | {:error, err} | :ok | :error, ok) :: ok
  def unwrap_or({:ok, value}, _default), do: value
  def unwrap_or(:ok, _default), do: nil
  def unwrap_or({:error, _}, default), do: default
  def unwrap_or(:error, default), do: default

  @doc """
  Returns the contained Ok value or computes a default from a function

  ## Examples
      iex> Result.unwrap_or_else({:ok, 42}, fn _ -> 0 end)
      42

      iex> Result.unwrap_or_else({:error, 42}, fn _ -> 0 end)
      0

      iex> Result.unwrap_or_else(:ok, fn _ -> 0 end)
      nil

      iex> Result.unwrap_or_else(:error, fn _ -> 0 end)
      0
  """
  @spec unwrap_or_else({:ok, ok} | {:error, err} | :ok | :error, (err -> ok)) :: ok
  def unwrap_or_else({:ok, value}, _f_default), do: value
  def unwrap_or_else(:ok, _f_default), do: nil
  def unwrap_or_else({:error, err}, f_default), do: f_default.(err)
  def unwrap_or_else(:error, f_default), do: f_default.(nil)

  @doc """
  Reduces a list while handling errors using Result types.

  This function is similar to Enum.reduce/3 but works with Result types. It will continue
  reducing until either:
  1. The list is exhausted (returns {:ok, final_acc})
  2. The reducer function returns an error (returns {:error, error})

  ## Parameters
    - list: The list to reduce over
    - acc: The initial accumulator value
    - f: A function that takes an element and accumulator, returning {:ok, new_acc} or {:error, error}

  ## Examples
      iex> Result.try_reduce([1, 2, 3], 0, fn x, acc -> {:ok, acc + x} end)
      {:ok, 6}

      iex> Result.try_reduce([1, 2, 3], nil, fn _, _ -> :ok end)
      :ok

      iex> Result.try_reduce([1, 2, 3], 0, fn x, acc ->
      ...>   if x == 2, do: {:error, "found 2"}, else: {:ok, acc + x}
      ...> end)
      {:error, "found 2"}

      iex> Result.try_reduce([1, 2, 3], 0, fn x, acc ->
      ...>   if x == 2, do: :error, else: {:ok, acc + x}
      ...> end)
      :error

      iex> Result.try_reduce([], 42, fn _x, acc -> {:ok, acc} end)
      {:ok, 42}

      # Since the enumerable is empty, {:ok, acc} is returned not :ok (because the function is never called)
      iex> Result.try_reduce([], 42, fn _x, _acc -> :ok end)
      {:ok, 42}
  """
  @spec try_reduce(list(any()), any(), (any(), any() -> {:ok, any()} | {:error, any()} | :ok | :error)) ::
          {:ok, any()} | {:error, any()} | :ok | :error
  def try_reduce(list, acc, f) do
    Enum.reduce_while(list, {:ok, acc}, fn elem, acc ->
      sub_acc =
        case acc do
          {:ok, sub_acc} -> sub_acc
          :ok -> nil
        end

      case f.(elem, sub_acc) do
        {:ok, new_sub_acc} -> {:cont, {:ok, new_sub_acc}}
        :ok -> {:cont, :ok}
        {:error, error} -> {:halt, {:error, error}}
        :error -> {:halt, :error}
      end
    end)
  end

  @doc """
  Tries to get a key from a map. If the key is not found, it returns an error.
  If the key is found, it returns {:ok, value}.


  ## Examples
      iex> Result.try_get(%{a: 1}, :a)
      {:ok, 1}

      iex> Result.try_get(%{a: 1}, :b)
      {:error, "Key ':b' is missing from map"}

      iex> Result.try_get(%{a: 1}, :a, "Custom error message")
      {:ok, 1}

      iex> Result.try_get(%{a: 1}, :b, "Custom error message")
      {:error, "Custom error message"}
  """
  @spec try_get(map(), any()) :: {:ok, any()} | {:error, any()} | :ok | :error
  def try_get(map, key, error_msg \\ nil) do
    cond do
      elem = Map.get(map, key) -> {:ok, elem}
      error_msg -> {:error, error_msg}
      true -> {:error, "Key '#{inspect(key)}' is missing from map"}
    end
  end
end
