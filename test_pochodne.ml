(* Autorka: Emilia Wiśniewska *)

(* Testy i przykłady do monady pochodnych*)
open Funkcja;;
open Pochodne;;
open Parser;;

(* tworzenie funkcji *)
(* funkcja: f1 = 3 * x + 4            *)
let f1 = Funkcja.Add (Mul (Val 3, Var "x"), Val 4);;

(* liczenie pochodnej funkcji *)
let f2 = Pochodne.pochodna f1 "x";;

(* tworzenie środowiska *)
let env = Pochodne.add_to_env Pochodne.empty_env "x" 7;;

(* sprawdzenie na najprostszej funkcji, czy działa środowisko *)
let f = Funkcja.Var "x";;
assert (Pochodne.eval env f = 7);;

(* sprawdzenie czy na funkcji i pochodnej będzie dobrze policzone *)
(* let w1 = eval env f1;; *)
assert (Pochodne.eval env f1 = 25);; (*   3*7+4 = 25   *)
assert (Pochodne.eval env f2 = 3);; (*  pochodna = 3 zawsze    *)


(* sprawdzenie, że jak nie podamy dobrego środowiska to fail będzie *)
let assert_fail f = 
  let aux () =
    try f(); false 
    with e -> print_string (Printexc.to_string e);  
      true 
  in
  assert (aux ());;

assert_fail (fun () -> Pochodne.eval Pochodne.empty_env f1);;

(* sprawdzenie, czy dzielenie przez 0 da fail *)
let f3 = Funkcja.Div ( Var "x", Var "y");;
let en1 = Pochodne.add_to_env (Pochodne.add_to_env Pochodne.empty_env "y" 3) "x" 4;;
let en2 = Pochodne.add_to_env (Pochodne.add_to_env Pochodne.empty_env "y" 0) "x" 4 ;;

assert (Pochodne.eval en1 f3 = 1);; (* dzielenie na intach jest dzieleniem całkowitym*)
assert_fail (fun () -> Pochodne.eval en2 f3);;

(* sprawdzenie pochodnej dla trudniejszych funkcji *)
(* 2x^3 + 3y^2 − 5x +7 *)
let g = Parser.parse "2*x*x*x + 3*y*y - 5*x + 7"

(* poprawna pochodna po "x": 3*2x^2 - 5 *)
(* poprawna pochodna po "y": 2*3y*)

let gx = Pochodne.pochodna g "x";;
let gy = Pochodne.pochodna g "y";;

(* sprawdzenie reduce *)
let gxr = Funkcja.reduce gx;; 
let gyr = Funkcja.reduce gy;;

(* 
(* wyświetlenie *)
Printf.printf "\n Funcja oryginalna:";;
print_string (Funkcja.to_string g);;

Printf.printf "\n Pochodna po x:";;
print_string (Funkcja.to_string gx);;
print_string "Pochodna po y";;
print_string (Funkcja.to_string gy);;

Printf.printf "\n Pochodna po x po redukcji:";;
print_string (Funkcja.to_string gxr);;
print_string "Pochodna po y po redukcji:";;
print_string (Funkcja.to_string gyr);; *)

(* sprawdzenie poprawności *)
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 1) gxr = 1);;
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 2) gxr = 19);;
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "y" 1) gyr = 6);;
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "y" 2) gyr = 12);;



(* sprawdzenie pochodnej dla trudniejszych funkcji *)
(* 2x^3 + 3y^2 − 5x +7 *)
let h = Parser.parse "2*x^3 + 3*y^2 -5*x+7"

(* poprawna pochodna po "x": 3*2x^2 - 5 *)
(* poprawna pochodna po "y": 2*3y*)

let hx = Pochodne.pochodna h "x";;
let hy = Pochodne.pochodna h "y";;

(* sprawdzenie reduce *)
let hxr = Funkcja.reduce hx;;
let hyr = Funkcja.reduce hy;;

(* wyświetlenie
Printf.printf "\n Funcja oryginalna:";;
print_string (Funkcja.to_string h);;

Printf.printf "\n Pochodna po x:";;
print_string (Funkcja.to_string hx);;
print_string "Pochodna po y";;
print_string (Funkcja.to_string hy);;

Printf.printf "\n Pochodna po x po redukcji:";;
print_string (Funkcja.to_string hxr);;
print_string "Pochodna po y po redukcji:";;
print_string (Funkcja.to_string hyr);;

print_string("\n\n\n\n\n");; *)

(* sprawdzenie *)
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 1) hxr = 1);;
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 2) hxr = 19);;
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "y" 1) hyr = 6);;
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "y" 2) hyr = 12);;



let i = Parser.parse "f(3 * (1 - x)) + 14";;
let ixr = Funkcja.reduce (Pochodne.pochodna i "x");; (*3*)

let j = Parser.parse "f(3 * (1 - x)) + 14 * g(3) * x - zero(x)";;
let jxr = Funkcja.reduce (Pochodne.pochodna j "x");; (*3 + 14 * g(3) = 3 + 14 * 4 = 59*)

let k = Parser.parse "2 * log(3 + x^2)";;
let kxr = Funkcja.reduce (Pochodne.pochodna k "x");; (*2 * (1 / (x^2 + 3) * 2x) = (2 * x * 2) / (3 + x^2) = 4x / (3+x^2) *)

(* sprawdzenie *)
assert (Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 1) ixr = 3);;
assert (Pochodne.eval Pochodne.empty_env ixr = 3);;

assert(Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 2) jxr = 59);;
assert(Pochodne.eval Pochodne.empty_env jxr = 59);;

assert(Pochodne.eval (Pochodne.add_to_env Pochodne.empty_env "x" 1) kxr = 1);;


