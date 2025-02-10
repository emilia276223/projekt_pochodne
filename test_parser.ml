open Funkcja;;
open Parser;;
open Lexer;;

let f = "2 + 2 * (4 - 28) / abc * f";;
Lexer.print_lexed (Lexer.lex f);;


Funkcja.to_string (Parser.parse f);; 
Funkcja.to_string (Parser.parse "2+2*2");; 
Funkcja.to_string (Parser.parse "2*2+2");; 
Funkcja.to_string (Parser.parse "10 - 1 - 2 - 3 - 4");; 
Funkcja.to_string (Parser.parse "10 - (8 - (4 - (2 - 1)))");;
Funkcja.to_string (Parser.parse "(3 - 4) - ((3 - 5) - 5)");;
Funkcja.to_string (Parser.parse "10 / (8 / (4 / (2 / 1)))");;
Funkcja.to_string (Parser.parse "(3 / 4) / ((3 / 5) / 5)");;

(* Potęgowanie *)
Funkcja.to_string (Parser.parse "2*2+2 ^ 2");; 
Funkcja.to_string (Parser.parse "(2*2+1)^2+3^2");;
Funkcja.to_string (Parser.parse "2^2^2^2");;
Funkcja.to_string (Parser.parse "2*3*4*5*6");; 

(* to powinno dać fail *)
(* Funkcja.to_string (Parser.parse "2^(2+2)^2");; *)

(*dodatkowe funkcje*)
Funkcja.to_string (Parser.parse "f(3)");;
Funkcja.to_string (Parser.parse "2 * f(4 - x)");; 
