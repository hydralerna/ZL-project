-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

require("scripts/meta/game")
require("scripts/meta/map")
require("scripts/hud/hud")
require("scripts/menus/pause/pause")
require("scripts/menus/dialog_box")
require("scripts/meta/block")
require("scripts/meta/bomb")
require("scripts/meta/chest")
require("scripts/meta/enemy")
require("scripts/meta/explosion")
require("scripts/meta/hero")
require("scripts/meta/npc")
require("scripts/utility/savegame_tables")
require("scripts/meta/sensor")
require"scripts/fx/lighting/lighting_manager"
require"scripts/fx/lighting/map_lighting"

require("scripts/debug")

return true
