defmodule Testiroom.ExamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Testiroom.Exams` context.
  """

  alias Testiroom.AccountsFixtures

  @doc """
  Generate a test.
  """
  def test_fixture(attrs \\ %{}, maybe_user \\ nil) do
    user = maybe_user || AccountsFixtures.user_fixture()

    {:ok, test} =
      attrs
      |> Enum.into(%{
        description: "some description",
        duration_in_seconds: 42,
        ends_at: ~N[2023-12-05 18:21:00],
        show_answer_for_student: true,
        show_correctness_for_student: true,
        show_grade_for_student: true,
        show_score_for_student: true,
        starts_at: ~N[2023-12-05 18:21:00],
        title: "some title"
      })
      |> Testiroom.Exams.create_test(user)

    test
  end

  @doc """
  Generate a grade.
  """
  def grade_fixture(attrs \\ %{}) do
    {:ok, grade} =
      attrs
      |> Enum.into(%{
        from: 42,
        grade: "some grade"
      })
      |> Testiroom.Exams.create_grade()

    grade
  end

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        media_path: "some media_path",
        order: 42,
        question: "some question",
        score: 42,
        shuffle_options: true,
        type: :mulitple
      })
      |> Testiroom.Exams.create_task()

    task
  end

  @doc """
  Generate a option.
  """
  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        is_correct: true,
        text: "some text"
      })
      |> Testiroom.Exams.create_option()

    option
  end
end
