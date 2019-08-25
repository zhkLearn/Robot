
-- dataType: 0, fieldTypeFloat: 1, fieldTypeString: 2
-- align: 0 left, 1 center, 2 right
-- stats最多20条
InitParams =
{
	width = 800,
	height = 618,
	dpi = 160,
	stats =
	{
		{key = "00_gold", cap = "金币", dataType = 0, width = 60, align = 0},
		{key = "01_floatTest", cap = "浮点数", dataType = 1, width = 50, align = 1},
		{key = "02_stringTest", cap = "字符串", dataType = 2, width = 120, align = 2},
	}
}

local key = ""
function PrintTable(table , level)
  level = level or 1
  local indent = ""
  for i = 1, level do
    indent = indent.."  "
  end

  if key ~= "" then
    print(indent..key.." ".."=".." ".."{")
  else
    print(indent .. "{")
  end

  key = ""
  for k,v in pairs(table) do
     if type(v) == "table" then
        key = k
        PrintTable(v, level + 1)
     else
        local content = string.format("%s%s = %s", indent .. "  ",tostring(k), tostring(v))
      print(content)  
      end
  end
  print(indent .. "}")

end

PrintTable(InitParams, 0)