
capture :: ($function: $F) -> F #expand {
    #insert #run () -> string {
        function_capture_sizes: [..] struct {
            name: string;
            size: int;
            type: Type;
            type_inst: *Code_Type_Instantiation;
        };

        // get the function capture offsets
        function_code := code_of(function);
        function_root, function_expressions := compiler_get_nodes(function_code);
        header := cast(*Code_Procedure_Header) function_root;

        for statement: header.body_or_null.block.statements {
            if statement.kind == .DECLARATION {
                declaration := cast(*Code_Declaration) statement;

                assert(!!declaration.type_inst);
                assert(!!declaration.type_inst.result);

                for note: declaration.notes {
                    if note.text == "capture" {
                        runtime_size := declaration.type_inst.result.runtime_size;
                        entry := array_add(*function_capture_sizes);
                        entry.name = declaration.name;
                        entry.size = runtime_size;
                        entry.type = (cast(*Type) *declaration.type_inst.result).*;
                        entry.type_inst = declaration.type_inst;
                    }
                }
            }
        }

        allocation_size := 0;
        for entry: function_capture_sizes {
            allocation_size += entry.size;
        }

        builder: String_Builder;

        append(*builder, "if capture_entries.count < capture_entries_byte_count {");
        append(*builder, "    array_resize(*capture_entries, capture_entries_byte_count);");
        append(*builder, "}");

        capture_byte_offset := capture_entries_byte_count;

        for entry: function_capture_sizes {
            append(*builder, tprint("%_pointer := *`%;\n", entry.name, entry.name));
            append(*builder, tprint("%_type :: #type ", entry.name));
            print_expression(*builder, entry.type_inst);
            append(*builder, ";\n");
            append(*builder, tprint("#if #run is_pointer_of(%_type, type_of(`%)) {\n", entry.name, entry.name));
            append(*builder, tprint("    memcpy(capture_entries.data + %, *%_pointer, %);\n", capture_entries_byte_count, entry.name, entry.size));
            append(*builder, tprint("} else #if #run %_type == type_of(`%) {\n", entry.name, entry.name));
            append(*builder, tprint("    memcpy(capture_entries.data + %, %_pointer, %);\n", capture_entries_byte_count, entry.name, entry.size));
            append(*builder, "} else {\n");
            append(*builder, "    #run assert(false, \"Your captured values do not match by value, or by pointer.\");\n");
            append(*builder, "}\n");

            capture_entries_byte_count += entry.size;
        }

        append(*builder, "generated :: (");

        for arg, arg_index: header.arguments {
            print_expression(*builder, arg);

            if arg_index < header.arguments.count - 1 {
                append(*builder, ", ");
            }
        }

        append(*builder, ") ");

        if header.returns.count > 0 {
            append(*builder, "-> ");
        }

        for ret, ret_index: header.returns {
            print_expression(*builder, ret);

            if ret_index < header.returns.count - 1 {
                append(*builder, ", ");
            } else {
                append(*builder, " ");
            }
        }

        append(*builder, "{\n");

        for statement: header.body_or_null.block.statements {
            capture_name: string;
            type_inst: *Code_Type_Instantiation;
            if statement.kind == .DECLARATION {
                declaration := cast(*Code_Declaration) statement;

                for note: declaration.notes {
                    if note.text == "capture" {
                        capture_name = declaration.name;
                        type_inst = declaration.type_inst;
                    }
                }
            }

            single_line: String_Builder;
            print_expression(*single_line, statement);
            print("%\n", builder_to_string(*single_line));


            print_expression(*builder, statement);
            if capture_name {
                offset := 0;
                for entry: function_capture_sizes {
                    if entry.name == capture_name {
                        // name: T = ---;
                        // memcpy(*name, current_capture_entry.data + offset, size);

                        append(*builder, " = ---;\n");
                        append(*builder, tprint("memcpy(*%, capture_entries.data + %, %);\n", entry.name, capture_byte_offset + offset, entry.size));
                    }

                    offset += entry.size;
                }
            } else {
                append(*builder, ";\n");
            }
        }

        append(*builder, "}\n");

        return builder_to_string(*builder);
    }();

    return generated;
}

#scope_file

is_pointer_of :: (pointer: Type, normal: Type) -> bool {
    info := cast(*Type_Info) pointer;
    if info.type != .POINTER {
        return false;
    }

    pointer_info := cast(*Type_Info_Pointer) pointer;
    pointer_to_type := (cast(*Type) *pointer_info.pointer_to).*;

    return pointer_to_type == normal;
}

capture_entries: [] u8;
#no_reset capture_entries_byte_count: int;

#import "Basic";
#import "Compiler";
#import "Program_Print";
