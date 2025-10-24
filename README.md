# Projekt: Program umożliwiający liczenie pochodnych symbolicznie

Autorka: Emilia Wiśniewska

## Informacje o projekcie
Jest to projekt napisany w jezyku OCaml. Umożliwia on przedstawienie symboliczne funkcji oraz liczenie na takiej postaci pochodnej funkcji. Program składa się z kilku modułów, które odpowiadają za różne możliwości programu. Poza liczeniem pochodnych program umożliwia również parsowanie wyrażeń zapisanych w postaci napisu (np. "2*x^4 + 4*y - 2*x/5"). Jest również możliwość dodania własnych funkcji (np. tan liczącej tangens argumentu) w module dodatkowe_funkcje.

## Moduły:
1. Funkcja - umożliwiaja reprezentację typem danych funkcji matematycznych
2. Dodatkowe_funkcje - umożliwia dodanie własnych funkcji (np. log) do gotowego zestawu z Funkcji
3. Pochodna - umożliwia tworzenie reprezentacji pochodnej wybranej funkcji (typu Funkcja) oraz ewaluacje takich funkcji. Korzysta z Funkcji oraz Dodatkowych_funkcji
4. Lexer - umożliwia zamianę funkcji zapisanej jako napis (string) na tokeny
5. Parser - korzysta z Lexera, umożliwia zamianę funkcji z napisu, przez tokeny, na funkcję typu Funkcja

## Uruchomienie programu:

### Z użyciem Utop:

1. Instalania utop: 
```bash
$ opam install utop
$ eval `opam config env`
```
2. Wejście do programu:
```bash
utop
```
3. Dodanie programów (trzeba to zrobić wewnątrz katalogu głównego projektu)
```utop
#use "funkcja.ml";;
#use "dodatkowe_funkcje.ml";;
#use "pochodne.ml";;
#use "lexer.ml";;
#use "parser.ml";;
```
4. Opcjonalne - uruchomienie testów
```utop
#use "test_pochodne.ml";;
#use "test_parser.ml";;
```
Jeśli nie ma errorów to oznacza, że testy są udane.
5. Korzystanie z programu
Przykład - można stworzyć własną Funkcję:
```utop
let f = Parser.parse "2*x^3 + 4*y^5 - 13*p";;
```
A następnie utworzyć jej pochodną po zmiennej "x":
```utop
let f1 = Pochodne.pochodna f "x";;
```
Można też zobaczyć, jak wygląda zredukowana pochodna zareprezentowana jako napis:
```utop
let f2 = Funkcja.reduce f1;;
Funkcja.to_string f2;;
```

Można też policzyć wartość funkcji dla podanych wartości zmiennych. Do tego należy stworzyć środowisko:
```utop
let env = (Pochodne.add_to_env Pochodne.empty_env "x" 3);;
```
I użyć go do policzenia wartości funkcji w tym miejscu:
```utop
Pochodne.eval env f2;;
```


## Dodatkowe informacje:
* warto używać 'reduce' - funkcje bez tego mogą dość szybko rosnąć
* testy używają funkcji z dodatkowych_funkcji, więc w przypadku usunięcia tego przestaną działać
* projekt jest dostępny na githubie: https://github.com/emilia276223/projekt_pochodne
