(* w parserze:
- na wejściu jest napis spełniający podane reguły:
	- znaki +, -, *, / 
	- nawiasy ( i ) 
	- spacje - dla oddzielenia wartości
	- liczby (dodatnie, bez spacji wewnątrz)
	- reszta znaków - traktowane jako litery, nazwy zmiennych
- na wyjściu jest funkcja zareprezentowana przez typ Func
		lub fail jak coś było nie tak
- przykładowe poprawne wejście to:
	(3 + x) 
- przykładowy wynik:
	Add(Val(3), Var) 
*)
open Funkcja (*żeby typ instniał*)

module Parser : sig

	val parse : string -> Funkcja.funkcja
	
end