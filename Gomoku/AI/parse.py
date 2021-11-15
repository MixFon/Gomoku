from sys import argv
from argparse import ArgumentParser


def get_arguments():
    parser = ArgumentParser(prog='gomoku.py', description='''
    Эта программа позволяет играть в гомоку с различной размерностью поля
    и по разным правилам. Играть можно как с алгоритмом,
    так и с человеком''',
                            add_help=True, epilog='''
    (c) December 2020''')
    parser.add_argument('--players', '-players', default=1, type=int,
                        help='''Количество игроков:
                            1 -     Играть с алгоритмом;
                            2 -     Играть с соперником;''')
    parser.add_argument('--size', '-size', default=10, type=int,
                        help='''Размер поля size на size''')
    parser.add_argument('--algo', '-algo', default='sub',
                        help='Правила игры')
    parser.add_argument('--first', '-first', default=1, type=int,
                        help='''Кому предоставляется право первого хода:
                                1 -     Первому игроку;
                                2 -     Второму игроку или алгоритму;''')
    return parser


def validation(parser):
    name = parser.parse_args(argv[1:])
    players, size = name.players, name.size
    algo, first = name.algo, name.first
    if size < 5:
        print(f'Некорректные значения size = {size}')
        exit()
    return players, size, algo, first
