
# Nodes.rb is responsible for building AST matched by found token sets in Juliet.rb
# This module uses runtime.rb to evaluate built AST.

class TopNode
    # Topnode is instansiated only in juliet.rb program rule, stores all statements in the program
    #   -statements: all statements in the program
    #   -scope: the current scope

    def initialize statements, scope 
        @statements = statements
        @scope = scope
    end
 
    
    def evaluate 
        # Evaluates the statements
        # if the statement is string it is ignored because it is Jargon

        result = nil
        if @statements.class != String and @statements.class != Array
            result = @statements.evaluate @scope  
        elsif @statements.class == Array
            x = @statements.each {|e| 
                if e.class != String    
                    result = e.evaluate @scope
                end
            } 
        end
        return result
    end
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Arithmetic expressions ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


class Artihmetic_node
    # Arithmetic and logic expressions
    #   -hl: right value in the expression
    #   -op: the operator used in the expression
    #   -vl: left value in the expression

    def initialize hl, op, vl 
        @hl = hl
        @op = op
        @vl = vl
    end

    def evaluate scope
        # Evaluate expression using Arithmetic_calculation from runtime.rb
        calc = Arithmetic_calculation.new @hl, @op, @vl, @scope
        return calc.run
    end
end

class Operator_node
    # Storing and translating an operator
    #   -operators: hash for translating Juliet operators to Ruby operators
    #   -op: the saved operator

    def initialize op
        @operators = {"plus"=>"+", "minus"=>"-", "multiplied by"=>"*", "divided by"=>"/", "is smaller than"=>"<", "is bigger than"=>">", "is equal to"=>"==", "is not equal to"=>"!="}
        @op = op
    end

    def evaluate scope
        # translate saved operator, takes current scope as parameter
        return @operators[@op]
    end
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Object/Datatype Constructions ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


class Object_node
    # Parent class for all datatypes

    # evaluating returns the value
    def evaluate scope
        return self.value
    end

    # get the class of the object
    def check_type
        return self.class 
    end
end

class Unknown_obj
    # Class for saving "unknown" objects in variables
    
    def initialize value
        # Initializes an Unknown_obj instance with the given value
        #   - value: The value to be stored

        @value = value
    end

    #Checks if @value has a meathod evaluate before returning value
    def evaluate scope
        # Evaluates the object in the given scope
        #   - scope: The scope in which the object is evaluated
        #
        # Returns:
        #   - The evaluated value of the object
        
        if @value.class.method_defined? :evaluate
            return @value.evaluate(scope)
        else
            return @value
        end
    end
end

class Integer_obj < Object_node
    # store an integer value
    #   -value: the number being stored
    #   -negative: boolean to check if the number is negativ or positive

    attr_reader :value
    def initialize value, negative = false
        @value = value
        @negative = negative
    end

    def evaluate scope
        # evaluate with current scope, return integer and multiply by -1 if negative is true

        if @negative == true
            return @value.to_i * -1
        else
            return @value.to_i
        end
    end
end

class Float_obj < Object_node
    # store a float value
    #   -value: stored float value
    #   -number: value of the first part of the float (before the dot) or a float value
    #   -decimal: value of the second part of the float (after the dot) or nil
    #   -negative: boolean to check if the number is negativ or positive

    attr_reader :value
    def initialize number, decimal=nil, negative = false
        check_value(number, decimal) 
        @negative = negative
    end
    
    
    def check_value number, decimal 
        # check if number is float or string, if string make float with decimal
        
        if decimal == nil 
            @value = number.to_f
        else 
            @value = number.concat(decimal.prepend(".")).to_f
        end
    end

    def evaluate scope
        # evaluate with current scope, return float and multiply by -1 if negative is true
        
        if @negative == true
            return @value * -1
        else
            return @value
        end
    end
end

class Boolean_obj < Object_node
    # stores bool object
    #   -value: bool value

    attr_reader :value
    def initialize value
        @value = value
    end
end

class Char_obj < Object_node
    # stores a single character
    #   -value: one character
    
    attr_reader :value
    def initialize value
        @value = value
    end
end

class String_obj
    # stores a list of characters (Char_obj) to make a string
    #   -value: array of characters

    attr_reader :value
    def initialize value
        @value = value
    end

    def evaluate scope
        # evaluate puts the array together to a string
        
        string_result = Array.new
        if @value.class == Array
            for i in @value  
                string_result.append(i.evaluate(scope))
            end
        else
            if @value.class.method_defined? :evaluate
                string_result.append(@value.evaluate(scope))
            else
                string_result.append(@value)
            end
        end

        string_result.join
    end
end


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Variables ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


class Variable_creation_node
    # creates variables
    #   -name: name of variable
    #   -value: value of variable

    attr_reader :name, :value
    
    def initialize name, value
        @name = name.name
        @value = value
    end

    def evaluate scope
        # evaluate with current scope, evaluate value if needed and add variable to scope

        value = @value
        if @value.class.method_defined? :evaluate
            if @value.class == Artihmetic_node or @value.class == Function_call_node
                result = value.evaluate(scope)
                if result.class == Integer
                    value = Integer_obj.new result
                elsif result.class == Float
                    value = Float_obj.new result
                elsif result.class == String
                    value = String_obj.new result
                end
            end
                  
        else
            if value == Integer
                value = Integer_obj.new result
            elsif value == Float
                value = Float_obj.new result
            elsif result.class == String
                value = String_obj.new result
            end
        end
        $stack.get.add_var(@name, value)
        return "#{@name} = #{value.evaluate(scope)}"  
    end
end

class Possible_variable
    # Possible_valiable, name that could be referencing an existing variable or function
    #   -name: the name of a valriable or function
    
    attr_reader :name
    def initialize(name)
        @name = name
    end

    
    def evaluate(scope, call_function_type = false)
        # if the name is known to be a function, run call_func_type, otherwise run call_var_type
        #   -scope: current scope
        #   -call_function_type: true if the name is known to be a function

        if call_function_type
            return call_func_type 
        else 
            return call_var_type(scope)
        end 
    end

    def call_func_type 
        # search scope for function

        func_obj = $stack.get.get_function_object(@name)
        if func_obj == nil
            raise NameError, "<# undefined function>"
        else 
            return func_obj
        end
    end 

    def call_var_type(scope) 
        # search scope for variable, if variable is not found search for funcion

        var_obj = $stack.get.get_variable_object(@name)
        if var_obj == nil
            func_obj = $stack.get.get_function_object(@name)
            if func_obj == nil
                raise NameError, "<# undefined variable or function>"
            else 
                return func_obj
            end
        else
            return var_obj.evaluate(scope)
        end
    end
end


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Arrays ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class Array_creation_node
    def initialize name, values
        # Class responsible for creating Array_creation_node instances with the given name and values
        # - name: The name of the array variable
        # - values: The values to be assigned to the array
        @name = name.name
        @values = values
    end

    def evaluate scope
        if @values != nil
            $stack.get.add_var(@name, Array_obj.new(@values))
            a = Array.new
            @values.each{|e| a.append(e.evaluate(scope))}
        else
            $stack.get.add_var(@name, Array_obj.new(nil))
            a = []
        end
        
        return "#{@name} = #{a}"
    end
end

class Array_obj
    def initialize obj
        # Class responsible for Array_obj instances with the given object
        #   - obj: The object to be stored in the array
        @obj = obj
    end

    def evaluate scope
        return @obj
    end
end



#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: If Statements ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class If_elsif_else_node
    # This class functions like a parent node, utilising and below if_else elsif else classes to evaluate a result.

    def initialize if_node, elsifs = nil, else_ = nil
        # Class represents an If_elsif_else_node instance with the given if node, elsif nodes, and else node
        #   - if_node: The if node representing the initial condition
        #   - elsifs: An array of elsif nodes representing additional conditions (optional)
        #   - else_: The else node representing the fallback condition (optional)

        @if = if_node
        @elsifs = elsifs
        @else = else_
    end

    def evaluate scope
        matched_condition = false

        # Check if the initial if condition is true
        if @if.eval_expr(scope) == true
            return @if.evaluate(scope)
        end

        # Check if there are elsif conditions in the form of an array
        if @elsifs.class == Array 
            matched_condition = false

            # Iterate over each elsif condition
            @elsifs.each {|e| 
                if matched_condition == false
                    # Evaluate the elsif condition
                    if e.eval_expr(scope) == true
                        return e.evaluate(scope)
                        matched_condition = true 
                    end 
                end
            }
        end

        # Check if there is a single elsif condition
        if @elsifs.class != Array and @elsifs != nil
            # Evaluate elsif condition
            if @elsifs.eval_expr(scope)
                return @elsifs.evaluate(scope)
            end
        end

        # Evaluate the else condition if it exists
        if @else != nil
            return @else.evaluate(scope)
        end
    end 
end 

class If_statement_node 

    def initialize expr, statements 
        @expr = expr
        @statements = statements
    end

    def eval_expr scope
        @expr.evaluate(scope)
    end

    def evaluate(scope)
        if eval_expr(scope)
            run_if(@statements, scope)
        end
    end
end

class Else_if_statement_node 

    def initialize expr, statements 
        @expr = expr
        @statements = statements
    end

    def eval_expr scope
        @expr.evaluate(scope)
    end    

    def evaluate(scope)
        run_if(@statements, scope)
    end
end

class Else_node
    def initialize statements
        @statements = statements
    end

    def evaluate scope
        run_if(@statements, scope)
    end
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Loops ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class For_statement_node
    # Class representing a for loop statement

    def initialize(var_name, range_expr, statements)
        # Initializes a for loop statement with the given parameters
        # Parameters:
        #   - var_name: The name of the loop variable
        #   - range_expr: The expression defining the range for the loop
        #   - statements: The statements to be executed in the loop

        @var_name = var_name.name
        @range_expr = range_expr
        @statements = statements
    end
    
    def evaluate(scope)
        # Evaluates the for loop statement in the given scope
        #   - scope: The scope in which the loop is evaluated
        # Returns:
        #   - The result of the loop evaluation, if any

        if @range_expr.class == Range_node
            start, stop = @range_expr.evaluate(scope)
            $stack.append Scope.new(:for, $stack.get.identifier)
            start_obj = Integer_obj.new(start)
            $stack.get.add_var(@var_name, start_obj)
            ################################################
            # Run the loop based on the range values

            if start < stop
                return run_for(@var_name, start, stop, @statements, 1)
            elsif start > stop
                return run_for(@var_name, start, stop, @statements, -1)
            end
            $stack.pop
            #################################################
            
        elsif @range_expr.class == Possible_variable
            var_value = @range_expr.evaluate(scope)
            if var_value.class == Array
                result = nil 
                for i in var_value do
                    $stack.get.add_var(@var_name, Unknown_obj.new(i))
                    result = run_all_statements(@statements, $stack.get.identifier)
                end
                $stack.pop
                return result
            end
        else 
            raise "Expected a range expression for the loop, got #{@range_expr.class}"
        end

    end
end 

class While_statement_node
    #class representing our while statements

    def initialize expr, statements
        # Initializes a while loop statement with the given parameters
        #   - expr: The expression to evaluate for the loop condition
        #   - statements: The statements to be executed in the loop
        
        @expr = expr
        @statements = statements
    end

    def evaluate scope
        while @expr.evaluate(scope) 
            # Continue looping while the expression evaluates to a True value
            run_if(@statements, scope)
        end 
    end
end

class Range_node
    def initialize begin_range, end_range
        # Initializes a Range_node instance with the given begin and end range values
        #   - begin_range: The start value of the range
        #   - end_range: The end value of the range

        @begin = begin_range
        @end = end_range
    end

    def evaluate scope
        # Function evaluates the range in the given scope and returns the begin and end values
        return evaluate_to_primitive_type(@begin, scope), evaluate_to_primitive_type(@end, scope)
    end
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Function Assignments ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


class Function_assignment_node
    def initialize(name, parameters = nil, statements, return_statement)
        # Class responsible for creating a function assignment node with the given parameters
        #   - name: Name of the function
        #   - parameters: Parameters of assigned function ( is optional )
        #   - statements: Statements to be evaluated inside the function
        #   - return_statement: The return statement of the whole function

        @name = name.name
        @parameters = parameters
        @statements = statements
        @return_statement = return_statement
    end

    def evaluate scope
        $stack.get.add_function(@name, @parameters, @statements, @return_statement)
    end
end

class Function_call_node
    def initialize name, parameters = nil
        # Class responsible for Function_call_node instances with the given name and parameters
        #   - name: The name of the function to call
        #   - parameters: The parameters to pass to the function (optional)

        @name = name
        @parameters = parameters
    end

    def evaluate scope
        function_call(@name, @parameters, scope)
    end
end

