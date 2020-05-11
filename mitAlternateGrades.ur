(* Assignment of final grades, with export in MIT Online Grades format *)

open Bootstrap4

open MitGradesGeneric.Make(struct
                               con grades = _
                               val grades : $(mapU string grades) =
                                   {PE = "PE",
                                    NE = "NE",
                                    IE = "IE",
                                    O = "O"}
                           end)
