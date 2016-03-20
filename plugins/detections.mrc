/**
* Plugin pour le DébugMode: detections.
*
* @author Mike 'PhiSyX' S.
* @version 1.0.2
*
* À améliorer.
*/
; -- [ Badwords ] --------------------
; ---- [ Insultes ] ------------------
/**
* @property string $prop=`donttouch`
*/
alias -l Detections::Badwords.insults {
  var %pattern = [#rkb]b+[a]+m+b+[o]+u+l+(?:[a]+|[i]),[#k]b+i+[a]+t+c+h+,[#rkb]b+[i]+[k]+[o]+(?:t+)?,[#rkb](?:b+[o]+u+)?(?:g+n+(?:[i]+)?|n+[i]+)[o]+u+l+(?:[e]+)?,[#rkb]b+[o]+u+[k]+(?:u+[a]+|[a]+)[k]+ $+ $&
    ,[#k]c+h+[i]+[e]+n+[a]+s+(?:[e]+)?,[#rkb]c+h+[i]+n+t+[o](?:[k]+u+[e]+|[k]+),[#k][k]+[o]+n+[a]+(?:s+[e]+|r+) $+ $&
    ,[#k][e]+n+[k]+u+l+(?:[e]+r+|[é]+)?,[e]+n+f+[a4]+n+t+\s+[2] $+ $&
    ,[#rkb]f+[a]+c+[e]+\s+[2]+\s+c+[i]+t+r+[o]+n+,[#rkb]f+d+p+,[#rkb]f+[i1]+l+s+\s+[2] $+ $&
    ,[#k]g+[a]+r+[a]+g+[e]+\s+[à]+\s+b+[i]+t+[e]+ $+ $&
    ,[#k]j+[e]+\s+t+[e]+\s+p+[i]+s+[e]+ $+ $&
    ,l+[è]+c+h+[e]+\s+(?:[#k]b+[i]+t+[e]+|(?:[k]+u+l+|q+)) $+ $&
    ,[#rkb]m+(?:[a]+[k]+){2},[#k]m+[a]+n+g+[e]+\s+t+(?:[a]+\s+(?:m+[è]+r+[e]+|r+[e]+u+m+)|o+n+\s+(?:p+[è]+r+[e]|r+[e]+u+p+)),[#k]m+[a]+n+g+[e]+(?:\-|\s)m+[e]+r+[2],[#kb]m+[o]+r+t+\s(?:[o]|a+u+(?:x+)?)\s+v+[a]+c+h+[e]+(?:s+)? $+ $&
    ,[#rkb]n+[é]+g+r+(?:[e]+|[o]+),[#kb]n+[i]+(?:q+u+[e]+|k+)\s+(?:t+(?:[a]+|[o]+n+)|l+[e]+s+) $+ $&
    ,[#rkb](?<![a-z])p+d+,[#rkb]p+[é]+d+(?:[a]+l+(?:[e]+)?|[é]+),[#k](?<![a-z])p+u+t+[e]+ $+ $&
    ,[#k]s+[a]+l+(?:h+)?[o]+(?:u+)?(?:p+[e]+),[#kb]s+[a]+c+\s+[à]+\s+(?:f+[o]+u+t+r+[e]+|m+[e]+r+d+[e]+),[#kb]s+u+c+[e]+\s+m+[a]+,[#kb]s+u+c+[e]+u+(?:r+|s+[e]+)\s+[2] $+ $&
    ,[#kb]t+[a]+f+[i]+[o]+l+[e]+,[#kb]t+[a]+r+l+[o]+u+(?:s+|z+)(?:[e])?,[#kb]t+[a]+p+[e]+t+[e]+,[#kb]t+(?:a|[e])+n+t+[o]+u+[zs]+(?:[e]+)? $+ $&
    ,[#rkb]y+[o]+u+p+[1]

  if ($prop === donttouch) {
    return $Detections::Regex.regexify(%pattern, $Detections::Sanctions.insults).donttouch
  }

  return $Detections::Regex.regexify(%pattern, $Detections::Sanctions.insults)
}
alias -l Detections::Sanctions.insults {
  return [#k]=(?#Kick:"04F1 ou F703") $+ $&
    ,[#kb]=(?#KickBan:"04sF1 ou sF703") $+ $&
    ,[#rkb]=(?#KickBan:"04sF903")
}

; ---- [ Pornographies ] -------------
/**
* @property string $prop=`donttouch`
*/
alias -l Detections::Badwords.porn {
  var %pattern = [c]+[a]+m+(?:\s+)?[2](?:\s+)?c+[a]+m+,s+p+(?:[e]+)?r+m+(?:[e]+)?,p+l+[a]+n+\s+q+,(?<![a-z])b+[i]+t+[e],b+r+[a]n+l+[e] $+ $&
    ,(?:m+[e][k]|m+[e]u+f+)\s+c+h+(?:[a]u+d+|[o])

  if ($prop === donttouch) {
    return $Detections::Regex.regexify(%pattern, $Detections::Sanctions.porn).donttouch
  }

  return $Detections::Regex.regexify(%pattern, $Detections::Sanctions.porn)
}
alias -l Detections::Sanctions.porn {
  return [#k]=(?#Kick:"04F203") $+ $&
    ,[#kb]=(?#KickBan:"04sF203") $+ $&
    ,[#rkb]=(?#KickBan:"04sF403")
}

; ---- [ Autres detections ] ---------
/**
* @property string $prop=`donttouch`
*/
alias -l Detections::Badwords.other {
  var %pattern = [a-z0-9]{5}\-[a-z0-9]{5}\-[a-z0-9]{5}\-[a-z0-9]{5}\-[a-z0-9]{5} $+ $&
    ,(?<![a-z])c+[o]+d+[e]+ $+ $&
    ,(?:ftp|http)(?:s)?:\/\/ $+ $&
    ,j+[e]\s+v+[e]n+d+ $+ $&
    ,p+[a]y+p+[a]l+ $+ $&
    ,y+[o]u+p+[a]+s+s+

  if ($prop === donttouch) {
    return $Detections::Regex.regexify(%pattern, $Detections::Sanctions.other).donttouch
  }

  return $Detections::Regex.regexify(%pattern, $Detections::Sanctions.other)
}
alias -l Detections::Sanctions.other {
  return [#k]=(?#Kick:"04F103") $+ $&
    ,[#kb]=(?#KickBan:"04cF1003") $+ $&
    ,[#rkb]=(?#KickBan:"04sF1003")
}


; -- [ Detections ] ------------------
alias Detections {
  var %nick = $right($token($1, 1, 33), -1)
  var %event = $2
  var %chan = $3
  var %text = $4-

  ; -------------------- ;

  if (%nick === $server) {
    return $false
  }

  var %window = $+($debug, [detections])
  $iif(!$window(%window), .window -nmk0 %window))

  if ($server === tmi.twitch.tv) {
    %config = $replace($1, $chr(59), $chr(44))
    if ($left(%config,1) != $chr(58)) {
      %nick = $Configure::read(%config, display-name, ->).value
      %event = $3
      %chan = $4
    }
  }

  var %nick_no_detect = chanserv,moobot,nightbot
  if ($istok(%nick_no_detect, %nick, 44)) {
    return $false
  }

  var %pattern
  var %pattern_id
  if ($regex(insult, $1-, /( $+ $Detections::Badwords.insults $+ )/i)) {
    %pattern = $Detections::Badwords.insults().donttouch
    %pattern_id = $Detections::Regex.pattern(%pattern, $regml(insult, 1))

    if (!$rawmsg) {
      echo 11 %window [on %event $+ ] Insulte: $timestamp $&
        $replace($1-, $regml(insult, 1), $+(04, $regml(insult, 1), )) $&
        03 $chr(91) %pattern_id $chr(93) 
    }

    return $regml(insult, 1)
  }
  elseif ($regex(porn, $1-, /( $+ $Detections::Badwords.porn $+ )/i)) {
    %pattern = $Detections::Badwords.porn().donttouch
    %pattern_id = $Detections::Regex.pattern(%pattern, $regml(porn, 1))

    if (!$rawmsg) {
      echo 11 %window [on %event $+ ] Pornographie: $timestamp $&
        $replace($1-, $regml(porn, 1), $+(04, $regml(porn, 1), )) $&
        03 $chr(91) %pattern_id $chr(93) 
    }

    return $regml(porn, 1)

  }
  elseif ($regex(other, $1-, /( $+ $Detections::Badwords.other $+ )/i)) {
    %pattern = $Detections::Badwords.other().donttouch
    %pattern_id = $Detections::Regex.pattern(%pattern, $regml(other, 1))

    if (!$rawmsg) {
      echo 11 %window [on %event $+ ] Detections: $timestamp $&
        $replace($1-, $regml(other, 1), $+(04, $regml(other, 1), )) $&
        03 $chr(91) %pattern_id $chr(93) 
    }

    return $regml(other, 1)
  }
  return $false
}

; -- [ Regex ] -----------------------
/**
* @param string $$1=%pattern Toutes les règles.
* @param string $2=%sanctions Les sanctions.
* @return string 
*/
alias -l Detections::Regex.regexify {
  var %pattern = $$1
  var %sanctions = $2

  ; -------------------- ;

  if (%sanctions) {
    if ($Configure::check(%sanctions, [#k], ->)) {
      %pattern = $replace(%pattern, [#k], $Configure::read(%sanctions, [#k], ->).value)
    }

    if ($Configure::check(%sanctions, [#kb], ->)) {
      %pattern = $replace(%pattern, [#kb], $Configure::read(%sanctions, [#kb], ->).value)
    }

    if ($Configure::check(%sanctions, [#rkb], ->)) {
      %pattern = $replace(%pattern, [#rkb], $Configure::read(%sanctions, [#rkb], ->).value)
    }
  }

  if ($prop === donttouch) {
    return %pattern
  }

  %pattern = $replace(%pattern, [1],(?:u+n+|[i]+n+|1+), [2],(?:d+[e]+u+x+|d+[e]+|t+[o]+|2+))
  %pattern = $replace(%pattern, [i],(?:[i1]|[e]+[a]+), [a],[a4], [e],[e3], [k],[ckq], [o],[o0])
  %pattern = $replace(%pattern, [à],[aà4], [é],[eé3], [è],[eè3])
  %pattern = $replace(%pattern, $chr(44), $chr(124))

  return %pattern
}

/**
* Récupère le bon pattern.
*
* @param string $$1=%pattern Toutes les règles.
* @param string $2=regml Le mot à tester.
*/
alias -l Detections::Regex.pattern {
  var %pattern = $$1
  var %regml = $2

  ; -------------------- ;

  var %pattern_total = $numtok(%pattern, 44)
  var %i = 1
  while (%i <= %pattern_total) {
    if ($regex(%regml, /( $+ $gettok(%pattern, %i, 44) $+ )/i)) {
      return $gettok(%pattern, %i, 44)
    }
    inc %i
  }
}


; -- [ Menu ] ------------------------
menu @*[detections] {
  Effacer le contenu de la fenêtre:clear $target
}
