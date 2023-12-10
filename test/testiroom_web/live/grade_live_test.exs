defmodule TestiroomWeb.GradeLiveTest do
  use TestiroomWeb.ConnCase

  import Phoenix.LiveViewTest
  import Testiroom.ExamsFixtures

  @create_attrs %{from: 42, grade: "some grade"}
  @update_attrs %{from: 43, grade: "some updated grade"}
  @invalid_attrs %{from: nil, grade: nil}

  defp create_grade(_context) do
    grade = grade_fixture()
    %{grade: grade}
  end

  describe "Index" do
    setup [:create_grade]

    test "lists all grades", %{conn: conn, grade: grade} do
      {:ok, _index_live, html} = live(conn, ~p"/grades")

      assert html =~ "Listing Grades"
      assert html =~ grade.grade
    end

    test "saves new grade", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/grades")

      assert index_live |> element("a", "New Grade") |> render_click() =~
               "New Grade"

      assert_patch(index_live, ~p"/grades/new")

      assert index_live
             |> form("#grade-form", grade: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#grade-form", grade: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/grades")

      html = render(index_live)
      assert html =~ "Grade created successfully"
      assert html =~ "some grade"
    end

    test "updates grade in listing", %{conn: conn, grade: grade} do
      {:ok, index_live, _html} = live(conn, ~p"/grades")

      assert index_live |> element("#grades-#{grade.id} a", "Edit") |> render_click() =~
               "Edit Grade"

      assert_patch(index_live, ~p"/grades/#{grade}/edit")

      assert index_live
             |> form("#grade-form", grade: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#grade-form", grade: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/grades")

      html = render(index_live)
      assert html =~ "Grade updated successfully"
      assert html =~ "some updated grade"
    end

    test "deletes grade in listing", %{conn: conn, grade: grade} do
      {:ok, index_live, _html} = live(conn, ~p"/grades")

      assert index_live |> element("#grades-#{grade.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#grades-#{grade.id}")
    end
  end

  describe "Show" do
    setup [:create_grade]

    test "displays grade", %{conn: conn, grade: grade} do
      {:ok, _show_live, html} = live(conn, ~p"/grades/#{grade}")

      assert html =~ "Show Grade"
      assert html =~ grade.grade
    end

    test "updates grade within modal", %{conn: conn, grade: grade} do
      {:ok, show_live, _html} = live(conn, ~p"/grades/#{grade}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Grade"

      assert_patch(show_live, ~p"/grades/#{grade}/show/edit")

      assert show_live
             |> form("#grade-form", grade: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#grade-form", grade: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/grades/#{grade}")

      html = render(show_live)
      assert html =~ "Grade updated successfully"
      assert html =~ "some updated grade"
    end
  end
end
