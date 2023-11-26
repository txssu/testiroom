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

Testiroom.Repo.delete_all(Testiroom.Exams.Test)

test =
  Testiroom.Repo.insert!(%Testiroom.Exams.Test{
    title: "Контрольная работа по математике №1",
    tasks: [
      %Testiroom.Exams.Task{
        type: :radio,
        question: "Сколько различных прямых может проходить через две произвольные точки?",
        options: [
          %Testiroom.Exams.Task.Option{text: "0", is_correct: false},
          %Testiroom.Exams.Task.Option{text: "1", is_correct: true},
          %Testiroom.Exams.Task.Option{text: "2", is_correct: false},
          %Testiroom.Exams.Task.Option{text: "Бесконечное множество", is_correct: false}
        ]
      },
      %Testiroom.Exams.Task{
        type: :text,
        question: "Сколько решений имеет уравнение x^2-2=0?",
        text_answers: [
          %Testiroom.Exams.Task.TextAnswer{
            text: "2"
          }
        ]
      }
    ]
  })

for task <- test.tasks do
  case task.type do
    :text ->
      answer = List.first(task.text_answers).text

      %Testiroom.Exams.StudentAnswer{task: task, text: answer}

    :radio ->
      option = Enum.find(task.options, & &1.is_correct)

      %Testiroom.Exams.StudentAnswer{
        task: task,
        selected_options: [option]
      }
  end
  |> Testiroom.Repo.insert!()
end
