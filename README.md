# Gomoku
Проект в котором необходимо реализовать игру Gomoku. В качестве противника должен выступать AI на основе алгоритма MiniMax.

В проекте присутствует два режима PvP и PvC. 

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/DemoMenu.gif)


![image](https://github.com/MixFon/Gomoku/blob/master/gifs/DemoPvC.gif)

## Правила игры

### Победа
Для победы необходимо выставить 5 камней или произвести 5 захватов камней противника. После выставления 5 камней игра сразу не заканчивается, ход передается противнику, для предоставления ему возможности сделать захват. Поэтому противник может выиграть по захватам, тем саммым перелоив ход игры.

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/Win.gif)

### Открытая тройка
Открытая тройка это три камня идущих подряд, и не закрытые с обоих краев камнями противника. Если противник вовремя не заблокирует открытую тройку, то следующими ходами будут выставленны четверка, которая не блокируется, а затем пятерка, которая приведет к победе.

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/FreeThree.gif)

### Двойная тройка
Двойная тройка - запрезенная комбинация, при которой одним ходом выставляется сразу две открытые тройки. Двойную тройку невозможно заблокировать, поэтому она считается запрященным ходом. 

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/DoubleThree.gif)

### Захват противника
Вы можете удалить пару камней противника с доски, окружив его камнями. Это правило добавляет условие победы, если вам удастся захватить пять пар камней вашего противника, вы выиграете игру. Можно переходить в захват не теряя при этом пары.

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/Capture.gif)
