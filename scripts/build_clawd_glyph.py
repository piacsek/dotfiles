import sys
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
GRID = """\
..#############..
..#############..
..##.#######.##..
..##.#######.##..
#################
#################
..#############..
..#############..
..#.#.......#.#..
..#.#.......#.#..""".splitlines()
CW, CH, TOP = 56, 62, 600
def glyph():
    p = TTGlyphPen(None)
    for j, row in enumerate(GRID):
        i = 0
        while i < len(row):
            if row[i] != '#': i += 1; continue
            k = i
            while k < len(row) and row[k] == '#': k += 1
            x0, x1 = 24 + i*CW, 24 + k*CW
            y1 = TOP - j*CH; y0 = y1 - CH
            p.moveTo((x0, y0)); p.lineTo((x0, y1)); p.lineTo((x1, y1)); p.lineTo((x1, y0)); p.closePath()
            i = k
    return p.glyph()
fb = FontBuilder(1000, isTTF=True)
fb.setupGlyphOrder([".notdef", "clawd"])
fb.setupCharacterMap({0x100000: "clawd"})
fb.setupGlyf({".notdef": TTGlyphPen(None).glyph(), "clawd": glyph()})
fb.setupHorizontalMetrics({".notdef": (1000, 0), "clawd": (1000, 24)})
fb.setupHorizontalHeader(ascent=800, descent=-200)
fb.setupNameTable({"familyName": "Clawd Glyph", "styleName": "Regular", "uniqueFontIdentifier": "ClawdGlyph-Regular", "fullName": "Clawd Glyph Regular", "psName": "ClawdGlyph-Regular", "version": "Version 1.0"})
fb.setupOS2(sTypoAscender=800, sTypoDescender=-200, usWinAscent=800, usWinDescent=200)
fb.setupPost(isFixedPitch=1)
fb.save(sys.argv[1])
