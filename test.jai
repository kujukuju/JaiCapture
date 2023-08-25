
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

//     first_captured_function_call := #insert #run capture(pointer_function_call);
//     second_captured_function_call := #insert #run capture(pointer_function_call);
//     value_captured_function_call := #insert #run capture(value_function_call);

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

//     captured_function_call := #insert #run capture(function_call);
//     captured_function_call();

//     (#insert #run capture(() {
//         out_of_scope: *int; @capture
//         << out_of_scope = 2;
//     }))();

//     print("updated out of scope is %\n", out_of_scope);
// }

#scope_file

#load "module.jai";

#import "Basic";
#import "Compiler";