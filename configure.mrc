/**
* Script Configure.mrc
*
* @author Mike 'PhiSyX' S.
* @version 1.1.0
*
* @identifier bool   `$Configure::check(string %path [ , string %default = $null ])`
*   ```
*   if ($Configure::check(debug))
*     echo -a La configuration $qt(debug) existe.
*   ```
*
* @identifier bool   `$Configure::check.inline(string %path [ , array %data = $null, string %default = $null ])`
*
* @identifier string `$Configure::read(string %path [ , string %default = $null ])`
*   - Retourne la valeur du chemin (%path) si trouvé.
*   - @property string $prop=`key` Retourne la clé de la valeur (%path quoi.) trouvé.
*   ```
*   if ($Configure::check(debug))
*     echo -a La configuration $qt(debug) existe et sa valeur est $qt($Configure::read(debug))
*   ```
*
* @identifier string `$Configure::read.inline(string %path [ , array %data = $null, string %default = $null ])`
*
* @identifier void `$Configure::write(string %config, string %value)`
*   ```
*   if (!$Configure::check(debug))
*     $Configure::write(debug, $true)
*
*   echo -a La configuration $qt(debug) existe et sa valeur est $qt($Configure::read(debug))
*   ```
*/

/**
* @param string $$1=%path La clé/valeur à chercher (par à rapport au fichier de configuration ou à %data)
* @param string $2=%default ($null) Valeur par défaut à attribuer en cas de fail.
* @return string|array
*/
:
; Dans le fichier de configuration: config.ini
; [config]
; debug=true
;
; Dans un script:
; echo -a $Configure::read(debug)
; @return `true`
;
; echo -a $Configure::read(debug2)
; @return `* /echo: insufficient parameters`
;
; echo -a $Configure::read(debug2, Valeur par défaut)
; @return `* /echo: insufficient parameters`
;
; Dans le fichier de configuration: config.ini
; [app]
; name=PhiSyXApp
; version=2.0.8-160420
;
; Dans un script:
; echo -a $Configure::read(app) => $null (error) (bientôt: name=PhiSyXApp,version=2.0.8-160420)
; echo -a $Configure::read(app.name) => PhiSyXApp
; echo -a $Configure::read(app.version) => 2.0.8-160420
;
alias Configure::read {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %path = $$1
  var %default = $iif($2, $v1, $null)

  ; -------------------- ;

  var %data = $Configure::_getFilePath

  if ($prop === key) {
    return $Configure::process(%data, %path, %default).key
  }

  return $Configure::process(%data, %path, %default)
}
/**
* Pareil que `Configure::read` sauf que ça retourne un booléen en cas de trouvaille.
*
* {inheritDoc}
* @return bool
*/
alias Configure::check {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %path = $$1

  ; -------------------- ;

  var %default = $null
  var %data = $Configure::_getFilePath

  return $iif($Configure::process(%data, %path, %default) !== $null, $true, $false)
}
/**
*
*/
alias Configure::write {
  var %config = $$1
  var %value = $$2

  var %table = config
  var %parts = $token(%config,0,46)

  if (%parts === 2) {
    %table = $token(%config,1,46)
    %config = $token(%config,2,46)
  }

  writeini $Configure::_getFilePath %table %config %value
}
/**
* Pareil que `Configure::read` mais prend en paramètre la configuration en deuxième paramètre.
*/
alias Configure::read.inline {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %path = $$1
  var %data = $$2
  var %default = $iif($3, $v1, $null)

  ; -------------------- ;

  if ($prop === key) {
    return $Configure::process(%data, %path, %default).key
  }

  return $Configure::process(%data, %path, %default)
}
/**
* Pareil que `Configure::check` mais prend en paramètre la configuration en deuxième paramètre.
*
* {inheritDoc}
* @return bool
*/
alias Configure::check.inline {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %path = $$1
  var %data = $$2

  ; -------------------- ;

  var %default = $null

  return $iif($Configure::process(%data, %path, %default) !== $null, $true, $false)
}
/**
* Assigne à une clé, une valeur.
*
* @param string $$1=%key La clé
* @param string $$2=%value Valeur à associer à la clé.
* @return string key=value
*/
alias Configure::assign {
  $iif(!$isid, return $false)
  return $+($1, $chr(61), $2, $iif($prop !== last, $chr(44)))
}
; -- [ Process ] --------------------
alias -l Configure::process {
  var %data = $$1
  var %path = $remove($$2, $chr(63), $chr(42))
  var %default = $iif($3, $v1, $null)

  ; ------------------------ ;

  var %_data = %data
  var %table = config
  var %parts = $token(%path,0,46)

  if ($isfile(%data)) {
    if (%parts === 2) {
      %table = $token(%path,1,46)
      %path = $token(%path,2,46)
    }

    var %line = $ini(%data, %table, %path)
    if (%line !== $null) {
      %data = $readini(%data, n, %table, %path)
      if ($prop === key) {
        %data = %path
      }
    }
  }
  else {
    if (%parts === 2) {
      var %path1 = $token(%path,1,46)

      %path = $token(%path,2,46)
      %data = $remove(%data, %path1 $+ =)

      if ($prop === key) {
        return $Configure::read.inline(%path, %data).key
      }

      return $Configure::read.inline(%path, %data)
    }
    else {
      var %_path = $replace(%_path, $chr(40), $+(\, $chr(40)))
      %_path = $replace(%_path, $chr(41), $+(\, $chr(41)))
      %_path = $replace(%_path, $chr(42), $+(\, $chr(42)))
      %_path = $replace(%path, $chr(45), $+(\, $chr(45)))

      %_path = $replace(%_path, $chr(63), $+(\, $chr(63)))

      %_path = $replace(%_path, $chr(91), $+(\, $chr(91)))
      %_path = $replace(%_path, $chr(93), $+(\, $chr(93)))

      %_path = $replace(%_path, $chr(124), $+(\, $chr(124)))

      if ($regex(data,%data,/^\[(.+)\]$)) {
        %data = $regml(data,1)
        %data = $wildtok(%data, $+(%path, =*), 1,44)
        %data = $token(%data,2,61)
        if ($prop === key) {
          %data = %path
        }
      }
      ; @example app=[name=PhiSyXApp,version=2.0.1-210416]
      ; @return name=PhiSyXApp,version=2.0.1-210416
      elseif ($regex(data,%data,/ $+ %_path $+ =\[([^\[]+)\]/)) {
        %data = $regml(data,1)
      }
      ; by index@*=*
      elseif ($regex(data,%data,/( $+ %_path $+ @[^,]+)/)) {
        %data = $regml(data,1)

        if ($prop === index) {
          %data = $gettok(%data, 1, 64)
        }
        elseif ($prop === key) {
          %data = $remove($gettok(%data, 1, 61), %path $+ @)
        }
        else {
          %data = $iif($gettok(%data, 2, 61), $v1, $gettok(%data, 2, 64))
        }
      }
      ; by key=*
      elseif ($regex(data,%data,/( $+ %_path $+ =[^,]+)/)) {
        %data = $regml(data,1)
        if ($prop === key) {
          %data = $gettok(%data, 1, 61)
        }
        else {
          %data = $gettok(%data, 2, 61)
        }
      }
      ; by *=value
      elseif ($regex(data,%data,/([^,]+= $+ %_path $+ )/)) {
        %data = $regml(data,1)

        if ($prop === key) {
          %data = $gettok(%data, 1, 61)
        }
        else {
          %data = $gettok(%data, 2, 61)
        }
      }
      else {
        %data = $wildtok(%data, %path, 1, 44)
      }
    }
  }

  return $iif(%data !== %_data, %data, %default)
}
/**
* Retourne le chemin du fichier de configuration
* @return string
*/
alias -l Configure::_getFilePath {
  var %filename = scripts\users\phisyx\config.ini
  if (!$exists(%filename)) {
    writeini %filename config debug true
  }
  return %filename
}
