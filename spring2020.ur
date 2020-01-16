fun r (s : string) : time = readError ("2020-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "01-31"
                       val classesDone = r "05-18"

                       val notable = (r "01-31", "Registration Day")
                                         :: (r "02-03", "First Day of Classes")
                                         :: (r "02-07", "Registration Deadline")
                                         :: (r "02-17", "Presidents Day - Holiday")
                                         :: (r "02-18", "Monday Schedule of Classes")
                                         :: (r "03-06", "Add Date")
                                         :: (r "03-23", "Spring Vacation")
                                         :: (r "03-24", "Spring Vacation")
                                         :: (r "03-25", "Spring Vacation")
                                         :: (r "03-26", "Spring Vacation")
                                         :: (r "03-27", "Spring Vacation")
                                         :: (r "04-16", "Campus Preview Weekend")
                                         :: (r "04-17", "Campus Preview Weekend")
                                         :: (r "04-18", "Campus Preview Weekend")
                                         :: (r "04-19", "Campus Preview Weekend")
                                         :: (r "04-20", "Patriots Day - Vacation")
                                         :: (r "04-21", "Drop Date")
                                         :: (r "05-12", "Last Day of Classes")
                                         :: []
                   end)
