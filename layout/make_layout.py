"""Parse the tsv files containing strip information and create
layout files that can be used by OPC clients and servers.

Want to be able to support local development mode, which is generally one
opc server on 127.0.0.1, and also production, which will be 4 opc server.
"""
import csv
import json
import math
import os
import sys

from constants import *

DIR = os.path.dirname(__file__)


def getLengths(rows):
    return [{'Index': int(r['Index']), 'Length': float(r['Length'])} for r in rows]


# TODO: add the OPC host and port to each tsv file.
# TODO: Figure out wiring order!
def main():
    with open(os.path.join(DIR, 'side.tsv')) as fin:
        side = getLengths(csv.DictReader(fin, delimiter='\t'))
    with open(os.path.join(DIR, 'front.tsv')) as fin:
        front = getLengths(csv.DictReader(fin, delimiter='\t'))
    with open(os.path.join(DIR, 'back.tsv')) as fin:
        back = getLengths(csv.DictReader(fin, delimiter='\t'))

    wing_width = max(row['Length'] for row in side)
    middle_width = (max(len(front), len(back)) + 1) * strip_spacing_inches
    center_x = wing_width + (middle_width / 2)
    
    left_side_center_x = (307 / 2) + (300 / 2) - 17
    left_start = wing_width
    
    right_side_center_x = ( 365 + 307 / 2) + (300 / 2) - 20
    right_start = left_start + middle_width


    front_shortest = min(row['Length'] for row in front)
    front_longest = max(row['Length'] for row in front)
    # I'm not really sure where the body is in relation to the wings
    # so this is just a guess!
    wing_offset = 18
    wing_end = wing_offset + (len(side) -1 )* strip_spacing_inches
    
    layout = []
    for row in side:
        y = row['Index'] * strip_spacing_inches + wing_offset
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            offset = col * in_per_px
            layout.append((left_start - offset, y, 0))
            layout.append((right_start + offset, y, 0))


    #
    # The front and back parts meet in the middle, but with a gap.
    # There is also a bubble in the front.
    # https://drive.google.com/open?id=0B3kxL7TL-XXES0NnSlJFWDdvdWlZVjBkandVMTNaZUpkUzZj
    #
    # Back   |  Front
    #
    #               ---
    #  ------|----------
    # -------|-----------
    # -----     -------
    # -----     -------
    # -------|-----------
    #  ------|----------
    #               ---
    #
    # The gap is 8.96" in both directions (and 13.81" high).
    # For the front, there are:
    # 4 strips that are part of the bubble
    # 4 strips that start from the mid-line
    # There are 7 strips that start at the gap.
    # 4 strips that start from the mid-line
    # 4 strips that are part of the bubble
    #
    gap = 8.96
    bubble_starts = tuple(range(25, 9, -4))
    assert len(bubble_starts) == 4, bubble_starts
    midline_starts = (0,) * 4
    gap_starts = (8.96,) * 7
    front_starts = (
        bubble_starts + midline_starts + gap_starts +
        midline_starts + tuple(reversed(bubble_starts)))

    assert len(front_starts) == len(front), len(front_starts)
    # my assumption is that the front
    # should end at the start of the wings in the front
    midline = front_longest
    front_width = (len(front) + 1) * strip_spacing_inches
    front_x_start = center_x - front_width / 2
    for fs, row in zip(front_starts, front):
        x = front_x_start + (row['Index'] + 1) * strip_spacing_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            y = midline - fs - col * in_per_px
            assert y >= 0, (y, fs, row)
            layout.append((x, y, 0))

    # The back is simpler:
    # 4 strips at the midline
    # 7 strips at the gap
    # 4 strips at the midline
    back_starts = ((0,)*4 + (gap,) * 7 + (0,)*4)
    assert len(back_starts) == len(back)

    # back_offset = min(row['Length'] for row in back)
    # back_y_start = wing_end - back_offset
    back_width = (len(back) + 1) * strip_spacing_inches
    back_x_start = center_x - back_width / 2
    for bs, row in zip(back_starts, back):
        x = back_x_start + (row['Index'] + 1) * strip_spacing_inches
        n_pixels = int(float(row['Length']) * px_per_in)
        for col in range(n_pixels + 1):
            # start at the midline and offset by one pixel
            # so that we don't have overlap with the front
            y = midline + in_per_px + bs + col * in_per_px
            layout.append((x, y, 0))
    
    print("Total pixels: {}".format(len(layout)))
    points = [[round(p, 2) for p in pts] for pts in layout]
    for point in points:
        for coordinate in point:
            assert coordinate >= 0
    assert len(points) == 6088
    with open(os.path.join(DIR, 'layout.json'), 'w') as fout:
        json.dump([{'host': '127.0.0.1', 'port': 7890, 'point': p} for p in points], fout)


if __name__ == '__main__':
    sys.exit(main())
