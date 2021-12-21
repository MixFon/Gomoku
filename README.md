# Gomoku
Проект в котором необходимо реализовать игру Gomoku. В качестве противника должен выступать AI на основе алгоритма MiniMax.

В проекте присутствует два режима PvP и PvC. 

## Правила игры

### Победа
Для победы необходимо выставить 5 камней или произвести 5 захватов камней противника. После выставления 5 камней игра сразу не заканчивается, ход передается противнику, для предоставления ему возможности сделать захват. Поэтому противник может выиграть по захватам, тем саммым перелоив ход игры.

### Открытая тройка
Открытая тройка это три камня идущих подряд, и не закрытые с обоих краев камнями противника. Если противник вовремя не заблокирует открытую тройку, то следующими ходами будут выставленны четверка, которая не блокируется, а затем пятерка, которая приведет к победе.

### Двойная тройка
Двойная тройка - запрезенная комбинация, при которой одним ходом выставляется сразу две открытые тройки. Двойную тройку невозможно заблокировать, поэтому она считается запрященным ходом. 

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/FreeThree.gif)
