/**
* Plugin pour le DébugMode.
*
* Auto Voice Intelligent.
*/

; ///////////////
; // VARIABLES //
; ///////////////
/**
* En combien de temps doit-on dévoicer un utilisateur voicé par ce script.
* En millisecondes! Sachant que la vérification se fait toutes les 1 minute
*   vous devrez le prendre en compte. (donc enlever une minute)
*
* Par defaut, 240000ms (= 4 minutes. +1 minute = 5 minutes).
*
* @var int
*/
alias -l Autovoice.idle {
  return 240000
}

/**
* En combien de temps doit-on voicer un utilisateur, après une inactivité ou pas de son temps parole.
*
* Par défaut: 15 secondes.
*
* @example 1:
*   10:10:00 <Utilisateur1> Coucou
*   10:10:02 <Utilisateur1> tu
*   10:10:03 <Utilisateur1> vas
*   10:10:06 <Utilisateur1> bien
*   <-->
*   10:10:07 <Utilisateur1> ?
*   -- C'est ici qu'on vérifie si son dernier message est inférieur à <15 secondes (par défaut)>
*   -- Si le temps du message est supérieur à "15 secondes après", alors on ne le voice pas et
*      son compteur de message redescend à 2.
*   -- Dans ce cas-ci on le voice.
*   10:10:07 * /mode $chan +v Utilisateur1
*
* @example 2:
*   10:10:00 <Utilisateur2> Coucou
*   10:10:02 <Utilisateur2> tu
*   10:10:03 <Utilisateur2> vas
*   10:10:05 <Utilisateur2> bien
*   <-->
*   10:10:21 <Utilisateur2> ??????
*   -- C'est ici qu'on vérifie si son dernier message est inférieur à <15 secondes (par défaut)>
*   -- Si le temps du message est supérieur à "15 secondes après", alors on ne le voice pas et
*      son compteur de message redescend à 2.
*   -- Dans ce cas-ci on ne le voice pas.
*
* @var int
*/
alias -l Autovoice.idle.message {
  return 15000
}

/**
* Nom de la base de donnée.
* @var string
*/
alias -l Autovoice._db {
  return autovoice
}

/**
* Destination de la base de donnée.
* @var string
*/
alias -l Autovoice._db.file {
  return scripts\users\phisyx\database.ini
}

; ///////////////
; // AUTOVOICE //
; ///////////////
/**
* Active l'autovoice.
*
* @param  string $$1=%chan
* @return void
*/
alias -l Autovoice.on {
  var %chan = $$1

  ; ----- ;

  var %database = $Autovoice._db
  var %database_file = $Autovoice._db.file
  var %database_key = %chan
  var %database_value = 1

  ; ----- ;

  .writeini %database_file %database %database_key %database_value

  .timerMsg 1 1 msg %chan Système d'auto-[dé]voice intelligent activé pour le salon $qt(%chan) $+ .
}

/**
* Désactive l'autovoice
*
* @return void
*/
alias -l Autovoice.off {
  var %chan = $$1

  ; ----- ;

  var %database = $Autovoice._db
  var %database_file = $Autovoice._db.file
  var %database_key = %chan

  ; ----- ;

  .remini %database_file %database %database_key

  .timerMsg 1 1 msg %chan Système d'auto-[dé]voice intelligent désactivé pour le salon $qt(%chan) $+ .

  $Autovoice.devoice_all(%chan)
}

/**
* Dévoice toutes les personnes qui ont été voicé par ce système.
* @param  string $$1=%chan Salon.
* @return void
*/
alias -l Autovoice.devoice_all {
  var %chan = $$1

  ; ----- ;

  var %database = $Autovoice._db
  var %database_file = $Autovoice._db.file

  ; ----- ;

  var %nicks, %v

  var %items_total = $ini(%database_file, %database, 0)
  var %u = 1
  while (%u <= %items_total) {
    var %database_key = $ini(%database_file, %database, %u)

    ; ----- ;

    var %nick = $token(%database_key, 2, 64)
    if (%chan isin %database_key) {
      %v = %v $+ v
      %nicks = $addtok(%nicks, %nick, 32)
      .timerRemini $+ $rand(0,1000) 1 1 .remini %database_file %database %database_key
    }

    inc %u
  }

  if ($me isop %chan) {
    .timerMsg  1 1 msg %chan INFO: 05Les utilisateurs voicés par ce système seront dévoicés.
    .timerMode 1 1 mode %chan $+(-, %v) %nicks
  }
}

; ////////////////
; // EVENEMENTS //
; ////////////////
/**
* ON INPUT #.
*
* @param string $$1=%chan Salon
* @param string $$2=text  Texte
*/
alias Autovoice::oninput {
  var %chan = $$1
  var %text = $right($$2-, -1)

  ; ------------------------ ;

  if (!$ischan(%chan)) {
    return $false
  }

  ; ------------------------ ;

  var %database = $Autovoice._db
  var %database_file = $Autovoice._db.file

  ; ------------------------ ;

  var %is_activated_for_this_chan = $readini(%database_file, n, %database, %chan)
  if ($me ishop %chan || $me isop %chan) {
    if (!autovoice on == %text && %is_activated_for_this_chan !== 1) {
      $Autovoice.on(%chan)
    }
    elseif (!autovoice off == %text && %is_activated_for_this_chan === 1) {
      $Autovoice.off(%chan)
    }
  }
}

/**
* ON TEXT #.
*
* @param string $$1=%nick Pseudo
* @param string $$2=%chan Salon
* @param string $$3=text  Texte
* @return void|$false
*/
alias Autovoice::ontext {
  var %nick = $right($token($$1, 1, 33), -1)
  var %chan = $$2
  var %text = $right($$3-, -1)

  ; -------------------------------------- ;

  if (!$ischan(%chan)) {
    return $false
  }

  ; -------------------------------------- ;

  var %database = $Autovoice._db
  var %database_file = $Autovoice._db.file
  var %database_key = $+(%chan, @, %nick)
  var %database_value = $+(1, $chr(44), $ticks)

  ; -------------------------------------- ;

  var %is_activated_for_this_chan = $readini(%database_file, n, %database, %chan)
  if (%nick isop %chan) {
    if (%text == !autovoice on && !%is_activated_for_this_chan) {
      $Autovoice.on(%chan)
    }
    elseif (%text == !autovoice off && %is_activated_for_this_chan === 1) {
      $Autovoice.off(%chan)
    }
    return $null
  }

  if ($is_chanoff(%chan) && ($me !ishop %chan || $me !isop %chan)) {
    return $false
  }

  if (%nick ishop %chan || %nick isop %chan) {
    return $false
  }

  if (%is_activated_for_this_chan !== 1) {
    return $false
  }

  var %nick_info = $readini(%database_file, n, %database, %database_key)
  if (%nick_info) {
    var %messages_total = $token(%nick_info, 1, 44)
    var %last_message = $token(%nick_info, 2, 44)

    %database_value = $+($calc(%messages_total +1), $chr(44), $ticks)
    if (%messages_total >= 4) {
      if (%nick !isvo %chan) {
        if ($Autovoice.idle.message >= $calc($ticks - %last_message)) {
          mode %chan +v %nick
        }
        else {
          %database_value = $+(2, $chr(44), $ticks)
        }
      }
    }
  }

  .writeini %database_file %database %database_key %database_value
}

; ////////////////////////
; // Toutes les minutes //
; ////////////////////////
/**
* Vérifie l'activité de tous les utilisateurs listé en bdd.
*/
alias Autovoice::check.activities {
  var %database = $Autovoice._db
  var %database_file = $Autovoice._db.file

  ; ------------------------------------ ;

  var %items_total = $ini(%database_file, %database, 0)
  var %u = 1
  while (%u <= %items_total) {
    var %database_key = $ini(%database_file, %database, %u)
    var %database_value = $readini(%database_file, n, %database, %database_key)

    ; -------------------------------------------------------------------- ;

    var %chan = $token(%database_key, 1, 64)
    var %nick = $token(%database_key, 2, 64)

    ; -------------------------------------------------------------------- ;

    if (%nick) {
      var %ticks = $token(%database_value, 2, 44)
      var %ticks_calc = $calc($ticks - %ticks)

      if (%ticks_calc >= $Autovoice.idle && ($me ishop %chan || $me isop %chan)) {
        if (%nick isvo %chan) {
          .timerMode $+ $rand(0,1000) 1 1 mode %chan -v %nick
        }

        .timerRemini $+ $rand(0,1000) 1 1 remini %database_file %database %database_key
      }
    }

    inc %u
  }
}
