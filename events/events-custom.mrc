/**
* A mettre ici les alias concernant les configurations des événements.
* @author Mike 'PhiSyX' S.
*/

; //////////
; // JOIN //
; //////////
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement JOIN.
* @var array 44 key=value
*/
alias EventFormat.config::onjoin {
  return $Configure::assign(prefix_sign, «).last
}

/**
* Pour les opérateurs
*
* Configuration spécifique à l'événement JOIN (supplémentaire).
* @var array 44 key=value
*/
alias EventFormat.config::onjoin&is_operator {
  var %format = [prefix_sign] [nick] est un pseudo certifié. (Opérateur Chat SKYROCK.COM OFFICIEL)
  return $Configure::assign(color, 05) $+ $&
    $Configure::assign(format, %format) $+ $&
    $Configure::assign(prefix_sign, «).last
}

; //////////
; // NICK //
; //////////
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement NICK.
* @var array 44 key=value
*/
alias EventFormat.config::onnick {
  var %format = [prefix_sign] [[event]] [oldnick] a changé son pseudo en [newnick]

  if ($nick === $me) {
    return $Configure::assign(prefix_sign, «) $+ $&
      $Configure::assign(format, %format) $+ $&
      $Configure::assign(switches, -est).last
  }

  return $Configure::assign(prefix_sign, «) $+ $&
    $Configure::assign(format, %format).last
}

; //////////
; // PART //
; //////////
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement PART. 
* @var array 44 key=value
*/
alias EventFormat.config::onpart {
  return $Configure::assign(prefix_sign, «) $+ $&
    $Configure::assign(format, [prefix_sign] [event][suffix_sign] [nick] ([address]) [message]).last
}

; //////////
; // QUIT //
; //////////
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement QUIT. 
* @var array 44 key=value
*/
alias EventFormat.config::onquit {
  return $Configure::assign(prefix_sign, «) $+ $&
    $Configure::assign(format, [prefix_sign] [event][suffix_sign] [nick] ([address]) [message]).last
}

; /////////////
; // RAWMODE //
; /////////////
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement RAWMODE.
* @var array 44 key=value
*/
alias EventFormat.config::onrawmode {
  return $Configure::assign(prefix_sign, «) $+ $&
    $Configure::assign(format, [prefix_sign] [[event]] [nick] a appliqué le mode [mode]).last
}

; //////////
; // QUIT //
; //////////
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement TEXT.
* @var array 44 key=value
*/
alias EventFormat.config::ontext {
  if ($is_skynaute($nick)) {
    return $Configure::assign(format, 04<[nick]04> [message]).last
  }

  return $Configure::assign(format, [nick] [suffix_sign] [message]).last
}
