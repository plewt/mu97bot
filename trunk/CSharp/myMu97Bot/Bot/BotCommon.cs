using System;
using System.Drawing;
using System.Windows.Forms;
using WindowScrape.Types;
using System.Threading;
using WindowsInput;

namespace DudEeer.myMu97Bot.Bot
{
    public enum CharacterClass { Elf, ME, DW, SM, DK, BK, MG }

    public static class BotCommonSettings
    {
        public static Point cMouseCcenter = new Point(512, 335); // mouse center position
        
        // for walking
        public static int cMouseDelta = 80; // mouse delta (when walking, to make one step in up/down/right/left direction)
        public static int cMouseCornerDelta = (int)(0.29 * 80.0); // mouse corner delta (when walking, to make one step in diagonal direction)

        public static Color cgtDefaultCurColor = Color.FromArgb(0x00FFFFFF); // default color of cursor in defined position
        public static Point cgtCursorColorPos = new Point(21, 17); // coords where to get cursor color to define cursor type

        // for party rebuff
        public static Point crPartyStart = new Point(1000, 20); // starting of party list
        public static int crPartyDeltaY = 35; // step between partymembers in list

        public static CharacterClass cCharClass = CharacterClass.BK; // character class
        public static string cMuHeader = "©WakeUp"; // Mu window header
        public static string cMuWindowClass = "MU"; // Mu window class
        public static string cMuPath = @"C:\MU"; // Path to mu executable
        public static string cMuExecutable = "main.exe"; // Mu executable name 
        public static string cMuLauncherHeader = "Losena MuOnline Launcher v0.1.0.6"; // Launcher window header
        public static string cMuLauncherPath = ""; // Path to launcher executable

        public static int cMainWndWidth = 1024; // Main window width
        public static int cMainWndHeight = 768; // Main window height

        // Key mapping
        public static VirtualKeyCode cMainSkillKey = VirtualKeyCode.VK_1;
        public static VirtualKeyCode cSecondarySkillKey = VirtualKeyCode.VK_2;
        public static VirtualKeyCode cTeleportKey = VirtualKeyCode.VK_5;
        public static VirtualKeyCode cManaShieldKey = VirtualKeyCode.VK_4;
        public static VirtualKeyCode cPowerBuffKey = VirtualKeyCode.VK_3;
        public static VirtualKeyCode cDefenceBuffKey = VirtualKeyCode.VK_2;
        public static VirtualKeyCode cHealBuffKey = VirtualKeyCode.VK_4;
        public static VirtualKeyCode cSummonBuffKey = VirtualKeyCode.VK_5;
        public static VirtualKeyCode cHealthBottleKey = VirtualKeyCode.VK_Q;
        public static VirtualKeyCode cManaBottleKey = VirtualKeyCode.VK_W;
        public static VirtualKeyCode cAlcoBottleKey = VirtualKeyCode.VK_E;
        public static VirtualKeyCode cAutoSkillKey = VirtualKeyCode.F10;
        public static string cLauncherPlay = "^p";
        public static VirtualKeyCode cLauncherToWindow = VirtualKeyCode.F12;
        public static VirtualKeyCode ActiveSkill = VirtualKeyCode.VK_1;
        public static HwndObject MuInstance { get { return HwndObject.GetWindowByTitle(cMuHeader); } }

        public static void SetResolution(int aWidth)
        {
            if (aWidth != cMainWndWidth)
            {
                double Multiplier = aWidth / 1024.0;
                cMainWndWidth = aWidth;
                cMainWndHeight = (int)(768 * Multiplier);

                cMouseCcenter.X = (int)(512 * Multiplier);
                cMouseCcenter.Y = (int)(335 * Multiplier);

                cMouseDelta = (int)(80 * Multiplier);
                cMouseCornerDelta = (int)(0.29 * cMouseDelta);
                cgtCursorColorPos.X = (int)(21 * Multiplier);
                cgtCursorColorPos.Y = (int)(17 * Multiplier);

                crPartyStart.X = (int)(1000 * Multiplier);
                crPartyStart.Y = (int)(20 * Multiplier);
                crPartyDeltaY = (int)(35 * Multiplier);
            }
        }
    }

    public static class BotCommon
    {
        public static void MouseMove(Point aP)
        {
            Cursor.Position = new Point(aP.X + BotCommonSettings.MuInstance.Location.X, aP.Y + BotCommonSettings.MuInstance.Location.Y);
        }
        public static void MouseMove(int aX, int aY)
        {
            Cursor.Position = new Point(aX + BotCommonSettings.MuInstance.Location.X, aY + BotCommonSettings.MuInstance.Location.Y);
        }
        public static Point MouseGetPos()
        {
            return new Point(Cursor.Position.X - BotCommonSettings.MuInstance.Location.X, Cursor.Position.Y - BotCommonSettings.MuInstance.Location.Y);
        }
        public static void CenterMouse()
        {
            MouseMove(BotCommonSettings.cMouseCcenter.X, BotCommonSettings.cMouseCcenter.Y);
        }
        public static void CenterMouse(int aDX, int aDY)
        {
            MouseMove(BotCommonSettings.cMouseCcenter.X + aDX, BotCommonSettings.cMouseCcenter.Y + aDY);
        }

        public static void DoMainClick()
        {
            InputSimulator.SimulateKeyDown(VirtualKeyCode.LBUTTON);
            Thread.Sleep(200);
            InputSimulator.SimulateKeyUp(VirtualKeyCode.LBUTTON);
        }
        public static void DoMainClick(int aDelay)
        {
            InputSimulator.SimulateKeyDown(VirtualKeyCode.LBUTTON);
            Thread.Sleep(aDelay);
            InputSimulator.SimulateKeyUp(VirtualKeyCode.LBUTTON);
        }
        public static void DoSecondaryClick()
        {
            InputSimulator.SimulateKeyDown(VirtualKeyCode.RBUTTON);
            Thread.Sleep(200);
            InputSimulator.SimulateKeyUp(VirtualKeyCode.RBUTTON);
        }

        public static void DoKeyPress(VirtualKeyCode aKey)
        {
            InputSimulator.SimulateKeyDown(aKey);
            Thread.Sleep(200);
            InputSimulator.SimulateKeyUp(aKey);
            Thread.Sleep(200);
        }

        public static void DoSkill(VirtualKeyCode aSkillKey)
        {
	        DoKeyPress(aSkillKey);
	        DoSecondaryClick();
	        DoKeyPress(BotCommonSettings.ActiveSkill);
        }
        
        public static void SwitchSkills()
        {
            if (BotCommonSettings.ActiveSkill == BotCommonSettings.cMainSkillKey)
            {
                BotCommonSettings.ActiveSkill = BotCommonSettings.cSecondarySkillKey;
                DoKeyPress(BotCommonSettings.cSecondarySkillKey);
            }
            else
            {
                BotCommonSettings.ActiveSkill = BotCommonSettings.cMainSkillKey;
                DoKeyPress(BotCommonSettings.cMainSkillKey);
            }
        }

        public static void DoManaShield()
        {
	        DoSkill(BotCommonSettings.cManaShieldKey);
        }
        public static void DoTeleport()
        {
            DoSkill(BotCommonSettings.cTeleportKey);
        }
        public static void DrinkHealthPoition()
        {
            DoSkill(BotCommonSettings.cHealthBottleKey);
        }
        public static void DrinkManaPoition()
        {
            DoSkill(BotCommonSettings.cManaBottleKey);
        }

        public static void DoBuff(VirtualKeyCode aKey, bool aSelf)
        {
	        Point OldMousePos = MouseGetPos();;
	        if (aSelf) CenterMouse();
            DoSkill(aKey);
	        if (aSelf) MouseMove(OldMousePos);
        }
        public static void DoHealBuff(bool aSelf)
        {
	        DoBuff(BotCommonSettings.cHealBuffKey, aSelf);
        }
        public static void DoPowerBuff(bool aSelf)
        {
	        DoBuff(BotCommonSettings.cPowerBuffKey, aSelf);
        }
        public static void DoDefenceBuff(bool aSelf)
        {
            DoBuff(BotCommonSettings.cDefenceBuffKey, aSelf);
        }

        public static void Rebuff(int aPartyCount)
        {
            if (aPartyCount == 0) 
            {
                DoPowerBuff(true);
                DoDefenceBuff(true);
            }
            else
            {
		        Point OldMousePos = MouseGetPos();
		        for (int aY = 0; aY < aPartyCount; aY++)
                {
			        MouseMove(BotCommonSettings.crPartyStart.X, BotCommonSettings.crPartyStart.Y + aY * BotCommonSettings.crPartyDeltaY);
			        DoPowerBuff(false);
                    DoDefenceBuff(false);
		        }
		        MouseMove(OldMousePos);
            }
        }

        public static void SetRequests(bool aStatus)
        {
		    if (!(aStatus))
            {
                DoKeyPress(VirtualKeyCode.RETURN);
			    InputSimulator.SimulateTextEntry("/re off");
                DoKeyPress(VirtualKeyCode.RETURN);
		    } else {
                DoKeyPress(VirtualKeyCode.RETURN);
                InputSimulator.SimulateTextEntry("/re on");
                DoKeyPress(VirtualKeyCode.RETURN);
            }
        }

        public static void TeleportTo(string aLocName)
        {
            DoKeyPress(VirtualKeyCode.RETURN);
            InputSimulator.SimulateTextEntry(String.Format("/move {0}", aLocName));
            DoKeyPress(VirtualKeyCode.RETURN);
        }

        public static void TakeSnapshot()
        {
            InputSimulator.SimulateKeyPress(VirtualKeyCode.SNAPSHOT);
        }

        // !!! NOT YET IMPLEMENTED !!!
        // Func Connect($aPassword, $aCharNumber, $aServerNumber = 1)
        // Func GetCursorColor($aX = 0, $aY = 0)
        // Func DeclineRequest()
        // Func GetWorldByLocation($aLocationName)
        // Func GoToCoordAStar($aToCoords, $aMapName, $aCanTeleport = 0, $aCenterMouse = True)
        // Func GoToCoord($aToCoords, $aCanTeleport = 0, $aCenterMouse = True)
        // Func DoMouseRoundMove($aStage = 0, $aRadius = 100, $aSleepTime = 2000)
    }
}
