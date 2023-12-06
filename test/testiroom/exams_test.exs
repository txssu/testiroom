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
    alias Testiroom.Exams.Grade

    import Testiroom.ExamsFixtures

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
end
