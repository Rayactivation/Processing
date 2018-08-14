"""Make an html file to display all of the colormaps"""
import csv
import glob
import os

DATA = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'main', 'data'))

files = glob.glob(os.path.join(DATA, '*.csv'))

rows = []
for colormap in sorted(files):
    name = os.path.basename(colormap)[:-4]
    rows.append(name)
    with open(colormap) as fin:
        data = list(csv.reader(fin))
    color_divs = []
    for color in data:
        div = '<span style="background-color:rgb({},{},{});"></span>'.format(*color)
        color_divs.append(div)
    rows.append(''.join(color_divs))
html = """<html>
<header>
<style>
span {{ height: 30px; width: 2px; display: inline-block }}
</style>
</header>
<body>
<table>
<tr><td>{}</td></tr>
</table>
</body>
</html>
""".format("</td></tr>\n<tr><td>".join(rows))
    

with open(os.path.join(os.path.dirname(__file__), 'colormap.html'), 'w') as fout:
    fout.write(html)
