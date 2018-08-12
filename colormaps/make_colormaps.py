import csv
import math
import os
import sys


DATA = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'main', 'data'))
assert os.path.exists(DATA)


def clamp(n, smallest, largest):
    return max(smallest, min(n, largest))


def hsi2rgb_region(h, s, i):
    assert 0 <= h < 2 * math.pi/3
    return (
        int(256 * i / 3 * (1 + s * math.cos(h) / math.cos(math.pi / 3 - h))),
        int(256 * i / 3 * (1 + s * (1 - math.cos(h) / math.cos(math.pi / 3 - h)))),
        int(256 * i / 3 * (1 - s)))


def hsi2rgb(h, s=1, i=1):
    h = math.pi * h / 128
    assert 0 <= h < 2*math.pi
    s = clamp(s, 0, 1)
    i = clamp(i, 0, 1)
    
    if h < 2 * math.pi / 3:
        r, g, b = hsi2rgb_region(h, s, i)
    elif h < 4 * math.pi / 3:
        h = h - 2 * math.pi / 3
        g, b, r = hsi2rgb_region(h, s, i)
    else:
        h = h - 4 * math.pi / 3
        b, r, g = hsi2rgb_region(h, s, i)
    return r, g, b, (r+g+b)/3


def main():
    with open(os.path.join(DATA, 'hsi.csv'), 'w') as fin:
        writer = csv.writer(fin)
        for i in range(256):
            writer.writerow(hsi2rgb(i, 1, 1))


if __name__ == '__main__':
    sys.exit(main())


