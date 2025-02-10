(* Autorka: Emilia Wiśniewska *)

module Funkcja : sig

	(* typ umożliwiający przedstawienie funkcji w formie symbolicznej
		* Var - (variable) zmienna (napis)
		* Val - (value) wartość (int)
		* Add - dodawanie
		* Sub - (substract) odejmowanie
		* Mul - (nultiply) mnożenie
		* Div - (divide) dzielenie
		* Pow - (power) potęgowanie, zawsze wykładnikiem jest liczba
		* Extra - reprezentuje to funkcję (w sensie matematycznym, dowolną,
				o pewnej nazwie i jednym argumencie), za ich interpretację
				odpowiada osobny moduł - Dodatkowe_funkcje, co umożliwia
				dodanie samodzielnie dowolnych funkcji (jak np. logarytm)*)
	type funkcja = 
		| Var of string
		| Val of int
		| Add of funkcja * funkcja
		| Sub of funkcja * funkcja
		| Mul of funkcja * funkcja
		| Div of funkcja * funkcja
		| Pow of funkcja * int
		| Extra of string * funkcja


	(* eval_fun jest funkcją, która ewaluuje daną funkcję (typu funkcja)
	używając do tego 
		* (funkcja -> int) - ewaluator dla użycia w pomniejszych wyrażeniach
		* (string -> int) - ewaluator dla zmiennych 
	I zwraca wyliczoną wartość*)
	val eval_fun : funkcja -> (funkcja -> int) -> (string -> int) -> int


	(* funkcja, która przekształca podaną funkcję w funkcję
	taką samą (dla każdego argumentu zwracającą takie same wartości),
	ale ze zmienioną (pomniejszoną) reprezentacją. Umożliwia to np. usunięcie
	fragmentów pomnożonych przez 0 *)
	val reduce : funkcja -> funkcja

	(* funkcja, która przyjmuje:
		* funkcję, której pochodna jest liczona
		* zmienną, po której liczona jest pochodna (napis)
		* funkcję pomocniczą, która umożliwia policzenie pochodnej
			dla podwyrażeń
	a zwraca nową funkcję, która reprezentuje pochodną *)
	val get_pochodna : funkcja -> string -> (funkcja -> funkcja) -> funkcja

	(* funkcja, która umożliwia wyświetlanie funkcji - zamienia 
	funkcję na napis typu string *)
	val to_string : funkcja -> string


	(* funkcje eval_fun oraz reduce get_pochodna zostały zaprojektowane
	w taki sposób, który umożliwia dokładanie modułu z dodatkowymi funkcjami
	bez zmian liczenia dotychczasowych funkcji. Jednoczeście zapewnia to większą
	czytelność kodu oraz niezależność poszczególnych części - jak reprezentacji
	środowiska do ewaluacji funkcji od samego liczenia tej wartości. W przypadku
	pochodnej umożliwia to zapisanie tak funkcji, że bardzo są widoczne zasady
	liczenia pochodnej, bez "przejmowania się" pozostałymi rzeczami, które są potrzebne *)
end