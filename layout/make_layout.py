"""Parse the tsv files containing strip information and create
layout files that can be used by OPC clients and servers.

Want to be able to support local development mode, which is generally one
opc server on 127.0.0.1, and also production, which will be 4 opc servers.
"""
import argparse
import csv
import json
import math
import os
import sys

from constants import *


DIR = os.path.dirname(__file__)
LEFT = 'left'
RIGHT = 'right'
FRONT = 'front'
BACK = 'back'


def to_decimeter(inches):
    return float(inches) * dm_per_in


def convert_row(rows):
    labels = ('LOC', 'IDX', 'LEN', 'HOST', 'PORT', 'STRIP')
    types = (str, int, to_decimeter, str, int, int)
    return [{lbl: typ(r[lbl]) for lbl, typ in zip(labels, types)} for r in rows]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dev-opc-server', default='127.0.0.1:7890')
    args = parser.parse_args()

    dev_opc_host, dev_opc_port = args.dev_opc_server.split(':')
    
    with open(os.path.join(DIR, 'layout.csv')) as fin:
        layout_input_data = convert_row(csv.DictReader(fin, delimiter='\t'))

    layout_input_data = sorted(
        layout_input_data, key=lambda row: (row['HOST'], row['PORT'], row['STRIP']))

    # The general layout is
    #    -----
    #   /| F |\
    #  / |   | \
    # < L|---|R >
    #  \ |   | /
    #   \| B |/
    #    -----
    #
    # With (0, 0) being the top left corner.
    # The strips start in the middle and go out in the respective direction
    
    n_front_strips = sum(1 for row in layout_input_data if row['LOC'] == FRONT)
    n_back_strips = sum(1 for row in layout_input_data if row['LOC'] == BACK)
    
    wing_width_dm = max(row['LEN'] for row in get_section(layout_input_data, LEFT))
    # The +1 is needed so that we don't have overlap
    middle_width_dm = (max(n_back_strips, n_front_strips) + 1) * strip_spacing_dm
    # Found the center line between the two wings
    center_x_dm = wing_width_dm + (middle_width_dm / 2)

    # the left wings start near the middle and go left (-)
    left_start_dm = wing_width_dm
    # the right wings start new the middle and go right (+)
    right_start_dm = left_start_dm + middle_width_dm

    front_longest_dm = max(row['LEN'] for row in get_section(layout_input_data, FRONT))
    # I'm not really sure where the body is in relation to the wings
    # so this is just a guess!
    wing_offset_dm = 18 * dm_per_in

    
    def get_start_and_offset_left(row):
        """Return the start and offset for the left wing.

        Start is the (x,y) coordinates of the first pixel.
        Offset is the distance between pixels.
        """
        assert row['LOC'] == LEFT
        # pixels on the left wing have a negative offset because they go right to left
        offset = Point(-dm_per_px, 0)
        start = Point(left_start_dm, row['IDX'] * strip_spacing_dm + wing_offset_dm)
        return start, offset


    def get_start_and_offset_right(row):
        """Return the start and offset for the right wing.

        Start is the (x,y) coordinates of the first pixel.
        Offset is the distance between pixels.
        """
        assert row['LOC'] == RIGHT
        # pixels on the right wing have a positive offset because they go left to right
        offset = Point(dm_per_px, 0)
        start = Point(right_start_dm, row['IDX'] * strip_spacing_dm + wing_offset_dm)
        return start, offset

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
    # ----- gap -------
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
    gap_in = 8.96
    # Its not clear from the drawing where each part of the bubble actually starts
    # So, this is my guess
    bubble_starts_in = (25, 21, 17, 13)
    midline_starts_in = (0,) * 4
    gap_starts_in = (gap_in,) * 7
    front_starts_in = (
        bubble_starts_in + midline_starts_in + gap_starts_in +
        midline_starts_in + tuple(reversed(bubble_starts_in)))
    front_starts_dm = [fs * dm_per_in for fs in front_starts_in]

    assert len(front_starts_dm) == n_front_strips, len(front_starts_dm)
    # my assumption is that the front
    # should end at the start of the wings in the front
    midline_dm = front_longest_dm
    front_width_dm = (n_front_strips + 1) * strip_spacing_dm
    front_x_start_dm = center_x_dm - front_width_dm / 2

    def get_start_and_offset_front(row):
        assert row['LOC'] == FRONT
        # front offset is negative because the pixels go up
        offset = Point(0, -dm_per_px)
        start_x = front_x_start_dm + (row['IDX'] + 1) * strip_spacing_dm
        fs = front_starts_dm[row['IDX']]
        start_y = midline_dm - fs
        assert start_y > 0, (fs, row)
        return Point(start_x, start_y), offset

    # The back is simpler:
    # 4 strips at the midline
    # 7 strips at the gap
    # 4 strips at the midline
    back_starts_in = ((0,)*4 + (gap_in,) * 7 + (0,)*4)
    back_starts_dm = [bs * dm_per_in for bs in back_starts_in]
    assert len(back_starts_dm) == n_back_strips

    # back_offset = min(row['Length'] for row in back)
    # back_y_start = wing_end - back_offset
    back_width_dm = (n_back_strips + 1) * strip_spacing_dm
    back_x_start_dm = center_x_dm - back_width_dm / 2

    def get_start_and_offset_back(row):
        assert row['LOC'] == BACK
        # back offset is positive because the pixels go down
        offset = Point(0, dm_per_px)
        start_x = back_x_start_dm + (row['IDX'] + 1) * strip_spacing_dm
        bs = back_starts_dm[row['IDX']]
        # start at the midline and offset by one pixel
        # so that we don't have overlap with the front
        start_y = midline_dm + dm_per_px + bs
        return Point(start_x, start_y), offset

    def get_start_and_offset(row):
        if row['LOC'] == FRONT:
            return get_start_and_offset_front(row)
        elif row['LOC'] == BACK:
            return get_start_and_offset_back(row)
        elif row['LOC'] == LEFT:
            return get_start_and_offset_left(row)
        elif row['LOC'] == RIGHT:
            return get_start_and_offset_right(row)

    layout = []
    # walk through all of the pixels in the order that they
    # will be hooked up to each opc server
    # ie - ordered by strip and then pixels on that strip.
    for row in layout_input_data:
        start, offset = get_start_and_offset(row)
        n_pixels = int(float(row['LEN']) * px_per_dm)
        for i in range(n_pixels + 1):
            pt = start + i * offset
            try:
                assert_positive(pt.to_array())
            except AssertionError:
                print(row, start, offset, i)
                raise
            layout.append(get_layout_datum(row, pt))
    
    print("Total pixels: {}".format(len(layout)))
    assert len(layout) == 6088
    round_points(layout)
    assert_positive_coordinates(layout)
    with open(os.path.join(DIR, 'layout.json'), 'w') as fout:
        json.dump(layout, fout)
    convert_to_dev_layout(layout, dev_opc_host, dev_opc_port)
    with open(os.path.join(DIR, 'dev_layout.json'), 'w') as fout:
        json.dump(layout, fout)
    

def convert_to_dev_layout(layout, dev_host, dev_port):
    strip = -1
    prod_strip = None
    for datum in layout:
        datum['host'] = dev_host
        datum['port'] = dev_port
        if datum['strip'] != prod_strip:
            strip += 1
            prod_strip = datum['strip']
        datum['strip'] = strip    
        # scale back to inches for the simulator.
        datum['point'] = [p * 5 for p in datum['point']]


def round_points(layout):
    for datum in layout:
        datum['point'] = [round(p, 2) for p in datum['point']]


def assert_positive_coordinates(layout):
    for datum in layout:
        assert_positive(datum['point'])


def assert_positive(coordinates):
    for coordinate in coordinates:
        assert coordinate >= 0

        
def get_section(layout_input_data, location):
    return (row for row in layout_input_data if row['LOC'] == location)


def get_layout_datum(row, pt):
    return {
        'host': row['HOST'], 'port': row['PORT'],
        'strip': row['STRIP'], 'point': pt.to_array(),
        'section': row['LOC']
    }


class Point:
    def __init__(self, x, y, z=0):
        self.x = x
        self.y = y
        self.z = z

    def __repr__(self):
        return repr((self.x, self.y, self.z))

    def __add__(self, b):
        return Point(self.x + b.x, self.y + b.y, self.z + b.z)

    def __rmul__(self, b):
        return self.__mul__(b)

    def __mul__(self, b):
        return Point(self.x * b, self.y * b, self.z * b)

    def to_array(self):
        return [self.x, self.y, self.z]


if __name__ == '__main__':
    sys.exit(main())
