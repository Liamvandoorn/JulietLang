
___ 
# To Do

## Språkspecifikation 3

[ ] Skriva detaljer till 

[ ] Komplett BNF <= full fokus.

[ ] Skriva information istället för syntax vad(ord), varför(ord) hur(syntax)

[ ] Krav har ingen text


## Arithmetics
[x] plus minus

[x] multiplication division

[] Avrunding


___
# 2023-02-24

- Integers rulen kommer alltid faila regex matchingar för at lexerna alltid gör det till integers redan. -- Einar

- integers avrundar alltid rakt ned från int.5 .. int.9 när den delas, exempelvis 10/3 =3.666 blir 3

- https://www.techotopia.com/index.php/Ruby_Operator_Precedence kul länk för operator precedens

___ 
# 2023-03-29 

- fixat BNF

Återstår att förstå hur man skapar noder och evaluerar det i parsern. 



___ 

# 2023-03-29

arithmetic calculation behöver evaluera typen av variabeln 
idag och igår fixade vi scope, det var svårt att förstå skillnaden på hur nodträdet skulle byggas och sen skapas i runtime men vi tog hjälp av tidigare exempel. 

vi skapade filerna nodesrb och runtime.rb där vi skapade noder i nodes.rb och scope i runtime.rb, vi skapade även en stack class idag som behållare för våra scopes. 

___
# 2023-04-3 

använde if satser för o checka scope tsms med en debugg funktion. 

kan ej skriva över variabler i nestlade scope eftersom vi int checkade

kan nu skriva över variabler i andra scopes, det var fel på grund av att vi använde copy/paste så vissa variabler var fel

gjort en ny parse funktion, en för att läsa varje rad för sig och en för att läsa hela texten

# 2023-04-4

fixade else till if satser, fungerar nu med både if, if else och else.

kan nu ändra på variabler med a is b samt a is b plus c, while loopar verkar fungera (behöver testas mer, specielt om det har korrekta scopes)

Vi gjorde även klart while loopar, Vi skapade en nod klass för while loopar, noden i tar in en expression och exekverar statements sålänge expressionen validerar false, som en vanlig while loop, vi har däremot ingen klass för whileloopare iomed att whileloopen i sig inte exekverar något utan skapar ett underträd som evaluerar statements. while loopen i sig skapar inget scope (tror jag, sitter på tågstationen och orkar inte utforska) vilket jag tycker det kanske borde. 

Vi försökte även fixa jargon men vi har kontinuerloga problem med att matcha rules med punkter och komma tecken, hitills fungerar komma tecken men inte punkt, har försökt att ta in punkt som \. och "[.]" och \W token men programmet ser punkter inte som jargon. syntaktiska tokens som också använder punkter som for, if och while satser slutar också fungera såfort jag lägger in punkt som en token. (beskriv hur det inte fungerar)

# 2023.04.5

Idag utvecklade vi arrays och for loopar, 

## Arrays and Loops


