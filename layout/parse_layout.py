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
    print('Width (in): {}'.format(width))
    x_pixels = int(width * px_per_in)
    print('Width (px): {}'.format(x_pixels))
    print('Height (in): {}'.format(height))
    y_pixels = int(height * px_per_in)
    print('Width (px): {}'.format(y_pixels))

    # Check Converting to dense pixels
    pixels = convert_to_pixels(data, min_x, x_pixels, width, min_y, y_pixels, height)
    counter = collections.Counter(pixels)
    cnts = collections.defaultdict(list)
    for pt, cnt in counter.most_common():
        if cnt <= 1:
            break
        cnts[cnt].append(pt)
    print(cnts)
    for key, value in cnts.items():
        print(key, len(value))


def convert_to_pixels(data, min_x, x_pixels, width, min_y, y_pixels, height):
    for datum in data:
        point = datum['point']
        yield (
            int((point[0] - min_x) * x_pixels / width),
            int((point[1] - min_y) * y_pixels / height)
        )


if __name__ == '__main__':
    sys.exit(main())
