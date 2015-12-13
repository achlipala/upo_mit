(* A simple course *)

open Bootstrap3
structure Theme = Ui.Make(Default)

structure Cal = Calendar.Make(struct
                                  val t = Spring2016.cal
                              end)

val main =
    Theme.simple "Course Home Page"
    (Cal.ui {FromDay = Spring2016.regDay,
             ToDay = Spring2016.classesDone})
