
// my_data :: #run () -> [] u8 {
//     thing: [..] u8;
//     return thing;
// }();

// my_data :: #run add_global_data(u8.[]);

main :: () {
    out_of_scope: int = 4;

    function_call :: () {
        out_of_scope: int; @capture

        print("out of scope is %\n", out_of_scope);
    };

    captured_function_call := capture(function_call);

    // after being captured by value, we don't care!
    out_of_scope = 6;

    captured_function_call();
}

#scope_file

// entries: [] u8;

#load "module.jai";

#import "Basic";
#import "Compiler";