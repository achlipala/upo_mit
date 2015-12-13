(* Authentication using MIT client certificates *)

functor Make(M : sig
                 con kerberos :: Name
                 (* Which column stores an MIT Kerberos ID? *)
                 con commonName :: Name
                 (* Which column stores the human name? *)

                 con groups :: {Unit}
                 (* Boolean flags indicating membership in classes of users *)

                 con others :: {Type}
                 (* Miscellaneous remaining fields of the users table *)

                 constraint [kerberos] ~ [commonName]
                 constraint [kerberos, commonName] ~ groups
                 constraint ([kerberos, commonName] ++ groups) ~ others

                 table users : ([kerberos = string, commonName = string] ++ mapU bool groups ++ others)

                 val defaults : option $(mapU bool groups ++ others)
                 (* If provided, automatically creates accounts for unknown usernames.
                  * Fields are initialized from these defaults. *)

                 val allowMasquerade : option (variant (mapU unit groups))
                 (* If present, members of this group can pretend to be anyone else.
                  * We assume that this is an uber-group that will always pass access-control checks! *)

                 val requireSsl : bool

                 val flg : folder groups
                 val flo : folder others

                 val injo : $(map sql_injectable others)
             end) : Auth.S where con groups = M.groups
