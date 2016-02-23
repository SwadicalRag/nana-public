if true then return end

local sqt = dofile("libs/sqlite_table.lua")

local Markov = {}
Markov.chain = sqt.new("markov_chain")
Markov.firstWords = sqt.new("markov_firstwords")
Markov.firstWords[0] = Markov.firstWords[0] or 0

function Markov:Learn(sentence,firstLearn,aux)
    local lastWord,lastChain

    for word in sentence:gmatch("%S+") do
        if lastWord then
            lastChain[word] = lastChain[word] or {
                [0] = 0,-- children total
                [1] = 0,-- self total
            }

            lastChain[0] = lastChain[0] + 1
            lastChain[word][1] = lastChain[word][1] + 1

            lastChain = lastChain[word]
        else
            if firstLearn then
                self.firstWords[word] = self.firstWords[word] or 0
                self.firstWords[word] = self.firstWords[word] + 1
                self.firstWords[0] = self.firstWords[0] + 1

                return
            else
                self.chain[word] = self.chain[word] or {
                    [0] = 0,-- children total
                    [1] = 0,-- self total
                }

                self.chain[word][1] = self.chain[word][1] + 1
                lastChain = self.chain[word]

                if not aux then
                    self:Learn(sentence,true,true)
                end
            end
        end

        lastWord = word
    end

    if not firstLearn then
        local oneWordLessSentence = sentence:match("%S+%s+(.+)")
        if oneWordLessSentence and (oneWordLessSentence ~= "") then
            self:Learn(oneWordLessSentence,false,true)
        end
    end
end

function Markov:randomFirstWord()
    local target,current = math.random(1,math.max(self.firstWords[0],1)),0
    for word,data in pairs(self.firstWords) do
        if type(word) == "string" then
            current = current + data
            if current >= target then return word end
        end
    end
end

function Markov:randomWordFromChain(chain)
    local target,current = math.random(1,math.max(chain[0],1)),0

    for word,data in pairs(chain) do
        if type(word) == "string" then
            current = current + data[1]
            if current >= target then return word end
        end
    end

    return false
end

function Markov:nextWord(chain,depth)
    local startChain = self.chain
    depth = math.min(#chain,depth)

    for i=1,depth do
        local word = chain[#chain-depth+i]
        if word and startChain[word] then
            startChain = startChain[word]
        else
            return false
        end
    end

    return self:randomWordFromChain(startChain)
end

function Markov:Generate(start,maxLength,depth)
    local output = {}

    if start then
        for word in start:gmatch("%S+") do
            output[#output+1] = word
        end
    else
        output[#output+1] = self:randomFirstWord()
    end

    while true do
        local nextWord = self:nextWord(output,depth or 2)

        if not nextWord then break end

        output[#output+1] = nextWord

        if maxLength and (#output >= maxLength) then break end
    end

    return table.concat(output," ")
end

timer.Simple(1,function()
    -- sandbox.env.Markov = Markov
end)
