/**
* Amélioration des événements.
*
* @author Mike 'PhiSyX' S.
* @require
*   - scripts/users/phisyx/bases.mrc
*   - scripts/users/phisyx/configure.mrc
*   - scripts/users/phisyx/nick.mrc
* @version 1.2.0
*/

/**
* Configuration par défaut.
*
* @var array 44 Toutes les configurations. (key=value)
*/
alias -l EventFormat._defaultConfig {
  var %config

  var %event = $event
  var %config_event = $+(event_, %event)

  var %format = {{prefix_sign}} {{event}}{{suffix_sign}} {{nick}} ({{address}}) {{message}}
  var %switches = $null
  var %prefix_sign = $Configure::read(event.prefix_sign, $chr(42))
  var %suffix_sign = $Configure::read(event.suffix_sign, $chr(58))

  ; par défaut pour ces évenemens:
  if (%event === rawmode) {
    %event = mode
    %format = {{nick}} sets mode: {{modes}}
  }
  elseif (%event === nick) {
    %format = {{prefix_sign}} {{oldnick}} is now known as {{newnick}}
    %switches = es
  }
  elseif (%event === text) {
    %format = <{{nick}}> {{message}}
    %switches = m
  }

  ; Configurations de l'utilisateur (fichier config.ini)
  %event = $Configure::read(%config_event $+ .name, %event)
  %format = $Configure::read(%config_event $+ .format, %format)
  %switches = $Configure::read(%config_event $+ .switches, %switches)
  %switches = $remove(%switches, $chr(45))
  %prefix_sign = $Configure::read(%config_event $+ .prefix_sign, %prefix_sign)
  %suffix_sign = $Configure::read(%config_event $+ .suffix_sign, %suffix_sign)

  if (%switches) {
    %switches = $chr(45) $+ %switches
  }

  if (!$Configure::check(event_ $+ $event $+ .config)) {
    %config = $Configure::assign(color, $iif($color(%event), $v1, 11)) $+ $&
      $Configure::assign(prefix_sign, %prefix_sign) $+ $&
      $Configure::assign(suffix_sign, %suffix_sign) $+ $&
      $Configure::assign(format, %format) $+ $&
      $Configure::assign(switches, %switches).last

    $Configure::write(event_ $+ $event $+ .config, %config)
  }
  else {
    %config = $Configure::read(event_ $+ $event $+ .config)
  }

  return %config
}

/**
* Retourne la configuration
*
* @param array $1-=%config Les configurations à ajouter à la configuration par défaut.
* @return array 44
*/
alias -l EventFormat.config {
  return $iif($1-, $+($v1, $chr(44))) $+ $EventFormat._defaultConfig
}

/**
* [event.format description]
*
* @param string $1=%config_name Nom de la configuration à lire.
* @return string Le format avec les bonnes informations.
*/
alias EventFormat {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %config_name = $1

  ; -------------------- ;

  haltdef

  ; Configuration de l'événement.
  var %config = $iif(%config_name, $call.alias($v1), $call.alias(EventFormat.config::on $+ $event)) $result
  ; Configuration par défaut (au cas où celle de l'événement n'existe pas)
  %config = $EventFormat.config(%config)

  var %nick = $iif($newnick, $v1, $nick)
  var %chan = $chan
  var %color = $Configure::read.inline(color, %config)
  var %switches = $Configure::read.inline(switches, %config)

  ; event has one chan
  if (%chan) {
    if (s isin %switches) {
      echo %color %switches $EventFormat._change(%nick, %chan, %config)
    }

    %switches = $remove(%switches, e, s, t)
    if ($len(%switches) === 1) {
      %switches = $null
    }
    echo %color %switches # $EventFormat._change(%nick, %chan, %config)
  }
  ; event has many chans
  else {
    if (s isin %switches) {
      if ($event === nick && $nick !== $me) {
      }
      else {
        echo %color %switches $EventFormat._change(%nick, $chan(1), %config)
      }
    }

    %switches = $remove(%switches, e, s, t)
    if ($len(%switches) === 1) {
      %switches = $null
    }

    var %chans_total = $comchan(%nick, 0)
    var %i = 1
    while (%i <= %chans_total) {
      %chan = $comchan(%nick, %i)
      echo %color %switches %chan $EventFormat._change(%nick, %chan, %config)
      inc %i
    }
  }
}

/**
* Construction de la sortie
*
* @param string $$1=%nick Le pseudo qui a déclenché l'événement.
* @param string $$2=%chan Sur quel salon l'événement doit être affiché.
* @param string $$3=%config Toutes les configurations.
* @return string Le format modifié avec les bonnes valeurs.
*/
alias -l EventFormat._change {
  var %nick = $$1
  var %chan = $$2
  var %config = $$3

  ; -------------------- ;

  var %output = $Configure::read.inline(format, %config)
  %output = $replace(%output, {{address}}, $EventFormat.info().address)
  %output = $replace(%output, {{event}}, $EventFormat.info().event)
  if ($Configure::read(detection)) {
    %output = $replace(%output, {{message}}, $EventFormat.info().message&detection)
  }
  else {
    %output = $replace(%output, {{message}}, $EventFormat.info().message)
  }
  %output = $replace(%output, {{nick}}, $EventFormat.info(%nick, %chan).nick)
  %output = $replace(%output, {{newnick}}, $EventFormat.info(%nick, %chan).newnick)
  %output = $replace(%output, {{oldnick}}, $EventFormat.info($nick, %chan).oldnick)

  if (%nick !== $me) {
    %output = $replace(%output, {{prefix_sign}}, $Configure::read.inline(prefix_sign, %config))
  }
  else {
    %output = $replace(%output, {{prefix_sign}}, $Configure::read.inline(prefix_sign_me, %config, »))
  }

  %output = $replace(%output, {{modes}}, $EventFormat.info().modes)
  %output = $replace(%output, {{modes:custom}}, $EventFormat.info().modes&custom)
  %output = $replace(%output, {{suffix_sign}}, $Configure::read.inline(suffix_sign, %config))

  %output = {{external}} {{timestamp}} %output
  if ($Configure::read(detection)) {
    %output = {{detection}} %output
  }

  %output = $replace(%output, {{external}}, $EventFormat.info(%nick, %chan).external)
  %output = $replace(%output, {{timestamp}}, $timestamp)
  %output = $replace(%output, {{detection}}, $EventFormat.info().detection)

  return %output
}

/**
* @return string
*/
alias EventFormat.info {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %nick = $1
  var %chan = $2

  ; -------------------- ;

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
      %external = 04(External Message $+ $iif($chan(%chan).mode, $+(/modes:, $v1)) $+ )
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
  elseif ($prop === modes) {
    var %modes_with_params = $4-
    return %modes_with_params
  }
  elseif ($prop === modes&custom) {
    var %modes = $+(14, $4, )
    var %params = $+(14, $5-, )
    return $qt(%modes) $iif($5-, avec les paramètres $qt(%params))
  }
}


; -- [ Evenements ] --------------------
; --- [ JOIN ] -------------------------
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
alias -l EventFormat.setJoin {
  %event. [ $+ [ $chan ] $+ . [ $+ [ $lower($nick) ] ] ] = $ticks
  .timerUnset 1 5 unset %event.*
}
; --- [ NICK ] -------------------------
on ^&*:NICK:$EventFormat
; --- [ PART ] -------------------------
on ^&*:PART:#:$iif($nick !== $me, $EventFormat)
; --- [ QUIT ] -------------------------
on ^&*:QUIT:$EventFormat
; --- [ RAWMODE ] ----------------------
on ^&*:RAWMODE:#: {
  var %timeonjoin = %event. [ $+ [ $chan ] $+ . [ $+ [ $lower($2) ] ] ]
  var %calc = $calc($ticks)
  if (%timeonjoin) {
    %calc = $calc($ticks - %timeonjoin)
  }

  if (%calc >= 600) { $EventFormat }
  else { haltdef }
}
; --- [ TEXT ] -------------------------
on ^&*:TEXT:*:#:$EventFormat
