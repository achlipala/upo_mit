(* Authentication using MIT client certificates *)

open Bootstrap4

functor Make(M : sig
                 con kerberos :: Name
                 con commonName :: Name
                     
                 con groups :: {Unit}

                 con others :: {Type}

                 constraint [kerberos] ~ [commonName]
                 constraint [Password] ~ [kerberos, commonName]
                 constraint [kerberos, commonName, Password] ~ groups
                 constraint ([kerberos, commonName, Password] ++ groups) ~ others

                 table users : ([kerberos = string, commonName = string, Password = option string] ++ mapU bool groups ++ others)

                 val defaults : option $(mapU bool groups ++ others)
                 val allowMasquerade : option (list (variant (mapU unit groups)))
                 val requireSsl : bool

                 val flg : folder groups
                 val flo : folder others

                 val injo : $(map sql_injectable others)
             end) = struct
    open M

    cookie byPassword : { kerberos : string, Password : string }

    val fourMonths = 4 * 30 * 24 * 60 * 60

    fun login r =
        name <- oneOrNoRowsE1 (SELECT (users.{commonName})
                               FROM users
                               WHERE users.{kerberos} = {[r.kerberos]}
                                 AND users.Password = {[Some r.Password]});
        case name of
            None => return None
          | Some _ =>
            tm <- now;
            setCookie byPassword {Value = r,
                                  Expires = Some (addSeconds tm fourMonths),
                                  Secure = requireSsl};
            return name

    val logout =
        clearCookie byPassword

    structure Login = struct
        type a = _

        val create =
            un <- fresh;
            pw <- fresh;
            username <- source "";
            password <- source "";

            byP <- getCookie byPassword;
            s <- (case byP of
                    None => source None
                  | Some r =>
                    name <- oneRowE1 (SELECT (users.{commonName})
                                      FROM users
                                      WHERE users.{kerberos} = {[r.kerberos]});
                    source (Some (Some name)));

            return {UsernameId = un,
                    PasswordId = pw,
                    Username = username,
                    Password = password,
                    Status = s}

        fun onload _ = return ()

        fun render _ a = <xml>
          <dyn signal={st <- signal a.Status;
                       return (case st of
                                   None => <xml></xml>
                                 | Some None => <xml><div class="bs-alert alert-danger"><strong>Error:</strong> wrong username or password</div></xml>
                                 | Some (Some name) => <xml>
                                   <div class="bs-alert alert-success">Logged in as <em>{[name]}</em></div>
                                   <button class="btn btn-primary"
                                           value="Log out"
                                           onclick={fn _ =>
                                                       rpc logout;
                                                       set a.Status None}/>

                                   <hr/>
                                 </xml>)}/>

          <div class="form-group">
            <label class="control-label" for={a.UsernameId}>E-mail address</label>
            <ctextbox class="form-control" source={a.Username} id={a.UsernameId}/>
            <label class="control-label" for={a.PasswordId}>Password</label>
            <cpassword class="form-control" source={a.Password} id={a.PasswordId}/>
          </div>

          <button class="btn btn-primary"
                  value="Log in"
                  onclick={fn _ =>
                              name <- get a.Username;
                              pass <- get a.Password;
                              res <- rpc (login {kerberos = name, Password = pass});
                              set a.Status (Some res)}/>
        </xml>

        val ui = {Create = create,
                  Onload = onload,
                  Render = render}
    end
            
    open Auth.Make(struct
                       open M

                       con name = commonName
                       con key = [kerberos = string]
                       con others = [Password = option string] ++ others
                       val injo = _ ++ injo
                       val flo = @Folder.cons [#Password] [_] ! flo

                       val defaults = case defaults of
                                          None => None
                                        | Some r => Some ({Password = None} ++ r)

                       val underlying =
                           byP <- getCookie byPassword;
                           case byP of
                               None =>
                               user <- ClientCert.user;
                               (case user of
                                    None => return None
                                  | Some user =>
                                    case String.split user.Email #"@" of
                                        None => error <xml>Invalid e-mail address in certificate</xml>
                                      | Some (uname, dom) =>
                                        if dom <> "MIT.EDU" then
                                            error <xml>Certificate is not for an MIT e-mail address.</xml>
                                        else
                                            let
                                                val uname =
                                                    (* Admittedly hacky special case, to detect usernames in the separate namespace for Lincoln Lab *)
                                                    if String.length uname >= 5 && String.all Char.isDigit (String.substring uname {Start = String.length uname - 5, Len = 5}) then
                                                        uname ^ "@LL.MIT.EDU"
                                                    else
                                                        uname
                                            in
                                                return (Some {kerberos = uname, commonName = user.CommonName})
                                            end)
                             | Some r =>
                               name <- oneOrNoRowsE1 (SELECT (users.{commonName})
                                                      FROM users
                                                      WHERE users.{kerberos} = {[r.kerberos]}
                                                        AND users.Password = {[Some r.Password]});
                               case name of
                                   None => error <xml>Bad username or password</xml>
                                 | Some name => return (Some {kerberos = r.kerberos, commonName = name})

                       constraint [name] ~ key
                       constraint ([name] ++ map (fn _ => ()) key) ~ groups
                       constraint ([name] ++ map (fn _ => ()) key ++ groups) ~ others
                       val fls = _
                       val injs = _
                       val eqs = _

                       val accessDeniedErrorMessage = <xml>Access denied.  Are you sure you have an <a href="https://ist.mit.edu/certificates">MIT client certificate</a> set up in your browser?</xml>
                   end)

end
