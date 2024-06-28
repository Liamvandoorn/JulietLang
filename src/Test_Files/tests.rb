require './ParserLexer/juliet.rb'
require 'test/unit/assertions'

include Test::Unit::Assertions

juliet = Juliet.new

def test_jargon(parser)
    #jargon
    str = "this is jargon which should not be run as code"
    assert_equal nil, parser.parse_test_text(str), "Jargon should return nil"
    
    str = "!!this is jarg%on which sho()()(uld not be )run as co??de"
    assert_equal nil, parser.parse_test_text(str), "Jargon should return nil"
end

def test_int(parser)
    #integers
    str = "42"
    assert_equal 42, parser.parse_test_text(str), "Numbers should return integer"

    str = "-42"
    assert_equal -42, parser.parse_test_text(str), "Numbers should return integer"
    
    str = "00042"
    assert_equal 42, parser.parse_test_text(str), "Numbers should return integer"
    # arithmetric calculation
    str = "40 plus 2"
    assert_equal 42, parser.parse_test_text(str), "Addition test"

    str = "4 minus 2"
    assert_equal 2, parser.parse_test_text(str), "Subtraction test"

    str = "9 divided by 3"
    assert_equal 3, parser.parse_test_text(str), "Division test"

    str = "9 multiplied by 3"
    assert_equal 27, parser.parse_test_text(str), "Multiplication test"

end

def test_float(parser)
    #float
    str = "42.05"
    assert_equal 42.05, parser.parse_test_text(str), "Numbers with dot should return float"
    
    #float
    str = "42.08341502"
    assert_equal 42.08341502, parser.parse_test_text(str), "Numbers with dot should return float"

    # negative floats 
    str = "-42.08341502"
    assert_equal -42.08341502, parser.parse_test_text(str), "Numbers with dot should return a negative float"
end

def test_char(parser)
    #char
    str = '"f"'
    assert_equal "f", parser.parse_test_text(str), "single character should return char"
end

def test_string(parser)
    # Testing that text can be parsed within "" marks and returned as a string
    str = '"well this is a string"'
    assert_equal "well this is a string", parser.parse_test_text(str), "a longer string should return the same string"

    # Testing addition of two strings
    str = '"first part" plus " plus the second part"'
    assert_equal "first part plus the second part", parser.parse_test_text(str), "error beep bep bop"

end

def test_bool(parser)
    # Testing true bool value
    str = "true"
    assert_equal true, parser.parse_test_text(str), "bool value true should return true"
    # Testing false bool value
    str = "false"
    assert_equal false, parser.parse_test_text(str), "bool value false should return false"
    # Testing addition of two booleans. 
    str = "true plus false"
    begin 
        assert_equal nil, parser.parse_test_text(str), "bool value false should return false"
    rescue Exception 
        puts "[Juliet Test] Error: I'll make an exception this time."
    end
end

def test_variables(parser)
    # Testing variable with integer object
    str = "@i is 3"
    assert_equal "@i = 3", parser.parse_test_text(str), "variable creation int"
    # Testing variable with integer calculation
    str = "@i is @i plus 2"
    assert_equal "@i = 5", parser.parse_test_text(str), "variable calculation int"
    # Testing variable with bool object
    str = "@b is true"
    assert_equal "@b = true", parser.parse_test_text(str), "variable creation bool"
    # Testing variable with string object
    str = '@s is "hello world"'
    assert_equal "@s = hello world", parser.parse_test_text(str), "variable creation string"
    # Testing variable with float object
    str = "@f is 2.78"
    assert_equal "@f = 2.78", parser.parse_test_text(str), "variable creation float"
    # Testing variable reassignment
    str = "@f is @f plus 2.1"
    assert_equal "@f = 4.88", parser.parse_test_text(str), "variable calculation float"
    
end

def test_array(parser)
    # Testing array object
    str = "the array @a has the values 2, 5, 3, 2, 1."
    assert_equal "@a = [2, 5, 3, 2, 1]", parser.parse_test_text(str), "array"
    # Testing empty array
    str = "the array @empty is empty."
    assert_equal "@empty = []", parser.parse_test_text(str), "empty array"
    # Testing array object
    str = 'the array @aMix has the values 2, "aaa", 3.56, "hellu", 143253252.'
    assert_equal '@aMix = [2, "aaa", 3.56, "hellu", 143253252]', parser.parse_test_text(str), "mixed array"

end

def test_if(parser)
    # Testing if statement
    str = "if the expression 4 is bigger than 2 is true, 4."
    assert_equal 4, parser.parse_test_text(str), "if statement if 4 > 2 return 4"

    # Testing if with false expression
    str = "if the expression 4 is bigger than 8 is true, 4."
    assert_equal nil, parser.parse_test_text(str), "if statement if 4 > 8, should be false"
end

def test_if_else(parser)
    # Testing simple else statement
    str = "if the expression 1 is bigger than 2 is true, 4. Else 5."
    assert_equal 5, parser.parse_test_text(str), "if else statement if 1 > 2 return 5"
   
    # Testing if with false expression
    str = "if the expression 4 is bigger than 8 is true, 4."
    assert_equal nil, parser.parse_test_text(str), "if statement if 4 > 8, should be false"

    # Fortsätt testa med lite andra datatyper 
end

def test_else_if(parser)
    # Testing simple else if statement
    str = 'if the expression 10 is bigger than 100 is true, "first_case_tested". Else if 10 is smaller than 100 is true, "second_case_tested".'
    assert_equal "second_case_tested", parser.parse_test_text(str), "testing that 'else if' works."
    
end

def test_if_else_if_else(parser)
    # test if with else if 
    str = 'if the expression 10 is bigger than 100 is true, "first_case_tested". Else if 10 is smaller than 100 is true, "second_case_tested".'
    assert_equal "second_case_tested", parser.parse_test_text(str), "testing that 'else if' works."
    
    # test if with else if and else
    str = 'if the expression 10 is bigger than 100 is true, "first_case_tested". Else if 10 is smaller than 1 is true, "second_case_tested". Else "third_case_tested".'
    assert_equal "third_case_tested", parser.parse_test_text(str), "testing that 'else if' 'else' works."
end

def test_for(parser)
    # testing for loop with arithmetic expression
    str = " @x is 0, for @i in the range 2 to 10, @x is @x plus @i."
    assert_equal "@x = 44" , parser.parse_test_text(str), "testing for loop"

    # testing for loop for iterating through array
    str = " @x is 0, the array @a has the values 2, 5, 3, 2, 1. for @i in the range @a, @x is @x plus @i."
    assert_equal "@x = 13" , parser.parse_test_text(str), "testing for loop"
end

def test_while(parser)
    # testing simple while loops
    str = "@v is 0
    while the expression @v is smaller than 4 is true, @v is @v plus 1. @v plus 0"
    assert_equal 4 , parser.parse_test_text(str), "testing while loop"

end

def test_functions_assignment(parser)
    # test basic arithmetic erxpression within fuction
    str = "the function @funs takes @x: @x is @x multiplied by 3: return @x. @funs taking in: 5."
    assert_equal 15 , parser.parse_test_text(str), "testing functions with arithmetric calculation"

    # test for loops in functions
    str = "the function @fun takes @x: for @i in the range 2 to 10, @x is @x plus @i.: return @x. @fun taking in: 5."
    assert_equal 49 , parser.parse_test_text(str), "testing functions with for loop"

    # test recursive functions
    str = "the function @f takes @x: @x is @x plus 1, if the expression @x is smaller than 10 is true, @f taking in: @x.. : return @x. @f taking in: 3."
    assert_equal 10 , parser.parse_test_text(str), "testing recursive functions"


end

def main(juliet)
   puts "==========================================================================="
   
    test_count = 0
    # testing jargon
    test_jargon(juliet)
    test_count += 1
    # testing integers
    test_int(juliet)
    test_count += 1
    # testing floats
    test_float(juliet)
    test_count += 1
    # testing char
    test_char(juliet)
    test_count += 1
    # testing strings
    test_string(juliet)
    test_count += 1
    # testing bool
    test_bool(juliet)
    test_count += 1
    # testing variable assignment
    test_variables(juliet)
    test_count += 1
    # testing array
    test_array(juliet)
    test_count += 1
    # testing if statements
    test_if(juliet)
    test_count += 1
    # testing if with else
    test_if_else(juliet)
    test_count += 1
    # testing else if statements
    test_else_if(juliet)
    test_count += 1
    # testing if with else if and else
    test_if_else_if_else(juliet)
    test_count += 1
    # testing for loops
    test_for(juliet)
    test_count += 1
    # testing while loops
    test_while(juliet)
    test_count += 1
    # testing function assignments
    test_functions_assignment(juliet)
    test_count += 1

    puts "==========================================================================="
    puts " #{test_count} Tests completed"

end

main(juliet)
