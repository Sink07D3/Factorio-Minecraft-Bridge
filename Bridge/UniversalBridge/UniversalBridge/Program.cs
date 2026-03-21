using System.Text;
using System.Net;
using CoreRCON;
using Newtonsoft.Json;

namespace UniversalBridge
{
    class Program
    {
        static void Main(string[] args)
        {
            /*
				Input and checking for settings file.
				This should probably not immediately check but instead prompt the user with the current settings and if they would like to change them
			*/
            Console.WriteLine("Starting Up!");
            Console.WriteLine("To change settings, enter 1, otherwise press enter to continue.");
            string choice = Console.ReadLine();
            Settings settings = new Settings();
            string startupDoc = Path.Combine(Environment.CurrentDirectory, "settings.json");
            if (!File.Exists(startupDoc) || choice.Equals("1"))
            {
                FileStream fs = new FileStream(startupDoc, FileMode.OpenOrCreate, FileAccess.Write, FileShare.ReadWrite);
                StreamWriter sw = new StreamWriter(fs, Encoding.Default);
                Console.WriteLine("Please enter Minecraft Location (Root of the Directory): ");
                settings.setMcPath(Console.ReadLine());
                Console.WriteLine("Please enter Factorio Server Path (Root of the Directory): ");
                settings.setFacotrioPath(Console.ReadLine());
                Console.WriteLine("Please enter the IP Address of the Factorio Server (127.0.0.1 if you're hosting on the same machine): ");
                settings.setIpAddress(Console.ReadLine());
                Console.WriteLine("Please enter RCON Port Number: ");
                settings.setPort(Int32.Parse(Console.ReadLine()));
                Console.WriteLine("Please enter RCON password: ");
                settings.setRconPass(Console.ReadLine());
                string output = JsonConvert.SerializeObject(settings);
                sw.WriteLine(output);
                sw.Close();
            }
            else
            {
                FileStream fs = new FileStream(startupDoc, FileMode.OpenOrCreate, FileAccess.Read, FileShare.ReadWrite);
                StreamReader sr = new StreamReader(fs, Encoding.Default);
                string input = "";
                while (!sr.EndOfStream)
                {
                    input += sr.ReadLine();
                }
                settings = JsonConvert.DeserializeObject<Settings>(input);
            }

            /*
				Load in the item mappings file.  
			*/
            DualDictionary<String, String> itemMappings = new DualDictionary<String, String>();
            Dictionary<String, double> minecraftRatios = new Dictionary<String, double>();
            Dictionary<String, double> factorioRatios = new Dictionary<String, double>();

            //Open up the file stream for the item mappings
            string itemMappingsPath = Path.Combine(Environment.CurrentDirectory, "item_mappings.txt");
            FileStream fileStream = new FileStream(itemMappingsPath, FileMode.OpenOrCreate, FileAccess.Read, FileShare.Read);
            StreamReader streamReader = new StreamReader(fileStream, Encoding.Default);

            //This loop needs to do a couple of things. 
            //The first is it needs to read in the mappings into the DualDictionary for better translation of names.
            //The second it needs to bind the item ratios to their respective lists.
            while (!streamReader.EndOfStream)
            {
                //Item Name Mappings first
                String readString = streamReader.ReadLine(); //read line
                if (readString.Contains("#") || readString.Equals("") || readString.Equals("\n"))
                { //if the line is a comment, is blank, or is nothing but a new line, move to the next iteration
                    continue;
                }
                String[] split = readString.Split('='); //split item pair from mapping file
                itemMappings.Add(split[0], split[1]); //add the pair to current list of item mappings
                                                      //Split the string again to get the ratios
                if (split.Length > 2)
                {
                    String[] ratios = split[2].Split(':');
                    minecraftRatios.Add(split[0], Double.Parse(ratios[0]));
                    factorioRatios.Add(split[1], Double.Parse(ratios[1]));
                }
            }
            streamReader.Close();
            fileStream.Close();

            /*
				Open RCON Connection to factorio server
				Parse the files and send the data to the approiate game.
			*/
            Console.WriteLine("Found settings. Beginning transfer.");
            var rcon = new RCON(IPAddress.Parse(settings.getIPAddress()), (ushort)settings.getPort(), settings.getRconPass());
            while (true)
            {
                try
                {
                    List<ItemPair> factorioItems = parseFactrio(settings, itemMappings, factorioRatios);
                    List<ItemPair> minecraftItems = parseMinecraft(settings, itemMappings, minecraftRatios);
                    sendToFactorio(minecraftItems, rcon);
                    sendToMinecraft(factorioItems, settings);
                    Thread.Sleep(50); //Thread.Sleep(1000); //Lowest common transfer rate is 50ms per transfer (should be roughly every minecraft tick and every 3 factorio ticks). Might cause serious problems.
                                      //I wish there was a way to sync tickrates between factorio and minecraft.
                }
                catch (Exception e)
                {
                    Console.WriteLine("Something went wrong. Moving past error. This is great error handling.");
                    Console.WriteLine(e.Message);
                    continue;
                }
            }
        }

        /// FACTORIO
        /// Reading and parsing for factorio 
        /// FACTORIO
        public static async void sendToFactorio(List<ItemPair> items, RCON rcon)
        {
            if (items.Count > 0)
            {
                for (int i = 0; i < items.Count; i++)
                {
                    StringBuilder str = new StringBuilder();
                    String cmd = "";
                    if (items[i].count > 100)
                    {
                        while (items[i].count > 100)
                        {
                            str.Append(@"/silent-command remote.call(""receiveItems"",""inputItems"",");
                            str.Append(@"""");
                            str.Append(items[i].name);
                            str.Append(@""",");
                            str.Append(100);
                            str.Append(")");
                            cmd = await rcon.SendCommandAsync(str.ToString());
                            items[i].count -= 100;
                            str.Clear();
                        }
                    }
                    str.Append(@"/silent-command remote.call(""receiveItems"",""inputItems"",");
                    str.Append(@"""");
                    str.Append(items[i].name);
                    str.Append(@""",");
                    str.Append(items[i].count.ToString());
                    str.Append(")");
                    cmd = await rcon.SendCommandAsync(str.ToString());
                    str.Clear();
                }
            }
        }

        public static List<ItemPair> parseFactrio(Settings settings, DualDictionary<String, String> mappings, Dictionary<String, double> ratios)
        {
            List<ItemPair> items = new List<ItemPair>();
            String fullPath = Path.Combine(settings.getFactorioPath(), "script-output/toMC.dat");
            FileStream fs = new FileStream(fullPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
            StreamReader sr = new StreamReader(fs, Encoding.Default);
            while (!sr.EndOfStream)
            {
                string proc = sr.ReadLine();
                string[] temp = proc.Split(':');
                int count = 0;
                if (ratios.Count > 0)
                {
                    double readNum = Double.Parse(temp[1]) * ratios[temp[0]]; ;
                    count = (int)Math.Round(readNum, MidpointRounding.AwayFromZero);
                }
                else
                {
                    count = (int)Double.Parse(temp[1]);
                }
                int containsTest = pairContains(items, temp[0]);

                if (containsTest != -1)
                {
                    if (items[containsTest].count < 64)
                    {
                        int remainder = 64 - items[containsTest].count;
                        if (remainder > 0)
                        {
                            items[containsTest].count += remainder;
                            count -= remainder;
                        }
                    }
                    if ((64 - count) < 0)
                    {
                        items.Add(new ItemPair(temp[0], 64));
                        int remain = Math.Abs(64 - count);
                        while (remain > 0)
                        {
                            if (remain > 64)
                            {
                                items.Add(new ItemPair(temp[0], 64));
                                remain -= 64;
                            }
                            else
                            {
                                items.Add(new ItemPair(temp[0], remain));
                                remain -= 64;
                            }
                        }
                    }
                    else
                    {
                        items.Add(new ItemPair(temp[0], Int32.Parse(temp[1])));
                    }
                }
                else
                {
                    if ((64 - count) < 0)
                    {
                        items.Add(new ItemPair(temp[0], 64));
                        int remain = Math.Abs(64 - count);
                        while (remain > 0)
                        {
                            if (remain > 64)
                            {
                                items.Add(new ItemPair(temp[0], 64));
                                remain -= 64;
                            }
                            else
                            {
                                items.Add(new ItemPair(temp[0], remain));
                                remain -= 64;
                            }
                        }
                    }
                    else
                    {
                        items.Add(new ItemPair(temp[0], Int32.Parse(temp[1])));
                    }
                    //items.Add(new ItemPair(temp[0], Int32.Parse(temp[1])));
                }
                StreamWriter sw = new StreamWriter(fs);
                sw.WriteLine("");
            }


            //Remap Items to the opposing item
            for (int i = 0; i < items.Count; i++)
            {
                items[i].name = mappings.facotrio[items[i].name];
            }
            return items;
        }

        /// MINECRAFT
        /// Reading and Parsing for minecraft 
        /// MINECRAFT

        public static List<ItemPair> parseMinecraft(Settings settings, DualDictionary<String, String> mappings, Dictionary<String, double> ratios)
        {
            List<ItemPair> items = new List<ItemPair>();
            String fullPath = Path.Combine(settings.getMcPath(), "toFactorio.dat");
            while (true)
            {
                try
                {
                    using (FileStream Fs = new FileStream(fullPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None, 100))
                    {
                        break;
                    }
                }
                catch (IOException)
                {
                    Thread.Sleep(100);
                }
            }
            FileStream fs = new FileStream(fullPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
            StreamReader sr = new StreamReader(fs, Encoding.Default);
            while (!sr.EndOfStream)
            {
                string proc = sr.ReadLine();
                string[] temp = proc.Split('~');
                int count = 0;
                if (ratios.Count > 0)
                {
                    double readNum = Double.Parse(temp[1]) * ratios[temp[0]]; ;
                    count = (int)Math.Round(readNum, MidpointRounding.AwayFromZero);
                }
                else
                {
                    count = (int)Double.Parse(temp[1]);
                }
                items.Add(new ItemPair(temp[0], count));
            }
            sr.Close();
            File.WriteAllText(fullPath, string.Empty);

            //Remap Items to the opposing item
            for (int i = 0; i < items.Count; i++)
            {
                items[i].name = mappings.minecraft[items[i].name];
            }
            return items;
        }

        public static void sendToMinecraft(List<ItemPair> items, Settings settings)
        {
            String fullPath = Path.Combine(settings.getMcPath(), "fromFactorio.dat");

            while (true)
            {
                try
                {
                    using (FileStream Fs = new FileStream(fullPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None, 100))
                    {
                        break;
                    }
                }
                catch (IOException)
                {
                    Thread.Sleep(100);
                }
            }
            StreamWriter sw = new StreamWriter(fullPath, true);
            for (int i = 0; i < items.Count; i++)
            {
                String itemToSend = items[i].name + "~" + items[i].count;
                sw.WriteLine(itemToSend);
            }
            sw.Close();
        }



        /// 
        /// The Pair Contains function used for parsing
        /// 
        public static int pairContains(List<ItemPair> list, string itemName)
        {
            for (int i = 0; i < list.Count(); i++)
            {
                if (list[i].name.Equals(itemName))
                {
                    return i;
                }
            }
            return -1;
        }
    }
}



        /// <summary>
        /// Application entry point. Initializes or prompts for settings, loads item mappings and ratio tables,
        /// opens an RCON connection to the Factorio server, then enters the main transfer loop that:
        /// - parses outgoing items from Factorio,
        /// - parses outgoing items from Minecraft,
        /// - sends Minecraft items to Factorio via RCON,
        /// - sends Factorio items to Minecraft via file writes.
        /// Errors during the loop are logged and the loop continues.
        /// </summary>
        /// <param name="args">Command-line arguments passed to the application.</param>

        /// <summary>
        /// Sends a list of items to a Factorio server using an RCON connection.
        /// Large item counts are split into chunks (100 per remote.call) and sent as /silent-command remote.call("receiveItems","inputItems", ...).
        /// </summary>
        /// <param name="items">List of ItemPair to send. Counts may be modified as chunks are sent.</param>
        /// <param name="rcon">An established RCON connection used to send commands to Factorio.</param>
        /// <remarks>
        /// This method is asynchronous and performs one or more RCON commands per item to transfer the requested quantity.
        /// </remarks>

        /// <summary>
        /// Parses items produced by Factorio for transfer to Minecraft.
        /// Reads the file "script-output\toMC.dat" in the configured Factorio path. Each line is expected as "itemName:count".
        /// Applies configured conversion ratios (if any), rounds counts, splits large counts into stack-sized ItemPair entries (max stack size 64),
        /// and remaps Factorio item names to Minecraft item names using the provided mappings.
        /// </summary>
        /// <param name="settings">Application settings containing the Factorio path.</param>
        /// <param name="mappings">DualDictionary mapping Factorio names to Minecraft names (uses mappings.facotrio lookup).</param>
        /// <param name="ratios">Optional per-item conversion ratios applied to counts.</param>
        /// <returns>A list of ItemPair objects ready to be sent to Minecraft (names already remapped).</returns>

        /// <summary>
        /// Parses items produced by Minecraft for transfer to Factorio.
        /// Reads the file "toFactorio.dat" in the configured Minecraft path. Each line is expected as "itemName~count".
        /// Waits for exclusive access to the file to avoid conflicts, applies conversion ratios (if provided),
        /// clears the source file after reading, and remaps Minecraft item names to Factorio names using the provided mappings.
        /// </summary>
        /// <param name="settings">Application settings containing the Minecraft path.</param>
        /// <param name="mappings">DualDictionary mapping Minecraft names to Factorio names (uses mappings.minecraft lookup).</param>
        /// <param name="ratios">Optional per-item conversion ratios applied to counts.</param>
        /// <returns>A list of ItemPair objects ready to be sent to Factorio (names already remapped).</returns>

        /// <summary>
        /// Writes a list of items produced by Factorio to the Minecraft input file.
        /// Waits until exclusive access to the destination file ("fromFactorio.dat" in the Minecraft path) is available,
        /// then appends each item as "itemName~count" on its own line.
        /// </summary>
        /// <param name="items">List of ItemPair to write to Minecraft.</param>
        /// <param name="settings">Application settings containing the Minecraft path.</param>
        /// <remarks>
        /// The method attempts exclusive access in a loop and sleeps briefly on IOException until the file can be opened.
        /// </remarks>

        /// <summary>
        /// Searches a list of ItemPair for an item with the specified name.
        /// </summary>
        /// <param name="list">List of ItemPair to search.</param>
        /// <param name="itemName">Name of the item to find.</param>
        /// <returns>The zero-based index of the matching ItemPair if found; otherwise -1.</returns>
