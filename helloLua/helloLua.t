-- 状态机框架

Unit = {
	State = {}, -- 状态
    Param = {}, -- 参数
}

Unit.State.Name = ""
Unit.State.PackageName = "com.sy.ydcs.samsung"   -- APP的名称


-- [状态机函数]
function ProcessState(processState, processStateTable, processStateParam) 
    TestGame()  --启动游戏检测机制
	if  processState[processStateTable] ~= nil then 
        
		return processState[processStateTable](processStateParam) ;   -- Task 全部放在 table 中
    end
    return "Error"
end

-- 主窗口启动
function floatwinrun()
    require("XM")
    Unit.State.Name = "Test"  --初始状态
    
    while true do
		Unit.State.Name = ProcessState(Unit.State , Unit.State.Name , Unit.Param[Unit.State.Name])
        XM.Print("当前状态"..Unit.State.Name)
        sleep(1000) --休眠一秒
    end
end 



-- 测试任务
Unit.Param.Test = {
	account = editgettext("text1")
    ,id = 1
}


-- 测试状态机
function Unit.State.Test(list)
    XM.Print(list.id)
		list.id = list.id + 1
        sleep(100)
		XM.Print(list.id)
        if list.id >= 30 then
			return "Task"
        end
    return "Test"
end



-- 任务状态机
Unit.Param.Task = {
}

function Unit.State.Task(list)
    XM.Print("进入任务状态")
    return "Task"
end


-- 启动游戏状态
function TestGame()
    if XM.Timer("TestGameTiner") then
		local name = gettopapppackagenameex()
        if Unit.State.PackageName ~= name then
			sysstartapp(Unit.State.PackageName)
            sleep(3000)
        end
    end
end
