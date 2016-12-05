/**
* Detection de mots sur le texte.
*/

;
; Les règles doivent être séparées par une virgule.
;
; Pour pouvoir aller à la ligne, ajoute en fin de ligne: $+ $& sauf pour la dernière ligne. (Aussi, n'oublie pas la virgule.)
; @exemple:
;   abcdefghijklmnopqrstuvwxyz,0123456789,azertyuiop $+ $&
;   ,tu.+[e]s.+m[a]gn[i]f[i][k].+tu.+l[e].+s[a][i]s,phisyx,pr[o]ut $+ $&
;   ,héhé
;
; [1] équivaut à "un, [i]n, 1"
; [2] équivaut à "d[e]ux, d[e], t[o], 2"
; [i] équivaut à "i, 1"
; [a] équivaut à "a, 4"
; [e] équivaut à "€, e, 3"
; [o] équivaut à "o, 0"
; [u] équivaut à "u, ù, ú, û, ü"
; [y] équivaut à "y, ý, ÿ"
; [`i] équivaut à "i, ì, í, î, ï, 1"
; [`a] équivaut à "a, à, á, â, ä, 4"
; [`e] équivaut à "e, è, é, ê, ë, 3"
; [`o] équivaut à "o, ò, ó, ô, ö, 0"
; [c] équivaut à "c, k, q"
; [k] équivaut à "c, k, q"
; [ch] équivaut à "ch, sh"
; [f] équivaut à "f, ph"
; [x] équivaut à "x, ks, iks"
; [ESPACE] équivaut à "\s"   (espaces)
; [CHIFFRES] équivaut à "\d" (0 à 9, répété plusieurs fois)
; [LETTRES] équivaut à "\w"  (a à z, répété plusieurs fois)
; [CL] équivaut à "\d, \w"   (0 à 9 et/ou a à z, répété plusieurs fois)
; @example:
; - [c][a]m2[c][a]m detecte "cam2cam, k4mtocam, c4mdeuxkam".
; [PRECIS] @example "[PRECIS]b[i]t[e]" detecte "bite, b1te, ..." mais ne détecte pas "habite, orbite, subitement"
;

; ----- [ Pornographie ] ---------------
;
; Si tu veux créer d'autres règles concernant par exemples, des insultes,
;   inspire toi de l'alias juste en dessous. (il doit avoir un nom d'alias different, genre insult$pattern)
;
alias -l porn$pattern {
  var %pattern = v+[o]t+[e](.+)[e][ch][a]n+g+(.+)[a]p+[e]l+,[c][a]m+(?:[ESPACE])?[2](?:[ESPACE])?[c][a]m+ $+ $&
    ,s+p+(?:[e])?r+m+(?:[e])?,p+l+[a]n+[ESPACE](q+|[k]u),b+r+[a]n+l+[e] $+ $&
    ,[PRECIS]b+[i]t+[e],(m[e][c]|m+[e][u]f+)[ESPACE][ch]([a][u]d|[o]) $+ $&
    ,m+[e][c]s+?(?:.+)p+v+(?:.+)[c][o]n+t+r(?:.+)s+[e]r+v+[i](?:c|ss)(?:e?)
  return $regexify(%pattern)
}

/**
* Evenement TEXT.
* on = actif
* off = inactif
*/
on &^*:TEXT:*:#:{
  var %detected = $false
  var %name = $null

  ; Ligne suivante à retirer si tu veux detecter même quand tu n'es pas @.
  if ($me !isop $chan) return

  ; Par défault le script ne detecte que les utilisateurs ayant un ASV.
  ; Ligne suivante à retirer si tu veux detecter tant bien les utilisateurs IRC que les utilisateurs ayant un ASV.
  if (!$is_skynaute($nick)) return

  ;
  ; Si tu as crée d'autres règles (alias), copie cette condition et remplace tous les "porn" par... par exemple insult
  ;
  ; @example
  ; if ($regex(insult, $strip($1-), $insult$pattern))
  ;  %detected = $true
  ;  %name = insult
  ; }
  ;
  if ($regex(porn, $strip($1-), $porn$pattern)) {
    %detected = $true
    %name = porn
  }

  ; Ce qui suit n'est pas nécessaire de modifier. Sauf si tu sais ce que tu fais ;-D
  if (%detected && %name) {
    var %nick =  $+ $cnick($nick).color $+ $nick $+ 

    var %window = $+(@Detections, $chr(91), %name, $chr(93))
    $iif(!$window(%window),window -nmk0 %window)

    ; On @Detections[%name]
    echo %window $chan : $timestamp < $+ %nick $+ > $replace($strip($1-), $regml(%name, 1), $+(04, $regml(%name, 1), ))

    ; Si tu ne veux pas afficher le message sur le SALON, enlève la ligne suivante suivi du haltdef.
    echo -m $chan 04-> $timestamp < $+ %nick $+ > $replace($strip($1-), $regml(%name, 1), $+(04, $regml(%name, 1), ))
    haltdef
  }
}

/**
* Ceci n'est pas nécessaire de le modifier. Sauf si tu sais ce que tu fais ;-D
* @param string $1 %regex expression à mapper
* @return string expression régulière mappé
*/
alias -l regexify {
  var %mapRegex = $$1

  ; ^, $
  %mapRegex = $replace(%mapRegex, $chr(94), $+($chr(92),$chr(94)), $chr(36), $+($chr(92),$chr(36)))
  ; /
  %mapRegex = $replace(%mapRegex, $chr(47), $+($chr(92),$chr(47)))
  %mapRegex = $replace(%mapRegex, [1],(?:u+n+|[i]+n+|1+), [2],(?:d+[e]u+x+|d+[e]|t+[o]+|2+))
  %mapRegex = $replace(%mapRegex, [i],(?:[i1]+), [a],[a4]+, [e],[€e3]+, [o],[o0]+)
  %mapRegex = $replace(%mapRegex, [u],[uùúûü], [y],[yýÿ])
  %mapRegex = $replace(%mapRegex, [`i],[iìíîï1]+, [`a],[aàáâä4]+, [`e],[eèéêë3]+, [`o],[oòóôö0]+)
  %mapRegex = $replace(%mapRegex, [c],[ckq]+, [k],[ckq]+)
  %mapRegex = $replace(%mapRegex, [ch],[cs]+h+, [f],(?:f+|p+h+), [x],(?:x|(i+)?k+s+))
  %mapRegex = $replace(%mapRegex, [ESPACE],\s+, [CHIFFRES],\d+, [LETTRES],\w+, [CL],[\d\w]+)
  %mapRegex = $replace(%mapRegex, [PRECIS],(?<![\d\w]))
  ; , to |
  %mapRegex = $replace(%mapRegex, $chr(44), $chr(124))
  ; || to |
  %mapRegex = $replace(%mapRegex, $+($chr(124),$chr(124)),$chr(124))

  ; Pour éviter le fameux "mot," to "mot|" en fin d'expression...
  ; Qui éviterait de retourner n'importe quoi.
  if ($right(%mapRegex,1) === $chr(124)) {
    %mapRegex = $left(%mapRegex,-1)
  }

  return /( $+ %mapRegex $+ )/i
}
