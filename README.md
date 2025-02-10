# Projekt: Program umożliwiający liczenie pochodnych symbolicznie

Autorka: Emilia Wiśniewska

## Moduły:
1. Funkcja - umożliwiaja reprezentację typem danych funkcji matematycznych
2. Dodatkowe_funkcje - umożliwia dodanie własnych funkcji (np. log) do gotowego zestawu z Funkcji
3. Pochodna - umożliwia tworzenie reprezentacji pochodnej wybranej funkcji (typu Funkcja) oraz ewaluacje takich funkcji. Korzysta z Funkcji oraz Dodatkowych_funkcji
4. Lexer - umożliwia zamianę funkcji zapisanej jako napis (string) na tokeny
5. Parser - korzysta z Lexera, umożliwia zamianę funkcji z napisu, przez tokeny, na funkcję typu Funkcja

## Uruochomienie programu:

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
```bash->utop
#use "funkcja.ml";;
#use "dodatkowe_funkcje.ml";;
#use "pochodne.ml";;
#use "lexer.ml";;
#use "parser.ml";;
```
4. Opcjonalne - uruchomienie testów
```bash->utop
#use "test_pochodne.ml";;
#use "test_parser.ml";;
```
Jeśli nie ma errorów to oznacza, że testy są udane.
5. Korzystanie z programu
Przykład - można stworzyć własną Funkcję:
```
let f = Parser.parse "2*x^3 + 4*y^5 - 13*p";;
```
A następnie utworzyć jej pochodną po zmiennej "x":
```
let f1 = Pochodne.pochodna f "x";;
```
Można też zobaczyć, jak wygląda zredukowana pochodna zareprezentowana jako napis:
```
let f2 = Funkcja.reduce f1;;
Funkcja.to_string f2;;
```

Można też policzyć wartość funkcji dla podanych wartości zmiennych. Do tego należy stworzyć środowisko:
```
let env = (Pochodne.add_to_env Pochodne.empty_env "x" 3);;
```
I użyć go do policzenia wartości funkcji w tym miejscu:
```
Pochodne.eval env f2;;
```

## Dodatkowe informacje:
* warto używać 'reduce' - funkcje bez tego mogą dość szybko rosnąć
* testy używają 'log' z dodatkowych_funkcji, więc w przypadku usunięcia tego przestaną działać