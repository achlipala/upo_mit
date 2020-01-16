(* Data associated with a semester at MIT *)

signature INPUT = sig
    val regDay : time
    val classesDone : time

    val notable : list (time * string)
    (* Which events are worth marking on calendars for this semester? *)
end

signature OUTPUT = sig
    val regDay : time
    val classesDone : time

    con private :: (Type * Type * Type)
    val cal : Calendar.t [Notable = string] [Notable = private]
end

functor Make(M : INPUT) : OUTPUT
