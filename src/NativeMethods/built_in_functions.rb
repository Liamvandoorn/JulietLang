# Hash with function name translations
$built_in_functions = {"@print"=>'print', "@input"=>'input'}

def print text
    # User function for printing to the terminal
    puts "[Juliet] => #{text}"
end


def input 
    # User function for taking in a value from the terminal
    text = $stdin.gets.chomp
    value = nil
    if text.to_i.to_s == text
        value = text.to_i
    elsif text.to_f.to_s == text
        value =  text.to_f
    else
        value = text
    end
    return value 
end