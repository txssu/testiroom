defmodule Testiroom.ExamsTest do
  use Testiroom.DataCase

  alias Testiroom.Exams

  describe "tests" do
    import Testiroom.AccountsFixtures, only: [user_fixture: 0]
    import Testiroom.ExamsFixtures

    alias Testiroom.Exams.Test

    @invalid_attrs %{
      description: nil,
      title: nil,
      starts_at: nil,
      ends_at: nil,
      duration_in_seconds: nil,
      show_correctness_for_student: nil,
      show_score_for_student: nil,
      show_grade_for_student: nil,
      show_answer_for_student: nil
    }

    # test "list_tests/0 returns all tests" do
    #   test = test_fixture()
    #   assert Exams.list_tests() == [test]
    # end

    test "get_test!/1 returns the test with given id" do
      test = test_fixture()
      assert Exams.get_test!(test.id) == test
    end

    test "create_test/1 with valid data creates a test" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        starts_at: ~N[2023-12-05 18:21:00],
        ends_at: ~N[2023-12-05 18:21:00],
        duration_in_seconds: 42,
        show_correctness_for_student: true,
        show_score_for_student: true,
        show_grade_for_student: true,
        show_answer_for_student: true
      }

      user = user_fixture()

      assert {:ok, %Test{} = test} = Exams.create_test(valid_attrs, user)
      assert test.description == "some description"
      assert test.title == "some title"
      assert test.starts_at == ~N[2023-12-05 18:21:00]
      assert test.ends_at == ~N[2023-12-05 18:21:00]
      assert test.duration_in_seconds == 42
      assert test.show_correctness_for_student == true
      assert test.show_score_for_student == true
      assert test.show_grade_for_student == true
      assert test.show_answer_for_student == true
    end

    test "create_test/1 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} = Exams.create_test(@invalid_attrs, user)
    end

    test "update_test/2 with valid data updates the test" do
      test = test_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        starts_at: ~N[2023-12-06 18:21:00],
        ends_at: ~N[2023-12-06 18:21:00],
        duration_in_seconds: 43,
        show_correctness_for_student: false,
        show_score_for_student: false,
        show_grade_for_student: false,
        show_answer_for_student: false
      }

      assert {:ok, %Test{} = test} = Exams.update_test(test, update_attrs)
      assert test.description == "some updated description"
      assert test.title == "some updated title"
      assert test.starts_at == ~N[2023-12-06 18:21:00]
      assert test.ends_at == ~N[2023-12-06 18:21:00]
      assert test.duration_in_seconds == 43
      assert test.show_correctness_for_student == false
      assert test.show_score_for_student == false
      assert test.show_grade_for_student == false
      assert test.show_answer_for_student == false
    end

    test "update_test/2 with invalid data returns error changeset" do
      test = test_fixture()
      assert {:error, %Ecto.Changeset{}} = Exams.update_test(test, @invalid_attrs)
      assert test == Exams.get_test!(test.id)
    end

    test "delete_test/1 deletes the test" do
      test = test_fixture()
      assert {:ok, %Test{}} = Exams.delete_test(test)
      assert_raise Ecto.NoResultsError, fn -> Exams.get_test!(test.id) end
    end

    test "change_test/1 returns a test changeset" do
      test = test_fixture()
      assert %Ecto.Changeset{} = Exams.change_test(test)
    end
  end

  describe "grades" do
    import Testiroom.ExamsFixtures

    alias Testiroom.Exams.Grade

    @invalid_attrs %{from: nil, grade: nil}

    test "list_grades/0 returns all grades" do
      grade = grade_fixture()
      assert Exams.list_grades() == [grade]
    end

    test "get_grade!/1 returns the grade with given id" do
      grade = grade_fixture()
      assert Exams.get_grade!(grade.id) == grade
    end

    test "create_grade/1 with valid data creates a grade" do
      valid_attrs = %{from: 42, grade: "some grade"}

      assert {:ok, %Grade{} = grade} = Exams.create_grade(valid_attrs)
      assert grade.from == 42
      assert grade.grade == "some grade"
    end

    test "create_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exams.create_grade(@invalid_attrs)
    end

    test "update_grade/2 with valid data updates the grade" do
      grade = grade_fixture()
      update_attrs = %{from: 43, grade: "some updated grade"}

      assert {:ok, %Grade{} = grade} = Exams.update_grade(grade, update_attrs)
      assert grade.from == 43
      assert grade.grade == "some updated grade"
    end

    test "update_grade/2 with invalid data returns error changeset" do
      grade = grade_fixture()
      assert {:error, %Ecto.Changeset{}} = Exams.update_grade(grade, @invalid_attrs)
      assert grade == Exams.get_grade!(grade.id)
    end

    test "delete_grade/1 deletes the grade" do
      grade = grade_fixture()
      assert {:ok, %Grade{}} = Exams.delete_grade(grade)
      assert_raise Ecto.NoResultsError, fn -> Exams.get_grade!(grade.id) end
    end

    test "change_grade/1 returns a grade changeset" do
      grade = grade_fixture()
      assert %Ecto.Changeset{} = Exams.change_grade(grade)
    end
  end

  describe "tasks" do
    import Testiroom.ExamsFixtures

    alias Testiroom.Exams.Task

    @invalid_attrs %{type: nil, order: nil, question: nil, media_path: nil, shuffle_options: nil, score: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Exams.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Exams.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{type: :mulitple, order: 42, question: "some question", media_path: "some media_path", shuffle_options: true, score: 42}

      assert {:ok, %Task{} = task} = Exams.create_task(valid_attrs)
      assert task.type == :mulitple
      assert task.order == 42
      assert task.question == "some question"
      assert task.media_path == "some media_path"
      assert task.shuffle_options == true
      assert task.score == 42
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exams.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{type: :single, order: 43, question: "some updated question", media_path: "some updated media_path", shuffle_options: false, score: 43}

      assert {:ok, %Task{} = task} = Exams.update_task(task, update_attrs)
      assert task.type == :single
      assert task.order == 43
      assert task.question == "some updated question"
      assert task.media_path == "some updated media_path"
      assert task.shuffle_options == false
      assert task.score == 43
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Exams.update_task(task, @invalid_attrs)
      assert task == Exams.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Exams.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Exams.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Exams.change_task(task)
    end
  end

  describe "task_options" do
    import Testiroom.ExamsFixtures

    alias Testiroom.Exams.Option

    @invalid_attrs %{text: nil, is_correct: nil}

    test "list_task_options/0 returns all task_options" do
      option = option_fixture()
      assert Exams.list_task_options() == [option]
    end

    test "get_option!/1 returns the option with given id" do
      option = option_fixture()
      assert Exams.get_option!(option.id) == option
    end

    test "create_option/1 with valid data creates a option" do
      valid_attrs = %{text: "some text", is_correct: true}

      assert {:ok, %Option{} = option} = Exams.create_option(valid_attrs)
      assert option.text == "some text"
      assert option.is_correct == true
    end

    test "create_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exams.create_option(@invalid_attrs)
    end

    test "update_option/2 with valid data updates the option" do
      option = option_fixture()
      update_attrs = %{text: "some updated text", is_correct: false}

      assert {:ok, %Option{} = option} = Exams.update_option(option, update_attrs)
      assert option.text == "some updated text"
      assert option.is_correct == false
    end

    test "update_option/2 with invalid data returns error changeset" do
      option = option_fixture()
      assert {:error, %Ecto.Changeset{}} = Exams.update_option(option, @invalid_attrs)
      assert option == Exams.get_option!(option.id)
    end

    test "delete_option/1 deletes the option" do
      option = option_fixture()
      assert {:ok, %Option{}} = Exams.delete_option(option)
      assert_raise Ecto.NoResultsError, fn -> Exams.get_option!(option.id) end
    end

    test "change_option/1 returns a option changeset" do
      option = option_fixture()
      assert %Ecto.Changeset{} = Exams.change_option(option)
    end
  end
end
