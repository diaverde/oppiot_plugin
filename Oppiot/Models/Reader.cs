using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Collections;
using System.Resources;
using System.Reflection;
using ReaderB;
using System.IO.Ports;
using System.IO;
using Newtonsoft.Json;

namespace Oppiot.Models
{
    public interface IOppiotReaderService
    {
        string OpenPort();
        string ClosePort();
        string GetInfo();
        string Inventory();
        bool TagWrite(string dataToWrite);

    }
    public class OppiotReader : IOppiotReaderService
    {
        private byte fComAdr = 0xff;    //Dirección actual
        private int ferrorcode;
        private byte fBaud;
        private double fdminfre;
        private double fdmaxfre;
        private byte Maskadr;
        private byte MaskLen;
        private byte MaskFlag;
        private int fCmdRet = 30;       // Valor de retorno esperado de las instrucciones
        private int fOpenCom;      // Número de puerto serial abierto
        //private bool fIsInventoryScan;
        private byte[] fPassWord=new byte[4];
        private string fInventory_EPC_List;
        private int frmcomportindex;
        
        public bool comOpen = false;
        public List<EPCInfo> EPCList = new List<EPCInfo>();

        
        // Método para abrir puerto serial
        public string OpenPort()
        {
            int port = 0;
            int openresult = 30;            
            int baudRate = 5;       // Opción 5: 57600 bps

            try {
                fBaud = Convert.ToByte(baudRate);
                openresult = StaticClassReaderB.AutoOpenComPort(ref port, ref fComAdr, fBaud, ref frmcomportindex);
                fOpenCom = frmcomportindex;
                if (openresult == 0 ) {
                    comOpen = true;
                    if ((fCmdRet==0x35) | (fCmdRet==0x30)) {
                        //Console.WriteLine("Error: puerto ocupado o inaccesible");                        
                        StaticClassReaderB.CloseSpecComPort(frmcomportindex);
                        comOpen = false;
                        return("Error: puerto ocupado o inaccesible");
                    }
                }
            } catch (Exception e) {
                //Console.WriteLine("Error abriendo puerto.");
                //Console.WriteLine(e);
                return("Error abriendo puerto - " + e);
            }

            if ((fOpenCom != -1) & (openresult != 0X35) & (openresult != 0X30)) {
                //Console.WriteLine("Puerto abierto: COM" + Convert.ToString(fOpenCom));                
                comOpen = true;
                return("Puerto abierto: COM" + Convert.ToString(fOpenCom));
            }
            if ((fOpenCom == -1) && (openresult == 0x30)) {
                //Console.WriteLine("Error de comunicación serial");
                return("Error de comunicación serial");
            }
            return("Error de comunicación serial");
        }

        // Método para cerrar puerto serial
        public string ClosePort()
        {
            int port;
            try {
                port = Convert.ToInt32(fOpenCom);
                fCmdRet = StaticClassReaderB.CloseSpecComPort(port);
                if (fCmdRet == 0) {
                    fOpenCom = 0;
                    //Console.WriteLine("Cerrando puerto COM" + port);
                    return("Cerrando puerto COM" + port);
                } else {
                    //Console.WriteLine("Error de comunicación serial");
                    return("Error de comunicación serial");
                }
            } catch {
                Console.WriteLine("Error cerrando puerto. ¿Estaba abierto?");
                return("Error cerrando puerto. ¿Estaba abierto?");
            } finally {
                comOpen = false;
            }
        }

        // Método para obtener información del lector
        public string GetInfo()
        {
            byte[] TrType = new byte[2];
            byte[] VersionInfo = new byte[2];
            byte ReaderType = 0;
            byte ScanTime = 0;
            byte dmaxfre = 0;
            byte dminfre = 0;
            byte powerdBm = 0;
            byte FreBand = 0;

            fCmdRet = StaticClassReaderB.GetReaderInformation(ref fComAdr, VersionInfo, ref ReaderType, TrType, ref dmaxfre, ref dminfre, ref powerdBm, ref ScanTime, frmcomportindex);
            if (fCmdRet == 0) {
                ReaderInfo reader = new ReaderInfo();
                string versionData = Convert.ToString(VersionInfo[0], 10).PadLeft(2, '0') + "." + Convert.ToString(VersionInfo[1], 10).PadLeft(2, '0');
                Console.WriteLine("Versión de firmware: " + versionData);
                Console.WriteLine("Potencia: " + Convert.ToString(powerdBm, 10).PadLeft(2, '0') + " dBm");
                Console.WriteLine("Dirección: " + Convert.ToString(fComAdr, 16).PadLeft(2, '0'));
                Console.WriteLine("Tiempo de escaneo: " + Convert.ToString(ScanTime, 10).PadLeft(2, '0') + "*100ms");
                reader.FirmwareVersion = versionData;
                reader.Power = Convert.ToString(powerdBm, 10).PadLeft(2, '0') + " dBm";
                reader.Address = Convert.ToString(fComAdr, 16).PadLeft(2, '0');
                reader.ScanTime = Convert.ToString(ScanTime, 10).PadLeft(2, '0') + "*100ms";

                FreBand= Convert.ToByte(((dmaxfre & 0xc0)>> 4)|(dminfre >> 6));
                switch (FreBand) {
                    case 0:
                        Console.WriteLine("Banda de frecuencia: Usuario");
                        reader.FrequencyBand = "User";
                        fdminfre = 902.6 + (dminfre & 0x3F) * 0.4;
                        fdmaxfre = 902.6 + (dmaxfre & 0x3F) * 0.4;
                        break;
                    case 1:
                        Console.WriteLine("Banda de frecuencia: China");
                        reader.FrequencyBand = "China";
                        fdminfre = 920.125 + (dminfre & 0x3F) * 0.25;
                        fdmaxfre = 920.125 + (dmaxfre & 0x3F) * 0.25;
                        break;
                    case 2:
                        Console.WriteLine("Banda de frecuencia: Imperio");
                        reader.FrequencyBand = "EEUU";
                        fdminfre = 902.75 + (dminfre & 0x3F) * 0.5;
                        fdmaxfre = 902.75 + (dmaxfre & 0x3F) * 0.5;
                        break;
                    case 3:
                        Console.WriteLine("Banda de frecuencia: Corea");
                        reader.FrequencyBand = "Corea";
                        fdminfre = 917.1 + (dminfre & 0x3F) * 0.2;
                        fdmaxfre = 917.1 + (dmaxfre & 0x3F) * 0.2;
                        break;
                    case 4:
                        Console.WriteLine("Banda de frecuencia: Europa");
                        reader.FrequencyBand = "UE";
                        fdminfre = 865.1 + (dminfre & 0x3F) * 0.2;
                        fdmaxfre = 865.1 + (dmaxfre & 0x3F) * 0.2;
                        break;
                }
                Console.WriteLine("Frecuencia mínima: " + Convert.ToString(fdminfre) + " MHz");
                Console.WriteLine("Frecuencia máxima: " + Convert.ToString(fdmaxfre) + " MHz");
                reader.MinFrequency = Convert.ToString(fdminfre) + " MHz";
                reader.MaxFrequency = Convert.ToString(fdmaxfre) + " MHz";

                if (ReaderType == 0x08) {
                    reader.Reader = "UHFReader09";
                    Console.WriteLine("Lector: UHFReader09");
                }
                // El cuarto bit inferior del segundo octeto representa el protocolo “ISO/IEC 15693”
                if ((TrType[0] & 0x02) == 0x02) {
                    reader.Protocols = "ISO180006B, EPCC1G2";
                    Console.WriteLine("Protocolos: ISO180006B, EPCC1G2");
                }
                return JsonConvert.SerializeObject(reader, Formatting.Indented);
            } else {
                Console.WriteLine("No se pudo capturar la información");
                return "No se pudo capturar la información";
            }
        }

        // Método para obtener inventario
        public string Inventory()
        {
            int i;
            int CardNum = 0;
            int Totallen = 0;
            int EPClen, m;
            byte[] EPC = new byte[5000];
            int CardIndex;
            string temps;
            string s, sEPC;
            bool isonlistview;

            //fIsInventoryScan = true;
            byte AdrTID = 0;
            byte LenTID = 0;
            byte TIDFlag = 0;

            EPCInfo aListItem = new EPCInfo();
            fCmdRet = StaticClassReaderB.Inventory_G2(ref fComAdr, AdrTID, LenTID, TIDFlag, EPC, ref Totallen, ref CardNum, frmcomportindex);
            Console.WriteLine("Return: " + fCmdRet);
            if ((fCmdRet == 1) | (fCmdRet == 2) | (fCmdRet == 3) | (fCmdRet == 4) | (fCmdRet == 0xFB)) {
                byte[] daw = new byte[Totallen];
                Array.Copy(EPC, daw, Totallen);
                temps = ByteArrayToHexString(daw);
                Console.WriteLine("Temps: " + temps);
                fInventory_EPC_List = temps;
                m = 0;

                // Si el conteo de encontrados es cero, terminar
                if (CardNum == 0) {
                    //fIsInventoryScan = false;
                    Console.WriteLine("Nada");
                    return "Error: no se encontró tag";
                }
                for (CardIndex = 0; CardIndex<CardNum; CardIndex++) {
                    EPClen = daw[m];
                    sEPC = temps.Substring(m*2+2, EPClen*2);
                    Console.WriteLine("sEPC: " + sEPC);
                    m = m + EPClen + 1;
                    if (sEPC.Length != EPClen*2) {
                        return "Error en lectura de tag";
                    }
                    isonlistview = false;
                    // Revisar si está en el listado actual
                    for (i=0; i< EPCList.Count;i++) {
                        if (sEPC == EPCList[i].ID) {
                            aListItem = EPCList[i];
                            ChangeSubItem(aListItem, 1, sEPC);
                            isonlistview=true;
                        }
                    }
                    if (!isonlistview) {
                        aListItem.Number = EPCList.Count + 1;
                        s = sEPC;
                        ChangeSubItem(aListItem, 1, s);
                        s = (sEPC.Length / 2).ToString().PadLeft(2, '0');
                        ChangeSubItem(aListItem, 2, s);
                        EPCList.Add(aListItem);
                    }
                }
                return aListItem.ID;
            } else {
                return "Error en lectura de tag";
            }
            //fIsInventoryScan = false;
        }

        // Método para convertir bytes a cadena hexadecimal
        private string ByteArrayToHexString(byte[] data)
        {
            StringBuilder sb = new StringBuilder(data.Length * 3);
            foreach (byte b in data)
                sb.Append(Convert.ToString(b, 16).PadLeft(2, '0'));
            return sb.ToString().ToUpper();

        }

        // Método para convertir de hexadecimal a bytes
        private byte[] HexStringToByteArray(string s)
        {
            s = s.Replace(" ", "");
            byte[] buffer = new byte[s.Length / 2];
            for (int i = 0; i < s.Length; i += 2)
                buffer[i / 2] = (byte)Convert.ToByte(s.Substring(i, 2), 16);
            return buffer;
        }

        // Método para procesar nuevos EPC encontrados
        public void ChangeSubItem(EPCInfo ListItem, int subItemIndex, string ItemText)
        {
            if (subItemIndex == 1) {
                if (ItemText=="") {
                    ListItem.ID = ItemText;
                    ListItem.ItemsCount += 1;
                } else {
                    if (ListItem.ID != ItemText) {
                    ListItem.ID = ItemText;
                    ListItem.ItemsCount = 1;
                    } else {
                        ListItem.ItemsCount += 1;
                        if ( ListItem.ItemsCount > 9999) {
                            ListItem.ItemsCount = 1;
                        }
                    }
                }

            }
            if (subItemIndex == 2) {
                if (ListItem.Length != ItemText) {
                    ListItem.Length = ItemText;
                }
            }
        }

        // Método para escribir Tag
        public bool TagWrite(string dataToWrite)
        {
            byte WordPtr, ENum;
            byte Num = 0;
            byte Mem = 0;
            byte WNum = 0;
            byte EPClength = 0;
            byte Writedatalen = 0;
            int  WrittenDataNum = 0;
            string s2, str;
            byte[] CardData = new byte[320];
            byte[] writedata = new byte[230];

            // No usar máscaras
            MaskFlag = 0;
            Maskadr = Convert.ToByte("00", 16);
            MaskLen = Convert.ToByte("00", 16);

            if (EPCList.Count == 0) {
                Console.WriteLine("No se han leído tags. Debe encontrar uno primero.");
                return false;
            }
            // Tomar el EPC más reciente
            str = EPCList[EPCList.Count-1].ID;
            if (str == "") {
                Console.WriteLine("Tag sin EPC asociado.");
                return false;
            }
            ENum = Convert.ToByte(str.Length/4);
            EPClength = Convert.ToByte(ENum*2);
            byte[] EPC = new byte[ENum];
            EPC = HexStringToByteArray(str);
            
            // 0: reservada, 1: EPC, 2: TID, 3: Usuario
            Mem = 1;
            // Inicio de lectura/escritura (word)
            string tagAddress = "02";
            WordPtr = Convert.ToByte(tagAddress, 16);
            // Longitud de dato a leer (word)
            string dataLength = "6";
            Num = Convert.ToByte(dataLength);
            // Código de acceso
            string accessCode = "00000000";
            fPassWord = HexStringToByteArray(accessCode);
            // Dato a escribir
            s2 = dataToWrite;
            if (s2.Length % 4 != 0) {
                Console.WriteLine("Dato debe tener 4*N caracteres");
                return false;
            }
            WNum = Convert.ToByte(s2.Length/4);
            byte[] Writedata = new byte[WNum*2];
            Writedata = HexStringToByteArray(s2);
            Writedatalen = Convert.ToByte(WNum*2);
            fCmdRet = StaticClassReaderB.WriteCard_G2(ref fComAdr, EPC, Mem, WordPtr, Writedatalen, Writedata, fPassWord,Maskadr,MaskLen,MaskFlag, WrittenDataNum, EPClength, ref ferrorcode, frmcomportindex);
            Console.WriteLine("Escribiendo dato "+ fCmdRet + " " + ferrorcode);
            if (fCmdRet == 0) {
                Console.WriteLine(DateTime.Now.ToLongTimeString() +  ": Escritura exitosa");
                return true;
            } else {
                Console.WriteLine("Escritura NO exitosa");
                return false;
            }
        }
 
    }

    public class ReaderInfo
    {
        public string FirmwareVersion { get; set; }
        public string Power { get; set; }
        public string Address { get; set; }
        public string ScanTime { get; set; }
        public string FrequencyBand { get; set; }
        public string MinFrequency { get; set; }
        public string MaxFrequency { get; set; }
        public string Reader { get; set; }
        public string Protocols { get; set; }
    }

    public class EPCInfo
    {
        public int Number { get; set; }
        public string ID { get; set; }
        public string Length { get; set; }
        public int ItemsCount { get; set; }
    }
}