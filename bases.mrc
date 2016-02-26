/**
* Mes bases.
*
* Ce script a été spécialement conçu pour être utilisé avec le script "Skyrock.fm v10".
* Pourquoi? Il contient des variables/identifieurs/alias provenant de ce script.
* Lesquel(le)s: get_team
*
* @author Mike 'PhiSyX' S.
* @require
*   - Script mIRC Skyrock.fm v10
*   - scripts/users/phisyx/debug-mode.mrc
*/
on &*:CONNECT:{
  ; Applique les modes utilisateurs automatiquement.
  mode $me +ixpwT

  ; A la connexion au serveur de SKYROCK.COM.
  if (ircd??.skyrock.net iswm $server) {
    ; Récupère les membres de l'équipe (SKYROCK.COM) Chat.
    get_team

    ; AutoJOIN
    j %MyFavoritesChannels
  }
  ; A la connexion au serveur de test.
  elseif (irc.local.dev === $server && $nick === %handle) {
    .timerServiceNSIdentification 1 1 ns id %key.local_dev.ns
    .timerOperIdentification 1 2 oper %key.local_dev.opuser %key.local_dev.oppwd
    .timerServiceOSSetSuperAdmin 1 2 os set superadmin on

    ; .timerServiceCSInvite 1 2 cs invite #services $me
    ; .timerJOINInvite 1 2 j #services

    ; Parce que c'est plus rapide.
    .timerSAJOINService 1 2 sajoin $me #services
  }
}

/**
* Appelle d'un ALIAS dynamiquement.
*
* @example utilisation:
*   alias event.join { return lol }
*   alias event.part { echo -a LOLOL }
*
*   alias name {
  *   ; imaginons que l'$event est égal à join
  *   ; event.join
  *   var %test = $call.alias(event. $+ $event).result
  *   echo -a %test @return lol
  *   $call.alias(event.part)
*   }
*
* @param  string $$1=%alias Nom de l'alias à executer
* @param  string $2=%params Les paramètres de l'alias.
* @return void
*/
alias call.alias {
  if (!$isid) {
    return $false
  }

  if ($isalias($$1)) {
    $$1 $2-

    if ($prop === result) {
      return $result
    }

    if ($debugmode.is_active) {
      echo $color(info) -t $debug $!call.alias: L'alias $qt($$1) a bien été trouvé et éxécuté.
    }
  }
  elseif ($debugmode.is_active) {
    echo $color(info2) -t $debug $!call.alias: L'alias $qt($$1) n'existe pas ou est privé (alias -l).
  }
}
