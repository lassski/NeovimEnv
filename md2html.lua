local input = arg[1]

if not input then
	print("Usage: lua md2html.lua file.md")
	os.exit(1)
end

local filename = input:gsub("%.md$", "")
local output = "/tmp/" .. filename .. ".html"

local cmd = "pandoc " .. string.format("%q", input) .. " -o " .. string.format("%q", output)

local success = os.execute(cmd)

if not success then
	print("Pandoc conversion failed!")
	os.exit(1)
end

os.execute("firefox " .. string.format("%q", output) .. " >/dev/null 2>&1 &")
