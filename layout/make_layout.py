import csv
import json
import math
import os
import sys


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
    # The LED strips are placed two inches apart
    two_inches = 2
    # We have 30 pixels per meter but the layout lengths
    # are in inches, so to convert:
    # 30 pixels / m * 0.0254 m / in = 0.762 pixels / in
    px_per_in = 0.762
    in_per_px = 1 / px_per_in

    wing_width = max(row['Length'] for row in side)
    middle_width = (max(len(front), len(back)) + 1) * two_inches
    center_x = wing_width + (middle_width / 2)
    
    left_side_center_x = (307 / 2) + (300 / 2) - 17
    left_start = wing_width
    
    right_side_center_x = ( 365 + 307 / 2) + (300 / 2) - 20
    right_start = left_start + middle_width
    
    layout = []
    for row in side:
        y = row['Index'] * two_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            offset = col * in_per_px
            layout.append((left_start - offset, y, 0))
            layout.append((right_start + offset, y, 0))

    # my assumption is that the shortest strip in the front
    # should end at the start of the wings in the front
    front_offset = min(row['Length'] for row in front)
    front_y_start = front_offset
    front_width = (len(front) + 1) * two_inches
    front_x_start = center_x - front_width / 2
    for row in front:
        x = front_x_start + (row['Index'] + 1) * two_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            y = front_y_start - col * in_per_px
            layout.append((x, y, 0))

    # my assumption is that the shortest strip in the back
    # should end at the start of the wings in the back
    back_offset = min(row['Length'] for row in back)
    back_y_start = len(side) * two_inches - back_offset
    back_width = (len(back) + 1) * two_inches
    back_x_start = center_x - back_width / 2
    for row in back:
        x = back_x_start + (row['Index'] + 1) * two_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            y = back_y_start + col * in_per_px
            layout.append((x, y, 0))
    
    print("Total pixels: {}".format(len(layout)))
    points = [[round(p, 2) for p in pts] for pts in layout]
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
