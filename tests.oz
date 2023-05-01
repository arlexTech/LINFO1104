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

%N-Gram tree
fun {InstanciateNGram} 
    'Root'('_occ':1.0) %Returns the root, a record that will contain all trees, _occ is the total number of entries
end

fun {NewNode Word Tree} %Adds a node on the first level of the tree w/ 1 occ
    local NodeToAdd = Word('_prob':0.0 '_occ':0.0) in
        {Record.adjoinAt Tree Word NodeToAdd} %Returns a tree w/ inserted node
    end
end

fun {CheckLabel Ls W} %Fnc to compare all labels to word 
    case Ls of nil then false
    [] L|Lr then 
        if L==W then
            true %returns true if Word is in labels
        else {CheckLabel Lr W} 
        end
    end
end

fun {ParseWord Words Tree}
    %{Browse Words}
    case Words of nil then {Browse 'Parsed nil word in ParseWord'} nil 
    %should never be the case and I'm too lazy to figure out exceptions/errors
    [] Word|nil then %If last word to parse
        if {CheckLabel {Arity Tree} Word} then %If word is already present in Tree, update occ and prob
            {UpdateOccProb Word Tree} %Returns tree w/ updated values
        else %If not present, add a new node and update prob
            local T = {NewNode Word Tree} in
                {UpdateOccProb Word T}
            end
        end
    [] Word|Wr then %If several words left
        if {CheckLabel {Arity Tree} Word} then %same as above
            local T = {UpdateOccProb Tree Word} in
                {Record.adjoinAt T Word {ParseWord Wr T.Word}}
                %Returns Tree with updated Word subtree
            end
        else 
            local T = {NewNode Word Tree} in %New node for new word
                local Tf = {UpdateOccProb Word T} in %Updates its occ and prob
                        {Record.adjoinAt Tf Word {ParseWord Wr Tf.Word}} %Keep on the parsing
                end
            end
        end
    end
end

fun {UpdateOccProb Word Tree}
    {Browse Word}
    {Browse Tree}
    local 
        TempT = {Record.adjoinAt Tree Word {Record.adjoinAt Tree.Word '_occ' Tree.Word.'_occ'+1.0}}
        FinalT= {Record.adjoinAt TempT Word {Record.adjoinAt TempT.Word '_prob' TempT.Word.'_occ'/TempT.'_occ'}}
    in
        FinalT
    end
end

fun {ParseTweet Tweet Words NGram N}
    case Tweet of nil then NGram %we looked at the whole file, return NGram
    [] T|Tr then
        if {List.length Words} < N then %Get new words from the tweet until we have as much as the degree of the N-gram
            {ParseTweet Tr {List.append Words T|nil} NGram N}
        else %We have enough words, call ParseWord
            local NewT = {ParseWord Words NGram} %Parse the words
                NewW = {List.append {List.drop Words 1} T|nil} %Drops 1st word, append T at the end
            in
                {ParseTweet Tr NewW NewT N} %Proceed with new selection and updated tree
            end
        end
    end
end

fun {StartParsing Path}
    local RootTree = {InstanciateNGram}
        WordsFromTweet = {CleanTweet Path}
    in
        {Browse WordsFromTweet}
        {ParseTweet WordsFromTweet nil RootTree 3}
    end
end

{Browse {StartParsing "LINFO1104\\Project\\Twit-Oz\\tweets\\test.txt"}}

%{DisplayList {FileToList "LINFO1104\\Project\\Twit-Oz\\tweets\\part_1.txt"}}