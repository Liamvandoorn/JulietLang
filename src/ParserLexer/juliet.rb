require './ParserLexer/rdparse.rb'
require './Execution/runtime.rb'
require './AST_Nodes/nodes.rb'

                      #                ######    (#########                                                                 
                      #     ##############       ############                                                               
                      #   *##########  ########### ##########                                                               
                      #    ######## (########  ###### ######                                                                
                      #     ########  ####### ######  ####                                                                  
                      #        ###/  /##########   ##### ###                                                                
                      #         #######  ##### /##### .###### ######/                                                       
                      #     *## ##########   ##### /######### #########                                                     
                      #    #### ######### ###  ############## ##########                                                    
                      #  .##### #######  ################### #############                                                  
                      #  ###### ######  #################### #########                                                      
                      #   ###### ##### #################### ########                                                        
                      #     *####,*### ################### #######.                                                         
                      #         ####,#  ################  #######                                                           
                      #             ###  #############  ######                                                              
                      #                    #######* @@@@@@@                                                                 
                      #                    @@@@@@@* @@   @@@@@@@@@                                                               
                      #                    @@@@@@@%    @@                                                                          
                      #                                @@                                                                          
                      #                                @@.                                                                         
                      #                                @@(                                                                         
                      #                                @@*         @@@@                                                            
                      #                                @@ @@@@@@@@@@@@                                                             
                      #                @               @@@@@  (@@@@@@                                                              
                      #                @@@@@@@@@      *@@@@@@@@@@@                                                                 
                      #                 @@@@@@@@@@@   @@                                                                           
                      #                  @@@@@@/ @@@/*@@                                                                           
                      #                    @@@@@@% @@@@                                                                            
                      #                         @@@(@@@                                                                            
                      #                            @@@                                                                             
                      #                            @@                                                                              
                      #                           @@%                                                                              
                      #                          @@@                                                                               
                      #                         @@@                                                                                
                      #                        @@@                                                                                 
                      #                       @@@                                                                                  
                      #                     %@@@                                                                                   
                      #                    @@@@.                                                                                   
                                                                                                                                  

class Juliet

  attr_accessor :topNode
  
  def initialize

    @topNode = nil

    variables = Hash.new

    @julietParser = Parser.new("Juliet") do
      
    in_string = false

    @@global_scope = Scope.new(:global)
    $stack = Stack.new @@global_scope


      # operators
      token(/\s+(?=(?:(?:[^"]*"){2})*[^"]*"[^"]*$)/){|s| s}
      token(/\s+/)
      #token(/\n/)
      token(/plus/) {|a| a}
      token(/minus/) {|a| a}
      token(/divided by/) {|a| a}
      token(/multiplied by/) {|a| a}
      
      #comparison operators
      token(/is smaller than/){|a| a}
      token(/is bigger than/){|a| a}
      token(/is equal to/) {|a| a}
      token(/is not equal to/) {|a| a}

      #control structure
      token(/if/) {|a| a}
      token(/expression/) {|a| a}
      token(/Else if/) {|a| a}
      token(/Else/) {|a| a}
      token(/then/) {|a| a}
      token(/while the expression/) {|a| a}
      token(/for/) {|a| a}
      token(/in the range/) {|a| a}
      token(/to/) {|a| a}
      
      #assignment and creations 
      token(/is/) {|a| a}
      token(/empty/){|a| a}
      token(/the/) {|a| a}
      token(/function/) {|a| a}
      token(/takes/) {|a| a}
      token(/taking/) {|a| a}
      token(/in/) {|a| a}
      token(/array/) {|a| a}
      token(/has the values/) {|a| a}
      token(/no parameters/) {|a| a}
      token(/no parameter/) {|a| a}

      #function expressions
      token(/return/) {|a|a}
      token(/returned/) {|a|a}
      token(/:/){|m| m} #1 

      # booleans
      token(/true/) {|a| a}
      token(/false/) {|a| a}
      
      # 
      token(/\./){|m| m}
      token(/\"/) {|m| m}
      token(/,/){|m| m}
      token(/'/)      
      token(/`/)
      token(/\d+/) {|m| m }
      
      # Variables and parameters
      token(/@\w+/){|m| m} 
      token(/./) {|a| a}

      token(/[åäöÅÄÖ]/) {|a| a}
      
      start :program do 
        match(:statements) {|a| 
          topNode = TopNode.new(a, @@global_scope.identifier)
          topNode.evaluate
        }
      end
      
      rule :statements do
        #have multiple statements by putting the first statement in the front of the list of other statements
        match(:statement, :statements){|s, sList| 
          if sList.class == Array
            x = sList.unshift(s) 
          elsif sList.class != Array
            x = [s, sList]
          end
          x
        } 
        match(:statement)
      end

      rule :statement do
        match(:assignment) 
        match(:control_structure)
        match(:expression)
        match(:jargon)
      end

      rule :jargon do
        match(/[\w0-9åäöÅÄÖ!%#*\(\)?]+/) {|e| e }
        match(/,/){|e| e }
      end 

      rule :control_structure do
        match(:for_loop) 
        match(:while) 
        match(:if_else)
      end

      rule :for_loop do
        match("for", :identifier, "in the range", :range, ",", :statements, ".") { | _, a, _, b, _, c, _|
         For_statement_node.new(a,b,c)
        } 
      end

      rule :range do
        match(:factor, "to", :factor) {|a, _, b| Range_node.new(a, b)}
        match(:identifier)
      end
      
       rule :while do
         match("while the expression", :expression, "is", "true" , ",", :statements, ".") { | _,  a, _, _, _, b, _, |
          While_statement_node.new(a,b)
        }
       end

      rule :if_else do
        match(:if, :else_ifs, :else){|a, b, c| 
        If_elsif_else_node.new(a, b, c)
      }
        match(:if, :else_ifs) {|a, b| 
          If_elsif_else_node.new(a, b)
        } 
        match(:if, :else){|a, b| 
          If_elsif_else_node.new(a, nil, b)
      }
        match(:if)
      end
      
      rule :if do
        match("if", "the", "expression", :expression, "is", "true" , ",", :statements, ".") {
          |_, _, _, a, _, _, _, b, _|   
          If_statement_node.new(a, b)
        }
      end

      rule :else_ifs do 
          match(:else_if, :else_ifs) {|a, b| 
            if b.class == Array
              x = b.unshift(a) #append but from front i think
            elsif b.class != Array
              x = [a, b]
            end
            x
          } 
          match(:else_if) 
      end

      rule :else_if do 
        match("Else if", :expression, "is", "true" , ",", :statements, ".") {
          | _, a, _, _, _, b, _ |
          Else_if_statement_node.new(a, b)
        }
      end
      
      rule :else do 
        match("Else", :statements, "."){
          |_, a, _|   
          Else_node.new(a)
        }
      end

      rule :assignment do
        match(:function_assignment){|a| 
        a}
        match(:variable_assignment) {|a| 
        a}
       
      end
  
      rule :variable_assignment do 
        match(:identifier, "is", :expression) {|a, _, b| 
        Variable_creation_node.new(a, b)
      }
        match(:array)
      end

      rule :function_assignment do

         #   # No parameters, no return
        match("the", "function", :identifier, "takes", "no parameters", ":", :statements, ".") {|_, _, id, _, par, _, s, _|
            Function_assignment_node.new(id, par, s, nil)
        }
        # # No parameters, with return
        match("the", "function", :identifier, "takes", "no parameters", ":", :statements, ":", :return, ".") {|_, _, id, _, par, _, s, _, r, _|
            Function_assignment_node.new(id, nil, s, r)
        }
        # with parameters, with return
        match("the", "function", :identifier, "takes", :parameters, ":", :statements, ":", :return, ".") {|_, _, id, _, par, _, s, _, r, _|
            Function_assignment_node.new(id, par, s, r)
        }
        # with parameters, no return
          match("the", "function", :identifier, "takes", :parameters, ":", :statements, ".") {|_, _, id, _, par, _, s, _|
            Function_assignment_node.new(id, par, s, nil)
        }
      end

      rule :return do
        match( "return", :expression) {|_, a | a} 
      end 
      
      rule :call do 
        match(:function)
      end
      
      rule :function do 
        match(:identifier, "taking", "in", "no parameters", "."){|id|
          Function_call_node.new(id)
        }
        match(:identifier, "taking", "in", ":", :factors, ".") {|id, _, _, _, par, _|
          Function_call_node.new(id, par)
        }
      end
      
      rule :array do 
        match("the", "array", :identifier, "has the values", :factors, "."){|_, _, a, _, b, _|
        Array_creation_node.new(a, b)}
        match("the", "array", :identifier, "is", "empty", "."){|_, _, a, _, _, _|
        Array_creation_node.new(a, nil)}
      end
      
      rule :expression do
        match(:call)
        match(:expression, :op, :factor) {|a, op, b| Artihmetic_node.new(a, op, b)} 
        match(:factor) 
        
      end 

      rule :factors do 
        match(:factor, ",", :factors) { |a, _, b|
          if b.class == Array
            x = b.unshift(a) #append but from front i think
          elsif b.class != Array
            x = [a, b]
          end
          x
        }
        match(:factor) 
      end
      

      rule :factor do 
        match(:variable)
        match(:string) 
        match(:number) {|d| d }    
        match(:boolean) {|a|a} 
        match("(", :expression, ")")
      end

      rule :op do
        match(:binary_op)
        match(:bool_op)
      end

      rule :bool_op do
        match(:compare)
        match(:and_or)
      end

      rule :compare do
        match("is smaller than") {|op| Operator_node.new(op) }
        match("is bigger than") {|op| Operator_node.new(op) }
        match("is equal to") {|op| Operator_node.new(op) }
        match("is not equal to") {|op| Operator_node.new(op) }
      end

      rule :and_or do
        match("and")
        match("or")
      end

      rule :binary_op do 
        match(:add_op)
        match(:sub_op)
        match(:mult_op)
        match(:div_op)
      end

      rule :add_op do
        match("plus") {|op| Operator_node.new(op) }
      end

      rule :sub_op do 
        match("minus") {|op| Operator_node.new(op) }
      end

      rule :unary_op do
        match("plus") {|op| Operator_node.new(op) }
        match("minus") {|op| Operator_node.new(op) }
      end

      rule :mult_op do
        match("multiplied by") {|op| Operator_node.new(op) }
      end

      rule :div_op do
        match("divided by") {|op| Operator_node.new(op) }
      end

      rule :parameters do 
        match("no parameter"){nil}
        match(:parameter, :parameters)
        match(:parameter)
      end

      rule :parameter do 
        match(/@[A-Za-z0-9_]+/){|par| par}
      end

      rule :identifier do
        match(/@[a-z][A-Za-z0-9_]*/){|i| Possible_variable.new(i)}
      end

      rule :variable do 
        match(/@[A-Za-z0-9_]+/) {|v| Possible_variable.new(v)}
      end

      rule :boolean do
        match("true"){
        Boolean_obj.new(true) 
      }
        match("false"){Boolean_obj.new(false) }
      end
        
      rule :string do
        match(/"/, :characters, /"/){ | n, a, _|
          string = String_obj.new(a)
        }
      end

      rule :characters do
        match(:char, :characters){|a, b|
          if b.class == Array
            x = b.unshift(a) #append but from front i think
          elsif b.class != Array
            x = [a, b]
          end
          x
        }
        match(:char) {|a| a}
      end

      rule :number do
        match(:float) {|f| f}
        match(:integer) 
      end

      rule :integer do
        match(:digit) {|d|
          Integer_obj.new(d) 
        }
        match("-", :digit) {|_, d|
          Integer_obj.new(d, true) 
        }
      end

      rule :float do 
        match(:digit, ".", :digit) {|a, _, b| Float_obj.new(a, b) }
        match("-",:digit, ".", :digit) {|_, a, _, b| Float_obj.new(a, b, true) }
      end

      rule :digit do 
        match(/\d+/) {|d| d}
      end

      rule :char do
        match(/\w{1}/) {|d| 
        Char_obj.new(d)}

        match(/\s/) {|d| 
        Char_obj.new(d)}
      end
    end
  end
     
    
  def done(str)
    ["quit","exit","bye",":qa!"].include?(str.chomp)
  end
  
  def parse file
  #parse entire file of code

    path = file
    f = File.read(path)
    str = f
    if done(str) then
      puts "Farewell..."
    else
      @julietParser.parse str
    end
  end

  #parse line by line
  def parse_lines file
    path = file
    f = File.readlines(path)
    for line in f do
      str = line
      if done(str) then
        puts "Farewell..."
      else
        @julietParser.parse str
      end
    end
  end

  def parse_test_text str
    parsed_text = @julietParser.parse(str)
    puts "[Juliet Test] => #{(parsed_text)}"
    return parsed_text
  end
  

  def log(state = true)
    if state
      @julietParser.logger.level = Logger::DEBUG
    else
      @julietParser.logger.level = Logger::WARN
    end
  end
end
