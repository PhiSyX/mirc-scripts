/**
* Amélioration du whois: les salons prennent des couleurs.
*
* Ce script a été spécialement conçu pour être utilisé avec le script "Skyrock.fm v10".
* Pourquoi? Il contient des variables/identifieurs/alias provenant de ce script.
* Lesquel(le)s: $is_chanoff, $is_hq, $isin_chanlist.
*
* @author Mike 'PhiSyX' S.
* @require
*   - mIRC Skyrock.fm v10
*   - scripts/users/phisyx/configure.mrc
* @version 1.1.0
*/

; 319 RPL_WHOISCHANNELS
raw 319:*: {
  haltdef
  echo -at $2 on $whois.chanlist
}

/**
* Construction de la liste des salons.
*/
alias -l whois.chanlist {
  var %chanlist = $right($token($rawmsg, 5-, 32), -1)
  var %channels_total = $numtok(%chanlist, 32)

  var %chanlist_temp
  var %i = 1
  while (%i <= %channels_total) {
    %chanlist_temp = $addtok(%chanlist_temp, $whois.channel($gettok(%chanlist, %i, 32)), 32)
    inc %i
  }

  return %chanlist_temp
}
/**
* Construction d'un seul salon avec ses couleurs.
*
* @param string $$1=%chan Salon complet.
* @return string Le salon avec ses couleurs.
*/
alias -l whois.channel {
  ; Salon complet : @%##ibug / +#irc
  var %chan = $$1

  ; -------------------- ;

  ; Salon sans les modes de salons +q/+a/+o/+h/+v : ##ibug / #irc
  var %chan_without_usermodes = $whois.channel.get(%chan).without_usermodes

  ; Récupération des modes du salon : @% / +
  var %chan_usermodes_only = $whois.channel.get(%chan).usermodes_only

  ; Couleur par défaut de la sortie du salon.
  var %color = $color(whois)

  ; Pour les salons officiels. (Skyrock.fm)
  if ($is_chanoff(%chan_without_usermodes)) {
    %color = $Configure::read(whois.is_chanoff)
    if ($chr(64) isin %chan_usermodes_only) {
      %color = $Configure::read(whois.is_chanoff_op)
    }
  }
  elseif ($is_hq(%chan_without_usermodes) || $isin_chanlist(%chan_without_usermodes, $Configure::read(whois.chanoff&perso))) {
    %color = $Configure::read(whois.is_chanoff&perso)
  }
  elseif ($regex(%chan_without_usermodes, / $+ $whois.channel.get().prefixes $+ /)) {
    %color = $Configure::read(whois.is_prefixed)
  }

  if ($len(%color) === 1) {
    %color = 0 $+ %color
  }

  if ($isin_chanlist(%chan_without_usermodes, $whois.channel.get().favorites)) {
    %color = %color $+ 
  }

  return $+(%chan_usermodes_only, , %color, %chan_without_usermodes, )
}
/**
* Récupère des informations concernant la configuration ou le salon.
*
* // TODO
*
* @param  string $1=%chan Le salon.
* @return string
*/
alias -l whois.channel.get {
  var %chan = $1

  ; -------------------- ;

  var %usermodes = $prefix

  ; Construction du pattern. (Expression régulière.)
  %usermodes = $replace(%usermodes, $chr(126), $+($chr(92), $chr(126), $chr(124)))
  %usermodes = $replace(%usermodes, $chr(38), $+($chr(92), $chr(38), $chr(124)))
  %usermodes = $replace(%usermodes, $chr(64), $+($chr(92), $chr(64), $chr(124)))
  %usermodes = $replace(%usermodes, $chr(37), $+($chr(92), $chr(37), $chr(124)))
  %usermodes = $replace(%usermodes, $chr(43), $+($chr(92), $chr(43)))

  var %pattern = $+($chr(40), ?:, %usermodes, $chr(41), $chr(43))
  %usermodes = $iif($regex(usermodes, %chan, /(\!? $+ %pattern $+ )/), $regml(usermodes, 1), $null)

  if ($prop === favorites) {
    return $Configure::read(whois.favorites)
  }
  elseif ($prop === prefixes) {
    var %prefixes = $Configure::read(whois.prefixes)
    var %pattern = $replace(%prefixes, $chr(44), $chr(124), $chr(45), $+($chr(92),$chr(45)))
    return %pattern
  }
  elseif ($prop === usermodes_only) {
    %usermodes = $replace(%usermodes, $chr(126), $+(04, $chr(126), ))
    %usermodes = $replace(%usermodes, $chr(38), $+(04, $chr(38), ))
    %usermodes = $replace(%usermodes, $chr(64), $+(04, $chr(64), ))
    %usermodes = $replace(%usermodes, $chr(37), $+(10, $chr(37), ))
    %usermodes = $replace(%usermodes, $chr(43), $+(07, $chr(43), ))
    %usermodes = $replace(%usermodes, $chr(33), $+(05, $chr(33), ))

    return %usermodes
  }
  elseif ($prop === without_usermodes) {
    return $remove(%chan, %usermodes)
  }
}
