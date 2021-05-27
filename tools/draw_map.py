import re
from PIL import Image, ImageDraw

pProject = "E:/GitHub_hydralerna/ZL-project/skylands-of-solarus/data/"
# pProject = "E:/APP/solarus-1.6.2-win32/TESTS/children-of-solarus-dev/data/"


pMaps = "maps/"
pTilesets = "tilesets/"
nameMap = "Tests/test_map.dat"
# nameMap = "dungeon_1/1f.dat"


print("ETAPE 1")

fMap = open(pProject + pMaps + nameMap, "r")
fMapContent = fMap.read()

regexTileset = r"  tileset \= \"(.*?)\"\,"
matchesTileset = re.finditer(regexTileset, fMapContent, re.MULTILINE | re.DOTALL)

regexProperties = r"properties\{(.*?)\}"
matchesProperties = re.finditer(regexProperties, fMapContent, re.MULTILINE | re.DOTALL)

for matchNum, match in enumerate(matchesProperties):
    for groupNum in range(0, len(match.groups())):
        groupStr = match.group(1).replace("\n","").replace(" ","").replace("=",":").replace('"',"")[:-1]
        properties = [] 
        for sub in groupStr.split(','): 
            if ':' in sub: 
                properties.append(map(str.strip, sub.split(':', 1))) 
        properties = dict(properties)

tilesets = {}
for matchNum, match in enumerate(matchesTileset):
    for groupNum in range(0, len(match.groups())):
        groupStr = match.group(1)
        if groupStr not in tilesets:
            tilesets[groupStr] = {}
fMap.close()


print("ETAPE 2")

for tileset in tilesets:
    
    fTileset = open(pProject + pTilesets + tileset + ".dat", "r")
    fTilesetContent = fTileset.read()

    regexTilePattern = r"tile_pattern\{(.*?)\}"
    matchesPattern = re.finditer(regexTilePattern, fTilesetContent, re.MULTILINE | re.DOTALL)

    tile_patterns = {}
    for matchNum, match in enumerate(matchesPattern):
        for groupNum in range(0, len(match.groups())):
            groupStr = match.group(1).replace("\n","").replace(" ","").replace("=",":")[:-1]
            tile_pattern = [] 
            for sub in groupStr.split(','): 
                if ':' in sub: 
                    tile_pattern.append(map(str.strip, sub.split(':', 1))) 
            tile_pattern = dict(tile_pattern)
            tile_patterns[eval(tile_pattern["id"])] = tile_pattern
    fTileset.close()
    tilesets[tileset] = tile_patterns.copy()
    tile_patterns.clear()



print("ETAPE 3")

fMap = open(pProject + pMaps + nameMap, "r")
fMapContent = fMap.read()

regexTile = r"(?:tile|wall)\{(.*?)\}"
matchesTile = re.finditer(regexTile, fMapContent, re.MULTILINE | re.DOTALL)

divisor = 8
# img = Image.new('RGB', (int(properties["width"]), int(properties["height"])), (0, 0, 0))
img = Image.new('RGB', (int(int(properties["width"]) / divisor), int(int(properties["height"]) / divisor)), (0, 0, 0))
draw = ImageDraw.Draw(img)


count = 0
for matchNum, match in enumerate(matchesTile):
    for groupNum in range(0, len(match.groups())):
        groupStr = match.group(1).replace("\n","").replace(" ","").replace("=",":").replace('"',"")[:-1]
        tile = [] 
        for sub in groupStr.split(','): 
            if ':' in sub: 
                tile.append(map(str.strip, sub.split(':', 1))) 
        tile = dict(tile)
        print(tile)
        # print(tile.get("stops_"))
        if int(tile["layer"]) == 0:
            if "stops_hero" not in tile:
                if "tileset" in tile:
                    tileset = tile["tileset"]
                else:
                    tileset = properties["tileset"]
                # print(tilesets[tileset][tile["pattern"]]["ground"])
                if tilesets[tileset][tile["pattern"]]["ground"] == '"traversable"':
                    color = (0, 255, 0)
                else:
                    color = (255, 0, 0)
            else:        
                color = (255, 0, 0)
            x1 = int(int(tile["x"]) / divisor)
            y1 = int(int(tile["y"]) / divisor)
            x2 = int(x1 + (int(tile["width"]) / divisor) - 1)
            y2 = int(y1 + (int(tile["height"]) / divisor) - 1)
            print(x1, y1, x2, y2)
            draw.rectangle((x1, y1, x2, y2), fill = color)
img.save('E:/GitHub_hydralerna/ZL-project/tools/test.png', "PNG")
fMap.close() 
