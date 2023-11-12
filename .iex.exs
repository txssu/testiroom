alias Testiroom.Exams
alias Testiroom.Exams.{Task, Test, StudentAnswer, StudentAttempt}

test = Test.new("New test")

task_1 =
  Task.new(type: :text, question: "What?")
  |> Task.add_text_answer("something")
  |> Task.add_text_answer("thing")

task_2 =
  Task.new(type: :radio, question: "What?")
  |> Task.add_option("correct", true)
  |> Task.add_option("incorrect", false)

test =
  test
  |> Test.add_task(task_1)
  |> Test.add_task(task_2)

user = %{id: 1}
