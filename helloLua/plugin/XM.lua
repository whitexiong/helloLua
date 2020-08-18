XM = {}

XM_version = "XM_1.0.5"
function XM.KeepScreen(id)--截屏
    id = id or 0
    releasecapture(id)
    keepcapture(id)
    TimerCloseMsg()
end

function TimerCloseMsg()
    if TimerMsg(TimingMsg_XM["str"]) then
        XM.MsgClose()
    end
end


--分辨率缩放
XM_resolPower = 1	--分辨率系数
function XM.SetScale(mX,mY)	--设置分辨率比例
    local sList = XM.GetScreen()	--当前分辨率
    if mX > mY then	
        local a = mX
        mX = mY
        mY = a
    end
    if sList[1] > sList[2] then
        local a = sList[1]
        sList[1] = sList[2]
        sList[2] = a
    end
    XM_resolPower = sList[1]/mX
end





MyTableXM = {}
function XM.AddTable(tbl)
    MyTableXM = tbl
end

function XM.SetTableID(str)
    if MyTableXM[str] == nil  then
        XM.Print("表名"..tostring(str).."不存在")
    end
    MyTableXM.ID = str
end



function XM.Find(...)	
    local Arr = {}
    local Rnd ,Str,bool= 5,"",false
    if ... == nil then
        return false
    end
    Arr = {...}
    local iRet, sRet = pcall(function()
		for i = 1,#Arr do
			if type(Arr[i]) == "string" or type(Arr[i]) == "table" then
				Str = Arr[i]
			elseif type(Arr[i]) == "number" then
				Rnd = Arr[i]
			elseif type(Arr[i]) == "boolean" then
				bool = Arr[i]
			end
		end
		local colorList = GetTable(Str)
		if colorList ~= nil then
			if type(colorList[1]) == "table" then
				for i = 1, #colorList do 
					local x,y,value = CurrencyFindColor(colorList[i])
					if(value > -1) then
						if(bool == true) then
							RndTap(x, y, Rnd)
						end
						XMLogEx("XM.Find:"..colorList[i][1].."-"..x.."-"..y)
						XM_TimingColorArr = {}
						return true
					end
				end
				
			else
				local x,y,value = CurrencyFindColor(colorList)
				if(value > -1) then
					if(bool == true) then
						RndTap(x, y, Rnd)
					end
					XMLogEx("XM.Find:"..colorList[1].."-"..x.."-"..y)
					XM_TimingColorArr = {}
					return true
				end
			end
		else
			if type(Str) == "table" and #Str == 2 then
				XM.Print("XM.Find:色点名\"{"..Str[1].."-"..Str[2].."}\"不存在")
			elseif type(Str) == "string" then
				XM.Print("XM.Find:色点名\""..Str.."\"不存在")
			else
				XM.Print("XM.Find:以下色点名不存在")
				XM.Print(Str)
			end
		end
		return false
    end)
    if iRet == true then
        return sRet
    end
	XM.Print("XM.Find:调用出错")
    return false
end




function XM.OcrFont(Str)
    local colorList = GetTable(Str)
    if colorList ~= nil then
		local sim = 0.8
        if type(colorList[1]) == "table" then
			XM.Print("OcrFont:参数不能为table")
        else
			if colorList[2] <= 1 then
				sim = colorList[2]
				usedict(colorList[8])
				return ocr(colorList[3],colorList[4],colorList[5],colorList[6],colorList[7],sim)
			else
				usedict(colorList[7])
				return ocr(colorList[2],colorList[3],colorList[4],colorList[5],colorList[6],sim)
			end	
            
        end
	end
	return nil
end


function XM.FindDev(...)		--偏移点击
	local X,Y,Str = 0,0,Str
	local B = false
	if ... == nil then
        return false
    end
    Arr = {...}
	for i = 1,#Arr do
		if type(Arr[i]) == "string" or type(Arr[i]) == "table" then
			Str = Arr[i]
		elseif type(Arr[i]) == "number" then
			if B == false then
				X = Arr[i]
				B = true
			else
				Y = Arr[i]
			end
		end
	end
    local colorList = GetTable(Str)
    if colorList ~= nil then
        if type(colorList[1]) == "table" then
            for i = 1, #colorList do 
				local x,y,value = CurrencyFindColor(colorList[i])
				if(value ~= -1) then
					XMLogEx("XM.FindDev:"..colorList[i][1].."-"..x .. "-" .. y )
					RndTap(x+X,y+Y,1)
					XM_TimingColorArr = {}
					return true
				end
            end
        else
			local x,y,value = CurrencyFindColor(colorList)
			if(value ~= -1) then
				XMLogEx("XM.FindDev:"..colorList[1].."-"..x .. "-" .. y )
				RndTap(x+X,y+Y,1)
				XM_TimingColorArr = {}
				return true
			end
        end	
	else
		if type(Str) == "table" and #Str == 2 then
			XM.Print("XM.FindDev:色点名\"{"..Str[1].."-"..Str[2].."}\"不存在")
		elseif type(Str) == "string" then
			XM.Print("XM.FindDev:色点名\""..Str.."\"不存在")
		else
			XM.Print("XM.FindDev:以下色点名不存在")
			XM.Print(Str)
		end
    end
    return false
end




XM_LogSwitch = false
function XM.XMLogExOpen()
	XM_LogSwitch = true
end

function XMLogEx(Str) 
	if XM_LogSwitch == true then
		XM.Print(Str)
	end
end

function XM.FindAllPosition(Str, diff)--返回所有找到的位置  diff:坐标距离
    local iRet, sRet = pcall(function()
    local colorList = GetTable(Str)
    if colorList ~= nil then
        if type(colorList[1]) == "table" then
            colorList = colorList[1]
        end
        local value = CurrencyFindColor(colorList,1)
        if value ~= nil then
            local Arr, List = {}, {}
            Arr = XM.Split(value, "|")
            for i = 1, #Arr do--获取所有相似色点并分割
                List[i] = XM.Split(Arr[i], ",")
            end
            for i = 1, #List do		
                if tonumber(List[i][1]) ~= nil  and tonumber(List[i][2]) ~= nil and tonumber(List[i][3]) ~= nil then
                    local x, y = tonumber(List[i][2]), tonumber(List[i][3])
                    for j = 1, #List do
                        local x1, y1 = tonumber(List[j][2]), tonumber(List[j][3])
                        if i ~= j and List[j][1] ~= "" then
                            if x ~= nil and y ~= nil and x1 ~= nil and y1 ~= nil then
                                local dis = XM.Distance(x, y, x1, y1)
                                if dis < diff then
                                    List[j][1] = ""
                                end
                            else
                                List[j][1] = ""
                            end
                        end
                    end
                end
            end
            local count, RetList = 1, {}
            for i = 1, #List do--去重
                if List[i][1] ~= "" then
                    RetList[count] = List[i]
                    count = count + 1
                end
            end
            return RetList
        end
        
    else
        XM.Print("FindAllPosition:请填写正确的色点名")
    end
    return nil
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
    end
    return nil
end


function XM.FindNumRet(Str) 	--返回区域数量
	local colorList = GetTable(Str)
    if colorList ~= nil then
		if type(colorList[1]) == "table"  then
			XM.Print("XM.FindNumRet:色点名\""..colorList[1][1].."\"此函数不支持二维数组传参")
		else
			local value  = CurrencyFindColor(colorList,2)
			return value
		end
	else
		XM.Print("FindNumRet:色点名\""..Str.."\"不存在")
	end
	return nil
end

function XM.FindNum(Str,bool)	--获取区域指定数量
    bool = bool or false
    local colorList = GetTable(Str)
    if colorList ~= nil then
        if type(colorList[1]) == "table" then
            for i = 1,#colorList do
				if FindAmount(colorList[i],bool) then
					return true
				end
			end
        else
            if FindAmount(colorList,bool) then
                return true
            end
        end
		return false
    end
	XM.Print("FindNum:色点名\""..Str.."\"不存在")
    return false
end

function FindAmount(list,bool)
	local x1,y1,x2,y2,color ,sim = 0,0,2000,2000,"",0.8
	if #list == 3 then
		color = list[2]	
	elseif #list == 4 then
		sim = list[2]
		color = list[3]	
	elseif #list == 7 then
		x1,y1,x2,y2 = list[2],list[3],list[4],list[5]
		color = list[6]	
	elseif #list == 8 then
		if list[2] < 1 then	--兼容以往的写法,防止作者更新插件后无法正常使用
			sim = list[2]
			x1,y1,x2,y2 = list[3],list[4],list[5],list[6]
			color = list[7]	
		else
			x1,y1,x2,y2 = list[2],list[3],list[4],list[5]
			color = list[6]	
			sim = list[7]
		end
	else
		XM.Print("XM.FindNum:色点名\""..list[1].."\",请传入正确的参数")
	end
	
    local num = getcolornum(x1,y1,x2,y2,color,sim)
    if num >= list[#list] then
        if bool == true then
            local x = x2-((x2-x1)/2)
            local y = y2-((y2-y1)/2)
            RndTap(x,y,1)
        end
        return true
    else
        XM.Print("找色数量为"..tostring(num).."小于"..list[8])
        return false
    end
end



XM_SwitchArr = {}
function XM.Switch(id)			--开关函数
    id = id or 1
    if XM_SwitchArr[id] == nil then
        XM_SwitchArr[id] = true
    end
    if(XM_SwitchArr[id] == true) then
        XM_SwitchArr[id] = false
        return true
    end
    return false
end
function XM.OpenSwitch(id)	--打开开关
    if id  == nil then
        XM_SwitchArr = {}
    else
        XM_SwitchArr[id] = true
    end
end





XM_ColorCardScreenCount = {}
function XM.ColorCardScreen(id,x,y,count)	--颜色卡屏判断
    if XM_ColorCardScreenCount[id] == nil then
        XM_ColorCardScreenCount[id] = {}
        XM_ColorCardScreenCount[id][1] = 0
        XM_ColorCardScreenCount[id][2] = getcolor(x,y,0)
    else
		local value = getcolor(x,y,0)
        if XM_ColorCardScreenCount[id][1]  >= count  then	--颜色超过count次一样,表明卡死,返回true
            XM_ColorCardScreenCount[id][1] = 0
            return true
        elseif XM_ColorCardScreenCount[id][2] == value then	--颜色相同,次数+1
            XM_ColorCardScreenCount[id][1] = XM_ColorCardScreenCount[id][1] + 1
        elseif  XM_ColorCardScreenCount[id][2] ~= value then	--颜色不相同,重置次数,颜色重置
            
            XM_ColorCardScreenCount[id][1] = 0
            XM_ColorCardScreenCount[id][2] = value
            
        end
    end
    
    return false
end



XM_TimingColorArr = {}
function XM.TimerColor(id,t)--定时器(找色)
    t = t or 5
    local times = os.time()
    XM_TimingColorArr[id] = XM_TimingColorArr[id] or os.time() + t
    if(XM_TimingColorArr[id] <= times) then
        XM_TimingColorArr[id] = os.time() + t
        return true
    end
    return false
end

XM_TimingArr = {}
function XM.Timer(id,t)--定时器
    t = t or 5
    local times = os.time()
    XM_TimingArr[id] = XM_TimingArr[id] or os.time() + t
    if(XM_TimingArr[id] <= times) then
        XM_TimingArr[id] = os.time() + t
        return true
    end
    return false
end

function XM.TimerFirst(id,t)--第一次进入定时器	
    t = t or 5
    local times = os.time()
    if(XM_TimingArr[id] == nil) then
        XM_TimingArr[id] = os.time() + t
        return true
    end
    if(XM_TimingArr[id] <= times) then
        XM_TimingArr[id] = os.time() + t
        return true
    end
    return false
end


function XM.TimerInit(id)	--初始化定时器
    if id  == nil then
        XM_TimingArr = {}
    else
        XM_TimingArr[id] = nil
    end
end

function XM.TimerRet(id)--返回定时器剩余时间 S	
    if id ~= nil then
        local times = os.time()
        if XM_TimingArr[id] == nil or (XM_TimingArr[id] - times) <= 0  then
            return 0
        else
            return XM_TimingArr[id] - times
        end
    else
        XM.Print("请填写正确的定时器ID")
    end
end

function XM.ReturnDate(t)		--返回天时分
    t = tonumber(t) or 0
    if t == 0 then
        XM.Print("XM.ReturnDate参数错误,请传入number值")
    else
		local str = ""
		local list = {}
		local sList = {"天", "小时", "分", "秒"}
		list[1] = math.floor((t / 60 / 60) / 24)--天 
		list[2] = math.floor((t / 60 / 60) % 24)--时
		list[3] = math.floor((t / 60) % 60)--分
		list[4] = math.floor(t % 60)--秒
		for i = 1, #list do
			if list[i] > 0 then
				str = str .. list[i]..sList[i]
			end
		end
		return str
    end
end
function XM.DateRet(t)
    return XM.ReturnDate(t)
end

function XM.Msg(str,x,y,t)	--信息框
    str = str or TimingMsg_XM["str"]
    x = x or 1
    y = y or 1
    t = t or 2000
    if TimingMsg_XM["str"] ~= str then
        TimingMsg_XM[TimingMsg_XM["str"]] = nil
        TimingMsg_XM["str"] = str
    end
    TimerMsg(TimingMsg_XM["str"],t/1000)
    messageboxex(str,t,x,y,0,12)
end


TimingMsg_XM = {}
TimingMsg_XM["str"] = 1
function TimerMsg(id,t)
    t = t or 5
    local times = os.time()
    if(TimingMsg_XM[id] == nil) then
        TimingMsg_XM[id] = os.time() + t
    end
    if(TimingMsg_XM[id] <= times) then
        TimingMsg_XM[id] = os.time() + t
        return true
    end
    return false
end

function XM.MsgClose()	--关闭信息框
    messageboxex("", 0, 0, 0, 0, 0)
end


XM_Key = ""
function XM.Print(...)--调试输出，可打印表
    local tab = {}
    local str = ""
    if ... == nil then
        return 
    end
    if type(...) == "table" then
        tab = ...
        str = tab
    else
        tab = {...}
        for i = 1,#tab do
            if type(tab[i])  == "table" then
               local value = PrintTable(tab[i],1)
               str = str .. value
			else
				str = str .. tostring(tab[i])
				if i ~= #tab then
					str = str
				end
            end
				
		end
    end
    
    level = level or 1
    if type(str) == "table" then	
        local indent = ""
		for i = 1, level do
			indent = indent.."  "
		end
		if XM_Key ~= "" then
			XM.Print(tostring(indent).."["..tostring(XM_Key).."]".." ".."=".." ".."{")
		else
			XM.Print(tostring(indent) .. "{")
		end
		XM_Key = ""
		for k, v in pairs(str) do
			if type(v) == "table" then
				XM_Key = k
				XM.Print(v, level + 1)
			else
				local content = string.format("%s[%s] = %s", tostring(indent) .. "  ", tostring(k), tostring(v))
				XM.Print(tostring(content))
			end
		end
		XM.Print(tostring(indent) .. "}")
    else
        traceprint(tostring(str))
        logex(tostring(str))
    end
end 


function PrintTable(str,level)
    local str2 = ""
    local indent = ""
	for i = 1, level do
		indent = indent.." "
	end
	if XM_Key ~= "" then
		str2 = str2 .. (tostring(indent).."["..tostring(XM_Key).."]".."".."=".." ".."{")
	else
		str2 = str2 ..(tostring(indent) .. "{")
	end
	XM_Key = ""
	for k, v in pairs(str) do
		if type(v) == "table" then
			XM_Key = k
			str2 = str2 .. PrintTable(v, level + 1)
		else
			local content = string.format("%s[%s] = %s,", tostring(indent) .. "", tostring(k), tostring(v))
			str2 = str2 ..(tostring(content))
		end
	end
	str2 = str2 ..(tostring(indent) .. "}")
    return str2
end


function XM.FindRet(Str)
    local colorList = GetTable(Str)
	local list = {-1,-1,-1}
    if colorList ~= nil then
        if type(colorList[1]) == "table" then
			for i =1 ,#colorList do
				list[1],list[2],list[3] = CurrencyFindColor(colorList[i])
				if list[1] > -1 then
					list[3] = colorList[i][1]
					XMLogEx("XM.FindRet:"..list[1].."-"..list[2].."-"..list[3])
					return list
				end
			end
			return list 
        else
			list[1],list[2],list[3] = CurrencyFindColor(colorList)
			if list[1] > -1 then
				list[3] = colorList[1]
				XMLogEx("XM.FindRet:"..list[1].."-"..list[2].."-"..list[3])
			end
			return list
        end
    else
        XM.Print("FindRet参数错误")
    end
    return nil
end



--2019年4月18日	for循环效率过低
function XM.RndTap(X, Y, R)--随机点击 X:x坐标 Y:y坐标 R（可选）:随机值
    R = R or 5
    local r1 = rnd(math.abs(R)*-1, math.abs(R))
    local r2 = rnd(math.abs(R)*-1, math.abs(R))
    --local r3 = rnd(100,500)
    X,Y = ColorChange(X,Y)
    tap(X + r1, Y + r2)
    --Sleep(r3)
    --XM.KeepScreen(0)
end

function XM.LongTouch(X, Y, t)--随机点击 X:x坐标 Y:y坐标 t:按下时间
	t = t or 2000
    X,Y = ColorChange(X,Y)
    touchdown(X,Y,0)
    Sleep(t)
    touchup(0)
    XM.KeepScreen(0)
end

function RndTap(X, Y, R)--随机点击 X:x坐标 Y:y坐标 R（可选）:随机值
    R = R or 5
    R = R or 5
    local r1 = rnd(math.abs(R)*-1, math.abs(R))
    local r2 = rnd(math.abs(R)*-1, math.abs(R))
    local r3 = rnd(100,500)
    tap(X + r1, Y + r2)
    Sleep(r3)
    XM.KeepScreen(0)
end





function XM.Swipe(x1,y1,x2,y2,id,R) --滑动
    R = R or 5
    local r 
    if id == 3 then 
        r = R
    else
        r = rnd(-1*R, R)
    end
    id = id or 1
    x1,y1,x2,y2 = ColorChange(x1,y1,x2,y2)
    if id == 1 then	--随机滑动
        touchdown(x1 + r, y1 + r, 0)
        Sleep(300)
        touchmove(x2 + r, y2 + r, 0)
        Sleep(111)
        touchup(0)
    elseif id == 2 then	--捏合滑动
        local g1, g2
        x1 = x1 + r
        y1 = y1 + r
        x2 = x2 + r
        y2 = y2 + r
        touchdown(x1, y1, 0)
        touchdown(x2, y2, 1)
        g1 = ((x2 - x1) / 2) + x1
        g2 = ((y2 - y1) / 2) + y1
        touchmove(g1, g2, 0)
        touchmove(g1, g2, 1)
        touchup(0)
        touchup(1)
    elseif id == 3 then	--长按滑动
        touchdown(x1, y1, 0)
        Sleep(r)
        touchmove(x2, y2, 0)
        touchup(0)
	elseif id == 4 then	--匀速滑动
		local diff1 = x1-x2
		local diff2  = y1-y2
		R = R or 400
		if R < 400 then
		   R = 400 
		end
		local time = (R-100)/300
		local count1 = diff1/time
		local count2 = diff2/time
		singletouchdown(x1,y1)
		for i = 1,time do
			singletouchmove(x1-(count1*(i-1)),y1-(count2*(i-1)),x1-(count1*(i)),y1-(count2*(i)))
		end
		sleep(100)
		singletouchup(x2,y2)
    end
end









--返回数组[w(宽),h(高),d(dpi)]
function XM.GetScreen()		--获取当前游戏分辨率
    local iRet, sRet = pcall(function()
    local ret = Execute("su -c 'dumpsys window'")
    local info = {}
    _,_,info[3] = ret:find("(%d+)dpi")
    _,_,info[1],info[2],_ = ret:find("app=(%d+)x(%d+)")
    if info[1] then
        info[1] = tonumber(info[1])
        info[2] = tonumber(info[2])
        info[3] = tonumber(info[3])
        return info
    else
        return nil
    end
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end

--返回数组[w(宽),h(高),d(dpi)]
function XM.GetScreenSimulator()		--获取当前模拟器分辨率
    local iRet, sRet = pcall(function()
    local ret = Execute("su -c 'dumpsys window'")
    local info = {}
    _,_,info[1],info[2],info[3] = ret:find("init=(%d+)x(%d+) (%d+)dpi")
    if info[1] then
        info[1] = tonumber(info[1])
        info[2] = tonumber(info[2])
        info[3] = tonumber(info[3])
        return info
    else
        return nil
    end
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end




function XM.Split(Str, cutSymbol)						--字符串分割
    Str = tostring(Str)
    cutSymbol = tostring(cutSymbol)
    if (cutSymbol=='') then 
        return false
    end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(Str, cutSymbol, pos, true) end do
        table.insert(arr, string.sub(Str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(Str, pos))
    return arr
end


function XM.ArrayAssign(Array)	--数组赋值
    local list = {}
    for k,v in pairs(Array) do
        list[k] = v
    end
    return list
end

-------------------------系统---------------------------------------------------------

function XM.GetTap()	--获取点击位置
    Time = 10
    local iRet, sRet = pcall(function()
    local list = XM.GetScreen()
    local ScreenX,ScreenY = tonumber(list[1]),tonumber(list[2])
    local mode = 0
    if ScreenX > ScreenY then
        mode = 1
    end
    local data = Execute("su -c 'getevent -pl'")
    local mList = {}
    local retVlaue = {} 
    if data~=nil then
        _,_,_,_,mList[1]=data:find("ABS_MT_POSITION_X     :+ value (%d*), min (%d*), max (%d*)")
        _,_,_,_,mList[2]=data:find("ABS_MT_POSITION_Y     :+ value (%d*), min (%d*), max (%d*)")
    end
    local localpath = TempFile("coor")
    os.execute("su -c 'getevent -l -c "..Time..">"..localpath.."'")
    file=io.open(localpath, "r+");
    value=file:read("*l")
    local a,b
    while value~=nil do
        value=file:read("*l")
        if value~=nil then
            if a ~= nil and b ~= nil then
				if mode == 1 then
					retVlaue[1] = b
					retVlaue[2]= (ScreenY-a)
				else
					retVlaue[1]= math.floor(a*ScreenX/mList[1])
					retVlaue[2]= math.floor(b*ScreenY/mList[2])
				end
				if retVlaue[1] ~= nil and retVlaue[2] ~= nil then
					break
				end
            else
                if value:find("ABS_MT_POSITION_X")~=nil then
					a = tonumber(value:sub(54,62),16)
				elseif value:find("ABS_MT_POSITION_Y")~=nil then
					b = tonumber(value:sub(54,62),16)
				end
            end
        end
    end
    os.remove(localpath)
    return retVlaue
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end



function TempPath()--临时目录
    local tJudge, tValue = pcall(function()
    return getrcpath():match("(.+)/[^/]").."/"
    end)
    if tJudge == true then
        return tValue
    else
        return nil
    end
end

function TempFile(fn)
    local tPath = TempPath()
    if tPath == "" then
        return ""
    else
        if fn == nil then
            return tPath .. "TempCmd.txt"
        else
            return tPath .. fn .. ".txt"
        end
    end
end
--执行并返回execute命令的结果[cmd:执行的命令行][返回结果文本]
function Execute(cmdex)
    local iRet, sRet = pcall(function()
    local tFile = TempFile()
    if tFile == "" then
        return ""
    else
        os.execute("su")
        cmdex = cmdex.." > " .. tFile
        local ret = os.execute(cmdex)
        return TrimEx(XM.ReadFile(tFile, false), "\r\n ")
    end
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end

--过滤前导字符[str:要处理的字符串, filt:要过滤的字符]
function LTrimEx(str, filt)
    local iRet, sRet = pcall(function()
    local retstr = ""
    for i = 1, string.len(str) do
        if string.find(filt, string.sub(str, i, i)) == nil then
            retstr = string.sub(str, i, -1)
            break
        end
    end
    return retstr
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end

--过滤后导字符[str:要处理的字符串, filt:要过滤的字符]
function RTrimEx(str, filt)
    local iRet, sRet = pcall(function()
    local retstr = ""
    for i = string.len(str), 1, -1 do
        if string.find(filt, string.sub(str, i, i)) == nil then
            retstr = string.sub(str, 1, i)
            break
        end
    end
    return retstr
    end)
    if iRet == true then
        return sRet
    else 
        XM.Print(sRet)
        return nil
    end
end
--过滤前导与后导字符[str:要处理的字符串, filt:要过滤的字符]
function TrimEx(str, filt)
    local tmpstr
    tmpstr = LTrimEx(str, filt)
    return RTrimEx(tmpstr, filt)
end

--读取文件[path:路径, isdel:是否删除][返回文件内容, 失败返回空字符串]
function XM.ReadFile(path, isdel)
    local iRet, sRet = pcall(function()
    local f = io.open(path, "r")
    if f == nil then
        return nil
    end
    local ret = f:read("*all")
    f:close()
    if isdel then
        os.remove(path)
    end
    return ret
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end


--写文件[path:路径, content:写入内容 ,isdel:是否清除内容][返回true, 失败nil]
function XM.WriteFile(path,content, isCle)
    local iRet, sRet = pcall(function()
		content = content or ""
		local mode = ""
		if isCle then
			mode = "w"
        else
            mode = "a"
		end
		local f = io.open(path, mode)
		local ret = f:write(content)
		f:close()
		return ret
    end)
    if iRet == true then
        return sRet
    else
        XM.Print(sRet)
        return nil
    end
end




function CurrencyFindColor(Array,mode) 
    mode = mode or 0
    local x1,y1,x2,y2,color,OffsetPos,sim= 0,0,2000,2000,"","",0.8
    -- local iRet, sRet = pcall(
    -- function()
    TimerCloseMsg()
	
	local id = 0
	if type(Array[#Array]) == "string"  then 		
		if  type(Array[#Array-1]) == "string" and Array[#Array-1] ~= Array[1] then 	--findmulticolor: Array[#Array-1] ~= Array[1] 
			id = 1
		else
			id = 2
		end
	-- elseif type(Array[#Array]) == "number" then	--
		-- id = 1
	else
		XM.Print("色点名:"..Array[1]..",请填写正确的结尾参数")
		return false
	end
	if id == 1 then	--findmulticolor
		if #Array == 3 then
			if type(Array[2]) == "string" then 
				color = Array[2] 
			end
			if type(Array[3]) == "string" then
				OffsetPos = Array[3] 
			end
		elseif #Array == 4 then
			if type(Array[2]) == "number" then 
				sim = Array[2] 
			end
			if type(Array[3]) == "string" then 
				color = Array[3] 
			end
			if type(Array[4]) == "string" then
				OffsetPos = Array[4] 
			end
		elseif #Array == 7 then 
			if type(Array[2]) == "number" then
				x1 = Array[2]
			end
			if type(Array[3]) == "number" then
				y1 = Array[3]
			end
			if type(Array[4]) == "number" then
				x2 = Array[4]
			end
			if type(Array[5]) == "number" then
				y2 = Array[5]
			end
			if type(Array[6]) == "string" then
				color = Array[6]
			end
			if type(Array[7]) == "string" then
				OffsetPos = Array[7]
			end
		elseif #Array == 8 then 
			if type(Array[2]) == "number" then
				sim = Array[2]
			end
			if type(Array[3]) == "number" then
				x1 = Array[3]
			end
			if type(Array[4]) == "number" then
				y1 = Array[4]
			end
			if type(Array[5]) == "number" then
				x2 = Array[5]
			end
			if type(Array[6]) == "number" then
				y2 = Array[6]
			end
			if type(Array[7]) == "string" then
				color = Array[7]
			end
			if type(Array[8]) == "string" then
				OffsetPos = Array[8]
			end
		else
			XM.Print("色点名:"..Array[1]..",请填写正确的结尾参数")
			return false
		end
		x1,y1, x2,y2 = ColorChange(x1,y1, x2,y2)
		OffsetPos = ColorChange(OffsetPos)	
	elseif id == 2 then
		if #Array == 2 then
			if type(Array[2]) == "string" then 
				color = Array[2] 
			end
		elseif #Array == 3 then
			if type(Array[2]) == "number" then 
				sim = Array[2] 
			end
			if type(Array[3]) == "string" then 
				color = Array[3] 
			end
		elseif #Array == 6 then 
			if type(Array[2]) == "number" then
				x1 = Array[2]
			end
			if type(Array[3]) == "number" then
				y1 = Array[3]
			end
			if type(Array[4]) == "number" then
				x2 = Array[4]
			end
			if type(Array[5]) == "number" then
				y2 = Array[5]
			end
			if type(Array[6]) == "string" then
				color = Array[6]
			end
		elseif #Array == 7 then 
			if type(Array[2]) == "number" then
				sim = Array[2]
			end
			if type(Array[3]) == "number" then
				x1 = Array[3]
			end
			if type(Array[4]) == "number" then
				y1 = Array[4]
			end
			if type(Array[5]) == "number" then
				x2 = Array[5]
			end
			if type(Array[6]) == "number" then
				y2 = Array[6]
			end
			if type(Array[7]) == "string" then
				color = Array[7]
			end
		else
			XM.Print("色点名:"..Array[1]..",请填写正确的结尾参数")
			return false
		end
		x1,y1, x2,y2 = ColorChange(x1,y1, x2,y2)
	end
    local x,y,value = -1,-1,-1
    if mode == 0 then
		if id == 1 then
			x, y, value = findmulticolor(x1,y1, x2,y2,color, OffsetPos,sim,0)
			return x,y,value
		elseif id == 2 then
			x, y, value = findcolor(x1,y1, x2,y2,color,sim,0)
			return x,y,value
		end
    elseif mode == 1 then
        value = findmulticolorex(x1, y1,x2, y2,color,OffsetPos,sim, 0)
        return value
	elseif mode == 2 then
		value = getcolornum(x1, y1,x2, y2,color,sim)
        return value
    end
    return -1,-1,-1
end


function ColorChange(...)	--色点缩放
    if XM_resolPower == 1 then
        return ...
    else
        if ... == nil then
            return ...
        end
        if type(...) == "table" then
            Arr = ...
        else
            Arr = {...}
        end
        if #Arr == 1 then
            local str = ""
			if Arr[1] ~= "" then
				local list = XM.Split(Arr[1],",")
				for i = 1,#list do
					if str ~= "" then
						str = str .. ","
					end
					local arr = XM.Split(list[i],"|")
					x = math.ceil(tonumber(arr[1]) * XM_resolPower)
					y = math.ceil(tonumber(arr[2]) * XM_resolPower)
					val = arr[3]
					str = str .. x .. "|" .. y .. "|" .. val 
				end
            end
            return str
        elseif #Arr == 4 then
            for g = 1,#Arr do
                if type(Arr[g]) == "number" then
                    Arr[g] = math.ceil(Arr[g] * XM_resolPower)
                end
            end
            return Arr[1],Arr[2],Arr[3],Arr[4]
        elseif #Arr == 2 then
            for g = 1,#Arr do
                if type(Arr[g]) == "number" then
                    Arr[g] = math.ceil(Arr[g] * XM_resolPower)
                end
            end
            return Arr[1],Arr[2]
        end
        return ...
    end
end


function GetTable(list)	
    local name,str = ""
    if type(list) == "table" then
        str = list[1]
        name = list[2]
    else
        name = list
    end
    if str == nil then
        if MyTableXM[MyTableXM.ID] ~= nil  then
            for k,v in pairs(MyTableXM[MyTableXM.ID]) do --当前这个表内有几个子表;		
                if v[1] == name then	
                    return v;
                elseif v[1][1] == name then
                    return v;
                end 
            end
        else
            XM.Print("表名"..tostring(MyTableXM.ID).."不存在")
        end
    else
        if MyTableXM[str] ~= nil  then
            for k,v in pairs(MyTableXM[str]) do --当前这个表内有几个子表;		
                if v[1] == name then	
                    return v;
                elseif v[1][1] == name then
                    return v;
                end 
            end
        else
            XM.Print("表名"..tostring(str).."不存在")
        end
    end
    return nil;
end

------------------------------界面--------------
function RecursionJson(list,id)
    for k,v in pairs(list) do
        if v.id == id then
            local value 
            value = value or v.title
            value = value or v.isSelect
            value = value or tonumber(v.selectItemPosition)
            return value
        elseif type(v) == "table" and v.id == nil then
            local value = RecursionJson(v,id)
            if value ~= nil then
                return value
            end
        end
    end
    return 
end
XM_JsonGetUI = {}
XM_JsonGetUIBool = false
function XM.GetUI(id)	--获取UI
    if XM_JsonGetUIBool == true then
		local value = RecursionJson(XM_JsonGetUI,id)
        if value == "true" then
           value = true
        elseif value == "false" then
			value = false
        end
        return value
    else
		local path = getrcpath("rc:saveDataJson.txt")
		local value =  XM.ReadFile(path,false)
		XM_JsonGetUI = XM.JsonDecode(value)
        if value ~= nil and value ~= "" then
            XM_JsonGetUIBool = true
        end
		local value = RecursionJson(XM_JsonGetUI,id)
        if value == "true" then
           value = true
        elseif value == "false" then
			value = false
        end
        return value
    end
end
--------------------

function XM.Distance(x,y,x1,y1)								--距离
    return 	math.abs(math.ceil(math.sqrt((math.pow((x - x1),2)+math.pow((y - y1),2)))))
end



local encode,next_char
local parse,create_set

function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[ select(i, ...) ] = true
    end
    return res
end


function XM.JsonDecode(str)	--解Json格式
    if type(str) ~= "string" then
        error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, create_set(" ", "\t", "\r", "\n"), true))
    idx = next_char(str, idx, create_set(" ", "\t", "\r", "\n"), true)
    if idx <= #str then
        decode_error(str, idx, "trailing garbage")
    end
    return res
end

function XM.JsonEncode(val)	--转Json格式
    return ( encode(val) )
end

local escape_char_map = {
[ "\\" ] = "\\\\",
[ "\"" ] = "\\\"",
[ "\b" ] = "\\b",
[ "\f" ] = "\\f",
[ "\n" ] = "\\n",
[ "\r" ] = "\\r",
[ "\t" ] = "\\t",
}

local escape_char_map_inv = { [ "\\/" ] = "/" }
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end


local function escape_char(c)
return escape_char_map[c] or string.format("\\u%04x", c:byte())
end


local function encode_nil(val)
return "null"
end


local function encode_table(val, stack)
local res = {}
stack = stack or {}

-- Circular reference?
if stack[val] then error("circular reference") end
    
    stack[val] = true
    
    if val[1] ~= nil or next(val) == nil then
        -- Treat as array -- check keys are valid and it is not sparse
        local n = 0
        for k in pairs(val) do
            if type(k) ~= "number" then
                error("invalid table: mixed or invalid key types")
            end
            n = n + 1
        end
        if n ~= #val then
            error("invalid table: sparse array")
        end
        -- Encode
        for i, v in ipairs(val) do
            table.insert(res, encode(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"
        
    else
        -- Treat as an object
        for k, v in pairs(val) do
            if type(k) ~= "string" then
                error("invalid table: mixed or invalid key types")
            end
            table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
        end
        stack[val] = nil
        return "{" .. table.concat(res, ",") .. "}"
    end
end


local function encode_string(val)
return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end


local function encode_number(val)
-- Check for NaN, -inf and inf
if val ~= val or val <= -math.huge or val >= math.huge then
    error("unexpected number value '" .. tostring(val) .. "'")
end
return string.format("%.14g", val)
end


local type_func_map = {
[ "nil"     ] = encode_nil,
[ "table"   ] = encode_table,
[ "string"  ] = encode_string,
[ "number"  ] = encode_number,
[ "boolean" ] = tostring,
}


encode = function(val, stack)
local t = type(val)
local f = type_func_map[t]
if f then
    return f(val, stack)
end
error("unexpected type '" .. t .. "'")
end





-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------




local literal_map = {
[ "true"  ] = true,
[ "false" ] = false,
[ "null"  ] = nil,
}


function next_char(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end


local function decode_error(str, idx, msg)
local line_count = 1
local col_count = 1
for i = 1, idx - 1 do
    col_count = col_count + 1
    if str:sub(i, i) == "\n" then
        line_count = line_count + 1
        col_count = 1
    end
end
error( string.format("%s at line %d col %d", msg, line_count, col_count) )
end


local function codepoint_to_utf8(n)
-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
local f = math.floor
if n <= 0x7f then
    return string.char(n)
elseif n <= 0x7ff then
    return string.char(f(n / 64) + 192, n % 64 + 128)
elseif n <= 0xffff then
    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
elseif n <= 0x10ffff then
    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
    f(n % 4096 / 64) + 128, n % 64 + 128)
end
error( string.format("invalid unicode codepoint '%x'", n) )
end


local function parse_unicode_escape(s)
local n1 = tonumber( s:sub(3, 6),  16 )
local n2 = tonumber( s:sub(9, 12), 16 )
-- Surrogate pair?
if n2 then
    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
else
    return codepoint_to_utf8(n1)
end
end


local function parse_string(str, i)
local has_unicode_escape = false
local has_surrogate_escape = false
local has_escape = false
local last
for j = i + 1, #str do
    local x = str:byte(j)
    
    if x < 32 then
        decode_error(str, j, "control character in string")
    end
    
    if last == 92 then -- "\\" (escape char)
        if x == 117 then -- "u" (unicode escape sequence)
            local hex = str:sub(j + 1, j + 5)
            if not hex:find("%x%x%x%x") then
                decode_error(str, j, "invalid unicode escape in string")
            end
            if hex:find("^[dD][89aAbB]") then
                has_surrogate_escape = true
            else
                has_unicode_escape = true
            end
        else
            local c = string.char(x)
            if not create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")[c] then
                decode_error(str, j, "invalid escape char '" .. c .. "' in string")
            end
            has_escape = true
        end
        last = nil
        
    elseif x == 34 then -- '"' (end of string)
        local s = str:sub(i + 1, j - 1)
        if has_surrogate_escape then
            s = s:gsub("\\u[dD][89aAbB]..\\u....", parse_unicode_escape)
        end
        if has_unicode_escape then
            s = s:gsub("\\u....", parse_unicode_escape)
        end
        if has_escape then
            s = s:gsub("\\.", escape_char_map_inv)
        end
        return s, j + 1
        
    else
        last = x
    end
end
decode_error(str, i, "expected closing quote for string")
end


local function parse_number(str, i)
local x = next_char(str, i, create_set(" ", "\t", "\r", "\n", "]", "}", ","))
local s = str:sub(i, x - 1)
local n = tonumber(s)
if not n then
    decode_error(str, i, "invalid number '" .. s .. "'")
end
return n, x
end


local function parse_literal(str, i)
local x = next_char(str, i, create_set(" ", "\t", "\r", "\n", "]", "}", ","))
local word = str:sub(i, x - 1)
if not create_set("true", "false", "null")[word] then
    decode_error(str, i, "invalid literal '" .. word .. "'")
end
return literal_map[word], x
end


local function parse_array(str, i)
local res = {}
local n = 1
i = i + 1
while 1 do
    local x
    i = next_char(str, i, create_set(" ", "\t", "\r", "\n"), true)
    -- Empty / end of array?
    if str:sub(i, i) == "]" then
        i = i + 1
        break
    end
    -- Read token
    x, i = parse(str, i)
    res[n] = x
    n = n + 1
    -- Next token
    i = next_char(str, i, create_set(" ", "\t", "\r", "\n"), true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "]" then break end
        if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
        end
        return res, i
    end
    
    
    local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, create_set(" ", "\t", "\r", "\n"), true)
        -- Empty / end of object?
        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end
        -- Read key
        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        -- Read ':' delimiter
        i = next_char(str, i, create_set(" ", "\t", "\r", "\n"), true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, create_set(" ", "\t", "\r", "\n"), true)
        -- Read value
        val, i = parse(str, i)
        -- Set
        res[key] = val
        -- Next token
        i = next_char(str, i, create_set(" ", "\t", "\r", "\n"), true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then break end
            if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
            end
            return res, i
        end
        
        
        local char_func_map = {
        [ '"' ] = parse_string,
        [ "0" ] = parse_number,
        [ "1" ] = parse_number,
        [ "2" ] = parse_number,
        [ "3" ] = parse_number,
        [ "4" ] = parse_number,
        [ "5" ] = parse_number,
        [ "6" ] = parse_number,
        [ "7" ] = parse_number,
        [ "8" ] = parse_number,
        [ "9" ] = parse_number,
        [ "-" ] = parse_number,
        [ "t" ] = parse_literal,
        [ "f" ] = parse_literal,
        [ "n" ] = parse_literal,
        [ "[" ] = parse_array,
        [ "{" ] = parse_object,
        }
        
        
        parse = function(str, idx)
        local chr = str:sub(idx, idx)
        local f = char_func_map[chr]
        if f then
            return f(str, idx)
        end
        decode_error(str, idx, "unexpected character '" .. chr .. "'")
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    return XM