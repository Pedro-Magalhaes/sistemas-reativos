## Comunicação entre node MCU e Love

O love publica no tópico "love" e subscreve ao topico "mcu", o mcu faz o contrário.

## Love

### eventos captiurados no love e ação:
* Clique no botão "a" do teclado
    * Publica no topico "love" a string "a"
* Clique no botão b do teclado
    * Publica no topico "love" a string "b"

### ação ao receber uma mensagem no tópico mcu:
* se a mensagem for == "1"
    * Mostra um retangulo na tela
* senão:
    * apaga o retangulo da tela

## MCU

### eventos captiurados no MCU e ação:
* Clique no botão 1 do teclado
    * Publica no topico "mcu" a string "1"
* Clique no botão 2 do teclado
    * Publica no topico "mcu" a string "2"

### ação ao receber uma mensagem no tópico "love":
* se a mensagem for == "a"
    * muda o estado do led 1
* senão:
    * muda o estado do led 2