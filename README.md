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

See the test.jai file.