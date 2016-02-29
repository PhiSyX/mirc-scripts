/**
* Amélioration des événements.
*
*   Liste des événements disponibles et fonctionnels:
*     - join
*     - nick
*     - part
*     - quit
*     - rawmode
*     - text
*
* @author Mike 'PhiSyX' S.
* @require
*   - scripts/users/phisyx/bases.mrc
*   - scripts/users/phisyx/configure.mrc
*   - scripts/users/phisyx/nick.mrc
* @version 1.1.9
*/

/**
* Configuration par défaut.
* 
* @var array 44 Toutes les configurations. (key=value)
*/
alias -l EventFormat._configDefault {
  var %event = $event
  var %format = [prefix_sign] [event][suffix_sign] [nick] ([address])
  var %switches = $null

  if (%event === rawmode) {
    %event = mode
    %format = [nick] sets mode: $token($rawmsg, 4-, 32)
  }
  elseif (%event === nick) {
    %format = [prefix_sign] [oldnick] is now known as [newnick]
  }
  elseif (%event === text) {
    %format = <[nick]> [message]
    %switches = -m
  }

  return $Configure::assign(color, $iif($color(%event), $v1, 11)) $+ $&
    $Configure::assign(prefix_sign, $chr(42)) $+ $&
    $Configure::assign(suffix_sign, $chr(58)) $+ $&
    $Configure::assign(format, %format) $+ $&
    $Configure::assign(switches, %switches).last
}

/**
* [event.format description]
*
* @param  string $1=%configname Nom de la configuration à lire.
* @return string                Le format avec les bonnes informations.
*/
alias EventFormat {
  haltdef

  ; ----------------- ;

  var %config_name = $1

  ; ----------------- ;

  ; Configuration de l'événement.  
  var %config = $iif(%config_name, $call.alias($v1), $call.alias(EventFormat.config::on $+ $event)) $result
  ; Configuration par défaut (au cas où celle de l'événement n'existe pas)
  %config = $EventFormat._config(%config) 

  var %nick = $iif($newnick, $v1, $nick)
  var %chan = $chan
  var %color = $Configure::read(%config, color)
  var %switches = $Configure::read(%config, switches)

  ; event has one chan
  if (%chan) {
    if (s isin %switches) {
      echo %color %switches %chan $EventFormat._change(%nick, %chan, %config)
    }

    echo %color $remove(%switches, e, s, t) # $EventFormat._change(%nick, %chan, %config)
  }
  ; event has many chans
  else {
    if (s isin %switches) {
      echo %color %switches %chan $EventFormat._change(%nick, $chan(1), %config)
    }

    var %chans_total = $comchan(%nick, 0)
    var %i = 1
    while (%i <= %chans_total) {
      %chan = $comchan(%nick, %i)
      echo %color $remove(%switches, e, s, t) %chan $EventFormat._change(%nick, %chan, %config)
      inc %i
    }
  }
}

/**
* Retourne la configuration
* 
* @param  array $1-=%config Les configurations à ajouter à la configuration par défaut.
* @return array 44
*/
alias -l EventFormat._config {
  return $iif($1-, $+($v1, $chr(44))) $+ $EventFormat._configDefault
}

/**
* Construction de la sortie
*
* @param  string $$1=%nick   Le pseudo qui a déclenché l'événement.
* @param  string $$2=%chan   Sur quel salon l'événement doit être affiché.
* @param  string $$3=%config Toutes les configurations.
* @return string             Le format modifié avec les bonnes valeurs.
*/
alias -l EventFormat._change {
  var %nick = $$1
  var %chan = $$2
  var %config = $$3

  ; ------------- ;

  var %output = $Configure::read(%config, format)
  %output = $replace(%output, [address], $EventFormat.info().address)
  %output = $replace(%output, [event], $EventFormat.info().event)
  if ($Configure::read(%config, detection)) {
    %output = $replace(%output, [message], $EventFormat.info().message&detection)
  }
  else {
    %output = $replace(%output, [message], $EventFormat.info().message)
  }
  %output = $replace(%output, [nick], $EventFormat.info(%nick, %chan).nick)
  %output = $replace(%output, [newnick], $EventFormat.info(%nick, %chan).newnick)
  %output = $replace(%output, [oldnick], $EventFormat.info($nick, %chan).oldnick)
  %output = $replace(%output, [prefix_sign], $Configure::read(%config, prefix_sign))
  %output = $replace(%output, [mode], $EventFormat.info().mode)
  %output = $replace(%output, [suffix_sign], $Configure::read(%config, suffix_sign))

  var %before_timestamp = $Configure::read(%config, before_timestamp)
  %before_timestamp = $replace(%before_timestamp, [external], $EventFormat.info(%nick, %chan).external)
  if ($Configure::read(%config, detection)) {
    %before_timestamp = [detection] %before_timestamp
  }
  %before_timestamp = $replace(%before_timestamp, [detection], $EventFormat.info().detection)

  return %before_timestamp $timestamp %output
}

/**
* @return string
*/
alias EventFormat.info {
  var %nick = $1
  var %chan = $2

  ; ---------- ;

  tokenize 32 $rawmsg

  if ($prop === address) {
    return $gettok($1, 2, 33)
  }
  elseif ($prop === event) {
    var %event_name = $replace($event, rawmode, mode)
    return $upper($left(%event_name, 1)) $+ $right(%event_name, -1) $+ s
  }
  elseif ($prop === detection) {
    var %detection = $call.alias(Detections, $1-).result
    if (%detection) {
      return 04->
    }
    return $null
  }
  elseif ($prop === external) {
    var %external = $null

    if (n !isincs $chan(%chan).mode && !$nick(%chan, %nick)) {
      %external = 04(External Message $+ $iif($chan(%chan).mode, $+(/ modes:, $v1)) $+ )
    }

    return %external
  }
  elseif ($prop === message || $prop === message&detection) {
    var %message = $right($4-, -1)
    if ($prop === message&detection) {
      var %detection = $call.alias(Detections, $1-).result
      if (%detection) {
        %message = $replace(%message, %detection, $+(04, %detection, ))
      }
    }

    if ($event === quit) {
      %message = $right($3-, -1)
    }

    if ($event === part || $event === quit) {
      return $iif(%message, $+($chr(40), %message, $chr(41)))
    }

    return %message
  }
  elseif ($prop === newnick || $prop === nick || $prop === oldnick) {
    var %currentNick = $iif(%nick, $v1, $right($gettok($1, 1, 33), -1))
    var %currentChan = $iif(%chan, $v1, $right($3, -1))
    return $nick.color(%currentNick, %currentChan).custom
  }
  elseif ($prop === mode) {
    var %modes = $+(14, $4, )
    var %params = $+(14, $5-, )
    return $qt(%modes) $iif($5-, avec les paramètres $qt(%params))
  }
}

alias -l EventFormat.setJoin {
  %event. [ $+ [ $chan ] $+ . [ $+ [ $lower($nick) ] ] ] = $ticks
  .timerUnset 1 5 unset %event.*
}

; ////////////////
; // Evenements //
; ////////////////
; //   JOIN     //
; ////////////////
on ^&*:JOIN:#:{
  if ($nick === $me) {
    haltdef

    var %color = $color($event)

    echo %color -t # ::.:::.:::.:::.:::.:::.:::.:::.:::.::
    echo %color -t # Bienvenue sur $+(12, #, ...)
  }
  else {
    $EventFormat

    if ($is_operator_off($nick)) {
      $EventFormat(EventFormat.config::onjoin&is_operator)

      $EventFormat.setJoin
    }
  }
}

; ////////////////
; //   NICK     //
; ////////////////
on ^&*:NICK:$EventFormat

; ////////////////
; //   PART     //
; ////////////////
on ^&*:PART:#:if ($nick !== $me) { $EventFormat }

; ////////////////
; //   QUIT     //
; ////////////////
on ^&*:QUIT:$EventFormat

; ////////////////
; //   RAWMODE  //
; ////////////////
on ^&*:RAWMODE:#: {
  var %timeonjoin = %event. [ $+ [ $chan ] $+ . [ $+ [ $lower($2) ] ] ]
  var %calc = $calc($ticks)
  if (%timeonjoin) {
    %calc = $calc($ticks - %timeonjoin)
  }

  if (%calc >= 300) { $EventFormat }
  else { haltdef }
}

; ////////////////
; //   TEXT     //
; ////////////////
on ^&*:TEXT:*:#:$EventFormat
