module Lexer : sig 

	(* Typ reprezentyjący "tokeny", które występują w 
	zapisie funkcji. Jest to typ zwracany przez lekser
	i pobierany przez parser, gdzie jest zamieniany na Funkcję.
		* Op - reprezentuje operatory: +, -, *, /, ^
		* Var_n - reprezentuje dowolną zmienną (napis)
		* Val_n - reprezentuje dowolną liczbę (int)
		* Nawias - zawiera wszystko, co zawierał nawias *)
	type niby_funkcja = 
	| Op of Char.t 
	| Var_n of string 
	| Val_n of int 
	| Nawias of (niby_funkcja list)

	(* Głównym typem w Lekserze (reprezentującym funkcję)
	jest lista typu niby_funkcja *)
	type t = niby_funkcja list

	(* funkcja lex zamienia napis typu string w wartość
	typu t. Funkcja może wyrzucić błąd, jeśli wyrażenie
	nie jest poprawnym zapisem funkcji *)
	val lex : string -> t
	
	(* funkcja print_lexed umożliwia wyświetlanie wartości
	tyu t. Używana głównie przez errory i testy *)
	val print_lexed : t -> string
	
end 