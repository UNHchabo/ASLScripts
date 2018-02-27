// Custom script for autosplitting on the 1 Yump category for the SMW Extended Categories group.
//
// For this, I made the following set of splits:
// 1. Load Map
// 2. Enter YI1
// 3. Goal Tape
// 4. Load Map
// 5. Enter YSP
// 6. Yump
//
// The second Load Map split should always be the same length, but I didn't want to bother with setting the memory query
// for only the opening cutscene. Also, if I failed the Yump and merely hit the switch, I would Undo Split, then Reset,
// to keep my best time as my actual PB.
//
// "Game Mode" ram values can be found here: http://old.smwiki.net/wiki/RAM_Address/$7E:0100

state("higan"){}
state("snes9x"){}
state("snes9x-x64"){}

startup
{
	settings.Add("levels", true, "Normal Levels");
	settings.SetToolTip("levels", "Split on crossing goal tapes and activating keyholes");
	settings.Add("bosses", true, "Boss Levels");
	settings.SetToolTip("bosses", "Split on boss fanfare");
	settings.Add("switchPalaces", false, "Switch Palaces");
	settings.SetToolTip("switchPalaces", "Split on completing a switch palace");
	settings.Add("levelDoorPipe", false, "Level Room Transitions");
	settings.SetToolTip("levelDoorPipe", "Split on door and pipe transitions within standard levels and switch palaces");
	settings.Add("castleDoorPipe", false, "Castle/GH Room Transitions");
	settings.SetToolTip("castleDoorPipe", "Split on door and pipe transitions within ghost houses and castles");
	settings.Add("loadWorldMap", false, "World Map");
	settings.SetToolTip("loadWorldMap", "Split on loading the world map");
	settings.Add("loadLevel", false, "Mario Start");
	settings.SetToolTip("loadLevel", "Split on loading a level");
}

init
{
	int memoryOffset = 0;
	while (memoryOffset == 0)
	{
		switch (modules.First().ModuleMemorySize)
		{
			case 5914624: //snes9x (1.53)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x6EFBA4);
				break;
			case 6909952: //snes9x (1.53-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140405EC8);
				break;
			case 6447104: //snes9x (1.54.1)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x7410D4);
				break;
			case 7946240: //snes9x (1.54.1-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1404DAF18);
				break;
			case 6602752: //snes9x (1.55)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x762874);
				break;
			case 8355840: //snes9x (1.55-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1405BFDB8);
				break;
			case 12509184: //higan (v102)
				memoryOffset = 0x915304;
				break;
			case 13062144: //higan (v103)
				memoryOffset = 0x937324;
				break;
			case 15859712: //higan (v104)
				memoryOffset = 0x952144;
				break;
			case 16756736: //higan (v105tr1)
				memoryOffset = 0x94F144;
				break;
			case 16019456: //higan (v106)
				memoryOffset = 0x94D144;
				break;
			default:
				memoryOffset = 1;
				break;
		}
	}

	vars.watchers = new MemoryWatcherList
	{
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1ED2) { Name = "fileSelect" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x906) { Name = "fanfare" },
		new MemoryWatcher<short>((IntPtr)memoryOffset + 0x1434) { Name = "keyholeTimer" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f28) { Name = "yellowSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f27) { Name = "greenSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f29) { Name = "blueSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1f2a) { Name = "redSwitch" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x141A) { Name = "roomCounter" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1B9B) { Name = "yoshiBanned" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x13C6) { Name = "bossDefeat" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x190D) { Name = "peach" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x100) { Name = "gameMode" },
	};
}

update
{
	vars.watchers.UpdateAll(game);
}

start
{
	return vars.watchers["fileSelect"].Old == 0 && vars.watchers["fileSelect"].Current == 1;
}

reset
{
	return vars.watchers["fileSelect"].Old != 0 && vars.watchers["fileSelect"].Current == 0;
}

split
{
	var goalExit = settings["levels"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 0;
	var keyExit = settings["levels"] && vars.watchers["keyholeTimer"].Old == 0 && vars.watchers["keyholeTimer"].Current == 0x0030;
	
	var yellowPalace = settings["switchPalaces"] && vars.watchers["yellowSwitch"].Old == 0 && vars.watchers["yellowSwitch"].Current == 1;
	var greenPalace = settings["switchPalaces"] && vars.watchers["greenSwitch"].Old == 0 && vars.watchers["greenSwitch"].Current == 1;
	var bluePalace = settings["switchPalaces"] && vars.watchers["blueSwitch"].Old == 0 && vars.watchers["blueSwitch"].Current == 1;
	var redPalace = settings["switchPalaces"] && vars.watchers["redSwitch"].Old == 0 && vars.watchers["redSwitch"].Current == 1;
	var switchPalaceExit = yellowPalace || greenPalace || bluePalace || redPalace;
	
	var levelDoorPipe = settings["levelDoorPipe"] && (vars.watchers["roomCounter"].Old + 1) == vars.watchers["roomCounter"].Current && vars.watchers["yoshiBanned"].Current == 0;
	var castleDoorPipe = settings["castleDoorPipe"] && (vars.watchers["roomCounter"].Old + 1) == vars.watchers["roomCounter"].Current && vars.watchers["yoshiBanned"].Current == 1;
	
	var bossExit = settings["bosses"] && vars.watchers["fanfare"].Old == 0 && vars.watchers["fanfare"].Current == 1 && vars.watchers["bossDefeat"].Current == 1;
	var bowserDefeated = settings["bosses"] && vars.watchers["peach"].Old == 0 && vars.watchers["peach"].Current == 1;
	
	var enterWorldMap = settings["loadWorldMap"] && vars.watchers["gameMode"].Old == 0xd && vars.watchers["gameMode"].Current == 0xe;
	var enterLevel = settings["loadLevel"] && vars.watchers["gameMode"].Old == 0xe && vars.watchers["gameMode"].Current == 0xf;

	return goalExit || keyExit || switchPalaceExit || levelDoorPipe || castleDoorPipe || bossExit || bowserDefeated || enterWorldMap || enterLevel;
}
