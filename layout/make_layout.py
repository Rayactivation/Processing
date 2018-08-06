import csv
import json
import math
import os
import sys

from constants import *

DIR = os.path.dirname(__file__)


def getLengths(rows):
    return [{'Index': int(r['Index']), 'Length': float(r['Length'])} for r in rows]


def main():
    with open(os.path.join(DIR, 'side.tsv')) as fin:
        side = getLengths(csv.DictReader(fin, delimiter='\t'))
    with open(os.path.join(DIR, 'front.tsv')) as fin:
        front = getLengths(csv.DictReader(fin, delimiter='\t'))
    with open(os.path.join(DIR, 'back.tsv')) as fin:
        back = getLengths(csv.DictReader(fin, delimiter='\t'))

    # We have 30 pixels per meter but the layout lengths
    # are in inches, so to convert:
    # 30 pixels / m * 0.0254 m / in = 0.762 pixels / in


    wing_width = max(row['Length'] for row in side)
    middle_width = (max(len(front), len(back)) + 1) * strip_spacing_inches
    center_x = wing_width + (middle_width / 2)
    
    left_side_center_x = (307 / 2) + (300 / 2) - 17
    left_start = wing_width
    
    right_side_center_x = ( 365 + 307 / 2) + (300 / 2) - 20
    right_start = left_start + middle_width

    # y = 0 needs to match up with the end of the
    # longest piece up front
    # and the start of the wing needs to line up with the
    # end of the shortest piece up front
    front_shortest = min(row['Length'] for row in front)
    front_longest = max(row['Length'] for row in front)
    wing_offset = front_longest - front_shortest
    wing_end = wing_offset + (len(side) -1 )* strip_spacing_inches
    
    layout = []
    for row in side:
        y = row['Index'] * strip_spacing_inches + wing_offset
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            offset = col * in_per_px
            layout.append((left_start - offset, y, 0))
            layout.append((right_start + offset, y, 0))

    # my assumption is that the shortest strip in the front
    # should end at the start of the wings in the front
    front_y_start = front_longest
    front_width = (len(front) + 1) * strip_spacing_inches
    front_x_start = center_x - front_width / 2
    for row in front:
        x = front_x_start + (row['Index'] + 1) * strip_spacing_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            y = front_y_start - col * in_per_px
            layout.append((x, y, 0))
            
    # my assumption is that the shortest strip in the back
    # should end at the start of the wings in the back
    back_offset = min(row['Length'] for row in back)
    back_y_start = wing_end - back_offset
    back_width = (len(back) + 1) * strip_spacing_inches
    back_x_start = center_x - back_width / 2
    for row in back:
        x = back_x_start + (row['Index'] + 1) * strip_spacing_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            y = back_y_start + col * in_per_px
            layout.append((x, y, 0))
    
    print("Total pixels: {}".format(len(layout)))
    points = [[round(p, 2) for p in pts] for pts in layout]
    for point in points:
        for coordinate in point:
            assert coordinate >= 0
    with open(os.path.join(DIR, 'layout.json'), 'w') as fout:
        json.dump([{'point': p} for p in points], fout)


if __name__ == '__main__':
    sys.exit(main())
    # import random
    # points = [{
    #     'point': [
    #         round(n, 2) for n in [random.random(), random.random(), random.random()]]}
    #     for _ in range(1000)]
    # with open('layout.json', 'w') as fout:
    #     json.dump(points, fout)
