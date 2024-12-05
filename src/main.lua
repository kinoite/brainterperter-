#!/usr/bin/lua

--[[

  ___          _     _                         _
 | _ )_ _ __ _(_)_ _| |_ ___ _ _ _ __  ___ _ _| |_ ___ _ _
 | _ \ '_/ _` | | ' \  _/ -_) '_| '_ \/ -_) '_|  _/ -_) '_|
 |___/_| \__,_|_|_||_\__\___|_| | .__/\___|_|  \__\___|_|
                                |_|
 the brainfuck interperter(™ /j)

 Brainfuck Interpreter in Lua

 Licensed under the terms of GPLv3

 Created By Kinoite

--]]
function read_file(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file: " .. filename)
    end
    local content = file:read("*a")
    file:close()
    return content
end

function brainfuck_interpreter(code, input_data)
    local tape = {}
    local tape_size = 30000
    for i = 1, tape_size do
        tape[i] = 0
    end
    local ptr = 1
    local code_ptr = 1
    local input_ptr = 1
    local output = {}
    local loop_stack = {}

    while code_ptr <= #code do
        local command = code:sub(code_ptr, code_ptr)

        if command == ">" then
            ptr = ptr + 1
            if ptr > tape_size then
                error("Tape pointer out of bounds!")
            end

        elseif command == "<" then
            ptr = ptr - 1
            if ptr < 1 then
                error("Tape pointer out of bounds!")
            end

        elseif command == "+" then
            tape[ptr] = (tape[ptr] + 1) % 256

        elseif command == "-" then
            tape[ptr] = (tape[ptr] - 1) % 256

        elseif command == "." then
            table.insert(output, string.char(tape[ptr]))

        elseif command == "," then
            if input_ptr <= #input_data then
                tape[ptr] = string.byte(input_data:sub(input_ptr, input_ptr))
                input_ptr = input_ptr + 1
            else
                tape[ptr] = 0
            end

        elseif command == "[" then
            if tape[ptr] == 0 then
                local open_brackets = 1
                while open_brackets > 0 do
                    code_ptr = code_ptr + 1
                    if code:sub(code_ptr, code_ptr) == "[" then
                        open_brackets = open_brackets + 1
                    elseif code:sub(code_ptr, code_ptr) == "]" then
                        open_brackets = open_brackets - 1
                    end
                end
            else
                table.insert(loop_stack, code_ptr)
            end

        elseif command == "]" then
            if tape[ptr] ~= 0 then
                code_ptr = loop_stack[#loop_stack]
            else
                table.remove(loop_stack)
            end
        end

        code_ptr = code_ptr + 1
    end

    return table.concat(output)
end

-- Main Program
if #arg < 1 then
    print("Usage: lua braininterpreter.lua <filename>")
    os.exit(1)
end

local filename = arg[1]
local code = read_file(filename)
local output = brainfuck_interpreter(code)
print(output)
