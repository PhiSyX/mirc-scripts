/**
* Script Configure.mrc
*
* @author Mike 'PhiSyX' S.
* @version 1.0.2
*
* @identifier boolean $Configure::check(array %config, string %key, string %direction = ->)
*
* @identifier string|null $Configure::read(array %config, string %key, string %direction = ->)
*   - Retourne la valeur entière de la clé trouvé.
*   - @property string $prop=`key` Retourne la clé de la clé trouvé.
*   - @property string $prop=`value` Retourne la valeur de la clé trouvé.
*/

/**
* Utilisé pour lire les informations de configurations.
*
* @param array $$1=%config La configuration.
* @param string|int $$2=%key La clé/valeur à chercher.
* @param string $3=%direction La direction.
*   - index: :key@*
*   - <- : *=:key
*   - -> : :key=*
*   - <-> : :key=*, *=:key
* @properties string $prop=`key` Retourne la clé de la clé trouvé.
* @properties string $prop=`value` Retourne la valeur de la clé trouvé.
* @return string|null Retourne la valeur entière, $null sinon.
*/
alias Configure::read {
  $iif(!$isid, return $false)

  ; -------------------- ;

  var %config = $$1
  var %key = $$2
  var %direction = $iif($3, $v1)
  var %default = $iif($4, $v1, $null)

  ; -------------------- ;

  var %directions = <-,->,<->,index
  var %name
  var %result, %return

  if (%direction && !$istok(%directions,%direction,44)) {
    echo $color(text) -a $chr(45)
    echo $color(info2) -a Erreur: La direction $qt(%direction) n'existe pas.
    echo $color(info2) -a Les directions possibles: $qt(%directions) (séparées par des virgules)
    echo $color(text) -a $chr(45)

    return $false
  }

  if (%direction === ->) {
    %name = $+(%key, $chr(61), *)
  }
  elseif (%direction === <-) {
    %name = $+(*, $chr(61), %key)
  }
  elseif (%direction === <->) {
    %name = $+(%key, $chr(61), *)
    %result = $wildtok(%config, %name, 1, 44)
    if (!%result) {
      %name = $+(*, $chr(61), %key)
      %result = $wildtok(%config, %name, 1, 44)
    }
  }
  elseif (%direction === index) {
    %name = $+(%key, $chr(64), *)
  }
  else {
    %name = %key
  }

  if (!%result) {
    %result = $wildtok(%config, %name, 1, 44)
  }

  if ($prop === key) {
    %return = $replace($token(%result, 1, 61), $chr(59), $chr(44))
  }
  elseif ($prop === value) {
    %return = $replace($token(%result, 2, 61), $chr(59), $chr(44))
  }
  else {
    %return = $replace(%result, $chr(59), $chr(44))
  }

  return $iif(%return, %return, %default)
}

/**
* Alias de Configure::read
*
* @param array $$1=%config La configuration.
* @param string|int $$2=%key La clé/valeur à chercher.
* @param string $3=%direction La direction.
*   - index: :key@*
*   - <- : *=:key
*   - -> : :key=*
*   - <-> : :key=*, *=:key
* @return boolean
*/
alias Configure::check {
  $iif(!$isid, return $false)
  return $iif($Configure::read($$1, $$2, $3) !== $null, $true, $false)
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
