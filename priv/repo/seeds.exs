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

Repo.insert!(%Exams.Test{
  title: "Контрольная работа по математике №1",
  author_id: Ecto.UUID.generate(),
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
      question: "Сколько различных корней имеет уравнение x^2-2=0?",
      options: [
        %Exams.Task.Option{text: "2", is_correct: true},
        %Exams.Task.Option{text: "два", is_correct: true},
        %Exams.Task.Option{text: "два корня", is_correct: true},
        %Exams.Task.Option{text: "два различных корня", is_correct: true}
      ]
    },
    %Exams.Task{
      type: :checkbox,
      question: "Выберете верные утверждения",
      options: [
        %Exams.Task.Option{
          text: "Если числитель уменьшить в 7 раз, то дробь увеличится в 7 раз",
          is_correct: true
        },
        %Exams.Task.Option{
          text: "При умножении целого числа на нецелое число всегда получается целое число",
          is_correct: true
        },
        %Exams.Task.Option{
          text: "Если знаменатель уменьшить в 5 раз, то дробь увеличится в 5 раз",
          is_correct: true
        },
        %Exams.Task.Option{
          text:
            "Если числитель и знаменатель дроби разделить на 8,то значение дроби не изменится",
          is_correct: true
        }
      ]
    }
  ]
})
