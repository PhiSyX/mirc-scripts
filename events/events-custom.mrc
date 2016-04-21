/**
* A mettre ici les alias concernant les configurations des événements.
* @author Mike 'PhiSyX' S.
*/

; -- [ Configurations ] ----------------
; --- [ JOIN ] -------------------------
/**
* Pour les opérateurs (SKYROCK)
*
* Configuration spécifique à l'événement JOIN (supplémentaire).
* @var array 44 key=value
*/
alias EventFormat.config::onjoin&is_operator {
  var %format = {{prefix_sign}} {{nick}} est un pseudo certifié. (Opérateur Chat SKYROCK.COM OFFICIEL)
  return $Configure::assign(color, 05) $+ $&
    $Configure::assign(format, %format).last
}

; --- [ TEXT ] -------------------------
/**
* Cet alias n'est pas obligatoire.
*
* Configuration spécifique à l'événement TEXT.
* @var array 44 key=value
*/
alias EventFormat.config::ontext {
  if ($is_skynaute($nick)) {
    var %format = 04<{{nick}}04> {{message}}
    return $Configure::assign(format, %format).last
  }
}
