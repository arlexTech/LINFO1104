declare
fun {FileToList FileName}
    local
    F={New Open.file init(name:FileName flags:[read text])} Is in
        {F read(list:Is size:all)}
        {F close}
        Is
    end
end

fun {CharToWords Ls Rs Acc} %Converts a list of char to a list of words
    case Ls of nil then
        {List.append Rs Acc|nil}
    [] L|Lr then
        if {Char.isSpace L} then
            {CharToWords Lr {List.append Rs Acc|nil} nil}
        else
            {CharToWords Lr Rs {List.append Acc L|nil}}
        end
    end
end

fun {StrToLiteral Ls Rs} %Converts "str" to 'str' for easier use later
    case Ls of nil then Rs
    [] L|Lr then 
        {StrToLiteral Lr {List.append Rs {String.toAtom L}|nil}}
    end
end

fun {CleanText Ls Rs} %Ls is the list to be cleaned Rs is the returned List
    case Ls of nil then Rs
    [] L|Lr then
        if {Char.isPunct L} then 
            {CleanText Lr Rs} %removes special symbols
        elseif {Char.isSpace L} then
            {CleanText Lr {List.append Rs & |nil}} %Replaces all new line, etc. by spaces
        else 
            {CleanText Lr {List.append Rs {Char.toLower L}|nil}} 
            %We want to keep L so append it to Rs as a lowercase, the |nil is required to keep the structure of a list
        end
    end
end

fun {CleanTextNonTail Ls} %Ls is the list to be cleaned
    case Ls of nil then nil
    [] L|Lr then
        if {Char.isPunct L} then %removes special symbols
            {CleanTextNonTail Lr}
        elseif {Char.isSpace L} then
            & |{CleanTextNonTail Lr} %Replaces all new line, etc. by spaces
        else 
            {Char.toLower L}|{CleanTextNonTail Lr} %We want to keep L so append it as a lowercase
        end
    end
end

fun {CleanTweet Path} %Returns a list of words from the given tweet path
    local FileChar = {FileToList Path} %Gets list of char
    in 
        local CleanedChar = {CleanTextNonTail FileChar} %Cleans from all extra characters
        in 
            local WordList = {CharToWords CleanedChar nil nil} 
            in
                local AtomWordList = {StrToLiteral WordList nil}
                in
                    AtomWordList
                end
            end
        end
    end
end