local Markov = {}
Markov.chain = {}
Markov.firstWords = {
    [0] = 0
}

Markov.wordCount = 10
Markov.words = {}
Markov.wordsLookup = {}
function Markov:word(word)
    if not self.words[word] then
        self.wordCount = self.wordCount + 1
        local id = self.wordCount
        self.words[word] = id
        self.wordsLookup[id] = word
    end

    return self.words[word]
end

function Markov:wordLookup(id)
    return self.wordsLookup[id]
end

function Markov:Learn(sentence,firstLearn,aux)
    local lastWord,lastChain

    for word in sentence:gmatch("%S+") do
        if lastWord then
            lastChain[self:word(word)] = lastChain[self:word(word)] or {
                [0] = 0,-- children total
                [1] = 0,-- self total
            }

            lastChain[0] = lastChain[0] + 1
            lastChain[self:word(word)][1] = lastChain[self:word(word)][1] + 1

            lastChain = lastChain[self:word(word)]
        else
            if firstLearn then
                self.firstWords[self:word(word)] = self.firstWords[self:word(word)] or 0
                self.firstWords[self:word(word)] = self.firstWords[self:word(word)] + 1
                self.firstWords[0] = self.firstWords[0] + 1

                return
            else
                self.chain[self:word(word)] = self.chain[self:word(word)] or {
                    [0] = 0,-- children total
                    [1] = 0,-- self total
                }

                self.chain[self:word(word)][1] = self.chain[self:word(word)][1] + 1
                lastChain = self.chain[self:word(word)]

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
    for idx,data in pairs(self.firstWords) do
        if idx and idx >= 10 then
            current = current + data
            if current >= target then return idx end
        end
    end
end

function Markov:randomWordFromChain(chain)
    local target,current = math.random(1,math.max(chain[0],1)),0

    for idx,data in pairs(chain) do
        if idx and idx >= 10 then
            current = current + data[1]
            if current >= target then return idx end
        end
    end

    return false
end

function Markov:nextWord(chain,depth)
    local startChain = self.chain
    depth = math.min(#chain,depth)

    for i=1,depth do
        local idx = chain[#chain-depth+i]
        if idx and startChain[idx] then
            startChain = startChain[idx]
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
            output[#output+1] = self:word(word)
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

    local sentence = ""
    for _,idx in ipairs(output) do
        sentence = sentence..self:wordLookup(idx).." "
    end

    return sentence:sub(1,-2)
end
