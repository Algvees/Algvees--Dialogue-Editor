Hello! This is the hap hazardly written manual for my dialogue editor, it is not finished but it is usable technically. This tool only provides an editor and is not a parser, you will have to provide that yourself. Also it's kinda set up for pool day sorgy </3

**important missing stuff**
> Right click menu to change node type and name

**Technical**
the dialogue nodes and types are automatically scanned upon the addon being loading, to load new ones or changes turn off and on the addon.

to add a new node or type for the editor please put the scene the corresponding "dialogue_nodes" and "dialogue_types" folder.

Dialogue nodes are GraphNodes that extend the "DialogueGraphNode" script. These nodes need a custom _populate_data and _create_save_dict to function properly. Where populate_data is where you want to fill all the entry fields with data from the dialogue dictionary; and _create_save_dict makes a dictionary with data from the entry fields. Please refer to the provided nodes for examples of how to make your own.

The types are the same idea a Control,typically HBoxContainer, extending "DialogueType" with _get_data_dict and _populate_data funcs. They also have an optional _clear() function that is intended to empty the type's entry fields so they arent filled with junk data when switching between dialogues.

**Dialogue Resource Structure**
The resource has a dictionary named Base_Dialogue, each dialogue dictionary is asigned by its name in the base dictionary. dialogue dictionaries may have more data but the basics are:
*nodes: Self explanitory 
*special: Marks if a node is special like the default or item dialogues you cannot delete
*start node: The name of the node intended to be the first called with a parser, cannot be moved or deleted
*type: Self explanitory 