## JaiCapture

Closure captures in jai that kind of works at compile time.

### Limitations

This library generates a new closure captured function for each macro call at compile time.

The data gets put into the closure capture when the `capture` function is called.

If the data is passed by value, going out of scope of the original captured values is fine. The data will persist by value.

If the data is passed by pointer, going out of the scope of the original captured values will result in garbage data being captured.

Each uniquely polymorphically compiled `capture` call has it's own unique capture data. For the most part this shouldn't matter, but if you call into the same `capture` method over and over in a loop, it will keep updating the same capture data.

This is fine if you immediately call into the captured function from within the same scope of that loop, but if you're storing all these captured functions in an array or something to call later, they will all operate on the same underlying captured data. This also might not matter, for example if everything is captured by pointer, but it's a limitation to be aware of.

### How To Use

```jai
#import "Basic";
#import "JaiCapture";

main :: () {
    out_of_scope: int = 4;

    function_call :: () {
        out_of_scope: int; @capture
        print("captured out of scope is %\n", out_of_scope);
        // captured out of scope is 4
    };

    captured_function_call := capture(function_call);
    captured_function_call();

    capture(() {
        out_of_scope: *int; @capture
        << out_of_scope = 2;
    })();

    print("updated out of scope is %\n", out_of_scope);
    // updated out of scope is 2
}
```
