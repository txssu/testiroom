defmodule Testiroom.ExamsFixtures do
  alias Testiroom.Exams.{Task, Test, StudentAnswer}

  @correct "correct"

  def test_fixture(title \\ "Some test") do
    Test.new(title)
  end

  def task_fixture(fields \\ []) do
    fields
    |> Keyword.merge(question: "Some question")
    |> Task.new()
  end

  def add_text_answer(task, answer \\ @correct) do
    task
    |> Map.put(:type, :text)
    |> Task.add_text_answer(answer)
  end

  def add_checkbox_answer(task, text \\ @correct, correct? \\ true) do
    task
    |> Map.put(:type, :checkbox)
    |> Task.add_option(text, correct?)
  end

  def add_radio_answer(task, text \\ @correct, correct? \\ true) do
    task
    |> Map.put(:type, :radio)
    |> Task.add_option(text, correct?)
  end

  def student_answer_text_fixture(task, text \\ @correct) do
    StudentAnswer.new_with_text(task, text)
  end

  def student_answer_options_fixture(task, select_correct? \\ true) do
    options = Enum.filter(task.options, & &1.is_correct == select_correct?)

    Enum.reduce(
      options,
      StudentAnswer.new_with_options(task),
      &StudentAnswer.select_option(&2, &1)
    )
  end
end
