-- lua.exe script.lua

--io.write("Waiting for debug hook...")
--local str = io.read()

--package.cpath = "..\\?.dll"
require "Robot"
require "ScriptRobot.StateScripts"

---------------------------------------------------------------------
g_UpdateTime =
{
	preTime = 0,
	curTime = 0,
	totalTime = 0
}

function UpdateTimeAdvance(robot, mostMS)
	g_UpdateTime.curTime = Wolves.GetCurTime()
	local dtTime = g_UpdateTime.curTime - g_UpdateTime.preTime
	g_UpdateTime.preTime = g_UpdateTime.curTime
	
	if dtTime < mostMS then
		Wolves.Sleep(mostMS - dtTime)
	end
	
	g_UpdateTime.totalTime = g_UpdateTime.totalTime + dtTime
	
	return dtTime
end

---------------------------------------------------------------------
function SleepWithSnapshot(robot, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		robot:Snapshot()
		
		Wolves.Sleep(30)
		timePassed = timePassed + 30
	end
end

---------------------------------------------------------------------
function IsSubSceneMatched_InTime(robot, subScene, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		local rcOuts = robot:IsSubSceneMatched(subScene)
		if (rcOuts:Size() ~= 0) then
			return true, rcOuts;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

function IsAnySubSceneMatched_InTime(robot, subScenes, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		local rcOuts = robot:IsAnySubSceneMatched(subScenes)
		if (rcOuts:Size() ~= 0) then
			return true, rcOuts;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

function IsSubSceneMatchedInRect_InTime(robot, subScene, rect, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		local rcOuts = robot:IsSubSceneMatchedInRect(subScene)
		if (rcOuts:Size() ~= 0) then
			return true, rcOuts;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

function IsPixelMatched_InTime(robot, posStart, offSetX, offSetY, pixelCount, rgb, rgbT, msMaxTime)
	local timePassed = 0
	if msMaxTime < 30 then
		msMaxTime = 30
	end
	
	while timePassed < msMaxTime do
		if robot:IsPixelMatched(posStart, offSetX, offSetY, pixelCount, rgb, rgbT) then
			return true;
		else
			SleepWithSnapshot(robot, 30)
			timePassed = timePassed + 30
		end
	end
	
	return false
end

---------------------------------------------------------------------
--local printed = false
function RobotRun(robot, msDelta)

	local gs = robot:TakeSnapshot()
	--if gs ~= nil and not printed then
		--print("Save image...")
		--gs:SaveToFile("E:/1.png")
		--printed = true
		
		--gs:ShowDebugWindow("gs")
		--GameScene.s_WaitKey(1000)
	--end

	StateManager:Update(robot, msDelta)
	
end

---------------------------------------------------------------------
-- 这些Log函数只在lua里面使用
-- 因为是在线程里面调用，需要使用SendMessageToMainThread将日志输出到Log窗口
function LogDebug(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Debug"
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogDebug(content)
end

function LogInfo(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Info "
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogInfo(content)
end

function LogWarn(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Warn "
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)
	
	-- to log to file
	Wolves.LogWarn(content)
end

function LogError(content)
	local t = Wolves.SharedManager.NewSharedTable()
	t.type = "Log"
	t.level = "Error"
	t.data = content
	Wolves.SharedManager.SendMessageToMainThread(t)

	-- to log to file
	Wolves.LogError(content)
end

---------------------------------------------------------------------
function main()

	local robot = Wolves.GetRobot()
	LogInfo("Wolves.GetRobot()")


	g_UpdateTime.preTime = Wolves.GetCurTime()
	g_UpdateTime.curTime = g_UpdateTime.preTime
	
	StateManager:ChangeState(robot, StateManager.stateUnknown)
	LogInfo("StateManager:ChangeState to stateUnknown")
	
	local bRun = true
	while bRun do
	
		local dtTime = UpdateTimeAdvance(robot, 50)

		RobotRun(robot, dtTime)

		local st = Wolves.SharedManager.FetchCurThreadMessage()
		if st ~= nil and st.type == "Quit" then
			LogInfo("Received Quit msg...")
			bRun = false
		end
	end
	

end

main()

--[[
函数说明： 时间单位都是毫秒。

Wolves
{
	bool Initialize(key)	-- argv 1
	Finalize()
	GetRobot()	-- Robot是单例，多线程之间共享

	Sleep(int msTime)						-- [线程安全]
	int GetCurTime()						-- [线程安全]
	LogDebug(string)						-- [线程安全]
	LogInfo(string)							-- [线程安全]
	LogWarn(string)							-- [线程安全]
	LogError(string)						-- [线程安全]
	LogFatal(string)						-- [线程安全]

	-- SharedManager 函数都是线程安全的
	SharedManager
	{
		sharedTable NewSharedTable()
		bool ShareSharedTable(sharedTable, name)
		sharedTable AcquireSharedTable(name)
		DumpSharedTable(sharedTable, codeFormat)

		bool CreateThread(name)
		bool IsThreadValid(name)
		bool PauseThread(name)
		bool ResumeThread(name)
		bool AbortThread(name)
		bool SendMessageToThread(name, sharedTable)
		sharedTable FetchCurThreadMessage()
		bool SendMessageToMainThread(sharedTable)
	}
}

-- Robot函数(注意： 只有标记为[线程安全]的函数才能在所有线程里面使用)
{
	-- 这些函数需要在同一个线程里面使用
	--[
		GameScene* TakeSnapshot()
		GameScene* GetCurGameScene()

		SRectVector IsSubSceneMatched(subSceneName)
		SRectVector IsAnySubSceneMatched(StringVector subSceneNames)
		SRectVector IsSubSceneMatchedInRect(subSceneName, rect)
		bool IsPixelMatched(SSize posStart, int offSetX, int offSetY, int pixelCount, SRGB rgb, SRGB rgbT)
		bool IsGrayRect(SRect)
	--]


	bool WindowIsValid()					-- [线程安全]
	WindowShowHide(b)						-- [线程安全] true for show
	WindowSetPosition(x, y)					-- [线程安全]
	WindowMinimize(b)						-- [线程安全] true for Minimize, false for Restore
	SSize WindowGetDeskTopSize()			-- [线程安全]

	-- 后台按键操作，x, y是窗口客户区坐标。Dx游戏要前台方式。
	InputClick(x, y, bChildWnd)				-- [线程安全]
	InputHoldDown(x, y, bChildWnd)			-- [线程安全]
	InputHoldMove(x, y, bChildWnd)			-- [线程安全]
	InputHoldRelease(x, y, bChildWnd)		-- [线程安全]

}

--]]
