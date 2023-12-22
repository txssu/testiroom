defmodule Testiroom.Proctoring.Event do
  @moduledoc false
  defstruct [:type, :user_id, :order, :datetime]

  def new_open_task(user_id, order, datetime) do
    %__MODULE__{type: :open_task, user_id: user_id, order: order, datetime: datetime}
  end

  def new_wrap_up(user_id, datetime) do
    %__MODULE__{type: :wrap_up, user_id: user_id, datetime: datetime}
  end
end
