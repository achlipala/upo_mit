fun r (s : string) : time = readError ("2022-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "01-24"
                       val classesDone = r "05-10"

                       val notable = (r "01-24", "Registration Week")
                                         :: (r "01-25", "Registration Week")
                                         :: (r "01-26", "Registration Week")
                                         :: (r "01-27", "Registration Week")
                                         :: (r "01-28", "Registration Week")
                                         :: (r "01-31", "First Day of Classes")
                                         :: (r "02-04", "Registration Deadline")
                                         :: (r "02-21", "Presidents Day - Holiday")
                                         :: (r "02-22", "Monday Schedule of Classes")
                                         :: (r "03-04", "Add Date")
                                         :: (r "03-21", "Spring Break")
                                         :: (r "03-22", "Spring Break")
                                         :: (r "03-23", "Spring Break")
                                         :: (r "03-24", "Spring Break")
                                         :: (r "03-25", "Spring Break")
                                         :: (r "04-07", "Campus Preview Weekend")
                                         :: (r "04-08", "Campus Preview Weekend")
                                         :: (r "04-09", "Campus Preview Weekend")
                                         :: (r "04-10", "Campus Preview Weekend")
                                         :: (r "04-11", "Campus Preview Weekend")
                                         :: (r "04-18", "Patriots Day - No Classes")
                                         :: (r "04-19", "Drop Date")
                                         :: (r "05-10", "Last Day of Classes")
                                         :: []
                   end)
