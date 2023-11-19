require './ParserLexer/juliet.rb'
require './NativeMethods/built_in_functions'

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::: Runtime Datatypes ::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class Scope
    # Scope class for juliets dynamic scope
    #   - Identifier: Is used to assign a assocation with whatever scope is created in (Makes it easy during debugging)
    #   - Parent_id: Knows it's parent so we can recursively search for objects 
    #   - Variable_stack: Stack for variables
    #   - Function_stack: Stack for functions

    attr_reader :identifier, :parent_id, :variable_stack, :function_stack

    # initialises scope_id, parent_scope id and a hash for the variables
    def initialize id, parent_id = nil
        @identifier = id
        @parent_id = parent_id
        @variable_stack = Hash.new
        @function_stack = Hash.new
    end

    def add_var id, object
        # Add a variable to the variable stack given that it doesn't exist in any parent scopes.
        if @variable_stack.has_key?(object)
            @variable_stack[id] = object 
        # if there's parent scopes, check if the variable exists in parents, if yes, overwrite the variable otherwise, make a new.
        elsif parent_id != nil
            if $stack.get_scope_by_id(parent_id).overwrite_var(id, object) == nil #id vi vill använda man den säger att den inte finns
                @variable_stack[id] = object
            end
        #if the current scope is global and it does not contain the variable, create the variable
        else
            @variable_stack[id] = object
        end

    end

    def overwrite_var id, object
        # Function for overwriting a variable (id) with given object, goes through parent scopes to check if a existing variable to overwrite exists
        #   - id: variable id to overwrite value 
        #   - object: new variable value

        #if the variable is in the current scope, overwrite
        if @variable_stack.has_key?(id)
            @variable_stack[id] = object
        #if the variable is not in the current scope and the scope is not global
        elsif parent_id != nil
            return $stack.get_scope_by_id(parent_id).overwrite_var(id, object)
        #if the current scope is global and does not have variable, variable does not exist
        else
            return nil
        end
    end

    def check_func id
        # Check if a function exists in given scope or parent scopes
        #   - id: function id to chec in function_stack

        if @function_stack.has_key?(id)
            raise "Can't allocate a new function with a existing function name."
        elsif parent_id != nil
            return $stack.get_scope_by_id(parent_id).check_func(id)
        else
            return nil
        end
    end

    def add_function id, parameters, object, return_s
        # Add function with id, parameters, object and return statement.
        #   - Value of function is given as a array with parameters and statements such as [[&x], [&x plus 2]]

        if @function_stack.has_key?(object)
            @function_stack[id] = [parameters, object, return_s]
        # If there's parent scopes, check if the variable exists in parents, if yes, overwrite the variable otherwise, make a new.
        elsif parent_id != nil
            if $stack.get_scope_by_id(parent_id).check_func(id) == nil #id vi vill använda man den säger att den inte finns
                @function_stack[id] = [parameters, object, return_s]
            end
        #if the current scope is global and it does not contain the variable, create the variable
        else
            @function_stack[id] = [parameters, object, return_s]
        end

    end

    def get_variable_object id
        # Get variable by name
        if @variable_stack.has_key?(id)
            return @variable_stack[id]
        # If the scope does not contain the variable ask parent
        elsif parent_id != nil
            return $stack.get_scope_by_id(parent_id).get_variable_object(id)
        # Variable does not exist
        else
            return nil
        end
    end

    def get_function_object id
    # Function to get scopes
        if @function_stack.has_key?(id)
            return @function_stack[id]
        #if the scope does not contain the variable ask parent
        elsif parent_id != nil
            return $stack.get_scope_by_id(parent_id).get_function_object(id)
        #variable does not exist, raise error
        else
            return nil
        end
    end

end

class Stack
    # Juliets object for storing the scopes
    #   - name: initialises scope with given name.
    
    def initialize name
        @stack = [name]
    end

    def append value
        @stack << value
    end

    def pop
        @stack.pop
    end

    def get
        @stack.last
    end

    def debugg_print
        # Debugging function for printing out all current scopes and their contents

        @stack.each {|e|
        puts
        puts " ::::::::::::START OF DEBUG ::::::::::::: "
        puts "::::::::VARIABLE STACK :::::::::"
        e.variable_stack.each {|f|
            p f
        }
        puts "::::::::FUNCTION STACK::::::::::"
        e.function_stack.each {|f|
            p f
        }
        puts " ::::::::::::: END OF DEBUG ::::::::::: "
        puts
        }
    end

    def get_scope_by_id id
        @stack.each {|e|
            if e.identifier == id
                return e
            end
        }
    end
end

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#     ::::::::::::::::::: Runtime Arithmetic objects ::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

class Arithmetic_calculation
    # Used to execute evalution in arithmetic nodes and their sub classes.
    #   - vl: Left side of expression
    #   - op: Operator used in expression
    #   - hl: Right side of expression
    #   - Scope: 

    def initialize vl, op, hl, scope
        @vl = vl
        @op = op
        @hl = hl
        @scope = scope
    end

    def run
        #evaluate values and calculate
        eval_vl = @vl.evaluate(@scope)
        eval_hl = @hl.evaluate(@scope)
        # Make sure they're the same type and not a boolean
        if  check_type(eval_vl) == check_type(eval_hl) and is_boolean(eval_vl) == false and is_boolean(eval_hl) == false
            return eval_vl.method(@op.evaluate(@scope)).(eval_hl)
        elsif is_boolean(eval_vl) == true or is_boolean(eval_hl) == true
            raise "[Juliet] Error: uh... arithmetic expression with boolean?"
        else
            raise Exception "[Juliet] Error: The factors in the arithmetic calculation aren'th the same datatype."
        end
    end

    def is_boolean value
        result = nil
        if value.class == true or value.class == false
            return result = true
        else
            return result = false
        end
    end

    def check_type object
        return object.class
    end
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::: Control Structures ::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

def run_if statements, scope
    # Function for calculating statements in if & Elsie_if nodes.
    #   - statements: statements to be evaluated.
    #   - scope: necessary for the evaluate function within run_all_statements.
    
    # create new scope for if_statement
    $stack.append Scope.new(:if, $stack.get.identifier)
    result = nil
    result = run_all_statements(statements, scope)

    # kill everything created if_statement after a result has been evaluated.
    $stack.pop
    return result
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Loops ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

def run_for var_name, start, stop, statements, change_var
    # Execute a loop for a specified range of values and perform statements within the loop
    #  - var_name: represents the name of the variable being iterated
    #  - start: the starting value of the loop
    #  - stop: the ending value of the loop 
    #  - statements: the code statements to be executed within the loop
    #  - change_var: the amount by which the variable value should change in each iteration

    result = nil

    start_checked = start
    stop_checked = stop

    # reverse the start and stop values if start is bigger than stop for obvious reasons
    start_checked = stop && stop_checked = start if start > stop

    $stack.get.add_var(var_name, Integer_obj.new(start_checked))

    #Evaluate all statements, calculate new value with variable and change_var, change variable to new value
    for i in start_checked..stop_checked-1 do
        result = run_all_statements(statements, $stack.get.identifier) # incase we have multiple statements
        new_value = Integer_obj.new($stack.get.get_variable_object(var_name).value + change_var)
        #new_value = Integer_obj.new(var_name.evaluate($stack.get) + change_var)
        $stack.get.add_var(var_name, new_value)
    end
    return result
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::::::::::::: Executing multiple statements ::::::::::::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

def run_all_statements statements, scope
    # Function for evaluating multiple statements.
    #   - statements: If it's a string, it's jargon, if it's a array, we have multiple statements, each statement will be called to be evaluated.
    #   - scope: necessary to evaluate statements

    if statements.class != String and statements.class != Array
        result = statements.evaluate scope
    elsif statements.class == Array
        statements.each {|e|
            if e.class != String
                result = e.evaluate scope
            end
        }
    end
    return result
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ::::::::: Parameter handling & Function calling::::::::::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

def set_variables_to_parameter_values(parameter_names, parameter_values)
    # Function responsible for setting a function's parameters to the values that have been sent in with the function call
    #   - parameter_names: user-given parameter names
    #   - parameter_values: user-given parameter values

    # Check if both parameter names and parameter values are nil (not provided)
    if parameter_names == nil and parameter_values == nil
        return
    # Check if parameter names are nil but parameter values are not nil
    elsif parameter_names == nil and parameter_values != nil
        raise "<# Expected no parameters >"
    # Check if parameter names are not nil and not equal to "no parameter", and parameter values are nil
    elsif (parameter_names != nil and parameter_names != "no parameter") and parameter_values == nil
        raise "<# Expected parameter >"
    #
    elsif parameter_names.class == Array and parameter_values.class == Array
        # Check if the size of parameter names array is equal to the size of parameter values array
        if parameter_names.size == parameter_values.size
            # Iterate over the parameter names and values
            for i in 0..parameter_names.size do
                if parameter_values[i].class == Possible_variable
                    # Evaluate the possible variable and check if it exists
                    var = parameter_values[i].evaluate($stack.get)
                    if var == nil
                        raise NameError, "<# Variable not found.>"
                    end
                    # Save value in Unknown_obj to avoid evaluation problems
                    var = Unknown_obj.new(var)
                    $stack.get.add_var(parameter_names[i.name], var)
                else
                    $stack.get.add_var(parameter_names[i.name], parameter_values[i])
                end
            end
        else
            raise "<# Given the wrong number of parameters >"
        end
    else
        if parameter_values.class == Possible_variable
            # Evaluate the possible variable and check if it exists
            var = parameter_values.evaluate($stack.get)
            if var == nil
                raise NameError, "<# Respectfully, the variable does not exist.>"
            end
            # Save value in Unknown_obj to avoid evaluation problems
            var = Unknown_obj.new(var)
            $stack.get.add_var(parameter_names, var)
        else
            $stack.get.add_var(parameter_names, parameter_values)
        end
    end
end

def evaluate_to_primitive_type obj, scope
    # Evaluate an object and return its primitive type value within the given scope
    #  - obj: the object to be evaluated
    #  - scope: the scope in which the evaluation should be performed

    # If it is a string, check variables; if it returns nil, check functions; if it returns nil, raise an error
    if obj.class == String
        var_obj = $stack.get.get_variable_object(obj)
        if var_obj == nil
            func_obj = $stack.get.get_function_object(obj)
            if func_obj == nil
                raise NameError, "<# Function object not found.>"
            else
                return func_obj.evaluate(scope)
            end
        else
            return var_obj.evaluate(scope)
        end
    end
    return obj.evaluate(scope)
end

def function_call name, parameters, scope
    #  Function responsible for handling function calls by evaluating the function based on its name and parameters within the given scope
    #   - name to check if function is a already built in function that we can use, otherwise X.
    #   - parameters as a function usually requires
    #   - scope to make sure it lives in the right scope. 

    # the function will check if we call a already built in function, otherwise we'll check with name.evaluate(scope,true) to see if it's a user built function. 

    built_in_func = name.name
    # If we call a built in function, evaluate found built in function
    if $built_in_functions.key? built_in_func
        eval_parameters = parameters
        if parameters != nil and parameters.class != Array
            eval_obj = parameters.evaluate(scope)
            eval_parameters = eval_obj.to_s.prepend(' "' ).concat('"') # evaluate parameters and make them into string
        elsif parameters.class == Array
            eval_parameters = String.new
            for par in parameters do 
                eval_obj = par.evaluate(scope)
                eval_parameters.concat(eval_obj.to_s.prepend(' "' ).concat('"'))
            end
        elsif parameters == nil
            eval_parameters = ""
        end
        func = $built_in_functions[built_in_func].dup #copy built in function name
        func = func.concat(eval_parameters) #add name string and parameter string to each other
        return eval(func)
    else
        # otherwise if we call a user built in function.
        function_object = name.evaluate(scope, true) 
        if function_object != nil
            $stack.append Scope.new(:function, $stack.get.identifier)
            set_variables_to_parameter_values(function_object[0], parameters)
            run_all_statements(function_object[1], scope)
            result = nil
            if function_object[2] != nil
                result = evaluate_to_primitive_type(function_object[2], scope)
            end
            $stack.pop
            return result
        else
            raise "function does not exist"
        end
    end
end