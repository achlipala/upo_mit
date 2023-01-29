fun r (s : string) : time = readError ("2023-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "01-30"
                       val classesDone = r "05-16"

                       val notable = (r "01-30", "Registration Week")
                                         :: (r "01-31", "Registration Week")
                                         :: (r "02-01", "Registration Week")
                                         :: (r "02-02", "Registration Week")
                                         :: (r "02-03", "Registration Week")
                                         :: (r "02-06", "First Day of Classes")
                                         :: (r "02-10", "Registration Deadline")
                                         :: (r "02-20", "Presidents Day - Holiday")
                                         :: (r "02-21", "Monday Schedule of Classes")
                                         :: (r "03-10", "Add Date")
                                         :: (r "03-27", "Spring Break")
                                         :: (r "03-28", "Spring Break")
                                         :: (r "03-29", "Spring Break")
                                         :: (r "03-30", "Spring Break")
                                         :: (r "03-31", "Spring Break")
                                         :: (r "04-13", "Campus Preview Weekend")
                                         :: (r "04-14", "Campus Preview Weekend")
                                         :: (r "04-15", "Campus Preview Weekend")
                                         :: (r "04-16", "Campus Preview Weekend")
                                         :: (r "04-17", "Patriots Day - No Classes")
                                         :: (r "04-25", "Drop Date")
                                         :: (r "05-16", "Last Day of Classes")
                                         :: []
                   end)
