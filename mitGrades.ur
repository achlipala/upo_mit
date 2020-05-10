(* Assignment of final grades, with export in MIT Online Grades format *)

open Bootstrap4

open MitGradesGeneric.Make(struct
                               con grades = _
                               val grades : $(mapU string grades) =
                                   {Aplus = "A+",
                                    A = "A",
                                    Aminus = "A-",
                                    Bplus = "B+",
                                    B = "B",
                                    Bminus = "B-",
                                    Cplus = "C+",
                                    C = "C",
                                    Cminus = "C-",
                                    D = "D",
                                    F = "F",
                                    I = "I",
                                    O = "O"}
                           end)
