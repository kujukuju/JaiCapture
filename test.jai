
main :: () {
    out_of_scope: int = 4;

    value_function_call :: () {
        out_of_scope: int; @capture

        print("value first out of scope is %\n", out_of_scope);
        out_of_scope = 3;
        print("value second out of scope is %\n", out_of_scope);
    };

    pointer_function_call :: () {
        out_of_scope: *int; @capture

        print("first out of scope is %\n", << out_of_scope);
        << out_of_scope = 2;
        print("second out of scope is %\n", << out_of_scope);
    };

    first_captured_function_call := capture(pointer_function_call);
    second_captured_function_call := capture(pointer_function_call);
    value_captured_function_call := capture(value_function_call);

    first_captured_function_call();
    print("first modified out of scope is %\n", out_of_scope);

    out_of_scope = 6;

    second_captured_function_call();
    print("second modified out of scope is %\n", out_of_scope);

    value_captured_function_call();
    print("third modified out of scope is %\n", out_of_scope);

}

#scope_file

// first out of scope is 4
// second out of scope is 2
// first modified out of scope is 2
// first out of scope is 6
// second out of scope is 2
// second modified out of scope is 2
// value first out of scope is 4
// value second out of scope is 3
// third mofidied out of scope is 2

#load "module.jai";

#import "Basic";
#import "Compiler";