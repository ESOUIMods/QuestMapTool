Subzone info collection (x,y,zoom_factor)
--------------------------------------

1. Delete SavedVariables\QuestMapTool.lua
2. It's best to deactivate all Map addons or disable all map pins from all addons
3. Under "Controls" bind a key for "Get subzone info"
4. Open the map
5. With the mouse cursor, click on the subzone that you want to collect info about and after that don't move your mouse anymore
6. Press the key from Step 3
7. Repeat step 5-6 for more subzones
8. /reloadui for saving the data to the file SavedVariables\QuestMapTool.lua

The addon will do the following steps (probably too fast to see):
1. Collect data
2. Zoom out to the main zone
3. Collect data
4. Zoom in again to the subzone (using mouse click, that's why the cursor must not be moved after step 5)
5. Collect data
6. Again zoom out to the main zone
7. Collect data
