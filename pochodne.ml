(* Autorka: Emilia Wiśniewska *)

(* do tego potrzebujemy typ funkcji *)
open Funkcja
open Dodatkowe_funkcje

module Pochodne = struct
	(* Ewaluacja
	Ewaluacja sprowadza funkcję zareprezentowaną w formie typu funkcja
	do funkcji, której można użyć  *)

  (* do ewaluacji będzie potrzebnme środowisko *)
	(* type t = funkcja *)
	type env = (string * int) list

	let empty_env = []


	(* Do ewaluacji jest potrzebna funkcja wyszukująca odpowiednią wartość
  w środowisku*)
	let rec find_value (e : env) (v : string)  = 
  match e with
  | [] -> failwith ("Wartośc zmiennej '" ^ v ^ "' nie została podana")
  | (name, value) :: e -> if name = v then value
                 else find_value e v


  (* dodawanie wartości do środowiska *)
	let add_to_env (e : env) (name : string) (value : int) = 
		(* nie chcemy ponownie dodawać do środowiska wartości,
    więc jeśli w środowisku jest zmienna chcemy tylko podmienić jej wartość *)
    let rec change_in_env (e : env) (name : string) (value : int) =
      match e with
      | [] ->  None (* nie udało się podmienić *)
      | (n, v) :: e -> if n = name then Some ((name, value) :: e) (*podmieniamy wartość*)
                        else match change_in_env e name value with
                        | None -> None
                        | Some(e) -> Some((n, v) :: e)

    in match change_in_env e name value with
    | Some(e) -> e
    | None -> (name, value) :: e



	(* funkcja eval korzysta z dostarczonej przez moduł funkcja funkcji
	count, która wylicza wartośc wyrażenia z użyciem funkcji wyliczających
	wartości podwyrażeń oraz funkcji wyliczającej wartości zmiennych *)
	let rec eval (e : env) (m : Funkcja.funkcja) = 
    match m with
    | Extra (name, m) -> Dodatkowe_funkcje.eval name m (eval e) 
		| _ -> Funkcja.eval_fun m (eval e) (find_value e) (* tu została zastosowana eta redukcja *)


	(* Liczenie symboliczne pochodnej
		* można znowu zauważyć, że taka operacja może zostać rozdzielona na funkcję, 
    króra umożliwia liczenie pochodnych "większego" typu i takie, które
    dostają funkcję liczącą pochodną "mniejszych części" i z ich użyciem liczą
    pochodną pewnego swojego wyrażenia*)
	let rec pochodna (m : Funkcja.funkcja) (v : string)  = 
    match m with
    | Extra (name,m) -> Dodatkowe_funkcje.pochodna name m v (fun f -> pochodna f v)
    | _ -> Funkcja.get_pochodna m v (fun f -> pochodna f v)
	
end
