# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Testiroom.Repo.insert!(%Testiroom.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Testiroom.Repo
alias Testiroom.Exams

Repo.delete_all(Exams.Test)

test =
  Repo.insert!(%Exams.Test{
    title: "Контрольная работа по математике №1",
    tasks: [
      %Exams.Task{
        type: :radio,
        question: "Сколько различных прямых может проходить через две произвольные точки?",
        options: [
          %Exams.Task.Option{text: "0", is_correct: false},
          %Exams.Task.Option{text: "1", is_correct: true},
          %Exams.Task.Option{text: "2", is_correct: false},
          %Exams.Task.Option{text: "Бесконечное множество", is_correct: false}
        ]
      },
      %Exams.Task{
        type: :text,
        question: "Сколько решений имеет уравнение x^2-2=0?",
        text_answers: [
          %Exams.Task.TextAnswer{
            text: "2"
          }
        ]
      },
      %Exams.Task{
        type: :checkbox,
        question: "Выбирайте",
        options: [
          %Exams.Task.Option{text: "Да", is_correct: false},
          %Exams.Task.Option{text: "Нет", is_correct: true},
          %Exams.Task.Option{text: "Нет", is_correct: true},
          %Exams.Task.Option{text: "Да", is_correct: false}
        ]
      }
    ]
  })
