(* Data associated with a semester at MIT *)

signature INPUT = sig
    val regDay : time
    val classesDone : time

    val notable : list (time * string)
end

signature OUTPUT = sig
    val regDay : time
    val classesDone : time

    con private
    val cal : Calendar.t [Notable = string] [Notable = private]
end

functor Make(M : INPUT) = struct
    open M

    table notables : { Notable : string, When : time }
      PRIMARY KEY When

    task initialize = fn () =>
         dml (DELETE FROM notables WHERE TRUE);
         List.app (fn (tm, s) => dml (INSERT INTO notables(Notable, When)
                                      VALUES ({[s]}, {[tm]}))) notable

    open Calendar.FromTable(struct
                                con tag = #Notable
                                con key = [Notable = (string, _, _)]
                                con times = [When]
                                val tab = notables
                                val labels = {Notable = "Event",
                                              When = "Day"}
                                val title = "Academic Calendar"
                                val display = None
                                val auth = return Calendar.Read
                                val kinds = {When = ""}
                                val sh = mkShow (fn {Notable = s} => s)
                                val showTime = False
                            end)
end
