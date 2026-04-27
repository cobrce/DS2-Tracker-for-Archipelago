state("darksoulsii")
{

}

startup
{

    Console.Clear();
    Console.WriteLine(DateTime.Now.ToString());

    vars.Green = System.Drawing.Color.LawnGreen;
    vars.White = System.Drawing.Color.White;
    vars.Logged = false;

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
    vars.GetControl = (Func<String,object>)((controlName)=>
    {
        LiveSplit.UI.Components.ILayoutComponent control = null;
        if (!controls.TryGetValue(controlName,out control))
        {
            foreach (var c in timer.Layout.LayoutComponents) // try to find it in layout
            {
                try
                {
                    dynamic comp = c.Component;
                    if (comp.Settings.Text1 == controlName)
                    {
                            controls[controlName] = control =  c;
                            vars.Logt("control found", controlName);
                            break;
                    }
                }
                catch 
                {
                    
                }
            }
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

    vars.SetText = (Action<String,String>)((Value1,Value2)=>
    {
        dynamic component = vars.GetControl(Value1).Component;
        component.Settings.Text1 = Value1;
        if (Value2!=null)
            component.Settings.Text2 = Value2;    
    });


    vars.SetColor = (Action<String,System.Drawing.Color>)((controlName,color)=>
    {
        dynamic component = vars.GetControl(controlName).Component;
        component.Settings.OverrideTextColor = true;
        component.Settings.TextColor = color;
        component.Settings.OverrideTimeColor = true;
        component.Settings.TimeColor = color;
    });


    vars.DisplayColoredText = (Action<String,String,bool>)((value1,value2,isGreen) =>
    {
        vars.SetColor(value1,isGreen ? vars.Green : vars.White);
        vars.SetText(value1,value2);

    });


    vars.DisplayStatues = (Action<bool[]>) ((values) =>
    {
        vars.SetText("Statues",null);
        if(values.Length == vars.statueNames.Length)
        {
            for (int i = 0;i< values.Length;i++)
            {
                vars.DisplayColoredText(vars.statueNames[i]," ", values[i]);
            }
        }
    });


    vars.DisplayGilliganInMajula = (Action<bool>) ((isInMajula) =>
    {
        vars.SetColor("Laddersmith Gilligan In majula",isInMajula ? vars.Green : vars.White);
        vars.SetText("Laddersmith Gilligan In majula"," ");
    });

    vars.DisplayKeyItems= (Action<int[]>) ((items)=>
    {
        const int SOLDIERS_KEY = 0x03041840;
        const int KINGS_PASSAGE = 0x03043F50;
        const int BASTILLE_KEY = 0x03072580;
        const int ANTIQUATED_KEY = 0x0307C1C0;
        const int ROTUNDA_LOCKSTONE = 0x03088510;
        const int GIANTS_KINSHIP = 0x0308AC20;
        const int ASHEN_MIST_HEART = 0x0308D330;
        const int SILVERCAT_RING = 0x0268C2A0;
        const int FLYING_FELINE_BOOTS = 0x01477487;
        const int LENIGRAST_KEY = 0X030836F0;


        vars.SetText("Key items",null);
        vars.DisplayColoredText( "Silver cat ring"," ",items.Contains(SILVERCAT_RING));
        vars.DisplayColoredText( "Flying feline boots"," ",items.Contains(FLYING_FELINE_BOOTS));
        vars.DisplayColoredText( "Rotunda lockstone"," ",items.Contains(ROTUNDA_LOCKSTONE));
        vars.DisplayColoredText( "Giant's Kinship"," ",items.Contains(GIANTS_KINSHIP));
        vars.DisplayColoredText( "Soldier key"," ",items.Contains(SOLDIERS_KEY));
        vars.DisplayColoredText( "King's passage"," ",items.Contains(KINGS_PASSAGE));
        // vars.DisplayColoredText( "Bastille key"," ",items.Contains(BASTILLE_KEY));
        vars.DisplayColoredText( "Antiquated key"," ",items.Contains(ANTIQUATED_KEY));
        vars.DisplayColoredText( "Lenigrast key"," ",items.Contains(LENIGRAST_KEY));
    });

    vars.DisplaySoulMemory = (Action<int>)((value)=>
    {
        vars.DisplayColoredText("Soul memory",value.ToString(), value >= 1000000);
    });

    
    #endregion

    #region Correct timing method
         
    if (timer.CurrentTimingMethod != TimingMethod.GameTime)
    {
        if (DialogResult.Yes ==  
            MessageBox.Show("This split uses GameTime as timing method, switch now?",
            "LiveSplit : Eldenring boss timer",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question))
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
    #endregion


    #region memory functions
    // from CE table at https://github.com/boblord14/Dark-Souls-2-SotFS-CT-Bob-Edition
    vars.inventory = new int [] { 0XA8, 0x10, 0x10, 0x00};
    vars.soulMemory = new int [] {0xD0,0x490,0xFC};
    vars.gilligan = new int [] { 0x70, 0x20, 0x18, 0x7F} ;
    // some cheat engine shenanigans, the mentiond above CE table was helpful for that
    vars.inventory_key = new int [] { 0XA8, 0x10, 0x10, 0x18, 0x190};
    // based on code from https://github.com/WildBunnie/DarkSoulsII-Archipelago
    vars.world_flags = new int[]{ 0x70, 0x20, 0x18, 0x0 };
    vars.game_state =  new int[]{ 0x24AC };
    vars.base_a =(IntPtr)0x16148F0;


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
        var gilliganPtr = vars.ResolvePointer(proc,baseAddress,vars.base_a,vars.gilligan);
        // vars.Log(gilliganPtr.ToString("x"));
        return (vars.ReadInt(proc,gilliganPtr) & 8) != 0;
    });

    vars.GetStatue = (Func<Process,IntPtr,int,bool>)((proc,baseAddress,statueId) => 
    {
        if (statueId >= vars.statueOffsets.GetLength(0))
            return false;

        var worldFalgsPtr = vars.ResolvePointer(proc,baseAddress,(IntPtr)vars.base_a,vars.world_flags);
        var worldFlags = vars.ReadInt(proc,(IntPtr)((Int64)worldFalgsPtr + vars.statueOffsets[statueId,0]));
        var value =worldFlags &  (1 << vars.statueOffsets[statueId,1]);
        

        return (value != 0);
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

    #region Init controls
    vars.DisplaySoulMemory(0);
    vars.DisplayKeyItems(new int[]{});
    vars.DisplayGilliganInMajula(false);
    vars.CreateSeparator(false);
    vars.DisplayStatues(new bool[vars.statueNames.Length]);
    #endregion

}

init
{
    vars.Logt("Init","");
    vars.BaseAddress = modules.FirstOrDefault(m => m.ModuleName.ToLower() == "darksoulsii.exe").BaseAddress;
    vars.Logt("Soul memory", vars.ReadSoulMemory(game,vars.BaseAddress).ToString("x"));
}


update
{
    // soul memory
    var soulMemory = vars.ReadSoulMemory(game,vars.BaseAddress);
    vars.DisplaySoulMemory(soulMemory);

    // key items
    var items = vars.ReadInventory(game,vars.BaseAddress);
    vars.DisplayKeyItems(items);

    // is gilligan inn majula
    var gilligan = vars.GetGilligan(game,vars.BaseAddress);
    vars.DisplayGilliganInMajula(gilligan);

    // petrified statues
    var values = new bool[vars.statueOffsets.GetLength(0)];
    for (int i = 0;i< vars.statueOffsets.GetLength(0);i++)
    {
        values[i] = vars.GetStatue(game,vars.BaseAddress,i);
    }
    vars.DisplayStatues(values);
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

