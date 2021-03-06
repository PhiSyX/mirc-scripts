/**
* Debug Mode.
*
* @author Mike 'PhiSyX' S.
* @version 1.1.1
* @require
*   - scripts/users/phisyx/bases.mrc
*   - scripts/users/phisyx/configure.mrc
* @commands
*   - /debugmode --help [command | mode | option]
*   - /debugmode --version
*   - /debugmode on|off [option]
*   - (TODO) /debugmode update
*/
; -- [ Configurations ] --------------------
/**
* Les configurations par défaut.
*   - `identifier` : L'identifieur/L'alias à utiliser pour la commande /debug.
* @var array 44 : key=value
*/
alias -l debugmode._defaultConfig {
  return identifier=debugmode.console
}
/**
* Configuration à utiliser.
* @return array
*/
alias -l debugmode.config {
  return $iif($1, $+($v1, $chr(44))) $+ $debugmode._defaultConfig
}

; -- [ Variables ] --------------------
/**
* Les commandes.
* @var array 44
*/
alias -l debugmode.commands {
  return update
}
/**
* Les modes.
* @var array 44
*/
alias -l debugmode.modes {
  return off,on
}
/**
* Les options.
* @var array 44 : key=value
*/
alias -l debugmode.options {
  return -h=--help,-q=--quiet,-v=--version
}

; -- [ Debug mode ] --------------------
/**
* @param string $1=%arg1 Commande, mode ou option.
* @param string $2=%arg2 Paramètres supplémentaires.
*/
alias debugmode {
  $iif($isid, return $null)

  ; -------------------- ;

  var %arg1 = $1
  var %arg2 = $2

  ; -------------------- ;

  var %name_alias
  if (!%arg1) {
    echo $color(info2) -ae Erreur: paramètre manquant.
    echo $color(notice) -a Pour obtenir de l'aide, tapez /debugmode --help.
    echo $color(text) -a $chr(45)
  }
  elseif ($debugmode.is(%arg1).command) {
    %name_alias = debugmode.command:: $+ %arg1
    $call.alias(%name_alias)
  }
  elseif ($debugmode.is(%arg1).mode) {
    %name_alias = debugmode.mode:: $+ %arg1
    $call.alias(%name_alias, %arg2)
  }
  elseif ($debugmode.is(%arg1).option) {
    %name_alias = debugmode.option:: $+ $debugmode.option::rename(%arg1).long
    $call.alias(%name_alias, %arg2)
  }
  else {
    echo $color(info2) -ae Erreur: $qt(%arg1) ne correspond à aucun(e) commande, mode ou option.
    echo $color(notice) -a Pour obtenir la liste des commandes/modes/options, tapez /debugmode --help.
    echo $color(notice) -a Pour obtenir de l'aide sur un(e) commande/mode/option particulier(e), $&
      tapez /debugmode --help nomdelacmd.
    echo $color(text) -a $chr(45)
  }
}
/**
* Vérifie si le mode débug est activé ou non.
*
* @return boolean
*/
alias debugmode.is_active {
  return $iif($debug, $true, $false)
}
/**
* @param  string  $$1=%name Nom de la variable à tester
* @return boolean
*
* @property string $prop=command
* @property string $prop=mode
* @property string $prop=option
*/
alias -l debugmode.is {
  var %name = $$1

  ; -------------------- ;

  var %config
  if ($prop === command) {
    %config = $Configure::check.inline(%name, $debugmode.commands)
  }
  elseif ($prop === mode) {
    %config = $Configure::check.inline(%name, $debugmode.modes)
  }
  elseif ($prop === option) {
    %config = $Configure::check.inline(%name, $debugmode.options)
  }

  return %config
}
/**
* Affiche les valeurs d'un tableau.
*
* @param  array  $1=%array
* @param  string $2=%format
* @return void
*/
alias -l debugmode::array_values::toString {
  var %array = $1
  var %format = $2

  ; -------------------- ;

  var %i = 1
  var %total_items = $token(%array, 0, 44)
  while (%i <= %total_items) {
    var %item = $iif($token($token(%array, %i, 44), 2, 61), $v1, $token(%array, %i, 44))
    var %name_alias
    var %item_help

    if ($debugmode.is(%item).command) {
      %name_alias = debugmode.command:: $+ %item $+ &help
      %item_help = $call.alias(%name_alias).result
    }
    elseif ($debugmode.is(%item).mode) {
      %name_alias = debugmode.mode:: $+ %item $+ &help
      %item_help = $call.alias(%name_alias).result
    }
    elseif ($debugmode.is(%item).option) {
      %name_alias = debugmode.option:: $+ $debugmode.option::rename(%item) $+ &help
      %item_help = $call.alias(%name_alias).result
    }

    var %item_list = $replace($token(%array, %i, 44), $chr(61), $+($chr(44), $chr(32)))
    var %item_text = $replace(%format, [value].replace, %item_list, [value], %item)

    echo $color(notice) -a %item_text $iif(%item_help, $+(:, $chr(32), $v1))
    inc %i
  }
}
/**
* Vérifie qu'une valeur corresponde à une option et qu'elle est égale au
*   résultat attendu.
*
* @example $1 = --quiet
* @example $debugmode::assertEquals(--help, $1) Retourne $false
*
* @param  string $$1 La valeur qu'on attend
* @param  string $2 La valeur à testé
* @return boolean
*/
alias -l debugmode::assertEquals {
  var %attempt = $debugmode.option::rename($$1)
  var %test = $iif($2, $debugmode.option::rename($2), $false)

  ; -------------------- ;

  return $iif(%test && (%attempt === %test), $true, $false)
}
/**
* Récupère le nom de l'option (complet ou court).
*
* @param  string $$1=%option Nom de l'option.
* @return string
*/
alias -l debugmode.option::rename {
  var %option = $$1

  ; -------------------- ;

  if ($prop === short) {
    return $remove($Configure::read.inline(%option, $debugmode.options).key, $chr(45))
  }

  return $remove($Configure::read.inline(%option, $debugmode.options), $chr(45))
}

; -- [ Commandes ] --------------------
/**
* TODO: Met à jour ce script.
*
* @command /debugmode update
*/
alias debugmode.command::update {}

; -- [ Modes ] --------------------
/**
* Activation du mode débug.
*
* @command /debugmode on [option]
* @param string $1=%option
*/
alias debugmode.mode::on {
  $iif($isid, return $null)

  ; -------------------- ;

  var %option = $1

  ; -------------------- ;

  var %window = $+(@, $server, :, $me)

  .enable #debugmode
  .window -enmk0 %window
  .debug -ip 14 %window $Configure::read.inline(identifier, $debugmode.config)

  if (!$debugmode::assertEquals(--quiet, %option)) {
    echo $color(info) -ae Mode débug: activé
    echo $color(info) $debug Mode débug: activé
  }
}

/**
* Désactivation du mode débug.
*
* @command /debugmode off [option]
* @param  string $1=%option
*/
alias debugmode.mode::off {
  $iif($isid, return $null)

  ; -------------------- ;

  var %option = $1

  ; -------------------- ;

  .disable #debugmode
  .close -@ $debug

  if (!$debugmode::assertEquals(--quiet, %option)) {
    echo $color(info) -ae Mode débug: désactivé
  }
}

; -- [ Options ] --------------------
/**
* Affiche de l'aide concernant toutes les commandes (ou une seule commande).
*
* @command /debugmode --help [name]
* @param  string $1=%name
*/
alias debugmode.option::help {
  $iif($isid, return $null)

  ; -------------------- ;

  var %name = $1

  ; -------------------- ;

  var %format

  echo $color(text) -a -

  if (!%name) {
    echo $color(notice) -a Usage:
    echo $color(notice) -a -> /debugmode $chr(60) command $chr(124) mode $chr(62) $chr(91) $&
      14option $chr(93)
    echo $color(notice) -a -> /debugmode 14--help [ command $chr(124) mode $chr(124) $&
      14option ]

    echo $color(notice) -a Commandes:
    %format = -> $+(, [value], )
    $debugmode::array_values::toString($debugmode.commands, %format)

    echo $color(notice) -a Modes:
    %format = -> $+(, [value], )
    $debugmode::array_values::toString($debugmode.modes, %format)

    echo $color(notice) -a Options:
    %format = -> $+(14, [value].replace, )
    $debugmode::array_values::toString($debugmode.options, %format)
  }
  else {
    if ($debugmode.is(%name).command) {
      $call.alias(debugmode.command:: $+ %name $+ &help, single)
    }
    elseif ($debugmode.is(%name).mode) {
      $call.alias(debugmode.mode:: $+ %name $+ &help, single)
    }
    elseif ($debugmode.is(%name).option) {
      $call.alias(debugmode.option:: $+ $debugmode.option::rename(%name) $+ &help, single)
    }
  }

  echo $color(text) -a -
}
/**
* @command /debugmode --version
*/
alias debugmode.option::version {
  $iif($isid, return $null)

  ; -------------------- ;

  echo $color(notice) -a Version du script $qt(debugmode.mrc) : v $+ $remove($read($scriptdir $+ debug.mrc, n, 14), * @version)
}

; -- [ Aides ] --------------------
; --- [ Aides commandes ] ---------
alias debugmode.command::update&help {
  $iif($isid, return $null)

  ; -------------------- ;

  var %help = 04Permet de mettre à jour le script $qt(debug.mrc)  (à faire)

  if ($1 === single) {
    echo $color(notice) -a Aide /debugmode update $chr(91) 14option $chr(93)
    echo $color(notice) -a %help
  }

  return $lower(%help)
}

; --- [ Aides modes ] -------------
alias debugmode.mode::on&help {
  $iif($isid, return $null)

  ; -------------------- ;

  var %help = Permet d'activer le mode débug.

  if ($1 === single) {
    echo $color(notice) -ae %help
    echo $color(notice) -a Usage: /debugmode on $chr(91) 14option $chr(93)
    echo $color(notice) -a Options:
    echo $color(notice) -a -> 14-q, 14--quiet : $debugmode.option::quiet&help
  }

  return $lower(%help)
}
alias debugmode.mode::off&help {
  $iif($isid, return $null)

  ; -------------------- ;

  var %help = Permet de désactiver le mode débug.

  if ($1 === single) {
    echo $color(notice) -ae %help
    echo $color(notice) -a Usage: /debugmode off $chr(91) 14option $chr(93)
    echo $color(notice) -a Options:
    echo $color(notice) -a -> 14-q, 14--quiet : $debugmode.option::quiet&help
  }

  return $lower(%help)
}

; --- [ Aides options ] ---------
alias debugmode.option::help&help {
  $iif($isid, return $null)

  ; -------------------- ;

  var %help = Affiche de l'aide.

  if ($1 === single) {
    echo $color(notice) -ae %help
    echo $color(notice) -a Usage: /debugmode 14--help $chr(91) command $chr(124) mode $chr(124) 14option $chr(93)
  }

  return $lower(%help)
}
alias debugmode.option::quiet&help {
  $iif($isid, return $null)

  ; -------------------- ;

  var %help = Permet de désactiver les messages du mode débug.

  if ($1 === single) {
    echo $color(notice) -a -> %help
    echo $color(notice) -a Usage: /debugmode < command $chr(124) mode > 14--quiet
    echo $color(notice) -a Commandes:
    var %format
    %format = -> $+(, [value], )
    $debugmode::array_values::toString($debugmode.commands, %format)

    echo $color(notice) -a Modes:
    %format = -> $+(, [value], )
    $debugmode::array_values::toString($debugmode.modes, %format)
  }

  return $lower(%help)
}
alias debugmode.option::version&help {
  var %help = Affiche la version du script $qt(debug.mrc) $+ .

  if ($1 === single) {
    echo $color(notice) -a Aide /debugmode --version
    echo $color(notice) -a -> %help
    return
  }

  return $lower(%help)
}

; -- [ Événements ] --------------------
#debugmode on
on &*:connect:debugmode on --quiet

/**
* ref config: `identifier`.
*/
alias debugmode.console {
  tokenize 32 $1-

  if ($1 === ->) { $debugmode.managment($1-).me }
  else { $debugmode.managment($1-).user }
  $debugmode.managment($1-).me&user
}
#debugmode end

alias -l debugmode.managment {
  tokenize 32 $1-

  if ($prop === me) {
    if (*P?NG* !iswmcs $3) {
      echo 3 -t $debug $1-

      ; Les événements de bases pour moi même.
      if ($3 === PRIVMSG) { $debugmode.event.text($1-).me }
      elseif ($3 === JOIN) { $debugmode.event.join($1-).me }
      elseif ($3 === MODE) { $debugmode.event.mode($1-).me }
      elseif ($3 === NICK) { $debugmode.event.nick($1-).me }
      elseif ($3 === NOTICE) { $debugmode.event.notice($1-).me }
      elseif ($3 === PART) { $debugmode.event.part($1-).me }
      elseif ($3 === QUIT) { $debugmode.event.quit($1-).me }

      ; Tous les événements (pour moi même)
      $debugmode.event.all($1-).me
    }
  }
  elseif ($prop === user) {
    if (*P?NG* !iswmcs $3) {
      echo 11 -t $debug $1-

      ; Les événements de bases (pour les autres).
      if ($3 === PRIVMSG) { $debugmode.event.text($1-).user }
      elseif ($3 === JOIN) { $debugmode.event.join($1-).user }
      elseif ($3 === MODE) { $debugmode.event.mode($1-).user }
      elseif ($3 === NICK) { $debugmode.event.nick($1-).user }
      elseif ($3 === NOTICE) { $debugmode.event.notice($1-).user }
      elseif ($3 === PART) { $debugmode.event.part($1-).user }
      elseif ($3 === QUIT) { $debugmode.event.quit($1-).user }

      ; Tous les événements (pour les autres)
      $debugmode.event.all($1-).user
    }
  }
  elseif ($prop === me&user) {
    if (ping == $2 || ping == $3) {
      $debugmode.timers
    }
    elseif (*P?NG* !iswmcs $3) {
      ; Les événements de bases (peu importe moi ou l'utilisateur).
      if ($3 === PRIVMSG) { $debugmode.event.text($1-).me&user }
      elseif ($3 === JOIN) { $debugmode.event.join($1-).me&user }
      elseif ($3 === MODE) { $debugmode.event.mode($1-).me&user }
      elseif ($3 === NICK) { $debugmode.event.nick($1-).me&user }
      elseif ($3 === NOTICE) { $debugmode.event.notice($1-).me&user }
      elseif ($3 === PART) { $debugmode.event.part($1-).me&user }
      elseif ($3 === QUIT) { $debugmode.event.quit($1-).me&user }

      ; Tous les événements (peu importe moi ou l'utilisateur)
      $debugmode.event.all($1-).me&user
    }
  }
}

alias -l debugmode.timers {
  $call.alias(Autovoice::check.activities)
}

alias -l debugmode.event.text {
  tokenize 32 $1-

  if ($prop === me) {
    $call.alias(Autovoice::oninput, $4, $5-)
  }
  elseif ($prop === user) {
    $call.alias(Autovoice::ontext, $2, $4, $5-)
  }
  else {
  }
}

alias -l debugmode.event.join {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
  }
  else {
  }
}

alias -l debugmode.event.mode {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
  }
  else {
  }
}

alias -l debugmode.event.nick {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
  }
  else {
  }
}

alias -l debugmode.event.notice {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
  }
  else {
  }
}

alias -l debugmode.event.part {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
  }
  else {
  }
}

alias -l debugmode.event.quit {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
  }
  else {
  }
}

alias -l debugmode.event.all {
  tokenize 32 $1-

  if ($prop === me) {
  }
  elseif ($prop === user) {
    $call.alias(Detections, $2-)
  }
  else {
  }
}
