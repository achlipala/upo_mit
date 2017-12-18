fun r (s : string) : time = readError ("2018-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "02-06"
                       val classesDone = r "05-18"

                       val notable = (r "02-05", "Registration Day")
                                         :: (r "02-06", "First Day of Classes")
                                         :: (r "02-09", "Registration Deadline")
                                         :: (r "02-19", "Presidents Day - Holiday")
                                         :: (r "02-20", "Monday Schedule of Classes")
                                         :: (r "03-09", "Add Date")
                                         :: (r "03-26", "Spring Vacation")
                                         :: (r "03-27", "Spring Vacation")
                                         :: (r "03-28", "Spring Vacation")
                                         :: (r "03-29", "Spring Vacation")
                                         :: (r "03-30", "Spring Vacation")
                                         :: (r "04-12", "Campus Preview Weekend")
                                         :: (r "04-13", "Campus Preview Weekend")
                                         :: (r "04-14", "Campus Preview Weekend")
                                         :: (r "04-15", "Campus Preview Weekend")
                                         :: (r "04-16", "Patriots Day - Vacation")
                                         :: (r "04-17", "Patriots Day - Vacation")
                                         :: (r "04-26", "Drop Date")
                                         :: (r "05-17", "Last Day of Classes")
                                         :: []
                   end)
