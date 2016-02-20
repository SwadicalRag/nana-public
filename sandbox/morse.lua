local alphaLookup = {
    A = ".-",
    B = "-...",
    C = "-.-.",
    D = "-..",
    E = ".",
    F = "..-.",
    G = "--.",
    H = "....",
    I = "..",
    J = ".---",
    K = "-.-",
    L = ".-..",
    M = "--",
    N = "-.",
    O = "---",
    P = ".--.",
    Q = "--.-",
    R = ".-.",
    S = "...",
    T = "-",
    U = "..-",
    V = "...-",
    W = ".--",
    X = "-..-",
    Y = "-.--",
    Z = "--..",
    [" "] = " ",
    ["1"] = ".----",
    ["2"] = "..---",
    ["3"] = "...--",
    ["4"] = "....-",
    ["5"] = ".....",
    ["6"] = "-....",
    ["7"] = "--...",
    ["8"] = "---..",
    ["9"] = "----.",
    ["0"] = "-----",
}

local CHAR_SPACE,WORD_SPACE

local function setSpace(char,word)
    CHAR_SPACE,WORD_SPACE = (" "):rep(char),(" "):rep(word)
end
setSpace(3,7)

local morseLookup = {}
for alpha,morse in pairs(alphaLookup) do
    morseLookup[morse] = alpha
end

local function alphaToMorse(txt)
    txt = txt:upper()
    txt = txt:gsub("[^A-Z0-9 ]","")

    return (txt:gsub("(.)",function(char)
        if char == " " then
            return WORD_SPACE
        else
            return alphaLookup[char]..CHAR_SPACE
        end
    end):match("^(.-) *$"))
end

local function morseToAlpha(txt)
    txt = txt:gsub("[^%.%- ]","")

    local out = ""

    for char,space in txt:gmatch("([%.%-]+)( *)") do
        if morseLookup[char] then
            out = out..morseLookup[char]
        end

        if #space > #CHAR_SPACE then
            out = out.." "
        end
    end

    return out
end


morse = {
    toAlpha = morseToAlpha,
    fromAlpha = alphaToMorse,
    setSpace = setSpace
}
