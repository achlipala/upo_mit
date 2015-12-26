(* Assignment of final grades, with export in MIT Online Grades format *)

open Bootstrap3

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
             end) = struct

    open M

    val show_commonName = mkShow (fn {UserName = s} => s)

    con letters = _
    val letters : $(mapU string letters) =
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

    structure FG = FinalGrades.Make(struct
        con key = [UserName = string]
        val tab = users
        val filter = (WHERE tab.IsStudent)

        type summaries = list (string * int)
        type summary = int
        fun summary sms u = Option.get 0 (List.assoc u.UserName sms)

        val grades = letters

        val keyLabel = "Student"
        val summaryLabel = "Average"
        val gradeLabel = "Grade"

        val access = access
    end)

    val summaries =
        all_grades <- Grades.allStudents grades;
        return (Grades.averagesOf all_grades)

    val eq_UserName = mkEq (fn {UserName = s1 : string} {UserName = s2 : string} => s1 = s2)

    val csv =
        acc <- access;
        case acc of
            FinalGrades.Forbidden => error <xml>Access denied</xml>
          | _ =>
            sms <- summaries;
            grs <- FG.grades sms;

            sheet <- query (SELECT users.MitId, users.UserName, users.Units, users.SubjectNum, users.SectionNum, users.LastName, users.FirstName, users.MiddleInitial
                            FROM users
                            WHERE users.IsStudent
                              AND users.MitId <> ''
                            ORDER BY users.LastName, users.FirstName, users.MiddleInitial)
                     (fn {Users = r} sheet =>
                         let
                             val grade =
                                 case List.assoc {UserName = r.UserName} grs of
                                     None => error <xml>No grade found for {[r.UserName]}!</xml>
                                   | Some g =>
                                     @@Record.select [fn _ => string] [fn _ => unit] [letters] _ [string]
                                     (fn [u] (text : string) () => text)
                                     letters g

                             val row = r.LastName ^ "," ^ r.FirstName ^ "," ^ r.MiddleInitial ^ "," ^ r.MitId ^ "," ^ r.SubjectNum ^ "," ^ r.SectionNum ^ "," ^ grade ^ "," ^ r.Units ^ ",\n"
                         in
                             return (sheet ^ row)
                         end)
                     "Last Name,First Name,Middle,MIT ID,Subject #,Section #,Grade,Units,Comment\n";

            returnBlob (textBlob sheet) (blessMime "text/csv")

    type a = _
    val ui = Ui.seq (Ui.computed FG.ui summaries,
                     Ui.const <xml><a class="btn btn-primary"
                                      link={csv}>Export for MIT Online Grade Submission</a></xml>)

end
