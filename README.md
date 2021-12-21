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

## Алгоритм

### MiniMax

В проекте используется алгорим MiniMax. ИИ создает дерево возможных решений и выбирает лучший ход в соответствии с этим деревом. При установке камня происходит расчет весов для обоих камней вокруг установленной точки. Одновременно с расчетом весов определятеся наилучший (наибольший) вес для каждого камня. И при выборе точки для дальнейшего хода эти точки расчитываются первыми. На каждом уровне рекурсии алгорим выбирает наилучшый вес для текущего камня (при ходе черных выбирает наилучий вес для черных, при ходе белых выбирает наилучший ход для белых) тем самым имитируя просчет ходов наперед.

Одним из главных критериев алгоритма должна быть скорость расчета следующего хода. Время на вычисления дальнейшего хода не должно превышать 0.5 секунды. Поэтому в рамках оптимицации использовалось многопоточность. Стартовые точки отправляются в алгорим MiniMax в отдельной асинхронной очереди DispatchQueue. Так же для оптимицации использовался MiniMax с альфа-бетта отсечением.

### Доска

![image](https://github.com/MixFon/Gomoku/blob/master/gifs/3KI1vYwqbfg.jpg)
![image](https://github.com/MixFon/Gomoku/blob/master/gifs/yO7SOXOYrbc.jpg)

