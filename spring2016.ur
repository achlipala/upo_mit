fun r (s : string) : time = readError ("2016-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "02-01"
                       val classesDone = r "05-13"

                       val notable = (r "02-01", "Registration Day")
                                         :: (r "02-02", "First Day of Classes")
                                         :: (r "02-05", "Registration Deadline")
                                         :: (r "02-15", "Presidents Day - Holiday")
                                         :: (r "02-16", "Monday Schedule of Classes")
                                         :: (r "03-04", "Add Date")
                                         :: (r "03-21", "Spring Vacation")
                                         :: (r "03-22", "Spring Vacation")
                                         :: (r "03-23", "Spring Vacation")
                                         :: (r "03-24", "Spring Vacation")
                                         :: (r "03-25", "Spring Vacation")
                                         :: (r "04-07", "Campus Preview Weekend")
                                         :: (r "04-08", "Campus Preview Weekend")
                                         :: (r "04-09", "Campus Preview Weekend")
                                         :: (r "04-10", "Campus Preview Weekend")
                                         :: (r "04-18", "Patriots Day - Vacation")
                                         :: (r "04-19", "Patriots Day - Vacation")
                                         :: (r "04-21", "Drop Date")
                                         :: (r "05-12", "Last Day of Classes")
                                         :: []
                   end)
