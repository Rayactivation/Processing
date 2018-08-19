"""send osc messages"""
import collections
import heapq
import functools
import math
import random
import sys
import time
import tkinter as tk

from pythonosc import udp_client


CIRCLE = 2*math.pi


def main():
    client = udp_client.SimpleUDPClient('127.0.0.1', 5000)
    print('Made client')

    recent = collections.deque([], 5)
    period = collections.deque([], 30)

    next_heatval_time = time.time() + 1
    next_rotation_time = time.time() + random.randint(0, 20)
    current_rotation_duration = rotation_duration()

    hs = HeatSimulator()
    people = []

    root = tk.Tk()
    app = Application(master=root)
    print(1, app.ray_id)
    root.update_idletasks()
    print(2, app.ray_id)
    root.update()
    print(3, app.ray_id)
    print('After update')
    print(app.ray_id)

    next_arrival_time = time.time() + 5

    while True:
        now = time.time()
        theta = get_theta(current_rotation_duration, next_rotation_time)
        assert 0 <= theta <= CIRCLE, theta
        app.rotate_ray(theta)

        if now >= next_arrival_time:
            print('Adding a person')
            person = Person(random.random() * CIRCLE, now + max(30, random.gauss(60, 20)))
            hs.add_person(person.location)
            person.tkid = app.add_person(person.location)
            heapq.heappush(people, person)
            next_arrival_time = now + max(0, random.gauss(30, 10))

        while people and now >= people[0].until:
            person = heapq.heappop(people)
            app.canvas.delete(person.tkid)
            hs.remove_person(person.location)

        if now >= next_heatval_time:
            val = hs.get_heat_val(theta)
            recent.append(val)
            period.append(val)
            send_message(client, "/cameraHeatVal", val)
            # # Uncomment these to do a quick spot check on the
            # # moving average calculations.
            # print('Recent period:', sum(period) / len(period))
            # print('Recent average:', sum(recent) / len(recent))
            next_heatval_time = time.time() + random.gauss(1, .1)

        if now >= next_rotation_time:
            send_message(client, '/rotation', 0)
            current_rotation_duration = rotation_duration()
            next_rotation_time = now + current_rotation_duration

        root.update_idletasks()
        root.update()


class Application(tk.Frame):
    def __init__(self, master=None):
        self.ray_id = None
        super().__init__(master)
        self.pack()
        self.create_widgets()
        self.radius = 100

    def create_widgets(self):
        print('Creating widgets')
        w = tk.Canvas(self.master, width=400, height=400)
        w.pack()

        # this it the center pole
        # create oval uses a "bounding box"
        # so this is a 20px circle in the middle
        w.create_oval(190, 190, 210, 210, fill="#000000")
        # the ray is a 40x40 ft box, starting at theta=0
        # fill=empty string is transparent
        self.ray_id = w.create_rectangle(280, 180, 320, 220, fill="")
        print('RAY ID:', self.ray_id)
        cords = w.coords(self.ray_id)
        print(cords)
        self.canvas = w
        print(self.canvas.coords(self.ray_id))
        
    def rotate_ray(self, theta):
        cords = self.canvas.coords(self.ray_id)
        x1, y1, x2, y2 = cords
        x = (x1 + x2) / 2
        y = (y1 + y2) / 2
        new_y = 100*math.sin(theta) + 200
        new_x = 100*math.cos(theta) + 200
        dx = new_x - x
        dy = new_y - y
        self.canvas.move(self.ray_id, dx, dy)

    def add_person(self, theta):
        new_y = 100*math.sin(theta) + 200
        new_x = 100*math.cos(theta) + 200
        return self.canvas.create_oval(new_x - 10, new_y - 10, new_x + 10, new_y + 10, fill="#00FF00")


    def say_hi(self):
        print("hi there, everyone!")


def clip(val, floor, ceil):
    return max(floor, min(val, ceil))


@functools.total_ordering
class Person:
    def __init__(self, location, until):
        self.location = location
        self.until = until
        self.tkid = None

    def as_tuple(self):
        return (self.until, self.location, self.tkid)

    def __lt__(self, other):
        return self.as_tuple() < other.as_tuple()

    def __eq__(self, other):
        return self.as_tuple() == other.as_tuple()


class HeatSimulator:
    def __init__(self):
        self.people_locations = []

    def get_heat_val(self, theta):
        # a 10% chance of just making noise
        if random.random() < .1:
            return random.randint(0, 100)
        # at 30 seconds a rotation, pi / 4 is 4 seconds of seeing a person
        n_people = len(list(self.get_people(theta, theta + math.pi / 4)))
        print('See {} people'.format(n_people))
        if n_people == 0:
            return int(clip(random.gauss(10, 5), 0, 100))
        if n_people == 1:
            return int(clip(random.gauss(50, 5), 0, 100))
        if n_people > 1:
            return int(clip(random.gauss(75, 5), 0, 100))

    def get_people(self, start, end):
        """Yield the people that are between start and end"""
        if end > CIRCLE:
            yield from self.get_people(start, CIRCLE)
            yield from self.get_people(0, end - CIRCLE)
        else:
            for loc in self.people_locations:
                if loc < start:
                    continue
                if loc >= end:
                    break
                yield loc

    def add_person(self, loc):
        self.people_locations.append(loc)
        self.people_locations = sorted(self.people_locations)

    def remove_person(self, loc):
        self.people_locations.remove(loc)
        self.people_locations = sorted(self.people_locations)


def get_theta(duration, end):
    now = time.time()
    start = end - duration
    elapsed = now - start
    # d = s * t
    speed = CIRCLE / duration
    theta = elapsed * speed
    if theta >= CIRCLE:
        theta -= CIRCLE
    return theta


def rotation_duration():
    # lets say it takes about 30 seconds to make a full rotation
    return random.gauss(30, 2)


def send_message(client, *msg):
    print('Sending message:', *msg)
    client.send_message(*msg)


if __name__ == '__main__':
    sys.exit(main())
