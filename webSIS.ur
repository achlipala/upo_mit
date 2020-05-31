open Bootstrap4

functor Make(M: sig
                 con others :: {Type}
                 constraint [Kerberos, MitId, UserName, IsStudent, IsListener, HasDropped, Units, SubjectNum, SectionNum, LastName, FirstName, MiddleInitial] ~ others

                 table user : ([Kerberos = string,
                                MitId = string,
                                UserName = string,
                                IsStudent = bool,
                                IsListener = bool,
                                HasDropped = bool,
                                Units = string,
                                SubjectNum = string,
                                SectionNum = string,
                                LastName = string,
                                FirstName = string,
                                MiddleInitial = string]
                                   ++ others)

                 val defaults : $others
                 val amAuthorized : transaction bool
                 val expectedSubjectNumber : string
                 val fl : folder others
                 val inj : $(map sql_injectable others)
             end) = struct

    open M

    fun trimField s =
        let
            val s = String.trim s
        in
            if String.length s >= 2 && String.sub s 0 = #"\"" && String.sub s (String.length s - 1) = #"\"" then
                String.trim (String.substring s {Start = 1, Len = String.length s - 2})
            else
                s
        end

    (* Find a subject number amidst a line like this one:
     * "  6.887            Adv Topics in Computer Systems    (entire class list)" *)
    fun findSubjectNum s =
        case String.split (trimField s) #" " of
            None => error <xml>No interior space character found on 2nd line of WebSIS data</xml>
          | Some (num, _) => num

    fun parse data =
        let
            fun skipLine s =
                case String.split s #"\n" of
                    None => error <xml>WebSIS data end too soon [2]</xml>
                  | Some (_, s) => s

            fun skipNonHeadingLines s =
                let
                    val s = trimField s
                in
                    if String.isPrefix {Full = s, Prefix = "MIT ID"} then
                        s
                    else
                        skipNonHeadingLines (skipLine s)
                end
        in
            (* Read the first line to check that we're looking at data for the right subject. *)
            case String.split (skipLine data) #"\n" of
                None => error <xml>WebSIS data end too soon [1]</xml>
              | Some (first, data) =>
                if findSubjectNum first <> expectedSubjectNumber then
                    error <xml>This WebSIS data dump is for another course!  It says "{[findSubjectNum first]}".</xml>
                else
                    let
                        (* The next lines do not concern us. *)
                        val data = skipNonHeadingLines data

                        (* Next, we need to parse the line of field headings. *)
                        fun findHeadings line acc =
                            case String.split line #"\t" of
                                None =>
                                let
                                    val heading = String.trim line

                                    val acc = if String.length heading > 0 then
                                                  heading :: acc
                                              else
                                                  acc
                                in
                                    List.rev acc
                                end
                              | Some (heading, line) => findHeadings line (String.trim heading :: acc)
                    in
                        case String.split data #"\n" of
                            None => error <xml>WebSIS data end too soon [3]</xml>
                          | Some (line, data) =>
                            let
                                val headings = findHeadings line []

                                (* The next line is filler, apparently intended to be easier on human eyes. *)
                                val data = skipLine data

                                (* Finally, we ready to parse lines of student data. *)
                                fun parseLine headings line fields =
                                    case headings of
                                        [] => fields
                                      | heading :: headings =>
                                        case String.split line #"\t" of
                                            None => (heading, trimField line) :: fields
                                          | Some (field, line) => parseLine headings line ((heading, trimField field) :: fields)

                                fun parseLines data acc =
                                    case String.split data #"\n" of
                                        None =>
                                        if String.all Char.isSpace data then
                                            acc
                                        else
                                            parseLine headings data [] :: acc
                                      | Some (line, data) =>
                                        if String.all Char.isSpace line then
                                            parseLines data acc
                                        else
                                            parseLines data (parseLine headings line [] :: acc)
                            in
                                parseLines data []
                            end
                    end
        end

    fun import data =
        let
            val students = parse data
        in
            b <- amAuthorized;
            (if not b then
                 error <xml>Access denied</xml>
             else
                 return ());
            List.app (fn alist =>
                         let
                             fun field name =
                                 case List.assoc name alist of
                                     None => error <xml>No "{[name]}" field in row of WebSIS data</xml>
                                   | Some v => v

                             fun fieldOpt name = Option.get "" (List.assoc name alist)

                             val email = field "Student Email"
                             val kerb = case String.split email #"@" of
                                                Some (kerb, "MIT.EDU") =>
                                                (* Admittedly hacky special case, to detect usernames in the separate namespace for Lincoln Lab *)
                                                if String.length kerb >= 5 && String.all Char.isDigit (String.substring kerb {Start = String.length kerb - 5, Len = 5}) then
                                                    kerb ^ "@LL.MIT.EDU"
                                                else
                                                    kerb
                                              | Some (kerb, "LL.MIT.EDU") => String.mp Char.toLower kerb ^ "@LL.MIT.EDU"
                                              | _ => email

                             (* Smart name concatenation, skipping blank parts *)
                             fun cat s1 s2 =
                                 case s1 of
                                     "" => s2
                                   | _ =>
                                     case s2 of
                                         "" => s1
                                       | _ => s1 ^ " " ^ s2

                             (* MIT client certificates leave out periods in middle initials, but WebSIS includes them.
                              * This function eats the periods. *)
                             fun eatPeriod s =
                                 if String.length s > 0 && String.sub s (String.length s - 1) = #"." then
                                     String.substring s {Start = 0, Len = String.length s - 1}
                                 else
                                     s

                             val status = Option.get "Reg" (List.assoc "Status" alist)

                             val data = {MitId = field "MIT ID",
                                         UserName = cat (field "Student First") (cat (eatPeriod (field "Student MI")) (field "Student Last")),
                                         IsStudent = status = "Reg",
                                         IsListener = status = "Lis",
                                         HasDropped = status = "Can",
                                         Units = fieldOpt "Units",
                                         SubjectNum = fieldOpt "Enrolled",
                                         SectionNum = fieldOpt "Section",
                                         LastName = field "Student Last",
                                         FirstName = field "Student First",
                                         MiddleInitial = field "Student MI"}
                         in
                             studentExists <- oneRowE1 (SELECT COUNT( * ) > 0
                                                        FROM user
                                                        WHERE user.Kerberos = {[kerb]});
                             if studentExists then
                                 Sql.easy_update'' user {Kerberos = kerb} data
                             else
                                 @@Sql.easy_insert [[Kerberos = string,
                                                     MitId = string,
                                                     UserName = string,
                                                     IsStudent = bool,
                                                     IsListener = bool,
                                                     HasDropped = bool,
                                                     Units = string,
                                                     SubjectNum = string,
                                                     SectionNum = string,
                                                     LastName = string,
                                                     FirstName = string,
                                                     MiddleInitial = string] ++ others] [_]
                                   (inj ++ _) (@Folder.concat ! fl _) user ({Kerberos = kerb} ++ data ++ defaults)
                         end) students
        end

    type a = source string

    val create = source ""

    fun onload _ = return ()

    fun render _ data = <xml>
        <p>Please copy and paste WebSIS's <b>ClassList Download</b> here.  To find it:</p>
        <ol>
          <li> Start from the <a href="http://websis.mit.edu/">WebSIS front page</a>.</li>
          <li> Follow the link "for Instructors and Departmental Administrators."</li>
          <li> Follow the link "Registered Student Class Lists" (or "Pre-registration Class Lists", before the semester starts).</li>
          <li> Select the term and subject and click the button "ClassList Download."</li>
          <li> The result masquerades as an Excel file but is really just TSV, suitable to paste here.</li>
        </ol>

        <p><button class="btn btn-primary"
                   value="Import"
                   onclick={fn _ => data <- get data; rpc (import data)}/></p>
        <ctextarea class="form-control" source={data} rows={20}/>
    </xml>

    fun notification _ _ = <xml></xml>

    val ui = {Create = create,
              Onload = onload,
              Render = render,
              Notification = notification}
end
