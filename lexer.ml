module Lexer = struct 

type niby_funkcja = 
  | Op of Char.t
  | Var_n of string 
  | Val_n of int 
  | Nawias of (niby_funkcja list)

type t = niby_funkcja list


(* funkcja pomocnicza do zmiany napisu w listę Charów bo łatwiej się na tym operuje *)
let to_list (str : string) : Char.t list =
  String.fold_right 
    (fun el acc -> el :: acc) str []

(* funkcja pomocnicza zamieniająca listę czarów na napis (string) *)
let rec list_to_string (xs : Char.t list) : string = 
  match xs with
  | x :: xs -> (Char.escaped x) ^ (list_to_string xs)
  | [] -> ""

(* funkcja pomocnicza do rozpoznania, czy dany Char jest cyfrą *)
let cyfra (c : Char.t) : bool = 
  String.contains "1234567890" c 

(* funkcja pomocnicza do rozpoznawania, czy dany Char jest operatorem *)
let operator (c : Char.t) : bool =
  String.contains "/+-*^" c 

(* funkcja pomocnocza, do rozpoznawania, czy dany Char jest literą
  przy czym: jako litery traktujemy wszystko co nie jest
  * cyfrą
  * operatorem
  * nawiasem
  * spacją
  Dzięki temu jest możliwe używanie takich zmiennych jak:
    * b_1
    * funkcja.o.dlugiej.nazwie *)
let litera (c : Char.t) = 
  if cyfra c then false
  else if operator c then false
  else match c with
  | ' ' | '(' | ')' -> false
  | _ -> true 

(* funkcja pomocnicza, która przejształca wszystkie
znaki z podanej listy na liczbę aż do pierwszej nie-cyfry
i zwraca string reprezentujący liczbę wraz z resztą -  
- nieprzeczytanymi, dalszymi znakami  
napis jest zwracany, ponieważ umożliwia to łatwe przekształcenie
tego na int*)
let rec liczba (xs : Char.t list) : string * Char.t list = 
  match xs with
  | x :: xs -> 
    if cyfra x then
      let rest, extra = liczba xs
        in ((Char.escaped x) ^	(rest), extra)
      else ("", x :: xs)
  | [] -> ("", [])

(* funkcja pomocnicza, umożliwia przeczytanie "do końca" zmiennej,
działa podobnie do funkcji 'liczba', czyta znaki aż do napotkania
nie-litery i zwraca powstały napis (string) oraz znaki, które
pozostały nieużyte *)
let rec zmienna (xs : Char.t list) : string * Char.t list =
  match xs with
  | x :: xs -> if litera x then 
    let rest, extra = zmienna xs
        in ((Char.escaped x) ^	(rest), extra)
      else ("", x :: xs)
  | [] -> ("", [])


(* lexer - funkcja, która przekształca podaną na wejściu listę znaków (Char.t)
na 
  * powstała rzecz (bo wykorzysta inne funkcje przy returnie)
  * pozostały napis *)
let rec lexer (xs : Char.t list) : (t * Char.t list) =
  match xs with
  | [] -> ([], [])
  | ' ' :: xs -> lexer xs (* spacje pomijamy *)
  | ')' :: xs -> ([], xs) (* bo się skończyło tutaj, tzn ten nawias się skończył *)
  | '(' :: xs -> 
      let inside, rest = lexer xs in (* parsujemy to co jest wewnątrz nawiasu *)
        (* reszta powinna nie zwrocic problemu *)
        let rest, extra = lexer rest in
        ((Nawias inside) :: rest, extra) (* powstaje nam coś w nawiasie a dalej no reszta, którą dalej liczymy *)
  | x :: xs -> begin
    (* jeśli cyfra to musimy złożyć całą liczbę *)
    if cyfra x then
      let l, rest = liczba (x :: xs) in 
        match l with 
        | "" -> failwith ("Coś ewidentnie źle napisałam -> liczba rest = "^(list_to_string rest))
        | _ -> let rest, extra = lexer rest in 
            ((Val_n (int_of_string l)) :: rest, extra)
    (* jeśli operator to zapisujemy i lecimy dalej *)
    else if operator x then
      let rest, extra = lexer xs in
        ((Op x) :: rest , extra)
    else 
      (*	jak nie operator, liczba ani nawias to musi być to początek nazwy zmiennej *)
      let z, rest = zmienna (x :: xs) in
        match z with
        | "" -> failwith "zmienna o pustej nazwie => raczej jest coś nie tak"
        | _ -> let rest, extra = lexer rest 
            in ((Var_n z) :: rest , extra)
    end


(* funkcja głównie pomocnicza - przydana przede wszytskim do testów
w celu aobserwacji działanie lexera, przyjmuje listę niby-funkcji,
inaczej t, i zwraca napis (string) reprezentujący wejście,
użyta też do stworzenia bardziej informatywnych błędów*)
let rec print_lexed (nf : t) = 
  match nf with
  | (Var_n x) :: rest -> " Var_n("^x^")"^(print_lexed rest)
  | (Val_n v) :: rest -> " Val("^(string_of_int v)^")"^(print_lexed rest)
  | (Op op) :: rest -> " Op("^(Char.escaped op)^")"^(print_lexed rest)
  | [] -> "." (*zanotowanie, że w danym miejscu jest koniec listy, 
        powinien pojawić się na koniec całości i zawsze 
        przed zamknięciem nawiasu*)
  | (Nawias n) :: rest -> "["^(print_lexed n)^"]" ^ (print_lexed rest) 


(* funkcja lex to funkcja, która wykorzystuje
funkcję lexer do przetworzenia napisu (string) na wejściu
na listę niby-funkcji (typu t), czyli 'tokeny'
które następnie zostaną przerobione przez parser na
funkcję typu 'funkcja'*)
let lex (str : string) : t =
  match lexer (to_list str) with
  | res, [] -> res
  | res, extra -> failwith ("Lexer: niepoprawne nawiasowanie, zostało"^(list_to_string extra))
end