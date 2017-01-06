fun r (s : string) : time = readError ("2017-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "02-06"
                       val classesDone = r "05-18"

                       val notable = (r "02-06", "Registration Day")
                                         :: (r "02-07", "First Day of Classes")
                                         :: (r "02-05", "Registration Deadline")
                                         :: (r "02-10", "Presidents Day - Holiday")
                                         :: (r "02-21", "Monday Schedule of Classes")
                                         :: (r "03-10", "Add Date")
                                         :: (r "03-27", "Spring Vacation")
                                         :: (r "03-28", "Spring Vacation")
                                         :: (r "03-29", "Spring Vacation")
                                         :: (r "03-30", "Spring Vacation")
                                         :: (r "03-31", "Spring Vacation")
                                         :: (r "04-06", "Campus Preview Weekend")
                                         :: (r "04-07", "Campus Preview Weekend")
                                         :: (r "04-08", "Campus Preview Weekend")
                                         :: (r "04-09", "Campus Preview Weekend")
                                         :: (r "04-17", "Patriots Day - Vacation")
                                         :: (r "04-18", "Patriots Day - Vacation")
                                         :: (r "04-27", "Drop Date")
                                         :: (r "05-18", "Last Day of Classes")
                                         :: []
                   end)
