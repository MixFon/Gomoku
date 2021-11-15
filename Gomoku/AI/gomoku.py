import parse
from check_field import print_field
from datetime import datetime
from find_best_positions import best_positions, best_positions_for_result
from dictionaries import all_positions


def human_step(field, best_steps):
    # Принимаю координаты, куда игрок ставит камень
    y, x = map(int, input().split())
    field[y][x] = 1
    best_steps[(y, x)][0] = 1
    #print_field(best_steps)
    return y, x


def minimax(field, depth, isMax, y, x, alpha, beta, best_steps):
    if isMax:
        '''my_positions = [x[0] for x in sorted({y: x for y, x in best_steps.items() if x[0] == 0 and x[22] < 2}.items(),
                                             key=lambda item: item[1][6], reverse=True)[:3]]'''
        # здесь идёт обмен данными, передаю словарь, где ключ - индекс позиции(y, x),
        # а значение - список с занятостью позиции(0, 1 или -1) и её привлекательностью
        positions = {key:[value[0], value[6]] for key, value in best_steps.items()}
        print(positions)
        my_positions = input()
        result = best_steps[(y, x)][1]
        if result >= 100000 or depth >= 5:
            return -result, (y, x), [0, 0]
        best_score = float('-inf')
        new_i = [y, x]
        enemy_best_step = [[0, float('-inf')], [0, float('-inf')]]
        for j, i in enumerate(my_positions):
            field[i[0]][i[1]] = -1
            best_steps[(i[0], i[1])][0] = -1
            old_positions = best_positions(i[0], i[1], field, best_steps)
            score, enemy_step, _ = minimax(field, depth + 1, False,  i[0], i[1],
                            alpha, beta, best_steps)
            field[i[0]][i[1]] = 0
            if score > best_score:
                best_score = score
                new_i = i
            if score > enemy_best_step[0][1] and enemy_step not in(enemy_best_step[0][0], enemy_best_step[1][0]):
                enemy_best_step[1] = [enemy_best_step[0][0], enemy_best_step[0][1]]
                enemy_best_step[0] = [enemy_step, score]
            elif score > enemy_best_step[1][1] and enemy_step not in(enemy_best_step[0][0], enemy_best_step[1][0]):
                enemy_best_step[1] = [enemy_step, score]
            best_steps.update(old_positions)
            best_steps[(i[0], i[1])][0] = 0
            alpha = max(alpha, score)
            if beta < alpha:
                break
        return best_score, new_i, enemy_best_step
    else:
        '''my_positions = [x[0] for x in sorted({y: x for y, x in best_steps.items() if x[0] == 0 and x[17] < 2}.items(),
                                             key=lambda item: item[1][1], reverse=True)[:2]]'''
        # здесь идёт обмен данными, передаю словарь, где ключ - индекс позиции(y, x),
        # а значение - список с занятостью позиции(0, 1 или -1) и её привлекательностью
        positions = {key: [value[0], value[1]] for key, value in best_steps.items()}
        print(positions)
        my_positions = input()
        result = best_steps[(y, x)][6]
        if result >= 100000:
            return result, (y, x), [0, 0]
        best_score = float('inf')
        new_i, new_score = 0, float('inf')
        for j, i in enumerate(my_positions):
            field[i[0]][i[1]] = 1
            best_steps[(i[0], i[1])][0] = 1
            old_positions = best_positions(i[0], i[1], field, best_steps)
            score, _, _ = minimax(field, depth, True, i[0], i[1],
                            alpha, beta, best_steps)
            field[i[0]][i[1]] = 0
            best_score = min(best_score, score)
            if score < best_score:
                best_score = score
            if score < new_score:
                new_score = score
                new_i = i
            best_steps.update(old_positions)
            best_steps[(i[0], i[1])][0] = 0
            beta = min(beta, score)
            if beta < alpha:
                break
        return best_score, new_i, _


def best_step(field, best_steps, y, x, printf=True):
    score, i, enemy_best_step = minimax(field, 0, True, y, x, float('-inf'), float('inf'), best_steps)
    if enemy_best_step[0][0] != i:
        next_player = enemy_best_step[0][0]
    else:
        next_player = enemy_best_step[1][0]
    if printf:
        # Подсказка для игрока
        print(next_player)
        field[i[0]][i[1]] = -1
    return i[0], i[1], next_player


def game_over(who, best_steps):
    # результат игры
    print(f'Игра окончена. Победил \033[31m{who}\033[0m')
    #print_field(best_steps)
    exit()


def game_with_algorithm(field, best_steps):
    while 1:
        y, x = human_step(field, best_steps)
        start_time = datetime.now()
        if best_steps[(y, x)][1] >= 100000:
            game_over('human', best_steps)
        best_positions_for_result(y, x, field, best_steps, 1)
        y, x, _ = best_step(field, best_steps, y, x)
        if best_steps[(y, x)][6] >= 100000:
            game_over('algorithm', best_steps)
        best_steps[(y, x)][0] = -1
        best_positions_for_result(y, x, field, best_steps)
        # время на расчёты
        print(datetime.now() - start_time)
        print_field(best_steps)


def main():
    # Принимаю информацию о том, кто ходит первым, 1 - человек, 2 - алгоритм
    first = int(input())
    field = [[0] * 19 for _ in range(19)]
    best_steps = all_positions()
    first_step = 19 // 2
    if first == 2:
        field[first_step][first_step] = -1
        best_positions(first_step, first_step, field, best_steps)
    else:
        # Подсказка для игрока, если он ходит первым
        print(first_step, first_step)
    game_with_algorithm(field, best_steps)


if __name__ == '__main__':
    main()
