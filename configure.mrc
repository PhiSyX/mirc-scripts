/**
* Configure
*   SCRIPT A AMÉLIORER.
*
* @author Mike 'PhiSyX' S.
*
* @property boolean $Configure::check(array %config, string %key, string %direction = =*)
* @property string|$null $Configure::read(array %config, string %key, string %direction = =*)
* @property boolean $Configure::checkByIndex(array %config, string %key, string %direction = =*)
* @property string|$null $Configure::readByIndex(array %config, string %key, string %direction = =*)
* @property string $Configure::assign(string %key, string %value)
*/

/**
* {inherit doc}
* Alias de Configure::read
*
* @param  array   $$1=%config   Le tableau de configuration.
* @param  string  $$2=%key      La clé à rechercher.
* @param  string  $3=%direction =*|*=|both
* @return boolean               $true en cas de succès, $false sinon.
*/
alias Configure::check {
  if (!$isid) {
    return $false
  }

  return $iif($Configure::read($$1, $$2, $3) !== $null, $true, $false)
}

/**
* Utilisé pour lire les informations de configurations. (sous forme key=value,key2=value2)
*
* @param  array  $$1=%config   Le tableau de configuration.
* @param  string $$2=%key      La clé à rechercher.
* @param  string $3=%direction =*|*=|both
* @return string|$null         La bonne valeur, $null sinon.
*/
alias Configure::read {
  if (!$isid) {
    return $false
  }

  ; ---------------------------------- ;

  var %config = $$1
  var %key = $$2
  var %direction = $iif(!$3, $false, $3)

  ; ---------------------------------- ;

  var %name
  var %result

  ; ?@*=* | .both
  if ($chr(64) isincs %key || $prop === both) {
    %name = %key
  }
  ; =*
  elseif (!%direction || %direction === $+($chr(61),$chr(42))) {
    %name = $+(%key, $chr(61), *)
  }
  ; *=
  elseif (%direction === $+($chr(42),$chr(61))) {
    %name = $+(*, $chr(61), %key)
  }
  elseif (%direction == both) {
    %name = $+(%key, $chr(61), *)
    %result = $wildtok(%config, %name, 1, 44)
    if (!%result) {
      %name = $+(*, $chr(61), %key)
      %result = $wildtok(%config, %name, 1, 44)
    }
  }

  %result = $wildtok(%config, %name, 1, 44)

  if ($prop === both || $prop === key) {
    if ($prop === key) {
      return $token(%result, 1, 61)
    }
    return %result
  }

  return $iif($token(%result, 2, 61), $replace($v1, $chr(59), $chr(44)))
}

/**
* {inherit doc}
* Alias de Configure::readByIndex
*
* @param  array   $$1=%config   Le tableau de configuration.
* @param  string  $$2=%key      La clé à rechercher.
* @param  string  $3=%direction =*|*=|both
* @return boolean               $true en cas de succès, $false sinon.
*/
alias Configure::checkByIndex {
  if (!$isid) {
    return $false
  }

  ; ----------- ;

  return $iif($Configure::readByIndex($$1, $$2, $3) !== $null, $true, $false)
}

/**
* Utilisé pour lire les informations de configuration ayant des index. (forme index@key=value)
*
* @param  array  $$1=%config   Le tableau de configuration.
* @param  int    $$2=%index    L'index à rechercher.
* @param  string $3=%direction =*|*=|both
* @return string|$null         La bonne valeur, $null sinon.
*/
alias Configure::readByIndex {
  if (!$isid) {
    return $false
  }

  ; ------------------------------------- ;

  var %config = $1
  var %index = $iif($2 isnum, $+($2, @, *))

  ; ------------------------------------- ;

  var %result = $Configure::read(%config, %index, $3).both

  if ($prop === key) {
    return $token(%result, 2, 64)
  }
  elseif ($prop === value) {
    return $token(%result, 2, 61)
  }

  return %result
}

/**
* Assigne à une clé, une valeur.
*
* @param  string $$1=%key   Clé
* @param  string $$2=%value Valeur
* @return string            key=value
*/
alias Configure::assign {
  if (!$isid) {
    return $false
  }

  ; ----------- ;

  return $+($1, $chr(61), $2, $iif($prop !== last, $chr(44)))
}
