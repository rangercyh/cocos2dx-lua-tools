----------------------------------------------------------
-- file:	testfunctions.lua
-- Author:	page
-- Time:	2015/01/25 : Happy Birthday to myself ^_^
-- Desc:	һЩ�����õ�lib����
----------------------------------------------------------
--����һ��table
--orgΪԴtable��desΪ���Ƴ�������table
function gf_CopyTable(tbOrg)
    local tbSaveExitTable = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object;
        elseif tbSaveExitTable[object] then	--����Ƿ���ѭ��Ƕ�׵�table
            return tbSaveExitTable[object];
        end
        local tbNewTable = {};
        tbSaveExitTable[object] = tbNewTable;
        for index, value in pairs(object) do
            tbNewTable[_copy(index)] = _copy(value);	--Ҫ������table�����������
        end
        return setmetatable(tbNewTable, getmetatable(object));
    end
    return _copy(tbOrg);
end

--�̳�
--����tbInitInfo��Ϊ�˶Ի���ĳ�Ա���г�ʼ����Ϊ�������������³�Ա
function gf_Inherit(base,tbInitInfo)	--����һ���̳к���
	local derive = {};
	local metatable = {};
	metatable.__index = base;
	setmetatable(derive,metatable);
	for i,v in pairs(base) do
		if type(v) == "table" then
			derive[i] = gf_CopyTable(v);
		end;
	end;
	if tbInitInfo then	--���Ҫ�ı����ĳ�Ա�������µĳ�Ա
		for i,v in pairs(tbInitInfo) do
			derive[i] = v;
		end;
	end;
	return derive;
end;

--��ô��и�����Ϣ���������
--[[
@param:���ʱ�, eg :tbPro={10,20,40,30},ÿһ��Ϊһ�����ʣ�
@nMaxNum:���ʵķ�ĸ
@return:���ض�Ӧ��������, û�����������0
@eg:nMaxNum=100��1�����ĸ���Ϊ10/100��2�����ĸ���Ϊ20/100,...
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

--@function:��ò��ظ����������
--@nSize����Χ��1-nSize��
--@nNum�����������������ĸ���
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

--��table�е����������ܺ�
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

--@function:���ݸ��ʱ��ȡ���������֧��С�����ʣ�
function gf_GetRandomIndexEx(tbProb)
	tst_print_lua_table(tbProb)

	local tbProbLocal = gf_CopyTable(tbProb)
	--StringFind��������sString��С����λ��
	local StringFind = function(sString, nTag)
		for i = 1, string.len(sString) do
			if string.sub(sString, -i, -i) == nTag then
				return i-1;
			end;
		end;
		return 0;
	end;
	--�жϸ��ʺ�Ϊ100
	local nProbSum = gf_GetTableNumSum(tbProbLocal);
	if (tostring(nProbSum) ~= "100") then
		return 0;
	end;
	--��ȡ������С��������λ��
	local nMaxDotPos = 0;
	local nDotPos = 0;
	for i = 1, #tbProbLocal do
		nDotPos = StringFind(tostring(tbProbLocal[i]), ".");
		if (nDotPos > nMaxDotPos) then
			nMaxDotPos = nDotPos;
		end;
	end;
	--����������ķ�Χ
	local nMaxNum = 100;
	for i = 1, nMaxDotPos do
		nMaxNum = nMaxNum * 10;
		for j = 1, #tbProbLocal do
			tbProbLocal[j] = tbProbLocal[j] * 10;
		end;
	end;
	--��ð��������������
	return gf_GetRandomIndex(tbProbLocal, nMaxNum);
end;

--����һ���࣬��ʱ��֧�ּ̳У��̳з�������quick��class����
--[[
���һ��new����
ʹ����������԰ѳ�ʼ�������Ž� ctor ��������Զ�����
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
�� Lua �����䷽����װΪһ����������
]]
function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end
