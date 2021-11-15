from create_directions import check_score_change_gorizont, check_score_change_vertical, check_score_change_antidiagonal, check_score_change_diagonal
from check_field import search_need_field


def best_positions(y, x, field, best_steps, depth=0):
    coordinates, i, j = {}, y - 1, x - 1
    need_x = search_need_field(x)
    need_y = search_need_field(y)
    while j >= need_x[0]:
        if best_steps[(y, j)][0] == 0:
            coordinates[(y, j)] = best_steps[(y, j)][:]
            check_score_change_gorizont(field, best_steps, y, j)
            j = -100
        j -= 1
    j = x + 1
    while j <= need_x[1]:
        if best_steps[(y, j)][0] == 0:
            coordinates[(y, j)] = best_steps[(y, j)][:]
            check_score_change_gorizont(field, best_steps, y, j)
            j = 100
        j += 1
    while i >= need_y[0]:
        if best_steps[(i, x)][0] == 0:
            coordinates[(i, x)] = best_steps[(i, x)][:]
            check_score_change_vertical(field,best_steps, i, x)
            i = -100
        i -= 1
    i = y + 1
    while i <= need_y[1]:
        if best_steps[(i, x)][0] == 0:
            coordinates[(i, x)] = best_steps[(i, x)][:]
            check_score_change_vertical(field, best_steps, i, x)
            i = 100
        i += 1
    i, j = y + 1, x + 1
    while i <= need_y[1] and j <= need_x[1]:
        if best_steps[(i, j)][0] == 0:
            coordinates[(i, j)] = best_steps[(i, j)][:]
            check_score_change_antidiagonal(field,  best_steps, i, j)
            j = 100
        i += 1
        j += 1
    i, j = y - 1, x - 1
    while i >= need_y[0] and j >= need_x[0]:
        if best_steps[(i, j)][0] == 0:
            coordinates[(i, j)] = best_steps[(i, j)][:]
            check_score_change_antidiagonal(field, best_steps, i, j)
            j = -100
        i -= 1
        j -= 1
    i, j = y + 1, x - 1
    while i <= need_y[1] and j >= need_x[0]:
        if best_steps[(i, j)][0] == 0:
            coordinates[(i, j)] = best_steps[(i, j)][:]
            check_score_change_diagonal(field, best_steps, i, j)
            j = -100
        i += 1
        j -= 1
    i, j = y - 1, x + 1
    while i >= need_y[0] and j <= need_x[1]:
        if best_steps[(i, j)][0] == 0:
            coordinates[(i, j)] = best_steps[(i, j)][:]
            check_score_change_diagonal(field, best_steps, i, j)
            j = 100
        i -= 1
        j += 1
    coordinates[(y, x)] = best_steps[(y, x)][:]
    #print(coordinates)
    return coordinates


def best_positions_for_result(y, x, field, best_steps, depth=0):
    i, j = y - 1, x - 1
    need_x = search_need_field(x)
    need_y = search_need_field(y)
    while j >= need_x[0]:
        if best_steps[(y, j)][0] == 0:
            check_score_change_gorizont(field, best_steps, y, j)
            j = -100
        j -= 1
    j = x + 1
    while j <= need_x[1]:
        if best_steps[(y, j)][0] == 0:
            check_score_change_gorizont(field, best_steps, y, j)
            j = 100
        j += 1
    while i >= need_y[0]:
        if best_steps[(i, x)][0] == 0:
            check_score_change_vertical(field,best_steps, i, x)
            i = -100
        i -= 1
    i = y + 1
    while i <= need_y[1]:
        if best_steps[(i, x)][0] == 0:
            check_score_change_vertical(field, best_steps, i, x)
            i = 100
        i += 1
    i, j = y + 1, x + 1
    while i <= need_y[1] and j <= need_x[1]:
        if best_steps[(i, j)][0] == 0:
            check_score_change_antidiagonal(field,  best_steps, i, j)
            j = 100
        i += 1
        j += 1
    i, j = y - 1, x - 1
    while i >= need_y[0] and j >= need_x[0]:
        if best_steps[(i, j)][0] == 0:
            check_score_change_antidiagonal(field, best_steps, i, j)
            j = -100
        i -= 1
        j -= 1
    i, j = y + 1, x - 1
    while i <= need_y[1] and j >= need_x[0]:
        if best_steps[(i, j)][0] == 0:
            check_score_change_diagonal(field, best_steps, i, j)
            j = -100
        i += 1
        j -= 1
    i, j = y - 1, x + 1
    while i >= need_y[0] and j <= need_x[1]:
        if best_steps[(i, j)][0] == 0:
            check_score_change_diagonal(field, best_steps, i, j)
            j = 100
        i -= 1
        j += 1
