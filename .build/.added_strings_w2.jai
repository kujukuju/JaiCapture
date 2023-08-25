// Workspace: Target Program
//
// #insert text. Generated from C:/Users/Kuju/Projects/JaiCapture/module.jai:3.
//
if capture_entries.count < capture_entries_count {    array_resize(*capture_entries, capture_entries_count);}if capture_entries[0].count != 8 {
    capture_entries[0] = NewArray(8, u8);
}
current_capture_entry := capture_entries[0];
out_of_scope_pointer := *`out_of_scope;
memcpy(current_capture_entry.data + 0, out_of_scope_pointer, 8);
generated :: () {
current_capture_entry := capture_entries[0];
out_of_scope: int = ---;
memcpy(*out_of_scope, current_capture_entry.data + 0, 8);
print("out of scope is %\n", out_of_scope);
}
