from check_field import create_gorizont, create_vertical, create_diagonal, create_antidiagonal, search_need_field


def check_score_change_gorizont(field, best_steps, y, x):
    need_x = search_need_field(x)
    field[y][x] = 1
    new_gorizont_player, double_three = create_gorizont(y, x, need_x, 1, field, 0)
    best_steps[(y, x)][1] += new_gorizont_player - best_steps[(y, x)][2]
    best_steps[(y, x)][2] = new_gorizont_player
    if double_three > 0:
        best_steps[(y, x)][17] += double_three - best_steps[(y, x)][18]
        best_steps[(y, x)][18] = double_three
    field[y][x] = -1
    new_gorizont_enemy, double_three = create_gorizont(y, x, need_x, -1, field, 0)
    best_steps[(y, x)][6] += new_gorizont_enemy - best_steps[(y, x)][7]
    best_steps[(y, x)][7] = new_gorizont_enemy
    if double_three > 0:
        best_steps[(y, x)][22] += double_three - best_steps[(y, x)][23]
        best_steps[(y, x)][23] = double_three
    field[y][x] = 0


def check_score_change_vertical(field, best_steps, y, x):
    need_y = search_need_field(y)
    field[y][x] = 1
    new_vertical_player, double_three = create_vertical(y, x, need_y, 1, field, 0)
    best_steps[(y, x)][1] += new_vertical_player - best_steps[(y, x)][3]
    best_steps[(y, x)][3] = new_vertical_player
    if double_three > 0:
        best_steps[(y, x)][17] += double_three - best_steps[(y, x)][19]
        best_steps[(y, x)][19] = double_three
    field[y][x] = -1
    new_vertical_enemy, double_three = create_vertical(y, x, need_y, -1, field, 0)
    best_steps[(y, x)][6] += new_vertical_enemy - best_steps[(y, x)][8]
    best_steps[(y, x)][8] = new_vertical_enemy
    if double_three > 0:
        best_steps[(y, x)][22] += double_three - best_steps[(y, x)][24]
        best_steps[(y, x)][24] = double_three
    field[y][x] = 0


def check_score_change_diagonal(field,best_steps, y, x):
    need_x = search_need_field(x)
    need_y = search_need_field(y)
    field[y][x] = 1
    new_diagonal_player, double_three = create_diagonal(y, x, need_y[:], need_x[:], 1, field, 0)
    best_steps[(y, x)][1] += new_diagonal_player - best_steps[(y, x)][4]
    best_steps[(y, x)][4] = new_diagonal_player
    if double_three > 0:
        best_steps[(y, x)][17] += double_three - best_steps[(y, x)][20]
        best_steps[(y, x)][20] = double_three
    field[y][x] = -1
    new_diagonal_enemy, double_three = create_diagonal(y, x, need_y, need_x, -1, field, 0)
    best_steps[(y, x)][6] += new_diagonal_enemy - best_steps[(y, x)][9]
    best_steps[(y, x)][9] = new_diagonal_enemy
    if double_three > 0:
        best_steps[(y, x)][22] += double_three - best_steps[(y, x)][25]
        best_steps[(y, x)][25] = double_three
    field[y][x] = 0


def check_score_change_antidiagonal(field, best_steps, y, x):
    need_x = search_need_field(x)
    need_y = search_need_field(y)
    field[y][x] = 1
    new_antidiagonal_player, double_three = create_antidiagonal(y, x, need_y[:], need_x[:], 1, field, 0)
    best_steps[(y, x)][1] += new_antidiagonal_player - best_steps[(y, x)][5]
    best_steps[(y, x)][5] = new_antidiagonal_player
    if double_three > 0:
        best_steps[(y, x)][17] += double_three - best_steps[(y, x)][21]
        best_steps[(y, x)][21] = double_three
    field[y][x] = -1
    new_antidiagonal_enemy, double_three = create_antidiagonal(y, x, need_y, need_x, -1, field, 0)
    best_steps[(y, x)][6] += new_antidiagonal_enemy - best_steps[(y, x)][10]
    best_steps[(y, x)][10] = new_antidiagonal_enemy
    if double_three > 0:
        best_steps[(y, x)][22] += double_three - best_steps[(y, x)][26]
        best_steps[(y, x)][26] = double_three
    field[y][x] = 0