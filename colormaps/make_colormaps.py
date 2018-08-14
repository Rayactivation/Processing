import csv
import itertools
import math
import os
import sys

import matplotlib.pyplot as plt
import numpy as np


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
    assert 0 <= r <= 255
    assert 0 <= g <= 255
    assert 0 <= g <= 255
    return r, g, b


def main():
    hsi = (hsi2rgb(i, 1, 1) for i in range(256))
    save_colormap('hsi', hsi)
    blue = itertools.chain(
        (hsi2rgb(i, 1, 1) for i in np.linspace(128, 192, 128)),
        (hsi2rgb(i, 1, 1) for i in np.linspace(192, 128, 128)))
    save_colormap('blue', blue)
    for name, cmap in plt.cm.cmap_d.items():
        if name.endswith("_r"):
            continue
        save_matplotlib_colormap(name, cmap)



def save_colormap(name, rgb_iter):
    with open(os.path.join(DATA, name + '.csv'), 'w') as fin:
        writer = csv.writer(fin)
        for color in rgb_iter:
            writer.writerow(color)


def save_matplotlib_colormap(name, cmap):
    step_size = cmap.N / 256
    colors = (cmap(int(i*step_size), bytes=True) for i in range(256))
    save_colormap(name, colors)


if __name__ == '__main__':
    sys.exit(main())


