defmodule ConformCodeTest do
  use ExUnit.Case

  test "can stringify function and case blocks" do
    single_fun_str = """
    fn val ->
      case val do
        :foo ->
          bar = String.to_atom("bar")
          bar
        :baz -> :qux
      end
    end
    """
    single_fun_formatted = """
    fn val ->
      case(val) do
        :foo ->
          bar = String.to_atom("bar")
          bar
        :baz ->
          :qux
      end
    end
    """
    multi_fun_str = """
    fn
      :foo -> bar
      val ->
        case val do
          :baz -> :qux
          _    ->
            result = val |> String.to_atom
            result
        end
    end
    """
    multi_fun_formatted = """
    fn
      :foo ->
        bar
      val ->
        case(val) do
          :baz ->
            :qux
          _ ->
            result = val |> String.to_atom()
            result
        end
    end
    """

    {:ok, single_fun} = single_fun_str |> Code.string_to_quoted
    {:ok, multi_fun}  = multi_fun_str  |> Code.string_to_quoted

    assert single_fun_formatted == (single_fun |> Conform.Utils.Code.stringify)
    assert multi_fun_formatted  == (multi_fun |> Conform.Utils.Code.stringify)
  end

  test "can stringify strings" do
    singleline      = "Doing stuff and things."
    single_expected = "\"Doing stuff and things.\"\n"
    multiline  = """
    Determine the type of thing.
    * active: it's going to be active
    * passive: it's going to be passive
    * active-debug: it's going to be active, with verbose debugging information
    Just testing "nested quotes"
    """
    multi_expected = """
    \"\"\"
      Determine the type of thing.
      * active: it's going to be active
      * passive: it's going to be passive
      * active-debug: it's going to be active, with verbose debugging information
      Just testing "nested quotes"
      \"\"\"
    """

    {:ok, singleline_quoted} = singleline |> Macro.to_string |> Code.string_to_quoted
    {:ok, multiline_quoted}  = multiline |> Macro.to_string |> Code.string_to_quoted
    assert single_expected == (singleline_quoted |> Conform.Utils.Code.stringify)
    assert multi_expected  == (multiline_quoted |> Conform.Utils.Code.stringify)
  end

  test "can stringify complex datastructures" do
    data = """
    ["myapp.another_val": [
      to:       "myapp.another_val",
      datatype: [enum: [:active, :passive, :'active-debug']],
      default:  %{test: :foo},
      doc: \"\"\"
      Determine the type of thing.
      * active: it's going to be active
      * passive: it's going to be passive
      * active-debug: it's going to be active, with verbose debugging information
      \"\"\"
    ]]
    """

    expected = """
    [
      "myapp.another_val": [
        to: "myapp.another_val",
        datatype: [
          enum: [
            :active,
            :passive,
            :"active-debug"
          ]
        ],
        default: %{test: :foo},
        doc: \"\"\"
          Determine the type of thing.
          * active: it's going to be active
          * passive: it's going to be passive
          * active-debug: it's going to be active, with verbose debugging information
          \"\"\"
      ]
    ]
    """

    {:ok, quoted} = data |> Code.string_to_quoted
    assert expected == (quoted |> Conform.Utils.Code.stringify)
  end

  test "can stringify function/case blocks mixed with datastructures" do
    data = """
    [translations: [
      "myapp.another_val": fn
        :foo -> :bar
        val ->
          case val do
            :active ->
              data = %{log: :warn}
              more_data = %{data | :log => :warn}
              {:on, [data: data]}
            :'active-debug' -> {:on, [debug: true]}
            :passive        -> {:off, []}
            _               -> {:on, []}
          end
      end,
      "myapp.some_val": fn
        :foo -> :bar
        val ->
          case val do
            :foo -> :bar
            _    -> val
          end
      end
    ]]
    """

    expected = """
    [
      translations: [
        "myapp.another_val": fn
          :foo ->
            :bar
          val ->
            case(val) do
              :active ->
                data = %{log: :warn}
                more_data = %{data | log: :warn}
                {:on, [data: data]}
              :"active-debug" ->
                {:on, [debug: true]}
              :passive ->
                {:off, []}
              _ ->
                {:on, []}
            end
        end,
        "myapp.some_val": fn
          :foo ->
            :bar
          val ->
            case(val) do
              :foo ->
                :bar
              _ ->
                val
            end
        end
      ]
    ]
    """

    {:ok, quoted} = data |> Code.string_to_quoted
    assert expected == (quoted |> Conform.Utils.Code.stringify)
  end

  test "can stringify a complex schema file" do
    Path.join(["test", "schemas", "test.schema.exs"])
    |> Path.expand
    |> Conform.Schema.read!
    |> Conform.Utils.Code.stringify
    
    assert true
  end
end