(* Authentication using MIT client certificates *)

open Bootstrap

type password_cookie = { Username : string, Password : string }

functor AlternativeLogin(M : sig
                             con kerberos :: Name
                             con commonName :: Name

                             con groups :: {Unit}

                             con others' :: {Type}

                             constraint [kerberos] ~ [commonName]
                             constraint [Password] ~ [kerberos, commonName]
                             constraint [kerberos, commonName, Password] ~ groups
                             constraint ([kerberos, commonName, Password] ++ groups) ~ others'

                             table users : ([kerberos = string, commonName = string, Password = option string] ++ mapU bool groups ++ others')

                             val requireSsl : bool
                             val byPassword : http_cookie password_cookie
                         end) = struct
    open M

    type a = _

    val fourMonths = 4 * 30 * 24 * 60 * 60

    fun login r =
        name <- oneOrNoRowsE1 (SELECT (users.{commonName})
                               FROM users
                               WHERE users.{kerberos} = {[r.Username]}
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
                                  WHERE users.{kerberos} = {[r.Username]});
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
                          res <- rpc (login {Username = name, Password = pass});
                          set a.Status (Some res)}/>
    </xml>

    fun notification _ _ = <xml></xml>
    fun buttons _ _ = <xml></xml>

    val ui = {Create = create,
              Onload = onload,
              Render = render,
              Notification = notification,
              Buttons = buttons}

    val whoami =
        byP <- getCookie byPassword;
        case byP of
            None => return None
          | Some r =>
            name <- oneOrNoRowsE1 (SELECT (users.{commonName})
                                   FROM users
                                   WHERE users.{kerberos} = {[r.Username]}
                                     AND users.Password = {[Some r.Password]});
            case name of
                None => error <xml>Bad username or password</xml>
              | Some name => return (Some {kerberos = r.Username, commonName = name})
end

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

    cookie byPassword : password_cookie

    structure Login = AlternativeLogin(struct
                                           open M
                                           con others' = others
                                           val byPassword = byPassword
                                       end)

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
                           byP <- Login.whoami;
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
                                            return (Some {kerberos = uname, commonName = user.CommonName}))
                             | r => return r

                       constraint [name] ~ key
                       constraint ([name] ++ map (fn _ => ()) key) ~ groups
                       constraint ([name] ++ map (fn _ => ()) key ++ groups) ~ others
                       val fls = _
                       val injs = _
                       val eqs = _

                       val accessDeniedErrorMessage = <xml>Access denied.  Are you sure you have an <a href="https://ist.mit.edu/certificates">MIT client certificate</a> set up in your browser?</xml>
                   end)

end
