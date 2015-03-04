----------------------------------------------------------
-- file:	testfunctions.lua
-- Author:	page
-- Time:	2015/01/25 : Happy Birthday to myself ^_^
-- Desc:	一些测试用的lib函数
----------------------------------------------------------
--复制一个table
--org为源table，des为复制出来的新table
function gf_CopyTable(tbOrg)
    local tbSaveExitTable = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object;
        elseif tbSaveExitTable[object] then	--检查是否有循环嵌套的table
            return tbSaveExitTable[object];
        end
        local tbNewTable = {};
        tbSaveExitTable[object] = tbNewTable;
        for index, value in pairs(object) do
            tbNewTable[_copy(index)] = _copy(value);	--要考虑用table作索引的情况
        end
        return setmetatable(tbNewTable, getmetatable(object));
    end
    return _copy(tbOrg);
end

--继承
--参数tbInitInfo是为了对基类的成员进行初始化或为派生类中增加新成员
function gf_Inherit(base,tbInitInfo)	--定义一个继承函数
	local derive = {};
	local metatable = {};
	metatable.__index = base;
	setmetatable(derive,metatable);
	for i,v in pairs(base) do
		if type(v) == "table" then
			derive[i] = gf_CopyTable(v);
		end;
	end;
	if tbInitInfo then	--如果要改变基类的成员或增加新的成员
		for i,v in pairs(tbInitInfo) do
			derive[i] = v;
		end;
	end;
	return derive;
end;

--获得带有概率信息的随机索引
--[[
@param:概率表, eg :tbPro={10,20,40,30},每一项为一个概率，
@nMaxNum:概率的分母
@return:返回对应概率索引, 没有随机到返回0
@eg:nMaxNum=100，1索引的概率为10/100，2索引的概率为20/100,...
]]
function gf_GetRandomIndex(tbPro, nMaxNum)
	nMaxNum = nMaxNum or 100;
	local nRand = math.random(1, nMaxNum);
	local nSum = 0;
	for i = 1, #tbPro do
		nSum = nSum + tbPro[i];
		if nRand <= nSum then
			return i;
		end;
	end;
	return 0;
end;

--@function:获得不重复的随机序列
--@nSize：范围（1-nSize）
--@nNum：随机序列中随机数的个数
function gf_GetRandomUnRepeatIdx(nSize,nNum)
	if nNum > nSize then
		nNum = nSize;
	end;
	local tbTemp = {};
	for i=1,nSize do
		tbTemp[i] = i;
	end;
	local tbRet = {};
	for i=1,nNum do
		local nRandIdx = math.random(1,#(tbTemp));
		tbRet[i] = tbTemp[nRandIdx];
		table.remove(tbTemp,nRandIdx);
	end;
	return tbRet;
end;

--求table中的所有数的总和
function gf_GetTableNumSum(tbNum)
	if type(tbNum) ~= "table" then
		return 0;
	end;
	local nSum = 0;
	for i=1,#tbNum do
		nSum = nSum + tbNum[i];
	end;
	return nSum;
end;

--@function:根据概率表获取随机索引（支持小数概率）
function gf_GetRandomIndexEx(tbProb)
	tst_print_lua_table(tbProb)

	local tbProbLocal = gf_CopyTable(tbProb)
	--StringFind函数返回sString的小数点位数
	local StringFind = function(sString, nTag)
		for i = 1, string.len(sString) do
			if string.sub(sString, -i, -i) == nTag then
				return i-1;
			end;
		end;
		return 0;
	end;
	--判断概率合为100
	local nProbSum = gf_GetTableNumSum(tbProbLocal);
	if (tostring(nProbSum) ~= "100") then
		return 0;
	end;
	--获取概率中小数点的最大位数
	local nMaxDotPos = 0;
	local nDotPos = 0;
	for i = 1, #tbProbLocal do
		nDotPos = StringFind(tostring(tbProbLocal[i]), ".");
		if (nDotPos > nMaxDotPos) then
			nMaxDotPos = nDotPos;
		end;
	end;
	--计算随机数的范围
	local nMaxNum = 100;
	for i = 1, nMaxDotPos do
		nMaxNum = nMaxNum * 10;
		for j = 1, #tbProbLocal do
			tbProbLocal[j] = tbProbLocal[j] * 10;
		end;
	end;
	--获得按概率随机的索引
	return gf_GetRandomIndex(tbProbLocal, nMaxNum);
end;

--创建一个类，暂时不支持继承，继承方法参照quick的class函数
--[[
添加一个new方法
使用它的类可以把初始化操作放进 ctor 函数里，会自动调用
]]
function gf_class()
    local cls = { ctor = function() end }
    cls.__index = cls

    function cls.new(...)
        local instance = setmetatable({}, cls)
        instance:ctor(...)
        return instance
    end

    return cls
end

--[[
将 Lua 对象及其方法包装为一个匿名函数
]]
function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end
