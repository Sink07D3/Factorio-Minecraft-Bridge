using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using CoreRCON;
using Newtonsoft.Json;

namespace Factorio_MC_Bridge
{
	class Program
	{
		const string RconExportCommand = @"/silent-command remote.call(""exportItems"",""pull"")";

		static void Main(string[] args)
		{
			Console.WriteLine("Starting Up!");
			Console.WriteLine("To change settings, enter 1, otherwise press any key other to continue.");
			string choice = Console.ReadLine();
			Settings settings = new Settings();
			string startupDoc = Path.Combine(Environment.CurrentDirectory, "settings.json");
			if (!File.Exists(startupDoc) || choice.Equals("1"))
			{
				FileStream fs = new FileStream(startupDoc, FileMode.OpenOrCreate, FileAccess.Write, FileShare.ReadWrite);
				StreamWriter sw = new StreamWriter(fs, Encoding.Default);
				Console.WriteLine("Please enter Minecraft Location (Root of the Directory): ");
				settings.setMcPath(Console.ReadLine());
				Console.WriteLine("Please enter Factorio Server Path (Root of the Directory — only used for legacy file export): ");
				settings.setFacotrioPath(Console.ReadLine());
				Console.WriteLine("Please enter the IP Address of the Factorio Server: ");
				settings.setIpAddress(Console.ReadLine());
				Console.WriteLine("Please enter RCON Port Number: ");
				settings.setPort(Int32.Parse(Console.ReadLine()));
				Console.WriteLine("Please enter RCON password: ");
				settings.setRconPass(Console.ReadLine());
				Console.WriteLine("Use legacy Factorio file export (script-output\\toMC.dat)? Enter 1 for yes, anything else for RCON pull: ");
				settings.setUseLegacyFactorioFileExport(Console.ReadLine() == "1");
				string output = JsonConvert.SerializeObject(settings);
				sw.WriteLine(output);
				sw.Close();
			}
			else
			{
				FileStream fs = new FileStream(startupDoc, FileMode.OpenOrCreate, FileAccess.Read, FileShare.ReadWrite);
				StreamReader sr = new StreamReader(fs, Encoding.Default);
				string input = "";
				while (!sr.EndOfStream) {
					input += sr.ReadLine();
				}
				sr.Close();
				settings = JsonConvert.DeserializeObject<Settings>(input) ?? new Settings();
			}

			DualDictionary<String, String> itemMappings = new DualDictionary<String, String>();
			Dictionary<String, double> minecraftRatios = new Dictionary<String, double>();
			Dictionary<String, double> factorioRatios = new Dictionary<String, double>();

			string itemMappingsPath = Path.Combine(Environment.CurrentDirectory, "item_mappings.txt");
			FileStream fileStream = new FileStream(itemMappingsPath, FileMode.OpenOrCreate, FileAccess.Read, FileShare.Read);
			StreamReader streamReader = new StreamReader(fileStream, Encoding.Default);

			while (!streamReader.EndOfStream) {
				String readString = streamReader.ReadLine();
				if (readString.Contains("#") || readString.Equals("") || readString.Equals("\n")) {
					continue;
				}
				String[] split = readString.Split('=');
				itemMappings.Add(split[0], split[1]);
				if (split.Length > 2) {
					String[] ratios = split[2].Split(':');
					minecraftRatios.Add(split[0], Double.Parse(ratios[0]));
					factorioRatios.Add(split[1], Double.Parse(ratios[1]));
				}
			}
			streamReader.Close();
			fileStream.Close();

			Console.WriteLine("Found settings. Beginning transfer.");
			if (settings.getUseLegacyFactorioFileExport()) {
				Console.WriteLine("Factorio export mode: legacy file (script-output\\toMC.dat).");
			} else {
				Console.WriteLine("Factorio export mode: RCON remote.call(exportItems, pull).");
			}

			RunAsync(settings, itemMappings, minecraftRatios, factorioRatios).GetAwaiter().GetResult();
		}

		static async Task RunAsync(
			Settings settings,
			DualDictionary<string, string> itemMappings,
			Dictionary<string, double> minecraftRatios,
			Dictionary<string, double> factorioRatios)
		{
			var rcon = new RCON(IPAddress.Parse(settings.getIPAddress()), (ushort)settings.getPort(), settings.getRconPass());
			// CoreRCON typically connects on first SendCommandAsync; if your build requires it, add await rcon.ConnectAsync() once here.

			while (true)
			{
				try
				{
					List<ItemPair> factorioItems = await ParseFactorioAsync(settings, rcon, itemMappings, factorioRatios);
					List<ItemPair> minecraftItems = parseMinecraft(settings, itemMappings, minecraftRatios);
					await SendToFactorioAsync(minecraftItems, rcon);
					sendToMinecraft(factorioItems, settings);
					Thread.Sleep(1000);
				}
				catch (Exception e) {
					Console.WriteLine("Something went wrong. Moving past error.");
					Console.WriteLine(e.Message);
					continue;
				}
			}
		}

		static async Task<List<ItemPair>> ParseFactorioAsync(
			Settings settings,
			RCON rcon,
			DualDictionary<String, String> mappings,
			Dictionary<String, double> ratios)
		{
			if (settings.getUseLegacyFactorioFileExport())
			{
				string fullPath = Path.Combine(settings.getFactorioPath(), "script-output\\toMC.dat");
				if (!File.Exists(fullPath))
				{
					return new List<ItemPair>();
				}
				string[] lines = File.ReadAllLines(fullPath);
				File.WriteAllText(fullPath, string.Empty);
				return ParseFactorioExportLines(lines, mappings, ratios);
			}

			string raw = await rcon.SendCommandAsync(RconExportCommand);
			string normalized = NormalizeFactorioSilentCommandReturn(raw);
			if (string.IsNullOrEmpty(normalized))
			{
				return new List<ItemPair>();
			}
			string[] splitLines = normalized.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
			return ParseFactorioExportLines(splitLines, mappings, ratios);
		}

		/// <summary>
		/// Factorio may return a Lua string as a JSON-encoded string (quoted) or plain text; normalize to raw export lines.
		/// </summary>
		static string NormalizeFactorioSilentCommandReturn(string raw)
		{
			if (string.IsNullOrWhiteSpace(raw))
			{
				return string.Empty;
			}
			string t = raw.Trim();
			if (t.Length >= 2 && t[0] == '"')
			{
				try
				{
					return JsonConvert.DeserializeObject<string>(t) ?? string.Empty;
				}
				catch
				{
					// ignore; use trimmed raw
				}
			}
			return t;
		}

		static List<ItemPair> ParseFactorioExportLines(
			IEnumerable<string> lines,
			DualDictionary<String, String> mappings,
			Dictionary<String, double> ratios)
		{
			List<ItemPair> items = new List<ItemPair>();
			foreach (string proc in lines)
			{
				if (string.IsNullOrWhiteSpace(proc))
				{
					continue;
				}
				int colon = proc.IndexOf(':');
				if (colon <= 0 || colon >= proc.Length - 1)
				{
					continue;
				}
				string nameF = proc.Substring(0, colon);
				string countStr = proc.Substring(colon + 1);
				string[] temp = new[] { nameF, countStr };

				int count = 0;
				if (ratios.Count > 0 && ratios.ContainsKey(temp[0])) {
					double readNum = Double.Parse(temp[1]) * ratios[temp[0]];
					count = (int)Math.Round(readNum, MidpointRounding.AwayFromZero);
				}
				else {
					count = (int)Double.Parse(temp[1]);
				}
				int containsTest = pairContains(items, temp[0]);

				if (containsTest != -1){
					if (items[containsTest].count < 64) {
						int remainder = 64 - items[containsTest].count;
						if (remainder > 0) {
							items[containsTest].count += remainder;
							count -= remainder;
						}
					}
					if ((64 - count) < 0) {
						items.Add(new ItemPair(temp[0], 64));
						int remain = Math.Abs(64 - count);
						while (remain > 0) {
							if (remain > 64) {
								items.Add(new ItemPair(temp[0], 64));
								remain -= 64;
							}
							else {
								items.Add(new ItemPair(temp[0], remain));
								remain -= 64;
							}
						}
					}
					else {
						items.Add(new ItemPair(temp[0], Int32.Parse(temp[1])));
					}
				}
				else
				{
					if ((64 - count) < 0) {
						items.Add(new ItemPair(temp[0], 64));
						int remain = Math.Abs(64 - count);
						while (remain > 0) {
							if (remain > 64) {
								items.Add(new ItemPair(temp[0], 64));
								remain -= 64;
							}
							else {
								items.Add(new ItemPair(temp[0], remain));
								remain -= 64;
							}
						}
					}
					else {
						items.Add(new ItemPair(temp[0], Int32.Parse(temp[1])));
					}
				}
			}

			for (int i = 0; i < items.Count; i++)
			{
				items[i].name = mappings.facotrio[items[i].name];
			}
			return items;
		}

		public static async Task SendToFactorioAsync(List<ItemPair> items, RCON rcon) {
			if (items.Count > 0) {
				for (int i = 0; i < items.Count; i++) {
					StringBuilder str = new StringBuilder();
					if (items[i].count > 100) {
						while (items[i].count > 100) {
							str.Append(@"/silent-command remote.call(""receiveItems"",""inputItems"",");
							str.Append(@"""");
							str.Append(items[i].name);
							str.Append(@""",");
							str.Append(100);
							str.Append(")");
							await rcon.SendCommandAsync(str.ToString());
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
					await rcon.SendCommandAsync(str.ToString());
					str.Clear();
				}
			}
		}

		public static List<ItemPair> parseMinecraft(Settings settings, DualDictionary<String,String> mappings, Dictionary<String, double> ratios)
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
				if (ratios.Count > 0) {
					double readNum = Double.Parse(temp[1]) * ratios[temp[0]]; ;
					count = (int)Math.Round(readNum, MidpointRounding.AwayFromZero);
				}
				else {
					count = (int)Double.Parse(temp[1]);
				}
				items.Add(new ItemPair(temp[0], count));
			}
			sr.Close();
			File.WriteAllText(fullPath, string.Empty);

			for (int i = 0; i < items.Count; i++) {
				items[i].name = mappings.minecraft[items[i].name];
			}
			return items;
		}

		public static void sendToMinecraft(List<ItemPair> items, Settings settings) {
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
			for (int i = 0; i < items.Count; i++) {
				String itemToSend = items[i].name + "~" + items[i].count;
				sw.WriteLine(itemToSend);
			}
			sw.Close();
		}

		public static int pairContains(List<ItemPair> list, string itemName) {
			for (int i = 0; i < list.Count(); i++) {
				if (list[i].name.Equals(itemName)) {
					return i;
				}
			}
			return -1;
		}
	}
}
