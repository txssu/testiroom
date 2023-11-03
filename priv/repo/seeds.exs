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

alias Testiroom.Exams.Test
alias Testiroom.Exams.Task
alias Testiroom.Exams.TaskOption

test = Testiroom.Repo.insert!(%Test{title: "Контрольная работа по математике №1"})

Testiroom.Repo.insert!(%Task{
  type: :shortanswer,
  question: "Сколько будет 2+2?",
  order: 0,
  answer: "4",
  test_id: test.id
})

task =
  Testiroom.Repo.insert!(%Task{
    type: :single,
    question: "Верно ли утверждение, что через три точки всегда можно провести ровно одну прямую?",
    order: 1,
    test_id: test.id
  })

Testiroom.Repo.insert!(%TaskOption{
  task_id: task.id,
  text: "Верно",
  is_correct: false
})

Testiroom.Repo.insert!(%TaskOption{
  task_id: task.id,
  text: "Неверно",
  is_correct: true
})


task =
  Testiroom.Repo.insert!(%Task{
    type: :multiple,
    question: "Выберете все ответы, где x = 1 является решением уравнения.",
    order: 2,
    test_id: test.id
  })

Testiroom.Repo.insert!(%TaskOption{
  task_id: task.id,
  text: "x + 1 = 1",
  is_correct: false
})

Testiroom.Repo.insert!(%TaskOption{
  task_id: task.id,
  text: "2 - x = 1",
  is_correct: true
})

Testiroom.Repo.insert!(%TaskOption{
  task_id: task.id,
  text: "x - 1 = 0",
  is_correct: true
})
