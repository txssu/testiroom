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

test = Testiroom.Repo.insert!(%Test{title: "Контрольная работа по математике №1"})

Testiroom.Repo.insert!(%Task{
  type: :shortanswer,
  question: "Сколько будет 2+2?",
  order: 1,
  answer: "4",
  test_id: test.id
})

Testiroom.Repo.insert!(%Task{
  type: :shortanswer,
  question: "Сколько будет 7+1?",
  order: 2,
  answer: "8",
  test_id: test.id
})

Testiroom.Repo.insert!(%Task{
  type: :shortanswer,
  question: "Сколько будет 8-3?",
  order: 3,
  answer: "5",
  test_id: test.id
})
