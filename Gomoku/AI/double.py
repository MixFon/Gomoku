def check_closed_double(field, best_steps, y, x, player):
    enemy = -player
    my_double = 0
    directions, left_up, right_down = [], [player, enemy, enemy], [enemy, enemy, player]
    if x > 2 and field[y][x-3: x] == left_up:
        my_double += 1
        directions.append('gorizont_left')
    if x < 15 and field[y][x+1: x+4] == right_down:
        my_double += 1
        directions.append('gorizont_right')
    if y > 2 and field[y-3: y][x] == left_up:
        my_double += 1
        directions.append('vertical_up')
    if y < 15 and field[y+1: y+4][x] == right_down:
        my_double += 1
        directions.append('vertical_down')
    if x > 2 and y > 2 and [best_steps[(y-3, x-3)], best_steps[(y-2, x-2)], best_steps[(y-1, x-1)]] == left_up:
        my_double += 1
        directions.append('antidiagonal_left')
    if x < 15 and y < 15 and [best_steps[(y+1, x+1)], best_steps[(y+2, x+2)], best_steps[(y+3, x+3)]] == right_down:
        my_double += 1
        directions.append('antidiagonal_right')
    if x > 2 and y < 15 and [best_steps[(y+3, x-3)], best_steps[(y+2, x-2)], best_steps[(y+1, x-1)]] == left_up:
        my_double += 1
        directions.append('diagonal_left')
    if x < 15 and y > 2 and [best_steps[(y-1, x+1)], best_steps[(y-2, x+2)], best_steps[(y-3, x+3)]] == right_down:
        my_double += 1
        directions.append('diagonal_right')
    if directions:
        if player == 1:
            best_steps[(y, x)][11] = 10 ** (my_double + best_steps[(y, x)][11])
        else:
            best_steps[(y, x)][14] = 10 ** (my_double + best_steps[(y, x)][14])
    return my_double, directions


def if_double_is_better(field, best_steps, y, x, directions):
    # нужно ли пересчитвать привлекательность позиции?
    if 'gorizont_left' in directions:
        best_steps[(y, x - 1)][0], best_steps[(y, x - 2)][0] = 0, 0
        field[y][x - 2: x] = [0, 0]
    if 'gorizont_right' in directions:
        best_steps[(y, x + 1)][0], best_steps[(y, x + 2)][0] = 0, 0
        field[y][x + 1: x + 3] = [0, 0]
    if 'vertical_up' in directions:
        best_steps[(y - 1, x)][0], best_steps[(y - 2, x)][0] = 0, 0
        field[y - 2: y][x] = [0, 0]
    if 'vertical_down' in directions:
        best_steps[(y + 1, x)][0], best_steps[(y + 2, x)][0] = 0, 0
        field[y + 1: y + 3][x] = [0, 0]
    if 'antidiagonal_left' in directions:
        best_steps[(y - 1, x - 1)][0], best_steps[(y - 2, x - 2)][0] = 0, 0
        field[y -1][x - 1], field[y - 2, x - 2] = 0, 0
    if 'antidiagonal_right' in directions:
        best_steps[(y + 1, x + 1)][0], best_steps[(y + 2, x + 2)][0] = 0, 0
        field[y + 1][x + 1], field[y + 2][x + 2] = 0, 0
    if 'diagonal_left' in directions:
        best_steps[(y + 1, x - 1)][0], best_steps[(y + 2, x - 2)][0] = 0, 0
        field[y + 1][x - 1], field[y + 2][x - 2] = 0, 0
    if 'diagonal_right' in directions:
        best_steps[(y - 1, x + 1)][0], best_steps[(y - 2, x + 2)][0] = 0, 0
        field[y - 1][x + 1], field[y - 2][x + 2] = 0, 0
