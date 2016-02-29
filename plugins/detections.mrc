/**
* Plugin pour le DébugMode.
*   Détections de mots.
* 
* À améliorer.
*/

; ///////////////
; // VARIABLES //
; ///////////////
/**
* Alias contenant toutes les règles concernant les insultes/injures.
* @return string
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

  if ($prop === pattern) {
    return $Detection.regex::regexify(%pattern, $Detections::Badwords.insults.keys).comments
  }

  return $Detection.regex::regexify(%pattern, $Detections::Badwords.insults.keys)
}

alias -l Detections::Badwords.insults.keys {
  return [#k]=(?#Kick:"04F1 ou F703"),[#kb]=(?#KickBan:"04sF1 ou sF703"),[#rkb]=(?#KickBan:"04sF903")
}

/**
* Alias contenant toutes les règles concernant la pornographie.
*
* @return string
*/
alias -l Detections::Badwords.porn {
  var %pattern = [c]+[a]+m+(?:\s+)?[2](?:\s+)?c+[a]+m+,s+p+(?:[e]+)?r+m+(?:[e]+)?,p+l+[a]+n+\s+q+,(?<![a-z])b+[i]+t+[e],b+r+[a]n+l+[e]

  if ($prop === pattern) {
    return $Detection.regex::regexify(%pattern, $Detections::Badwords.porn.keys).comments
  }

  return $Detection.regex::regexify(%pattern, $Detections::Badwords.porn.keys)
}
alias -l Detections::Badwords.porn.keys {
  return [#k]=(?#Kick:"04F203"),[#kb]=(?#KickBan:"04sF203"),[#rkb]=(?#KickBan:"04sF403")
}

/**
* Alias contenant toutes les autres règles.
*
* @return string
*/
alias -l Detections::Badwords.other {
  var %pattern = (?:ftp|http)(?:s)?:\/\/

  if ($prop === pattern) {
    return $Detection.regex::regexify(%pattern, $Detections::Badwords.other.keys).comments
  }

  return $Detection.regex::regexify(%pattern, $Detections::Badwords.other.keys)
}
alias -l Detections::Badwords.other.keys {
  return [#k]=(?#Kick:"04F103"),[#kb]=(?#KickBan:"04cF1003"),[#rkb]=(?#KickBan:"04sF1003")
}

/**
* Construction des regex fait à la va vite...
* À améliorer.
*/
alias -l Detection.regex::regexify {
  var %pattern = $$1

  ; ------------- ;

  if ($2) {
    %pattern = $replace(%pattern, [#k], $Configure::read($2,[#k]), [#kb], $Configure::read($2, [#kb]), [#rkb], $Configure::read($2, [#rkb]))
    if ($prop === comments) {
      return %pattern
    }
  }

  %pattern = $replace(%pattern, [1],(?:u+n+|[i]+n+|1+), [2],(?:d+[e]+u+x+|d+[e]+|t+[o]+|2+))
  %pattern = $replace(%pattern, [i],(?:[i1]|[e]+[a]+), [a],[a4], [e],[e3], [k],[ckq], [o],[o0])
  %pattern = $replace(%pattern, [à],[aà4], [é],[eé3], [è],[eè3])

  %pattern = $replace(%pattern, $chr(44), $chr(124))

  return %pattern
}

alias -l Detection.regex::tester {
  var %pattern = $$1
  var %regml = $2

  ; -------------- ;

  var %pattern_total = $numtok(%pattern, 44)
  var %i = 1
  while (%i <= %pattern_total) {
    if ($regex(%regml, /( $+ $Detection.regex::regexify($gettok(%pattern, %i, 44)) $+ )/i)) {
      %pattern = $replace(%pattern, [#kb], (?#KickBan:"04sF903"), [#k], (?#Kick:"04F703"))
      return $gettok(%pattern, %i, 44)
    }
    inc %i
  }
}

/**
*
*/
alias -l Detection.regex::humanize {
  var %pattern = $replace($1, $chr(124),$chr(44))
  return %pattern
}


; ////////////////
; // DETECTIONS //
; ////////////////
alias Detections {
  tokenize 32 $1-

  var %nick = $right($token($1, 1, 33), -1)
  var %event = $2
  var %chan = $3
  var %text = $4-

  ; ------------------------------------ ;

  if (%nick === $server) {
    return $false
  }

  var %window = $+($debug, [detections])

  $iif(!$window(%window), .window -nmk0 %window))

  if ($2 === JOIN) {
    %chan = $right(%chan, -1)
    %text = $null
  }
  elseif ($2 === NOTICE) {
    %chan = $iif($ischan(%chan), %chan, $comchan(%nick, 1))
  }
  elseif ($2 === PRIVMSG) {
    %event = TEXT
    %text = $right(%text, -1)
  }

  var %pattern
  var %tester

  ; Sur le %text
  if ($regex(insult, %text __Pseudo__ $+ %nick, /( $+ $Detections::Badwords.insults $+ )/i)) {
    %pattern = $Detections::Badwords.insults().pattern
    %tester = $Detection.regex::tester(%pattern, $regml(insult,1))

    if (!$rawmsg) {
      echo 11 %window [on %event $+ ] Insulte: $timestamp $&
        < $+ $nick.color(%nick,%chan).custom $+ : $+ %chan $+ :03 $+ %tester $+ > $&
        $replace(%text, $regml(insult, 1), $+(04, $regml(insult, 1), ))
    }

    return $regml(insult, 1)
  }
  elseif ($regex(porn, %text __Pseudo__ $+ %nick, /( $+ $Detections::Badwords.porn $+ )/i)) {
    %pattern = $Detections::Badwords.porn().pattern
    %tester = $Detection.regex::tester(%pattern, $regml(porn,1))

    if (!$rawmsg) {
      echo 11 %window [on %event $+ ] Pornographie: $timestamp $&
        < $+ $nick.color(%nick,%chan).custom $+ : $+ %chan $+ :03 $+ %tester $+ > $&
        $replace(%text, $regml(porn, 1), $+(04, $regml(porn, 1), ))
    }

    return $regml(porn, 1)
  }
  elseif ($regex(other, %text __Pseudo__ $+ %nick, /( $+ $Detections::Badwords.other $+ )/i)) {
    %pattern = $Detections::Badwords.other().pattern
    %tester = $Detection.regex::tester(%pattern, $regml(other,1))

    if (!$rawmsg) {
      echo 11 %window [on %event $+ ] Detection: $timestamp $&
        < $+ $nick.color(%nick,%chan).custom $+ : $+ %chan $+ :03 $+ %tester $+ > $&
        $replace(%text, $regml(other, 1), $+(04, $regml(other, 1), ))  
    }

    return $regml(other, 1)
  }

  return $false
}

; //////////
; // MENU //
; //////////
menu @*[detections] {
  Effacer le contenu de la fenêtre:clear $target
}
