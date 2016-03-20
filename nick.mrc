/**
* Alias utiles liés aux pseudonymes.
*
* Ce script a été spécialement conçu pour être utilisé avec le script "Skyrock.fm v10".
* Pourquoi? Il contient des variables/identifieurs/alias provenant de ce script.
* Lesquel(le)s: %hq-chan, $is_botoff, $is_skynaute, $ison_hq, `skyteam` hash table.
*
* @author "Mike 'PhiSyX' S."
* @version 1.1.4
* @require
*   - Script mIRC Skyrock.fm v10
*   - scripts/users/phisyx/configure.mrc
*
* @identifier boolean $is_operator_off(string %pseudo)
*   - default: Retourne un boolean si le pseudo est un Opérateur Chat Skyrock.com officiel.
*
* @identifier string $nick.color(string %pseudo, string %salon)
*   - default: Retourne le pseudonyme avec sa couleur suivant son grade (op|hop|vip).
*   - `.custom`: Retourne le pseudonyme avec plus de couleurs.
*     La première lettre a une couleur spécifique.
*     La derniere lettre à une couleur spécifique.
*     Les lettres entre la première et la dernière lettre ont une couleur spécifique.
*     Les status ([absent],...) ont une couleur spécifique et sont soulignés.
*
* @identifier string $nick.operator.sign(string %pseudo)
*   - default: Retourne le signe du groupe de l'opérateur.
*     - test = *
*     - préadd = '
*     - ircop lite = °
-     - developer && ircop = ° (bold)
*   - `.color`: comme default mais avec les couleurs.
*
* @identifier string $nick.operator.sponsor(string %pseudo)
*   - default: Retourne le parrain d'un pseudo. (Opérateur)
*/

; -- [ Variables ] --------------------
/**
* Configuration des couleurs.
*
* Liste des options de couleurs disponibles:
*   - between
*   - first
*   - last
*   - status
*   - if_status__<between | first | last | status>
*   - botoff__<between | first | last>
*   - skyrock_vhost__<between | first | last | status>
*
* @var array 44 key=value
*/
alias -l nick.color._defaultConfig {
  return $Configure::assign(first, 14) $+ $&
    $Configure::assign(last, 14) $+ $&
    $Configure::assign(nonworld, 14) $+ $&
    $Configure::assign(botoff__between, 01) $+ $&
    $Configure::assign(botoff__first, 14) $+ $&
    $Configure::assign(botoff__last, 01) $+ $&
    $Configure::assign(skyrock_vhost__between, 14) $+ $&
    $Configure::assign(skyrock_vhost__first, 03) $+ $&
    $Configure::assign(skyrock_vhost__last, 04).last
}

; -- [ Nick color ] --------------------
/**
* Coloration pseudonyme.
*
* @param string $$1=%nick Pseudo à colorer.
* @param string $2=%chan  Salon du pseudo (obligatoire).
* @return $false|string   Le pseudonyme avec les couleurs qui vont bien.
*
* @property string $prop=custom Plus de couleurs.
*/
alias nick.color {
  var %nick = $$1
  var %chan = $iif($2, $v1, $active)

  if (!$ischan(%chan)) {
    echo $color(info2) -a -
    echo $color(info2) -at ERREUR: L'alias `$nick.color` prend 2 paramètres.
    echo $color(notice) -at Info: Paramètre `nick` obligatoire
    echo $color(notice) -at Info: Paramètre `chan` non obligatoire mais à condition que la fenêtre active s'agit d'un salon.
    echo $color(info2) -at -
    echo $color(info2) -at Sortie alias: $+($,nick.color,$chr(40),%nick=,%nick,$chr(44), %chan= $+ $iif(%chan, $v1, $active),$chr(41))
    echo $color(ctcp) -at Votre erreur: $iif(%chan, $v1, $active) $+ .
    echo $color(info2) -a -
    return $false
  }

  var %config = $nick.color._defaultConfig

  var %nick_mode = $nick.get(%nick, %chan).chanusermode
  var %nick_color = $nick(%chan, %nick).color
  if ($len(%nick_color) === 1) {
    %nick_color = $+(0, %nick_color)
  }

  var %nick_without_asv = $rm_asv(%nick)
  var %nick_asv_only = $nick.get(%nick).asv_only

  var %nick_sign = $null
  if ($is_skynaute(%nick)) {
    %nick_sign = $nick.operator.sign($strip(%nick_without_asv)).color
  }
  else {
    %nick_sign = $nick.operator.sign(%nick).color
  }

  ; MON STYLE
  if ($prop === custom) {
    if (!$is_skynaute(%nick)) {
      var %nick_without_status = $nick.get(%nick).without_status
      var %nick_status_only = $nick.get(%nick).status_only
      var %nick_first_char = $nick.get(%nick_without_status).first_char
      var %nick_between_f&l_chars = $nick.get(%nick_without_status).between_f&l_chars
      var %nick_last_char = $nick.get(%nick_without_status).last_char

      ; COULEURS:
      ;   First
      var %nfc = $iif($Configure::read(%config, first, ->).value, $v1, %nick_color)
      ;   Between
      var %nbc = $iif($Configure::read(%config, between, ->).value, $v1, %nick_color)
      ;   Last
      var %nlc = $iif($Configure::read(%config, last, ->).value, $v1, %nick_color)
      ;   Status
      var %nsc = $iif($Configure::read(%config, status, ->).value, $v1, %nick_color)

      if (%nick_status_only) {
        %nbc = $iif($Configure::read(%config, if_status__between, ->).value, $v1, %nbc)
        %nfc = $iif($Configure::read(%config, if_status__first, ->).value, $v1, %nfc)
        %nlc = $iif($Configure::read(%config, if_status__last, ->).value, $v1, %nlc)
        %nsc = $iif($Configure::read(%config, if_status__status, ->).value, $v1, %nsc)
      }

      if ($is_botoff(%nick)) {
        %nbc = $iif($Configure::read(%config, botoff__between, ->).value, $v1, %nbc)
        %nfc = $iif($Configure::read(%config, botoff__first, ->).value, $v1, %nfc)
        %nlc = $iif($Configure::read(%config, botoff__last, ->).value, $v1, %nlc)
      }
      elseif ($nick.is_skyrock_vhost(%nick)) {
        %nbc = $iif($Configure::read(%config, skyrock_vhost__between, ->).value, $v1, %nbc)
        %nfc = $iif($Configure::read(%config, skyrock_vhost__first, ->).value, $v1, %nfc)
        %nlc = $iif($Configure::read(%config, skyrock_vhost__last, ->).value, $v1, %nlc)
        %nsc = $iif($Configure::read(%config, skyrock_vhost__status, ->).value, $v1, %nsc)
      }

      %nbc = $iif($len(%nbc) === 1, $+(0, %nbc), %nbc)
      %nfc = $iif($len(%nfc) === 1, $+(0, %nfc), %nfc)
      %nlc = $iif($len(%nlc) === 1, $+(0, %nlc), %nlc)
      %nsc = $iif($len(%nsc) === 1, $+(0, %nsc), %nsc)

      %nfc = $+(, %nfc, %nick_first_char, )
      %nbc = $+(, %nbc, %nick_between_f&l_chars, )
      %nlc = $+(, %nlc, %nick_last_char, )
      %nick_status_only = $replace(%nick_status_only, $chr(91), $+($chr(91), ), $chr(93), $+($chr(93), ))
      %nsc = $+(, %nsc, %nick_status_only, )

      return $+(%nick_mode, %nfc, %nbc, %nlc, %nsc, %nick_sign)
    }
    else {
      %nick_asv_only = $nick.get(%nick).asv_only&custom
    }
  }

  if ($is_skynaute(%nick)) {
    if ($nick.is_skyrock_vhost(%nick)) {
      %nick_without_asv = $strip(%nick_without_asv)
      %nick_without_asv = $+(, %nick_color, %nick_without_asv, )
    }
    %nick = $+(%nick_without_asv, , %nick_color, $chr(124), , %nick_asv_only)
  }

  return $+(%nick_mode, , %nick_color, %nick, , %nick_sign)
}
/**
* Retourne des informations concernant le pseudonyme.
*
* @param  string $$1=%nick Pseudo.
* @param  string $2=%chan Salon.
* @return string|$null
*/
alias -l nick.get {
  var %nick = $$1
  var %chan = $2

  ; -------------------- ;

  var %nick_status = $regex(nick_status, %nick, /(\[.+\])$/)
  var %nick_asv = $regex(nick_asv, %nick, /\|(\d{2}[a-z0-9]{2}[fm][a-z0-9]{2})$/i)

  if ($prop === asv_only || $prop == asv_only&custom) {
    var %asv_color = 12
    if ($nick.is_skyrock_vhost(%nick)) {
      %asv_color = 03
    }
    elseif (????f?? iswmcs $regml(nick_asv, 1)) {
      %asv_color = 13
    }

    if ($prop === asv_only&custom) {
      %asv_color = 02
      if ($nick.is_skyrock_vhost(%nick)) {
        %asv_color = 12
      }
      if (????f?? iswm $regml(nick_asv, 1)) {
        %asv_color = 06
        if ($nick.is_skyrock_vhost(%nick)) {
          %asv_color = 13
        }
      }
    }

    return $+(, %asv_color, $regml(nick_asv, 1), )
  }
  elseif ($prop === between_f&l_chars) {
    return $iif($len(%nick) !== 1, $mid(%nick, 2, -1))
  }
  elseif ($prop === chanusermode) {
    var %mode = $iif(%nick isop %chan, $chr(64), $iif(%nick ishop %chan, $chr(37), $iif(%nick isvo %chan, $chr(43))))

    if ($is_botoff(%nick)) {
      return $+(14, %mode, )
    }

    return $+(, $nick(%chan, %nick).color, %mode, )
  }
  elseif ($prop === first_char) {
    return $left(%nick, 1)
  }
  elseif ($prop === last_char) {
    return $iif($len(%nick) !== 1,$right(%nick, 1))
  }
  elseif ($prop === status_only) {
    return $regml(nick_status, 1)
  }
  elseif ($prop === without_status) {
    return $iif(%nick_status, $remove(%nick, $regml(nick_status, 1)), %nick)
  }
}

; -- [ Opérateurs Skyrock Officiel ] --------------------
/**
* Vérifie si le pseudo passé en paramètre est un Opérateur Chat SKYROCK.COM OFFICIEL.
* (alias de $nick.groups::check(N) mais meilleur appellation)
*
* @example code:
*   echo $color(notice) -ae -> $me $iif($is_operator_off($me), est un opérateur officiel SKYROCK.COM :-], n'est pas opérateur... :-[)
*
* @param  string $$1=%nick Pseudo à vérifier.
* @return boolean Retourne $true en cas de trouvaille.
*/
alias is_operator_off {
  if (!$isid) {
    return $false
  }

  var %group = $nick.operator($$1).group
  return $iif(%group isnum && %group !== 1, $Configure::check($nick.groups, %group, index), $false)
}

/**
* Tableau contenant les noms de groupes d'opérateurs (+ user)
* @var array 44 : index@key=value
*/
alias -l nick.groups {
  return 1@User,3@Test=*,4@PréAdd=',5@Add,6@IRCLite=°,6.5@Developer=°,7@IRCop=°
}
alias nick.operator {
  var %nick = $$1

  ; -------------------- ;

  var %operator = $hget(skyteam, $token(%nick, 1, 91))
  var %group = $iif($token(%operator, 1, 32), $v1, 1)

  if ( ($ison_hq(%nick) && %nick isop %hq-chan) || (ircd??.skyrock.net iswm $server && %nick isop #irc) ) {
    %group = 7
  }

  if ($prop === group) {
    return %group
  }
  elseif ($prop === sponsored_by) {
    return $token(%operator, 2, 32)
  }
}
/**
* Récupère le signe du groupe de l'opérateur.
*
* @param  string $$1=%operator Pseudo de l'opérateur.
* @return string|$null         Signe du groupe des opérateurs.
*
* @property string $prop=color Retourne le signe du groupe de l'opérateur mais avec sa couleur.
*/
alias nick.operator.sign {
  if (!$isid) {
    return $false
  }

  ; -------------------- ;

  var %operator = $$1

  ; -------------------- ;

  if (!$is_operator_off(%operator)) {
    return $null
  }

  var %group_num = $nick.operator(%operator).group

  var %group = $Configure::read($nick.groups, %group_num, index).key
  var %sign = $Configure::read($nick.groups, %group_num, index).value

  if ($prop === color) {
    %sign = $replace(%sign, $chr(42), $+(07, $chr(42), ))
    %sign = $replace(%sign, $chr(39), $+(06, $chr(39), ))

    if (irclite isin %group) {
      %sign = $replace(%sign, $chr(176), $+(10, $chr(176), ))
    }
    elseif (developer isin %group || ircop isin %group) {
      %sign = $replace(%sign, $chr(176), $+(04, $chr(176), ))
    }
  }

  return %sign
}
/**
* Récupère le parrain de l'opérateur.
*
* @param  string $$1=%operator Pseudo de l'opérateur.
* @return string Parrain de l'opérateur.
*/
alias nick.operator.sponsor {
  if (!$isid) {
    return $false
  }

  ; -------------------- ;

  if ($is_operator_off($$1)) {
    return $nick.operator($$1).sponsored_by
  }
}

/**
* Vérifie que le pseudo passé en paramètre s'agit d'une personne venant des locaux Skyrock.com
*
* @param  string $$1=%nick
* @return boolean
*/
alias nick.is_skyrock_vhost {
  if (!$isid) {
    return $false
  }

  ; -------------------- ;

  var %addr = $address($$1,4)
  return $iif(*@*.skyrock.net* iswm %addr || *@*.orbus.fr iswm %addr, $true, $false)
}
