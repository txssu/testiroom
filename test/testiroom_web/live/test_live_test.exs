defmodule TestiroomWeb.TestLiveTest do
  use TestiroomWeb.ConnCase

  # import Phoenix.LiveViewTest
  # import Testiroom.ExamsFixtures

  # @create_attrs %{
  #   description: "some description",
  #   title: "some title",
  #   starts_at: "2023-12-05T18:21:00",
  #   ends_at: "2023-12-05T18:21:00",
  #   duration_in_seconds: 42,
  #   show_correctness_for_student: true,
  #   show_score_for_student: true,
  #   show_grade_for_student: true,
  #   show_answer_for_student: true
  # }
  # @update_attrs %{
  #   description: "some updated description",
  #   title: "some updated title",
  #   starts_at: "2023-12-06T18:21:00",
  #   ends_at: "2023-12-06T18:21:00",
  #   duration_in_seconds: 43,
  #   show_correctness_for_student: false,
  #   show_score_for_student: false,
  #   show_grade_for_student: false,
  #   show_answer_for_student: false
  # }
  # @invalid_attrs %{
  #   description: nil,
  #   title: nil,
  #   starts_at: nil,
  #   ends_at: nil,
  #   duration_in_seconds: nil,
  #   show_correctness_for_student: false,
  #   show_score_for_student: false,
  #   show_grade_for_student: false,
  #   show_answer_for_student: false
  # }

  # defp create_test(_context) do
  #   test = test_fixture()
  #   %{exam_test: test}
  # end

  # describe "Index" do
  #   setup [:create_test]

  #   test "lists all tests", %{conn: conn, exam_test: test} do
  #     {:ok, _index_live, html} = live(conn, ~p"/tests")

  #     assert html =~ "Listing Tests"
  #     assert html =~ test.description
  #   end

  #   test "saves new test", %{conn: conn} do
  #     {:ok, index_live, _html} = live(conn, ~p"/tests")

  #     assert index_live |> element("a", "New Test") |> render_click() =~
  #              "New Test"

  #     assert_patch(index_live, ~p"/tests/new")

  #     assert index_live
  #            |> form("#test-form", exam_test: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert index_live
  #            |> form("#test-form", exam_test: @create_attrs)
  #            |> render_submit()

  #     assert_patch(index_live, ~p"/tests")

  #     html = render(index_live)
  #     assert html =~ "Test created successfully"
  #     assert html =~ "some description"
  #   end

  #   test "updates test in listing", %{conn: conn, exam_test: test} do
  #     {:ok, index_live, _html} = live(conn, ~p"/tests")

  #     assert index_live |> element("#tests-#{test.id} a", "Edit") |> render_click() =~
  #              "Edit Test"

  #     assert_patch(index_live, ~p"/tests/#{test}/edit")

  #     assert index_live
  #            |> form("#test-form", exam_test: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert index_live
  #            |> form("#test-form", exam_test: @update_attrs)
  #            |> render_submit()

  #     assert_patch(index_live, ~p"/tests")

  #     html = render(index_live)
  #     assert html =~ "Test updated successfully"
  #     assert html =~ "some updated description"
  #   end

  #   test "deletes test in listing", %{conn: conn, exam_test: test} do
  #     {:ok, index_live, _html} = live(conn, ~p"/tests")

  #     assert index_live |> element("#tests-#{test.id} a", "Delete") |> render_click()
  #     refute has_element?(index_live, "#tests-#{test.id}")
  #   end
  # end

  # describe "Show" do
  #   setup [:create_test]

  #   test "displays test", %{conn: conn, exam_test: test} do
  #     {:ok, _show_live, html} = live(conn, ~p"/tests/#{test}")

  #     assert html =~ "Show Test"
  #     assert html =~ test.description
  #   end

  #   test "updates test within modal", %{conn: conn, exam_test: test} do
  #     {:ok, show_live, _html} = live(conn, ~p"/tests/#{test}")

  #     assert show_live |> element("a", "Edit") |> render_click() =~
  #              "Edit Test"

  #     assert_patch(show_live, ~p"/tests/#{test}/show/edit")

  #     assert show_live
  #            |> form("#test-form", exam_test: @invalid_attrs)
  #            |> render_change() =~ "can&#39;t be blank"

  #     assert show_live
  #            |> form("#test-form", exam_test: @update_attrs)
  #            |> render_submit()

  #     assert_patch(show_live, ~p"/tests/#{test}")

  #     html = render(show_live)
  #     assert html =~ "Test updated successfully"
  #     assert html =~ "some updated description"
  #   end
  # end
end
