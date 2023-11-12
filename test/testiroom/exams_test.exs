defmodule Testiroom.ExamsTest do
  use Testiroom.DataCase

  import Testiroom.ExamsFixtures

  describe "student answer" do
    alias Testiroom.Exams.StudentAnswer

    test "text is correct" do
      student_answer =
        task_fixture()
        |> add_text_answer()
        |> student_answer_text_fixture()

      assert StudentAnswer.correct?(student_answer)
    end

    test "text is incorrect" do
      student_answer =
        task_fixture()
        |> add_text_answer()
        |> student_answer_text_fixture("incorrect")

      refute StudentAnswer.correct?(student_answer)
    end

    test "multiple correct answers" do
      task =
        task_fixture()
        |> add_text_answer("correct1")
        |> add_text_answer("correct2")
        |> add_text_answer("correct3")

      assert task |> student_answer_text_fixture("correct1") |> StudentAnswer.correct?()
      assert task |> student_answer_text_fixture("correct2") |> StudentAnswer.correct?()
      assert task |> student_answer_text_fixture("correct3") |> StudentAnswer.correct?()
    end

    test "radio is correct" do
      student_answer =
        task_fixture()
        |> add_radio_answer()
        |> add_radio_answer("incorrect", false)
        |> student_answer_options_fixture()

      assert StudentAnswer.correct?(student_answer)
    end

    test "radio is incorrect" do
      student_answer =
        task_fixture()
        |> add_radio_answer()
        |> add_radio_answer("incorrect", false)
        |> student_answer_options_fixture(false)

      refute StudentAnswer.correct?(student_answer)
    end

    test "checkbox is correct" do
      student_answer =
        task_fixture()
        |> add_checkbox_answer()
        |> student_answer_options_fixture()

      assert StudentAnswer.correct?(student_answer)
    end

    test "checkbox is incorrect" do
      student_answer =
        task_fixture()
        |> add_checkbox_answer()
        |> add_checkbox_answer("incorrect", false)
        |> student_answer_options_fixture(false)

      refute StudentAnswer.correct?(student_answer)
    end

    test "checkbox correct and incorrect" do
      task =
        task_fixture()
        |> add_checkbox_answer()
        |> add_checkbox_answer("incorrect", false)

      student_answer =
        Enum.reduce(
          task.options,
          StudentAnswer.new_with_options(task),
          &StudentAnswer.select_option(&2, &1)
        )

      refute StudentAnswer.correct?(student_answer)
    end
  end

  describe "student attempt" do
    alias Testiroom.Exams.{Test, StudentAttempt, StudentAnswer}

    test "selected first task" do
      task = task_fixture()

      test =
        test_fixture()
        |> Test.add_task(task)

      attempt = StudentAttempt.new(test)

      assert attempt.current_task == task
      assert attempt.variant[0] == task
      assert attempt.current_answer == nil
    end

    test "answering is working" do
      task =
        task_fixture()
        |> add_text_answer()

      test =
        test_fixture()
        |> Test.add_task(task)

      answer = student_answer_text_fixture(task)

      attempt =
        test
        |> StudentAttempt.new()
        |> StudentAttempt.answer_task(answer)

      assert attempt.current_answer == answer
    end
  end
end
