from dictionaries import score, enemy_score


def print_field(best_steps):
    field = [value[0] for value in best_steps.values()]
    for i, k in enumerate(field):
        if k == 1:
            print('\033[31m{:<2d}\033[0m'.format(k), end=' ')
        elif k == -1:
            print('\033[32m{:<2d}\033[0m'.format(k), end=' ')
        elif (i + 1) % 19 == 0:
            print('{:<2d}'.format(k))
        else:
            print('{:<2d}'.format(k), end=' ')


def search_need_field(axis):
    coordinate_1 = axis - 5 if axis - 5 > 0 else 0
    coordinate_2 = axis + 5 if axis + 5 < 19 else 18
    return [coordinate_1, coordinate_2]


def cut_zeros(line, x):
    num_l, num_r = x, x
    ln = len(line) - 1
    count_zeros = 0
    #print(line, x)
    while count_zeros < 2 and num_l > 0 and ((line[num_l] != 0) or (line[num_l] == 0 and line[num_l - 1] != 0)):
        if line[num_l] == 0:
            count_zeros += 1
        num_l -= 1
    count_zeros = 0
    while count_zeros < 2 and num_r < ln and ((line[num_r] != 0) or (line[num_r] == 0 and line[num_r + 1] != 0)):
        if line[num_r] == 0:
            count_zeros += 1
        num_r += 1
    return line[num_l:num_r + 1]


def cut_zeros_enemy(line, x):
    num_l, num_r = x, x
    ln = len(line) - 1
    enemy = line[x]
    count_zeros = 0
    while count_zeros < 2 and num_l > 0 and line[num_l - 1] != enemy and ((line[num_l] != 0) or (line[num_l] == 0 and line[num_l - 1] != 0)):
        if line[num_l] == 0:
            count_zeros += 1
        num_l -= 1
    count_zeros = 0
    while count_zeros < 2 and num_r < ln and line[num_r + 1] != enemy and ((line[num_r] != 0) or (line[num_r] == 0 and line[num_r + 1] != 0)):
        if line[num_r] == 0:
            count_zeros += 1
        num_r += 1
    return line[num_l:num_r + 1]


def player_score(line, x, printf=False):
    new_line = cut_zeros(line, x)
    new_line = ''.join(map(str, new_line))
    return score(new_line)


def for_enemy_score(line, x, printf=False):
    #print(line, x, player)
    new_line = cut_zeros_enemy(line, x)
    new_line = ''.join(map(str, new_line))
    return enemy_score(new_line)


def create_gorizont(y, x, need_x, player, field, depth):
    line = field[y][need_x[0]: need_x[1] + 1]
    index = x - need_x[0]
    line_left = line[:index]
    line_right = line[index + 1:]
    #print(need_x[0], need_x[1])
    return checkline(line, line_left, line_right, player)


def create_vertical(y, x, need_y, player, field, depth):
    line = [i[x] for i in field[need_y[0]: need_y[1] + 1]]
    index = y - need_y[0]
    line_left = line[:index]
    line_right = line[index + 1:]
    return checkline(line, line_left, line_right, player)


def create_antidiagonal(y, x, need_y, need_x, player, field, depth):
    y_down, x_down = y - need_y[0], x - need_x[0]
    if y_down < x_down:
        need_x[0] += x_down - y_down
    else:
        need_y[0] += y_down - x_down
    index = x - need_x[0]
    need_y = range(need_y[0], need_y[1] + 1)
    need_x = range(need_x[0], need_x[1] + 1)
    line = [field[i][j] for i, j in zip(need_y, need_x)]
    line_left = line[:index]
    line_right = line[index + 1:]
    return checkline(line, line_left, line_right, player)


def create_diagonal(y, x, need_y, need_x, player, field, depth):
    need_y.reverse()
    #print(need_y, need_x)
    y_down, x_down = need_y[0] - y, x - need_x[0]
    if y_down < x_down:
        need_x[0] += x_down - y_down
    else:
        need_y[0] -= y_down - x_down
    index = x - need_x[0]
    #print(need_y, need_x)
    need_y = range(need_y[0], need_y[1] - 1, -1)
    need_x = range(need_x[0], need_x[1] + 1)
    line = [field[i][j] for i, j in zip(need_y, need_x)]
    line_left = line[:index]
    line_right = line[index + 1:]
    #print(f'antidiagonal is {line} for position {y, x}')
    return checkline(line, line_left, line_right, player)


def checkline(line, line_left, line_right, player, printf=False):
    """Поиск горизонтали максимальной длины для подсчёта score"""
    enemy = -player
    ln_l = len(line_left)
    ln_r = len(line_right)
    # Проверяем, влияет ли ход на игру
    if line.count(0) == len(line) - 1:
        return 10, 0
    # Проверяем, влияет ли ход на врага
    if enemy not in line:
        return player_score(line, ln_l)
    # Смотрим, насколько близко позиции врага или конец поля
    if enemy in line_right:
        enemy_right = (line_right.index(enemy), enemy)
    else:
        enemy_right = (ln_r, 0)
    if enemy in line_left:
        enemy_left = (line_left[::-1].index(enemy), enemy)
    else:
        enemy_left = (ln_l, 0)
    # Если враг близко, то вычисляем score
    '''if printf:
        print(enemy_left, enemy_right)'''
    # Проверяем, возможно ли построить линию из 5
    if enemy_right[0] + enemy_left[0] < 4:
        return for_enemy_score(line, ln_l, printf), 0
    if enemy_left[0] == ln_l:
        player_line = line[: enemy_right[0] - ln_r]
        player_result, double_three = player_score(player_line, ln_l, printf)
        return player_result + for_enemy_score(line, ln_l, printf), double_three
    elif enemy_right[0] == ln_r:
        player_line = line[ln_l - enemy_left[0]:]
    else:
        player_line = line[ln_l - enemy_left[0]:enemy_right[0] - ln_r]
        #print(f'player_line {player_line}')
    player_position = len(player_line) - enemy_right[0] - 1
    player_result, double_three = player_score(player_line, player_position, printf)
    return player_result + for_enemy_score(line, ln_l, printf), double_three
