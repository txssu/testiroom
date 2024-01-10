defmodule Testiroom.Proctoring.Dispatcher do
  @moduledoc false
  defmacro __using__([]) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :handlers, accumulate: true)
    end
  end

  defmacro __before_compile__(%{module: module}) do
    handlers_data =
      module
      |> Module.get_attribute(:handlers)
      |> init_handlers()

    struct = build_struct(handlers_data)
    handlers = build_handlers(handlers_data)

    quote do
      unquote(struct)

      def handle(data, %event_type{} = event) do
        do_handle(event_type, event, data)
      end

      unquote(handlers)
    end
  end

  defmacro handle(type, module, options \\ []) do
    quote do
      @handlers {unquote(type), unquote(module), unquote(options)}
    end
  end

  defp init_handlers(handlers_data) do
    Enum.map(handlers_data, fn {type, module, init_options} ->
      {:ok, call_options, fields} = module.init(init_options)
      {type, module, call_options, fields}
    end)
  end

  defp build_handlers(handlers_data) do
    handlers_data
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {_type, data} -> build_handler(data) end)
  end

  defp build_handler(data) do
    type = data |> List.first() |> elem(0)
    modules = Enum.map(data, fn {_type, module, options, _fields} -> {module, options} end)

    quote do
      defp do_handle(unquote(type), event, %__MODULE__{} = data) do
        Enum.reduce(unquote(modules), data, fn {module, options}, acc -> module.call(acc, event, options) end)
      end
    end
  end

  defp build_struct(handlers_data) do
    fields =
      handlers_data
      |> Enum.flat_map(&elem(&1, 3))
      |> Enum.dedup_by(&elem(&1, 0))

    quote do
      defstruct unquote(fields)
    end
  end
end
