if not markov then return print("Can not see markovLib!") end

sandbox.env.markov = {
    load = function(path)
        assert(path:match("^%w+$"))
        return markov.load(path)
    end,
    save = function(path)
        assert(path:match("^%w+$"))
        return markov.load(save)
    end,
    learn = markov.learn,
    generate = markov.generate
}
