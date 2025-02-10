
(* W tym module wykorzystujemy zaprogramowany lexer *)
open Lexer
open Funkcja

module Parser = struct

	(* 
		funkcja pomocnicza, która tłumaczy wartości Var_n, Val_n i Nawias
    na wyrażenia typu Funkcja. Nawias jest tłumaczony poprzez zaaplikowanie
    funkcji 'dodawanie' (przekazanej jako argument) na tym, co nawias zawiera.
    Wymusza to zachowanie kolejności obliczeń 
	*)
	let handle_var_val_nawias (nf : Lexer.niby_funkcja) (add : Lexer.t -> Lexer.t -> Funkcja.funkcja) : Funkcja.funkcja =
		match nf with
		| Var_n v -> Var v 
		| Val_n x -> Val x
		| Nawias ins -> add (List.rev ins) []
		| _ -> failwith "handle_var_val_nawias wywołanie na nie-VAR i nie-VAl i nie-nawias"


  (* Drugą z kolei (w kolejności obliczeń) są funkcje dodatkowe (zdefiniowane
  w module 'dodatkowe_funkcje). W związku z tym są one tłumaczone na Funkcję 
  zaraz przed nawiasami i wartościami, żeby zachować odpowiednio kolejność
  obliczeń. Od dodatkowych funkcji jest wymagana składnia, która jest opisana
  w module "dodatkowe_funkcje".  *)
	let rec extra_funkcje (nf : Lexer.t) (acc : Lexer.t) (add : Lexer.t -> Lexer.t -> Funkcja.funkcja) : Funkcja.funkcja =
		match nf, acc with
		(* wykluczenie złych przypadków - które nie powinny się wydarzyć (programmer error) *)
		| _ , x :: y :: xs -> failwith "(programmer error) Extra: acc ma więcej niż 1 element"
		| (Op _) :: _, _  -> failwith "(programmer error) operator w extra_funkcje"
		| [],[] -> failwith "(chyba user error) Extra: wywłane na [] []"

		(* no i już 'normalne' przypadki *)
    | x :: rest, [] -> extra_funkcje rest [x] add
    (* skoro to JEDYNA rzecz to powinna być var val lub nawiasem*)
		| [], x :: []  -> handle_var_val_nawias x add 
		(* jeśli jest nazwa i po niej nawias to mamy funkcję *)
		| (Var_n v) :: [], [Nawias ins] -> Extra (v, add (List.rev ins) [])
		(* jesli to nie jest operator to powinien to byc "pierwszy" element*)
		| _ -> failwith ("Coś nie tak, lub niezaimplementowanie, Extra: "^ (Lexer.print_lexed nf) ^ "''''" ^ (Lexer.print_lexed acc))


  (* Trzecią w kolejności obliczeń rzeczą jest potęgowanie, dlatego 
  jest ono tłumaczone zaraz przed. Zgodnie z uznanymi założeniami
  pątegowanie jest możliwe tylko przez liczby całkowite, dlatego
  jest to sprawdzane przy okazji translacji *)
  let rec potegowanie (nf : Lexer.t) (acc : Lexer.t) (add : Lexer.t -> Lexer.t -> Funkcja.funkcja) : Funkcja.funkcja =
		match nf, acc with
		(* wykluczenie złych przypadków - które nie powinny się wydarzyć (programmer error) *)
		| (Op '+') :: _, _ | (Op '-') :: _, _ | (Op '*') :: _, _ | (Op '/') :: _, _ -> failwith ("(programmer error) +, -, * lub / w potęgowaniu: " ^ Lexer.print_lexed nf ^" '''' "^ Lexer.print_lexed acc)
		| [],[] -> failwith "(chyba user error) Potęgowanie: wywłane na [] []"

		(* jesli jest operator to przed nim powinno być coś, a dokładniej (skoro to ostatni poziom) to jedna rzecz*)
		| (Op '^') :: rest , x :: [] -> 
        	begin match x with 
        	| (Val_n v) -> Pow(potegowanie rest [] add,v) 
        	| err -> failwith ("(user error) Potęgowanie: próba podnoszenia do nie-inta potęgi : "^ (Lexer.print_lexed [err]))
        	end
    
    | [], rest -> extra_funkcje (List.rev rest) [] add 
		| nf :: rest, extra -> potegowanie rest (nf :: extra) add
	
    
	(*
    Kolejnymi w kolejności obliczeń jest mnożenie i dzielenie, które są tłumaczone
    zaraz po dodawaniu i odejmowaniu.
	*)
	let rec mnozenie (nf : Lexer.t) (rev_acc : Lexer.t) (add : Lexer.t -> Lexer.t -> Funkcja.funkcja) : Funkcja.funkcja =
		match nf, rev_acc with
    (* jeśli napotkamy + lub - to ewidentnie coś jest nie tak *)
    | (Op '+')::_,_ | (Op '-')::_,_ -> failwith "(programmer error) Mnożenie: znaleziono + lub -"
		(* jesli jest operator to przed nim powinno być coś*)
		| (Op '*') :: rest , _ -> Mul(mnozenie rest [] add, potegowanie (List.rev rev_acc) [] add)
		| (Op '/') :: rest , _ -> Div(mnozenie rest [] add, potegowanie (List.rev rev_acc) [] add)
		(* jesli to nie jest operator to dodajemy do acc*)
		| nf :: rest, _ -> mnozenie rest (nf :: rev_acc) add
    | [], _ -> potegowanie (List.rev rev_acc) [] add
		(* | _ -> failwith ("Coś nie tak, lub niezaimplementowanie, mnożenie: "^ (Lexer.print_lexed nf) ) *)


	(* 
    Ostatnimi w kolejności są dodawanie i odejmowanie, dlatego one
    są tłumaczone na początku. Jest to zrobione w ten sposób, że 
    wyszykiwane są wszystkie wystąpienia + i - (które są łatwo czytelne
    dzięki wcześniejszemu zastosowaniu lexera) i odpowiadającymi
    częściami typu Funkcja (dokładniej Add i Sub) łączone są 
    przetłumaczone (przez mnożenie, a następnie potęgowanie, ...)
    ciągi elementów występujących pomiędzy. Dzięku temu zostaje zachowana
    kolejność działań
    Dodatkową trudnością było zapewnienie dobrej łączości obliczeń.
    Dokładniej tego, by obliczenia typu 1 - 2 - 3 zostały zparsowane
    jako (1 - 2) - 3 a nie 1 - (2 - 3). Dlatego wejściowy ciąg jest
    odwrócony, żeby umożliwić przejście po nim w dobrej kolejności.
    Z tego też wynika to, że elementy do Add() i Sub() (jak i Mul(),
    Div(), ... w pozostałych funkcjach) są dodawane w odwrotnej kolejności
    niż zostały przeczytane			
    *)
	let rec dodawanie (nf : Lexer.t) (rev_acc : Lexer.t) : Funkcja.funkcja =
		match nf with
		(* jeśli już nie ma nic to 'mnozymy' akumulator *)
		| [] -> mnozenie (List.rev rev_acc) [] dodawanie
		
		(* jeśli trafilismy na operator to dodajemy (akumulator) + (reszta) *)
		| (Op '+') :: rest ->  Add(dodawanie rest [], mnozenie (List.rev rev_acc) [] dodawanie)
		
		(* z mnożeniem odpowiednio *)
		| (Op '-') :: rest -> Sub(dodawanie rest [], mnozenie (List.rev rev_acc) [] dodawanie)
		
		(* jeśli to nie operator to zapisujemy do akumulatora *)
		(* nawias chcemy zostawić i dopiero w 'mnozenie' przekształcić to przez 'dodawanie' (i 'mnozenie') *)
		| x :: rest -> dodawanie rest (x :: rev_acc)
			
	
	(* funkcja parsująca podany na wejściu napis (string)
	i zwracająca reprezentację w typie 'funkcja' *)
	let parse (str : string) : Funkcja.funkcja = 
		(* do otrzymania listy 'tokenów' używamy lexera
		z modułu Lexer *)
		let lexed = Lexer.lex str in
				(* tak przetworzony napis można już poddać przetworzeniu 
				na 'funkcję', co zrobi funkcja 'dodawanie' oraz
        wywołane przez nią funkcje*)
			dodawanie (List.rev lexed) []


end
