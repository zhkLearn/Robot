-- Common

---------------------------------------------------------------------
EGenericEvent =
{
	eGE_None            = 0,
	eGE_UserPause		= 1,
	eGE_UserUnPause		= 2,
	eGE_UserStop		= 3,
	eGE_UserQuit		= 4,
	eGE_EmuReady		= 5,
	eGE_EmuStarting		= 6,
	eGE_AppRestarting	= 7,
	eGE_Abnormal		= 8,
	eGE_Count			= 9,
}

function ShouldYield(event)
	return (event == EGenericEvent.eGE_UserPause or event == EGenericEvent.eGE_EmuStarting or event == EGenericEvent.eGE_AppRestarting);
end

function ShouldResume(event)
	return (event == EGenericEvent.eGE_UserUnPause or event == EGenericEvent.eGE_EmuReady);
end

function ShouldQuit(event)
	return event == EGenericEvent.eGE_UserQuit;
end
	
---------------------------------------------------------------------
g_currentEvent = EGenericEvent.eGE_None
g_UpdateTime =
{
	preTime = 0,
	curTime = 0,
	totalTime = 0
}

function UpdateTimeAdvance(robot, mostMS)
	g_UpdateTime.curTime = robot:GetCurTime()
	local dtTime = g_UpdateTime.curTime - g_UpdateTime.preTime
	g_UpdateTime.preTime = g_UpdateTime.curTime
	
	if dtTime < mostMS then
		robot:Sleep(mostMS - dtTime)
	end
	
	g_UpdateTime.totalTime = g_UpdateTime.totalTime + dtTime
	
	return dtTime
end

---------------------------------------------------------------------
function SleepWithSnapshot(robot, msMaxTime)
	local count = (msMaxTime + 16) / 30
	
	for i = 1, count do
		g_currentEvent = robot:Update(30)
		
		if ShouldYield(g_currentEvent) then
			g_currentEvent = EGenericEvent.eGE_None
			coroutine.yield()
		end
	end
end

---------------------------------------------------------------------
function IsSubSceneMatched_InTime(robot, subScene, msMaxTime)
	local count = (msMaxTime + 16) / 30
	for i = 1, count do
		local rcOuts = robot:IsSubSceneMatched(subScene)
		if (rcOuts:Size() ~= 0) then
			return rcOuts;
		end

		g_currentEvent = robot:Update(30)
		
		if ShouldYield(g_currentEvent) then
			g_currentEvent = EGenericEvent.eGE_None
			coroutine.yield()
		end
	end
end

function IsAnySubSceneMatched_InTime(robot, subScenes, msMaxTime)
	local count = (msMaxTime + 16) / 30
	for i = 1, count do
		local rcOuts = robot:IsAnySubSceneMatched(subScenes)
		if (rcOuts:Size() ~= 0) then
			return rcOuts;
		end

		g_currentEvent = robot:Update(30)
		
		if ShouldYield(g_currentEvent) then
			g_currentEvent = EGenericEvent.eGE_None
			coroutine.yield()
		end
	end
end

function IsSubSceneMatchedInRect_InTime(robot, subScene, rect, msMaxTime)
	local count = (msMaxTime + 16) / 30
	for i = 1, count do
		local rcOuts = robot:IsSubSceneMatchedInRect(subScene, rect)
		if (rcOuts:Size() ~= 0) then
			return rcOuts;
		end

		g_currentEvent = robot:Update(30)
		
		if ShouldYield(g_currentEvent) then
			g_currentEvent = EGenericEvent.eGE_None
			coroutine.yield()
		end
	end
end

function IsPixelMatched_InTime(robot, posStart, offSetX, offSetY, pixelCount, rgb, rgbT, msMaxTime)
	local count = (msMaxTime + 16) / 30
	for i = 1, count do
		if robot:IsPixelMatched(posStart, offSetX, offSetY, pixelCount, rgb, rgbT) then
			return true;
		end

		g_currentEvent = robot:Update(30)
		
		if ShouldYield(g_currentEvent) then
			g_currentEvent = EGenericEvent.eGE_None
			coroutine.yield()
		end
	end
end
