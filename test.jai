
ComplexType :: struct (A: Type) {
    thing: A;
}

main :: () {
    out_of_scope: ComplexType(int);
    out_of_scope.thing = 1;

    generic_call(out_of_scope);

    print("generated complex type is %\n", out_of_scope);
}

generic_call :: (a: ComplexType($T)) {
    function_call :: () {
        a: ComplexType(T); @capture
        print("thing is  %\n", a.thing);
    };

    array_resize(*capture_entries, 100);

    captured := #insert #run capture(function_call);
    captured();
    // (#insert #run capture(function_call))();
    // (() -> type_of(function_call) #expand {
    // print("got here1\n");
    // if capture_entries.count < capture_entries_byte_count {
    //     array_resize(*capture_entries, capture_entries_byte_count);
    // }
    // print("got here2\n");
    // a_pointer := *`a;
    // print("got here2.1\n");
    // a_type :: #type ComplexType(T);
    // #if #run is_pointer_of(a_type, type_of(`a)) {
    //     memcpy(capture_entries.data + 0, *a_pointer, 8);
    // } else #if #run a_type == type_of(a) {
    //     memcpy(capture_entries.data + 0, a_pointer, 8);
    // } else {
    //     #run assert(false, "Your captured values do not match by value, or by pointer.");
    // }
    // print("got here3\n");
    // generated :: () {
    // print("got here4\n");
    // a: ComplexType(T) = ---;
    // memcpy(*a, capture_entries.data + 0, 8);
    // print("thing is  %\n", a.thing);
    // }
    // print("got here5\n");
    // return generated;
    // }())();
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
//         out_of_scope.* = 2;
//     })();

//     print("updated out of scope is %\n", out_of_scope);
// }

#scope_file

#load "module.jai";

#import "Basic";
#import "Compiler";