
capture :: ($function: $F) -> F #expand {
    #insert #run () -> string {
        function_capture_sizes: [..] struct {
            name: string;
            size: int;
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
                    }
                }
            }
        }

        allocation_size := 0;
        for entry: function_capture_sizes {
            allocation_size += entry.size;
        }

        builder: String_Builder;

        // current_capture_index := capture_entries_count;
        // capture_entries_count += 1;

        append(*builder, "if capture_entries.count < capture_entries_byte_count {");
        append(*builder, "    array_resize(*capture_entries, capture_entries_byte_count);");
        append(*builder, "}");

        // append(*builder, tprint("if capture_entries[%].count != % {\n", current_capture_index, allocation_size));
        // append(*builder, tprint("    capture_entries[%] = NewArray(%, u8);\n", current_capture_index, allocation_size));
        // append(*builder, "}\n");

        capture_byte_offset := capture_entries_byte_count;
        // append(*builder, tprint("current_capture_entry := capture_entries.data + %;\n", capture_byte_offset));

        for entry: function_capture_sizes {
            append(*builder, tprint("%_pointer := *`%;\n", entry.name, entry.name));
            append(*builder, tprint("memcpy(capture_entries.data + %, %_pointer, %);\n", capture_entries_byte_count, entry.name, entry.size));

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

        // append(*builder, tprint("current_capture_entry := capture_entries.data + %;\n", capture_byte_offset));

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

            print_expression(*builder, statement);
            if capture_name {
                offset := 0;
                for entry: function_capture_sizes {
                    if entry.name == capture_name {
                        // TODO if you're capturing something that's 1 more of a pointer than the original, we will actually point to it in memory instead of dereference

                        // name = ---;
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

capture_entries: [] u8;
#no_reset capture_entries_byte_count: int;

#import "Basic";
#import "Compiler";
#import "Program_Print";
