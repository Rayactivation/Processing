import argparse
import collections
import json
import sys

from constants import *


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('layout')
    args = parser.parse_args()

    with open(args.layout) as fin:
        data = json.load(fin)
    min_y = min(d['point'][1] for d in data)
    max_y = max(d['point'][1] for d in data)
    min_x = min(d['point'][0] for d in data)
    max_x = max(d['point'][0] for d in data)

    print(min_x, min_y, max_x, max_y)
    width = max_x - min_x
    height = max_y - min_y
    x_pixels = int(width * px_per_dm)
    y_pixels = int(height * px_per_dm)
    
    # keep adding pixels until there are no doubles.  This is roughly
    # the smallest screen size that we can use.
    while True:
        pixels = convert_to_pixels(data, min_x, x_pixels, width, min_y, y_pixels, height)
        counter = collections.Counter(pixels)
        cnts = collections.defaultdict(list)
        found_double = False
        for pt, cnt in counter.most_common():
            if cnt > 1:
                found_double = True
                break
        if found_double:
            x_pixels += 1
            y_pixels += 1
        else:
            break

    print('Width (dm): {}'.format(width))
    print('Width (in): {}'.format(width / dm_per_in))
    print('Width (px): {}'.format(x_pixels))
    print('Height (dm): {}'.format(height))
    print('Height (in): {}'.format(height / dm_per_in))
    print('Width (px): {}'.format(y_pixels))


def convert_to_pixels(data, min_x, x_pixels, width, min_y, y_pixels, height):
    for datum in data:
        point = datum['point']
        x = int((point[0] - min_x) * (x_pixels - 1) / width)
        assert x < x_pixels
        y = int((point[1] - min_y) * (y_pixels - 1) / height)
        assert y < y_pixels
        yield (x, y)


if __name__ == '__main__':
    sys.exit(main())
