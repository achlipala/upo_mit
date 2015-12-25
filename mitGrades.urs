(* Assignment of final grades, with export in MIT Online Grades format *)

functor Make(M : sig
                 con groups :: {Unit}
                 (* Boolean flags indicating membership in classes of users *)

                 con others :: {Type}
                 (* Miscellaneous remaining fields of the users table *)

                 constraint groups ~ others
                 constraint [MitId, UserName, IsStudent, Units, SubjectNum, SectionNum, LastName, FirstName, MiddleInitial, Grade, Min, Max] ~ (mapU bool groups ++ others)

                 con keyName :: Name
                 con otherKeys :: {{Unit}}
                 constraint [keyName] ~ otherKeys
                 val users : sql_table ([MitId = string, UserName = string, IsStudent = bool, Units = string, SubjectNum = string, SectionNum = string, LastName = string, FirstName = string, MiddleInitial = string] ++ mapU bool groups ++ others) ([keyName = [UserName]] ++ otherKeys)

                 val grades : Grades.t

                 (* Current user allowed to access grades interface? *)
                 val access : transaction FinalGrades.access
             end) : Ui.S0
