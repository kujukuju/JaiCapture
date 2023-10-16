
// ComplexType :: struct (A: Type) {
//     thing: A;
// }

// main :: () {
//     out_of_scope: ComplexType(int);
//     out_of_scope.thing = 1;

//     generic_call(out_of_scope);

//     print("generated complex type is %\n", out_of_scope);
// }

// generic_call :: (a: ComplexType($T)) {
//     function_call :: () {
//         a: ComplexType(T); @capture
//         print("thing is %\n", a.thing);
//     };

//     array_resize(*capture_entries, 100);

//     captured := capture(function_call);
//     captured();
// }

main :: () {
    function :: () -> bool {
        StructType :: struct {
            a: int;
            b: *bool;
        }

        value: bool;

        declared := StructType.{
            1,
            *value,
        };

        defined_function :: (a: int) -> int {
            return a;
        }

        print("ran\n");
        
        return true;
    };

    // capture(function)();

    #insert #run () -> Code {
        function_code := code_of(function);
        function_root := compiler_get_nodes(function_code);
        return compiler_get_code(function_root);
        // header := cast(*Code_Procedure_Header) function_root;
        // builder: String_Builder;
        // for statement: header.body_or_null.block.statements {
        //     print_expression(*builder, statement);
        //     append(*builder, ";");
        //     append(*builder, "\n");
        // }

        // print("%\n", builder_to_string(*builder));
    }();
}

// main :: () {
//     out_of_scope: int = 4;

//     value_function_call :: () {
//         out_of_scope: int; @capture

//         print("value first out of scope is %\n", out_of_scope);
//         out_of_scope = 3;    
//         print("value second out of scope is %\n", out_of_scope);
//     };

//     pointer_function_call :: () {
//         out_of_scope: *int; @capture

//         print("first out of scope is %\n", << out_of_scope);
//         << out_of_scope = 2;
//         print("second out of scope is %\n", << out_of_scope);
//     };

//     first_captured_function_call := capture(pointer_function_call);
//     second_captured_function_call := capture(pointer_function_call);
//     value_captured_function_call := capture(value_function_call);

//     first_captured_function_call();
//     print("first modified out of scope is %\n", out_of_scope);

//     out_of_scope = 6;

//     second_captured_function_call();
//     print("second modified out of scope is %\n", out_of_scope);

//     value_captured_function_call();
//     print("third modified out of scope is %\n", out_of_scope);
// }

// main :: () {
//     out_of_scope: int = 4;

//     function_call :: () {
//         out_of_scope: int; @capture
//         print("captured out of scope is %\n", out_of_scope);
//     };

//     captured_function_call := capture(function_call);
//     captured_function_call();

//     capture(() {
//         out_of_scope: *int; @capture
//         << out_of_scope = 2;
//     })();

//     print("updated out of scope is %\n", out_of_scope);
// }

#scope_file

#load "module.jai";

#import "Basic";
#import "Compiler";