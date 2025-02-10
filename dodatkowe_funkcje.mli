open Funkcja

module Dodatkowe_funkcje : sig 

	(* To jest moduł, który umożliwia dodanie dodatkowych funkcji
	do Funkcji. Nowo dodane funkcje muszą:
		* mieć pewną nazwę (np. "name")
		* być zapisywane (w postaci napisu) jako
			'name(...)'
			gdzie ... to jest zapis dowolnej Funkcji
		* muszą mieć ustaloną pochodną, której wzór można zapisać
		używając Funkcji lub dodanych funkcji
		* muszą być możliwe do ewaluacji (ale może taka ewalacja w wyjątkowych
		przypadkach zweacać error - np jak dzielenie przez 0 *)

	(* na ten moment są tu dodane 4 funkcje:
		f(x) = 2 - x
		g(x) = 1 + x
		zero(x) = 0
		log(x) = część całkowita log(x)*)

	(*             nazwa       argument      wybrana zmienna   funkcja licząca pochodną "reszty"   zwracana jest Funkcja*)
	val pochodna : string -> Funkcja.funkcja -> string -> (Funkcja.funkcja -> Funkcja.funkcja) -> Funkcja.funkcja

	(*         nazwa       argument           ewaluator "reszty"    wynik typu int*)
	val eval : string -> Funkcja.funkcja -> (Funkcja.funkcja -> int) -> int
 
end