using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Factorio_MC_Bridge {
	class Settings {
		public String mcPath = "";
		public String factorioPath = "";
		public String ipAddress = "";
		public int portNumber = 0;
		public String rconPass = "";
		/// <summary>
		/// When true, read Factorio exports from script-output\toMC.dat (legacy). When false (default), pull via RCON remote.call("exportItems","pull").
		/// </summary>
		public bool useLegacyFactorioFileExport = false;

		public Settings() {
		}

		public String getMcPath() {
			return mcPath;
		}

		public String getFactorioPath() {
			return factorioPath;
		}

		public String getIPAddress() {
			return ipAddress;
		}

		public int getPort() {
			return portNumber;
		}

		public String getRconPass() {
			return rconPass;
		}


		public void setMcPath(String s) {
			mcPath = s;
		}
		public void setFacotrioPath(String s) {
			factorioPath = s;
		}
		public void setIpAddress(String s) {
			ipAddress = s;
		}
		public void setPort(int x) {
			portNumber = x;
		}
		public void setRconPass(String s) {
			rconPass = s;
		}

		public bool getUseLegacyFactorioFileExport() {
			return useLegacyFactorioFileExport;
		}

		public void setUseLegacyFactorioFileExport(bool value) {
			useLegacyFactorioFileExport = value;
		}
	}
}
