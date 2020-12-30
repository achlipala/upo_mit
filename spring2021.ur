fun r (s : string) : time = readError ("2021-" ^ s ^ " 12:00:00")

open Semester.Make(struct
                       val regDay = r "02-08"
                       val classesDone = r "05-20"

                       val notable = (r "02-08", "Registration Week")
                                         :: (r "02-09", "Registration Week")
                                         :: (r "02-10", "Registration Week")
                                         :: (r "02-11", "Registration Week")
                                         :: (r "02-12", "Registration Week")
                                         :: (r "02-15", "Presidents Day - Holiday")
                                         :: (r "02-16", "First Day of Classes")
                                         :: (r "02-19", "Registration Deadline")
                                         :: (r "03-08", "Student Holiday - No Classes")
                                         :: (r "03-09", "Monday Schedule of Classes")
                                         :: (r "03-19", "Add Date")
                                         :: (r "03-22", "Student Holiday - No Classes")
                                         :: (r "03-23", "Student Holiday - No Classes")
                                         :: (r "04-15", "Campus Preview Weekend")
                                         :: (r "04-16", "Campus Preview Weekend")
                                         :: (r "04-17", "Campus Preview Weekend")
                                         :: (r "04-18", "Campus Preview Weekend")
                                         :: (r "04-19", "Patriots Day - No Classes")
                                         :: (r "04-20", "Student Holiday - No Classes")
                                         :: (r "04-29", "Drop Date")
                                         :: (r "05-07", "Student Holiday - No Classes")
                                         :: (r "05-20", "Last Day of Classes")
                                         :: []
                   end)
