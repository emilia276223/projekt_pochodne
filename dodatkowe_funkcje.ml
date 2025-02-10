open Funkcja

module Dodatkowe_funkcje = struct 

    let eval (name : string) (m : Funkcja.funkcja) (eval_rest : Funkcja.funkcja -> int) : int =
      match name with
      | "f" -> 2 - (eval_rest m)
      | "g" -> 1 + (eval_rest m)
      | "zero" -> 0
      | "log" -> let x = eval_rest m in
              Float.to_int (Float.log (Float.of_int x))
      | _ -> failwith ("Extra.eval: taka funkcja nie istnieje: "^ name )

    let pochodna (name : string) (m : Funkcja.funkcja) (variable : string) 
                      (pochodna : Funkcja.funkcja -> Funkcja.funkcja ) : Funkcja.funkcja =
    match name with
    | "f" -> Funkcja.Sub (Funkcja.Val 0, pochodna m) 
    | "g" -> pochodna m
    | "zero" -> Funkcja.Val(0)
    | "log" -> Funkcja.Mul(
                  Funkcja.Div(Funkcja.Val 1, m),
                  pochodna m
                  )
    | _ -> failwith ("Extra.pochodna: Taka funkcja nie istnieje" ^ name)

end