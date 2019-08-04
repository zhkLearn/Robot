-- lua.exe script.lua

--io.write("Waiting for debug hook...")
--local str = io.read()

--package.cpath = "..\\?.dll"
require "Robot"
require "ScriptRobot.Common"
require "ScriptRobot.StateScripts"

---------------------------------------------------------------------

function main()

	os.execute("CHCP 65001")

	print("Robot框架...")

	---[[
	for k, v in pairs(arg) do
		print("Argument:", k, v)
	end

	SetConsoleTitle("Robot:" .. arg[1])

	local robot = Robot()

	if robot:Initialize(arg[1]) then
		print("robot:Initialize()")
	else
		print("robot:Initialize() failed!")
		return
	end

	local coLogicMain = coroutine.create(
    function(r, dt)
		RobotRun(r, dt)
    end)

	g_UpdateTime.preTime = robot:GetCurTime()
	g_UpdateTime.curTime = g_UpdateTime.preTime
	
	while not ShouldQuit(g_currentEvent) do

		local dtTime = UpdateTimeAdvance(robot, 30)

		local coStatus = coroutine.status(coLogicMain)

		g_currentEvent = robot:Update(dtTime)
		
		if coStatus == "suspended" then
		
			if ShouldResume(g_currentEvent) then
				print("coroutine.resume")
				g_currentEvent = EGenericEvent.eGE_None
				coroutine.resume(coLogicMain, robot, dtTime)
			end
			
		elseif coStatus == "dead" then
		
			if ShouldResume(g_currentEvent) then

				print("coroutine.create")
				g_currentEvent = EGenericEvent.eGE_None
				coLogicMain = coroutine.create(
				function(r, dt)
					RobotRun(r, dt)
				end)
				
				coroutine.resume(coLogicMain, robot, dtTime)
			end
			
		end
		
	end

	robot:LogInfo("robot:Finalize()")
	robot:Finalize()
	--]]

end

main()

--[[
Robot函数：时间单位都是毫秒。

bool Initialize(string)
bool Update(int msTime)					-- 毫秒, 返回如果是false, 结束运行
Finalize()
ReportState(string)						-- utf8编码, 所有lua文件编码都要是utf8
UpdateStats(vectorStats)				-- 上报统计信息
bool WindowIsValid()
WindowShowHide(b)						-- true for show
WindowSetPosition(x, y)
WindowMinimize(b)						-- true for Minimize, false for Restore
SSize WindowGetDeskTopSize()
InputClick(x, y, b)						-- b: true for client area
InputHoldDown(x, y, b)					-- b: true for client area
InputHoldMove(x, y, b)					-- b: true for client area
InputHoldRelease(x, y, b)				-- b: true for client area
SRectVector IsSubSceneMatched(subSceneName)
SRectVector IsAnySubSceneMatched(vectorString subSceneNames)
SRectVector IsSubSceneMatchedInRect(subSceneName, rect)
bool IsPixelMatched(SSize posStart, int offSetX, int offSetY, int pixelCount, SRGB rgb, SRGB rgbT)
bool IsGrayRect(SRect)
Sleep(int msTime)						-- 毫秒
int GetCurTime()						-- 毫秒
LogDebug(string)
LogInfo(string)
LogWarn(string)
LogError(string)
LogFatal(string)
--]]










