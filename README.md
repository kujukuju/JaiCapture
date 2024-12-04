# Warning

Probably don't use this library. I wanted to have anonymous captures in jai, but I had a parallel issue in my code that I _think_ I narrowed down to being caused by the JaiCapture library.

I'm not sure how, and the repro case was extremely rare, so instead of fixing it, I'll just say if you're going to be working in a multithreaded environment, probably don't use this library.

## Future self note

I think this might actually work if you capture the stuff, put it in a struct bundled with the function somewhere, and then when you call the function it puts the stuff into the scope memory, and calls into an inner function that reads it... I guess.

Like the actual thing `capture` will return is a struct that contains the function pointer and directly after it the raw memory of the thing to be passed in.

The actual function `capture` returns just reads this raw memory from the address, passes it into the inner function that it generates.

I guess the actual size of the returned function would be pointer sized though so idk but I think this is close to a reasonable answer...

## JaiCapture

Closure captures in jai that kind of works at compile time.

### Limitations

This library generates a new closure captured function for each macro call at compile time.

The data gets put into the closure capture when the `capture` function is called.

If the data is passed by value, going out of scope of the original captured values is fine. The data will persist by value.

If the data is passed by pointer, going out of the scope of the original captured values will result in garbage data being captured.

Each uniquely polymorphically compiled `capture` call has it's own unique capture data. For the most part this shouldn't matter, but if you call into the same `capture` method over and over in a loop, it will keep updating the same capture data.

This is fine if you immediately call into the captured function from within the same scope of that loop, but if you're storing all these captured functions in an array or something to call later, they will all operate on the same underlying captured data. This also might not matter, for example if everything is captured by pointer, but it's a limitation to be aware of.

This library doesn't yet work with nested captures. This is fixable in the future but it's hard.

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
        out_of_scope.* = 2;
    })();

    print("updated out of scope is %\n", out_of_scope);
    // updated out of scope is 2
}
```
