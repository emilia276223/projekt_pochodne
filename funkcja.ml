(* Autorka: Emilia Wiśniewska *)

module Funkcja = struct

	type funkcja = 
		| Var of string
		| Val of int
		| Add of funkcja * funkcja
		| Sub of funkcja * funkcja
		| Mul of funkcja * funkcja
		| Div of funkcja * funkcja
		| Pow of funkcja * int
    | Extra of string * funkcja

	(* eval dostaje wszystko co potrzebuje i jedynie musi zastosować odpowiednie działania *)
	(* Do ewaluacji jest potrzebne coś, co przekształci element typu
	funkcji na wartość int. Żeby jak najbardziej umożliwić modularność
	możemy zauważyć, że nasza funkcja nie potrzebuje wiedzieć, w jaki sposób
	ewaluowane są wartości - może to być środowisko, może to być losowanie
	i możemy z użyciem przekazywania funkcji wykorzystać to i zapewnić poprawne
	liczenie funkcji dla dowolnego sposobu ewaluacji - jedynie potrzebujemy mieć
	podane:
		* m - to, co chcemy ewaluować
		* eval_rest - funkcję, która policzy "za nas" resztę wyrażenia (pomniejsze wyrażenia)
		* eval_var - funkcję, która poda nam wartość  
	Używając tego można policzyć wartość funkcji nakładając warstwę abstrakcji na
	sposób ewaluacji wyrażeń*)

	(* funkcja pomocnicza - funkcja licząca potęgowanie *)
	let rec power (x : int) (n : int) : int =
		if n = 0 then 1 else
			if n < 0 then failwith "Nie można liczyć ujemnej pochodnej" 
			else x * (power x (n-1)) 

	let eval_fun (m : funkcja) (eval_rest : funkcja -> int) (eval_var : string -> int) : int = 
		match m with
		| Var x -> eval_var x
		| Val v -> v
		| Add (m1, m2) -> (eval_rest m1) + (eval_rest m2)
		| Sub (m1, m2) -> (eval_rest m1) - (eval_rest m2)
		| Mul (m1, m2) -> (eval_rest m1) * (eval_rest m2)
		| Div (m1, m2) -> let mianownik = (eval_rest m2) in
						if mianownik = 0 then failwith "Eval: dzielenie przez 0"
						else (eval_rest m1) / mianownik
		| Pow (m, x)  -> power (eval_rest m) x
    | _ -> failwith "Not implemented"

	(* Reduce jest funkcją umożliwiającą w pewnym stopniu
			zmniejszenie drzewa reprezentującego daną funkcję.
			Używane jest parę oczywistych własności.
			Niestety nie wszystkie funkcje można uprościć używając tej funkcji,
			ale upraszcza ona niektóre wyrażenia, jak na przykład:
			Val(1) + Val(2)	+ Val(3) + Val(4) uprości do 10 
			
		Całość liczymy w ten sposób, że najpierw rekurencyjnie wywołujemy się
		na obu funkcjach z operatora, i jeśli natrafimy na jeden z przypadków
		redukujących funkcję to to robimy
		
		Do tego przydaje się funkcja porównująca funkcje ze sobą - niestety nie jest
		ona idealna, więc czasami redukcja nie nastąpi nawet, gdyby mogła*)

	(* Do reduce przydatna będzie funkcja, która porówna ze sobą dwie funkcje i będzie
	w stanie (przynajmniej czasami) określić, czy dane dwie funkcje są równe *)
	let rec equal m1 m2 = match m1, m2 with
  | Add(x, y), Add(z, t) -> 
      if (equal x z) && (equal y t) then true
      else if (equal x t) && (equal y z) then true
      else false
  | Mul(x, y), Mul(z, t) -> 
        if (equal x z) && (equal y t) then true
        else if (equal x t) && (equal y z) then true
        else false
  | Sub(x, y), Sub(z, t) -> 
          if (equal x z) && (equal y t) then true
          else false
  | Div(x, y), Div(z, t) -> 
            if (equal x z) && (equal y t) then true
            else false
  | _ -> false

	(* Reduce - jak opisane wcześniej *)
	let rec reduce m =
		match m with
		(* w przypadku pojedynczej zmiennej czy pojedynczej wartości nie da się nic uprościć *)
		| Val(x) -> Val(x)
		| Var(v) -> Var(v)
		| Add(f1, f2) -> begin match reduce f1, reduce f2 with
		
						(* dodawanie dwóch liczb można uprościć używając znanego + *)
						| Val(x), Val(y) -> Val(x+y)
		
						(* dodawanie 0 nie zmienia nic: *)
						| x, Val(0) | Val(0), x -> x
		
						(* w pozostałych przypadkach zostawiamy funkcję bez zmian *)
						| x, y -> Add(x, y)
						end
		
		| Sub(f1, f2) -> begin match reduce f1, reduce f2 with
						(* odejmowanie można uprościć używając - *)
						| Val(x), Val(y) -> Val(x-y)

						(* odejmowanie 0 nic nie zmienia, ale odejmowanie
						od 0 zmienia znak, więc wtedy Sub() jest nadal potrzebne *)
						| x, Val(0) -> x

						(* w pozostałych przypadkach: 
							* jeśli odejmujemy od siebie identyczne rzeczy to można to zredukować do 0
							* jeśli różne to niestety nie*)
						| x, y -> if equal x y then Val(0)
									else Sub(x, y)
						end

		| Mul(f1, f2) -> begin match reduce f1, reduce f2 with

						(* mnożenie można uprościć używając * *)
						| Val(x), Val(y) -> Val(x*y)

						(* mnożenie przez 0 daje zawsze w wyniku 0 *)
						| x, Val(0) | Val(0), x -> Val(0)

						(* mnożenie przez 1 nie zmienia wartości wyrażenia *)
						| x, Val(1) | Val(1), x -> x

            (* gdy jeden z elementów jest dzieleniem *)
            | Div(a, b), c | c, Div(a, b) ->  (* pomaga bo na liczbach całkowitych jest wszystko*)
                begin match a with
                | Val(1) -> Div(c, b)
                | _ -> Div(Mul(a, c), b)
                end
						(* w pozostałych przypadkach zostaje to, co było *)
						| x, y -> Mul(x, y)

						end

		| Div(f1, f2) -> begin match reduce f1, reduce f2 with

						(*	dzielenie przez 0 jest niemożliwe
						rozwiązaniem tymczasowym jest pozostawienie tego tak, jak jest,
						ale możliwym rozwiązaniem jest rozszeżenie typu o operację Error
						(aczkolwiek nie musi to być dobre rozwiązanie) *)
						| x, Val(0) -> Div(x, Val(0))

						(* dzielenie można policzyć: *)
						| Val(x), Val(y) -> Val(x/y)

						(* dzielenie zera przez cokolwiek (co nie jest zerem) to dalej zero*)
						| Val(0), x -> Val(0)

						(* dzielenie przez 1 nie zmienia wyniku *)
						| x, Val(1) -> x

						(* dzielenie przez siebie dwóch tych samych wartości daje 1: *)
						(* TODO !!!! *)

						(* w pozostałych przypadkach:
							* jeśli są równe x i y to można to zredukować do 1
							* w przeciwnym przypadku musi zotać to, co było*)
						| x, y -> if equal x y then Val(1) 
									else Div(x, y)
						end
		| Pow(f, n) -> begin match reduce f, n with
						| _, 0 -> Val(1)
						| f, 1 -> f
						| Val(1), _ -> Val(1)
						| f, n -> Pow(f, n)
					end
    | Extra (name, m) -> Extra (name, reduce m)


	(* funkcja tworząca napis reprezentujący funkcję na 
	podstawie przedstawionej funkcji *)
	(* TODO - fajnie by było stawiać nawiasy tylko, jeśli są potrzebne *)
	let rec to_string (m : funkcja) =
		match m with
		| Val x -> string_of_int x
		| Var v -> v
		| Add(m1, m2) -> "(" ^ (to_string m1) ^ " + " ^ (to_string m2) ^ ")"
		| Sub(m1, m2) -> "(" ^ (to_string m1) ^ " - " ^ (to_string m2) ^ ")"
		| Mul(m1, m2) -> (to_string m1) ^ " * " ^ (to_string m2)
		| Div(m1, m2) -> "(" ^ (to_string m1) ^ " / " ^ (to_string m2) ^ ")"
		| Pow(m, x) -> "("^(to_string m) ^ ")^" ^ (string_of_int x) ^" "
    | Extra(name, m) -> " ." ^ name ^  "("^(to_string m) ^ ")"


	(* funkcja, która tworzy pochodną zgodnie z zasadami liczenia
	pochodnych *)
	let get_pochodna (m : funkcja) (zmienna : string) (pochodna : funkcja -> funkcja) : funkcja =
		match m with
		| Val x -> Val(0)
		| Var v -> if v = zmienna then Val(1) else Val(0)
		| Add (m1, m2) -> Add (pochodna m1, pochodna m2)
		| Sub (m1, m2) -> Sub (pochodna m1, pochodna m2)
		| Mul (m1, m2) -> Add(	Mul(pochodna m1, m2), 
								Mul(m1, pochodna m2))
		| Div (m1, m2) -> Div(Sub (Mul (pochodna m1, m2), 
								(Mul (m1,  pochodna m2))),
						Mul (m2, m2))
		| Pow (m, x) -> if x = 0 then Val 0 (*bo x^0 = 1 a pochodna 1 to 0 *)
						else if x = 1 then pochodna m (* x^1 = x *)
						else Mul ((Val x), Mul ((Pow (m, (x-1))), (pochodna m)))
    | _ -> failwith "Not implemented"


end