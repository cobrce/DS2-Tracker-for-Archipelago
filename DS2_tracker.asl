state("darksoulsii")
{

}

startup
{

    try
    {
        Console.Clear();
    }
    catch{}
    Console.WriteLine(DateTime.Now.ToString());

    vars.Green = System.Drawing.Color.LawnGreen;
    vars.White = System.Drawing.Color.White;
    vars.archipelago_dll =(IntPtr) 0;

    #region log

    vars.Msgb = (Action<String>)((text) =>
    {
        MessageBox.Show(text,"DS2_tracker",MessageBoxButtons.OK,MessageBoxIcon.Information);
    });

    vars.Log = (Action<String>) ((text) =>
    {
        print(String.Format("[DS2 tacker] {0}",text));
        Console.WriteLine(String.Format("[DS2 tracker] {0}",text));
    });
    vars.Logt = (Action<String,String>)((title,text)=>
    {
        print(String.Format("[DS2 tracker : {0}] {1}",title,text));
        Console.WriteLine(String.Format("[DS2 tracker : {0}] {1}",title,text));

    });
    #endregion
    
    #region Create/Find Textboxes
    var controls = new Dictionary<String,LiveSplit.UI.Components.ILayoutComponent>();
    // find existing control or return null
    vars.FindControl = (Func<String,LiveSplit.UI.Components.ILayoutComponent>)((controlName) =>
    {
        LiveSplit.UI.Components.ILayoutComponent control = null;
        if (controls.TryGetValue(controlName,out control))
            return control;

        foreach (var c in timer.Layout.LayoutComponents) // try to find it in layout
        {
            try
            {
                dynamic comp = c.Component;
                if (comp.Settings.Text1 == controlName)
                {
                        controls[controlName] =  c;
                        vars.Logt("control found", controlName);
                        return (LiveSplit.UI.Components.ILayoutComponent)c;
                }
            }
            catch 
            {
                
            }
        }
        return null;
    });
    // find or create control
    vars.GetControl = (Func<String,object>)((controlName)=>
    {
        LiveSplit.UI.Components.ILayoutComponent control = vars.FindControl(controlName);
        if (control == null)
        {
            controls[controlName]= control = LiveSplit.UI.Components.ComponentManager.LoadLayoutComponent("LiveSplit.Text.dll",timer);
            vars.Logt("control created", controlName);
        }
        if (!timer.Layout.LayoutComponents.Contains(control))
        {
            vars.Logt("control added", controlName);
            timer.Layout.LayoutComponents.Add(control);
        }
        return (object)control;

    });

    vars.CreateSeparator = (Action<bool>)((ignoreExistant)=>
    {
        bool found = false;
            foreach (var c in timer.Layout.LayoutComponents)
            {
                if(c.Component is LiveSplit.UI.Components.SeparatorComponent)
                {
                    vars.Logt("Sperator", "Existing");
                    found = true;
                    break;
                }
        }
        if (ignoreExistant || !found)
        {
            var compo = new LiveSplit.UI.Components.LayoutComponent("",new LiveSplit.UI.Components.SeparatorComponent());
            timer.Layout.LayoutComponents.Add(compo);
            vars.Logt("Separator","Created");
        }
    });
    #endregion

    #region Update textboxes

    vars.SetText = (Func<String,String,object>)((Value1,Value2)=>
    {
        dynamic component = vars.GetControl(Value1).Component;
        component.Settings.Text1 = Value1;
        if (Value2!=null)
            component.Settings.Text2 = Value2;    
        return component;
    });

    vars.RemoveControl = (Action<String>)((controlName)=>
    {
        var control = vars.FindControl(controlName);
        // if (control == null)// for some reason livesplit hates returning nothing;
        //     return;
        if (control != null) 
        {
            vars.Log("removing");
            controls.Remove(controlName);
            var components = (ICollection<LiveSplit.UI.Components.ILayoutComponent>) timer.Layout.LayoutComponents;
            components.Remove(control);
        }
            
        


    });


    vars.SetColor = (Func<String,System.Drawing.Color,object>)((controlName,color)=>
    {
        dynamic component = vars.GetControl(controlName).Component;
        component.Settings.OverrideTextColor = true;
        component.Settings.TextColor = color;
        component.Settings.OverrideTimeColor = true;
        component.Settings.TimeColor = color;
        return component;
    });


    vars.DisplayColoredText = (Func<String,String,bool,object>)((value1,value2,isGreen) =>
    {
        vars.SetColor(value1,isGreen ? vars.Green : vars.White);
        return vars.SetText(value1,value2);

    });


    vars.DisplayStatues = (Action<bool[],bool[]>) ((display,values) =>
    {
        bool displayTitle = false;
        foreach (var d in display)
            displayTitle |= d;
        
        if (displayTitle)
        { 
            vars.SetText("Statues",null);
        }
        else
        { 
            vars.RemoveControl("Statues");
        }
        if(values.Length == vars.statueNames.Length)
        {
            for (int i = 0;i< values.Length;i++)
            {
                if (display[i])
                {
                    vars.DisplayColoredText(vars.statueNames[i]," ", values[i]);
                }
                else
                {
                    vars.RemoveControl(vars.statueNames[i]);
                }
            }
        }
    });


    vars.DisplayKeyItems= (Action<int[]>) ((items)=>
    {
        const int SOLDIERS_KEY = 0x03041840;
        const int BASTILLE_KEY = 0x03072580;
        const int ANTIQUATED_KEY = 0x0307C1C0;
        const int ROTUNDA_LOCKSTONE = 0x03088510;
        const int ASHEN_MIST_HEART = 0x0308D330;
        const int LENIGRAST_KEY = 0X030836F0;
        const int KINGS_PASSAGE = 0x03043F50;

        vars.SetText("Key items",null);
        vars.DisplayColoredText( "Rotunda lockstone"," ",items.Contains(ROTUNDA_LOCKSTONE));
        vars.DisplayColoredText( "Soldier key"," ",items.Contains(SOLDIERS_KEY));
        vars.DisplayColoredText( "King's passage"," ",items.Contains(KINGS_PASSAGE));
        // vars.DisplayColoredText( "Bastille key"," ",items.Contains(BASTILLE_KEY));
        vars.DisplayColoredText( "Antiquated key"," ",items.Contains(ANTIQUATED_KEY));
        vars.DisplayColoredText( "Lenigrast key"," ",items.Contains(LENIGRAST_KEY));
    });

    vars.DisplayEndGame = (Action<int[]>)((items)=>
    {

        const int GIANTS_KINSHIP = 0x0308AC20;
        const int KINGS_RING = 0x026A2230;


        var giantKinship = items.Contains(GIANTS_KINSHIP);
        var kingsRing = items.Contains(KINGS_RING);

        var control = vars.DisplayColoredText("End game",
            String.Format("[{0}]king's ring + [{1}]giant's  kinship",
                kingsRing ? "✔": " " ,
                giantKinship ? "✔": " "),
                giantKinship && kingsRing

            );
        control.Settings.Display2Rows = true;

    });
    vars.DisplayBlackGulch = (Action<int[],bool>)((items,gilligan)=>
    {

        const int SILVERCAT_RING = 0x0268C2A0;
        const int FLYING_FELINE_BOOTS = 0x01477487;
        
        var silverCatRing = items.Contains(SILVERCAT_RING);
        var flyingFelineBoots = items.Contains(FLYING_FELINE_BOOTS);

        var control = vars.DisplayColoredText("Black gulch", 
        String.Format("[{0}]SCR / [{1}]FFB / [{2}]Gilligan",
            silverCatRing ? "✔": " ",
            flyingFelineBoots ? "✔": " ",
            gilligan ? "✔": " "),
            silverCatRing || flyingFelineBoots || gilligan);

        control.Settings.Display2Rows = true;
    });

    vars.DisplayShrineOfWinter = (Action<int,bool,int,bool,bool>)((soulMemory,lostSinner,freyja,ironKing,rotten)=>
    {

        var count = (lostSinner ? 1 : 0) + 
                    (freyja == 2 ? 1 : 0) +
                    (ironKing ? 1 : 0) +
                    (rotten ? 1 : 0);
        var control = vars.DisplayColoredText("Shrine of winter", String.Format("SM {0} / GS {1}{2}",
                                                                    soulMemory,
                                                                    count,
                                                                    (freyja == 1 ? " (hank! the red orb!)" : "")),
                                count == 4 || soulMemory > 1000000
                                                                    );
        control.Settings.Display2Rows = true;

    });

    #endregion

    #region Correct timing method
         
    if (timer.CurrentTimingMethod != TimingMethod.GameTime)
    {
        // if (DialogResult.Yes ==  
        //     MessageBox.Show("This split uses GameTime as timing method, switch now?",
        //     "LiveSplit : Eldenring boss timer",
        //     MessageBoxButtons.YesNo,
        //     MessageBoxIcon.Question))
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
    #endregion

    #region memory functions
    // from CE table at https://github.com/boblord14/Dark-Souls-2-SotFS-CT-Bob-Edition
    vars.inventory = new int [] { 0XA8, 0x10, 0x10, 0x00};
    vars.soulMemory = new int [] {0xD0,0x490,0xFC};
    vars.gilliganInMajulaFlag = new int[] {0x7F,3};
    // some cheat engine shenanigans, the mentiond above CE table was helpful for that
    vars.inventory_key = new int [] { 0XA8, 0x10, 0x10, 0x18, 0x190};
    vars.boss_level = new int [] {0x70, 0X28, 0x20, 0x8};// if boss level is not null it means that it has been defeated at least once
    vars.ROTTEN_INDEX = 0x1A;
    vars.FREIJA_INDEX = 0xB;
    vars.IRONKING_INDEx = 0xC;
    vars.LOSTSINNER_INDEx = 0x17;
    vars.freyjaGreatSoulsEmbracedFlag = new int[] {0x41,3};
    // based on code from https://github.com/WildBunnie/DarkSoulsII-Archipelago
    vars.world_flags = new int[]{ 0x70, 0x20, 0x18, 0x0 };
    vars.game_state =  new int[]{ 0x24AC };
    vars.base_a =(IntPtr)0x16148F0;

    // reading events from archipelago dll
    vars.archipelago_event_flag_count = 0x72DF08;


    vars.statueOffsets = new int[,]
    {
     {0x9D2, 5},  // Unpetrify Statue in Things Betwixt
     {0x152, 7},  // Unpetrify Rosabeth of Melfia
     {0xCED, 5},  // Unpetrify Statue in Heide's Tower of Flame
     {0xA33, 0},  // Unpetrify Statue in Lost Bastille
     {0x15E, 2},  // Unpetrify Straid of Olaphis
     {0xAC9, 4},  // Unpetrify Statue in Black Gulch
     {0xB13, 7},  // Unpetrify Statue near Manscorpion Tark
     {0xB12, 5},  // Unpetrify Statue near Black Knight Halberd
     {0xB13, 5},  // Unpetrify Statue Blocking the Chest in Shaded Ruins
     {0xB12, 3}, // Unpetrify Lion Mage Set Statue in Shaded Ruins
     {0xB12, 1}, // Unpetrify Fang Key Statue in Shaded Ruins
     {0xB13, 6}, // Unpetrify Warlock Mask Statue in Shaded Ruins
     {0xB78, 1}, // Unpetrify Milfanito Entrance Statue
     {0xCA7, 5}, // Unpetrify Cyclops Statue in Aldia's Keep
     {0xCA7, 4}, // Unpetrify Left Cage Statue in Aldia's Keep
     {0xCA7, 3}, // Unpetrify Right Cage Statue in Aldia's Keep
     {0xCBD, 1}  // Unpetrify Statue in Dragon Aerie
    };

    // check those vents in "archipelago.dll"
    vars.events = new int[]
    {
        102000050, // Unpetrify Statue in Things Betwixt                 
        102640,    // Unpetrify Rosabeth of Melfia                       
        132000010, // Unpetrify Statue in Heide's Tower of Flame         
        116000031, // Unpetrify Statue in Lost Bastille                  
        102741,    // Unpetrify Straid of Olaphis                        
        125000027, // Unpetrify Statue in Black Gulch                    
        132000016, // Unpetrify Statue near Manscorpion Tark             
        132000010, // Unpetrify Statue near Black Knight Halberd         
        132000018, // Unpetrify Statue Blocking the Chest in Shaded Ruins
        132000012, // Unpetrify Lion Mage Set Statue in Shaded Ruins     
        132000014, // Unpetrify Fang Key Statue in Shaded Ruins          
        132000017, // Unpetrify Warlock Mask Statue in Shaded Ruins      
        211000030, // Unpetrify Milfanito Entrance Statue                
        115000050, // Unpetrify Cyclops Statue in Aldia's Keep           
        115000051, // Unpetrify Left Cage Statue in Aldia's Keep         
        115000052, // Unpetrify Right Cage Statue in Aldia's Keep        
        127000030, // Unpetrify Statue in Dragon Aerie                   
    };

    vars.statueNames = new string[]{
        "Things betwixt",
        "Rosabeth of Melfia",
        "Heide's Tower of Flame",
        "Lost Bastille",
        "Straid of Olaphis",
        "Black Gulch",
        "Manscorpion Tark",
        "Next to Black Knight Halberd",
        "Chest in Shaded Ruins",
        "Lion Mage Set Statue in Shaded Ruins",
        "Fang Key Statue in Shaded Ruins",
        "Warlock Mask Statue in Shaded Ruins",
        "Milfanito Entrance Statue",
        "Cyclops Statue in Aldia's Keep",
        "Left Cage Statue in Aldia's Keep",
        "Right Cage Statue in Aldia's Keep",
        "Dragon Aerie"
    };


    vars.IsBossDefeatedAtLeastOnce = (Func<Process,IntPtr,int,bool>)((proc,baseAddress,bossIndex)=>
    {
        var bossPtr0 = vars.ResolvePointer(proc,baseAddress,vars.base_a,vars.boss_level);
        var bossPtr =(IntPtr)(vars.ReadPointer(proc,bossPtr0) + (bossIndex * 4));
        var state = vars.ReadInt(proc,bossPtr);
        return (state != 0); // if not null it means that the boss already defeated once

    });

    vars.ReadRotten = (Func<Process,IntPtr,bool>)((proc,baseAddress)=>
    {
        return vars.IsBossDefeatedAtLeastOnce(proc,baseAddress,vars.ROTTEN_INDEX);

    });

    vars.ReadFreyja = (Func<Process,IntPtr,int>)((proc,baseAddress)=>
    {
        var greateSoulEmbraced = vars.ReadWorldEvent(proc,baseAddress,vars.freyjaGreatSoulsEmbracedFlag[0],vars.freyjaGreatSoulsEmbracedFlag[1]);
        var bossDefeated = vars.IsBossDefeatedAtLeastOnce(proc,baseAddress,vars.FREIJA_INDEX);
        return (greateSoulEmbraced ? 1 : 0) + (bossDefeated ? 1 : 0);
    });

    vars.ReadIronKing = (Func<Process,IntPtr,bool>)((proc,baseAddress)=>
    {
        return vars.IsBossDefeatedAtLeastOnce(proc,baseAddress,vars.IRONKING_INDEx);
    });

    vars.ReadLostSinner = (Func<Process,IntPtr,bool>)((proc,baseAddress)=>
    {
        return vars.IsBossDefeatedAtLeastOnce(proc,baseAddress,vars.LOSTSINNER_INDEx);
    });

    vars.ReadSoulMemory = (Func<Process,IntPtr,int>)((proc,baseAddress)=>
    {
        var soulMemoryPtr = vars.ResolvePointer(proc,baseAddress,vars.base_a,vars.soulMemory);
        return vars.ReadInt(proc,soulMemoryPtr);
        // return 0;
    });

    vars.ReadPointer = (Func<Process,IntPtr,IntPtr>)((proc,ptr) =>
    {
        return proc.ReadPointer(ptr);
    });

    vars.ResolvePointer = (Func<Process,IntPtr,IntPtr,int[],IntPtr>) ((proc,baseAddress,address,offsets) =>
    {
        var newAddress =(IntPtr)((Int64)baseAddress+(Int64)address);
        var result = vars.ReadPointer(proc,newAddress);
        int i = 0;
        for (; i < offsets.Length - 1;i++)
        {
               result = (IntPtr)((Int64)result + offsets[i]);
               result = vars.ReadPointer(proc,result);
        }
        result = (IntPtr)((Int64)result + offsets[i]);
        return result;
    });


    vars.ReadInventory = (Func<Process,IntPtr,int[]>) ((proc,baseAddress)=>
    {
    // based on code from "ItemGive" function, CE table at https://github.com/boblord14/Dark-Souls-2-SotFS-CT-Bob-Edition
        var items = new List<int>();
        var inventoryPtr = vars.ResolvePointer(proc,baseAddress,(IntPtr)vars.base_a,vars.inventory);
        
        for (int i = 0; i< 3839;i++)
        {
            IntPtr itemPtr =(IntPtr) ( (Int64)inventoryPtr + (i * 0x10) );
            var itemID = vars.ReadInt(proc,itemPtr);
            if (itemID != 0)
                items.Add(itemID);
        }


        // Read key items
        inventoryPtr = vars.ResolvePointer(proc,baseAddress,vars.base_a,vars.inventory_key);

        for (int i = 0; i < 1000;i++) // arbitrary limit, should stop when find "0" in previousItem
        {
            if ((Int64)inventoryPtr == 0)
                break;
            var itemID = vars.ReadInt(proc,(IntPtr)(inventoryPtr + 0x14));
            if (itemID!=0)
                items.Add(itemID);

            inventoryPtr = vars.ReadPointer(proc,(IntPtr)(inventoryPtr + 0x8));
        }
        return items.ToArray();
    });


    vars.GetGilligan = (Func<Process,IntPtr,bool>) ((proc,baseAddress) =>
    {
        return vars.ReadWorldEvent(proc,baseAddress,vars.gilliganInMajulaFlag[0],vars.gilliganInMajulaFlag[1]);
        
    });


    vars.ReadWorldEvent = (Func<Process,IntPtr,int,int,bool>)((proc,baseAddress,offset,bitIndex)=>
    {
        var worldFalgsPtr = vars.ResolvePointer(proc,baseAddress,(IntPtr)vars.base_a,vars.world_flags);
        var worldFlags = vars.ReadInt(proc,(IntPtr)((Int64)worldFalgsPtr + offset));
        var value = worldFlags &  (1 << bitIndex);
        return value!=0;

    });

    vars.GetStatue = (Func<Process,IntPtr,int,bool>)((proc,baseAddress,statueId) => 
    {
        if (statueId >= vars.statueOffsets.GetLength(0))
            return false;

        var value = vars.ReadWorldEvent(proc,baseAddress,vars.statueOffsets[statueId,0],vars.statueOffsets[statueId,1]);
        if (value)
            return true;


        if (vars.archipelago_dll == (IntPtr) 0)
        {
            foreach (System.Diagnostics.ProcessModule module in proc.Modules)
            {
                if(module.ModuleName.ToLower() == "archipelago.dll")
                {
                    vars.archipelago_dll = module.BaseAddress;
                    vars.Logt("Archipelago.dll address", vars.archipelago_dll.ToString("x"));
                    break;
                }
            }
        }
        else
        {
            var event_flag_countPtr = vars.archipelago_dll + vars.archipelago_event_flag_count;
            var event_flags = (IntPtr) event_flag_countPtr + 4;
            var nEvents = vars.ReadInt(proc,(IntPtr)event_flag_countPtr) % 4000; // 4000 is an arbitrary limit, should never happen

            for (int i = 0;i<nEvents;i++)
            {
                var eventId = vars.ReadInt(proc,(IntPtr)event_flags + i * 4);
                if (eventId == vars.events[statueId])
                    return true;
            }

        }
        return false;
    });


    vars.ReadInt = (Func<Process,IntPtr,Int32>)((proc,ptr) =>
    {
        return proc.ReadValue<Int32>(ptr);
    });

    vars.IsInGame = (Func<Process,IntPtr,bool>) ((proc,baseAddress)=>
    {
        var gameStatePtr = vars.ResolvePointer(proc,baseAddress,(IntPtr)vars.base_a,vars.game_state);
        var state = vars.ReadInt(proc,gameStatePtr);
        return state == 30;
    });

    #endregion

    #region Config
    settings.Add("Compact");
    settings.Add("Statues");
    foreach (var statue in vars.statueNames)
    {
        settings.Add(statue,true,statue,"Statues");
    }
    #endregion

    #region Init controls
    vars.DisplayShrineOfWinter(0,false,0,false,false);
    vars.DisplayBlackGulch(new int[]{},false);
    vars.DisplayEndGame(new int[]{});
    vars.DisplayKeyItems(new int[]{});
    vars.CreateSeparator(false);
    // vars.DisplayStatues(false,new bool[vars.statueNames.Length]);
    #endregion

    #region init run
    timer.Run.GameName = "Dark Souls II: Scholar of the First Sin";
    timer.Run.CategoryName = "Archipelago";
    #endregion

}

init
{
    vars.Logt("Init","");
    vars.BaseAddress = modules.FirstOrDefault(m => m.ModuleName.ToLower() == "darksoulsii.exe").BaseAddress;
    vars.Logt("Soul memory", vars.ReadSoulMemory(game,vars.BaseAddress).ToString());
}


update
{
    // great souls
    vars.DisplayShrineOfWinter(vars.ReadSoulMemory(game,vars.BaseAddress),
                            vars.ReadLostSinner(game,vars.BaseAddress),
                            vars.ReadFreyja(game,vars.BaseAddress),
                            vars.ReadIronKing(game,vars.BaseAddress),
                            vars.ReadRotten(game,vars.BaseAddress));



    // key items
    var items = vars.ReadInventory(game,vars.BaseAddress);
    var gilligan = vars.GetGilligan(game,vars.BaseAddress);
    vars.DisplayBlackGulch(items,gilligan);
    vars.DisplayEndGame(items);
    vars.DisplayKeyItems(items);

    // petrified statues
    var values = new bool[vars.statueOffsets.GetLength(0)];
    var display = new bool[vars.statueOffsets.GetLength(0)];
    for (int i = 0;i< vars.statueOffsets.GetLength(0);i++)
    {
        values[i] = vars.GetStatue(game,vars.BaseAddress,i);
        display[i] = settings[vars.statueNames[i]];
    }

    vars.DisplayStatues(display,values);
}

onReset
{
   
}
reset
{
  
}

start
{
      return vars.IsInGame(game,vars.BaseAddress);
}

isLoading
{
    return !vars.IsInGame(game,vars.BaseAddress);
}

