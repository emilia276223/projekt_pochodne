(* Autorka: Emilia Wiśniewska *)

open Funkcja

module Pochodne : sig

	(* Liczenie pochodnej:
	funkcja na podstawie:
		* funkcji, z której ma zostać policzona pochodna
		* zmiennej, po której ta pochodna ma być policzona
		zwraca policzoną pochodną *)
	val pochodna : Funkcja.funkcja -> string -> Funkcja.funkcja
	

	(* Ewaluacja: *)

	(* Typ środowiska, które przechowuje wartościowanie zmiennych *)
	type env 

	(* Funkcja eval zwraca wartość podanej funkcji
	dla wartościowania zmiennych według podanego środowiska*)
	val eval : env -> Funkcja.funkcja -> int

	(* utworzenie pustego środowiska *)
	val empty_env : env

	(* dodanie wartości pewnej zmiennej do środowiska,
	ewentualnie update, jeśli taka zmienna już jest w środowisku *)
	val add_to_env : env -> string -> int -> env

end