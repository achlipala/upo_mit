(* Authentication using MIT client certificates *)

functor Make(M : sig
                 con kerberos :: Name
                 con commonName :: Name
                     
                 con groups :: {Unit}

                 con others :: {Type}

                 constraint [kerberos] ~ [commonName]
                 constraint [kerberos, commonName] ~ groups
                 constraint ([kerberos, commonName] ++ groups) ~ others

                 table users : ([kerberos = string, commonName = string] ++ mapU bool groups ++ others)

                 val defaults : option $(mapU bool groups ++ others)
                 val allowMasquerade : option (variant (mapU unit groups))
                 val requireSsl : bool

                 val flg : folder groups
                 val flo : folder others

                 val injo : $(map sql_injectable others)
             end) =
Auth.Make(struct
              open M

              con name = commonName
              con key = [kerberos = string]

              val underlying =
                  user <- ClientCert.user;
                  case String.split user.Email #"@" of
                      None => error <xml>Invalid e-mail address in certificate</xml>
                    | Some (uname, dom) =>
                      if dom <> "MIT.EDU" then
                          error <xml>Certificate is not for an MIT e-mail address.</xml>
                      else
                          return (Some {kerberos = uname, commonName = user.CommonName})

              constraint [name] ~ key
              constraint ([name] ++ map (fn _ => ()) key) ~ groups
              constraint ([name] ++ map (fn _ => ()) key ++ groups) ~ others
              val fls = _
              val injs = _
              val eqs = _
          end)
