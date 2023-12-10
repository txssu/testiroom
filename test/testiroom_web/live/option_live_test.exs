defmodule TestiroomWeb.OptionLiveTest do
  use TestiroomWeb.ConnCase

  import Phoenix.LiveViewTest
  import Testiroom.ExamsFixtures

  @create_attrs %{text: "some text", is_correct: true}
  @update_attrs %{text: "some updated text", is_correct: false}
  @invalid_attrs %{text: nil, is_correct: false}

  defp create_option(_) do
    option = option_fixture()
    %{option: option}
  end

  describe "Index" do
    setup [:create_option]

    test "lists all task_options", %{conn: conn, option: option} do
      {:ok, _index_live, html} = live(conn, ~p"/task_options")

      assert html =~ "Listing Task options"
      assert html =~ option.text
    end

    test "saves new option", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/task_options")

      assert index_live |> element("a", "New Option") |> render_click() =~
               "New Option"

      assert_patch(index_live, ~p"/task_options/new")

      assert index_live
             |> form("#option-form", option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#option-form", option: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/task_options")

      html = render(index_live)
      assert html =~ "Option created successfully"
      assert html =~ "some text"
    end

    test "updates option in listing", %{conn: conn, option: option} do
      {:ok, index_live, _html} = live(conn, ~p"/task_options")

      assert index_live |> element("#task_options-#{option.id} a", "Edit") |> render_click() =~
               "Edit Option"

      assert_patch(index_live, ~p"/task_options/#{option}/edit")

      assert index_live
             |> form("#option-form", option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#option-form", option: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/task_options")

      html = render(index_live)
      assert html =~ "Option updated successfully"
      assert html =~ "some updated text"
    end

    test "deletes option in listing", %{conn: conn, option: option} do
      {:ok, index_live, _html} = live(conn, ~p"/task_options")

      assert index_live |> element("#task_options-#{option.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#task_options-#{option.id}")
    end
  end

  describe "Show" do
    setup [:create_option]

    test "displays option", %{conn: conn, option: option} do
      {:ok, _show_live, html} = live(conn, ~p"/task_options/#{option}")

      assert html =~ "Show Option"
      assert html =~ option.text
    end

    test "updates option within modal", %{conn: conn, option: option} do
      {:ok, show_live, _html} = live(conn, ~p"/task_options/#{option}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Option"

      assert_patch(show_live, ~p"/task_options/#{option}/show/edit")

      assert show_live
             |> form("#option-form", option: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#option-form", option: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/task_options/#{option}")

      html = render(show_live)
      assert html =~ "Option updated successfully"
      assert html =~ "some updated text"
    end
  end
end
