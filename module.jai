
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

        current_capture_index := capture_entries_count;
        capture_entries_count += 1;

        append(*builder, "if capture_entries.count < capture_entries_count {");
        append(*builder, "    array_resize(*capture_entries, capture_entries_count);");
        append(*builder, "}");

        append(*builder, tprint("if capture_entries[%].count != % {\n", current_capture_index, allocation_size));
        append(*builder, tprint("    capture_entries[%] = NewArray(%, u8);\n", current_capture_index, allocation_size));
        append(*builder, "}\n");

        append(*builder, tprint("current_capture_entry := capture_entries[%];\n", current_capture_index));

        offset := 0;
        for entry: function_capture_sizes {
            append(*builder, tprint("%_pointer := *`%;\n", entry.name, entry.name));
            append(*builder, tprint("memcpy(current_capture_entry.data + %, %_pointer, %);\n", offset, entry.name, entry.size));

            offset += entry.size;
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

        append(*builder, tprint("current_capture_entry := capture_entries[%];\n", current_capture_index));

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
                        append(*builder, tprint("memcpy(*%, current_capture_entry.data + %, %);\n", entry.name, offset, entry.size));
                    }

                    offset += entry.size;
                }
            } else {
                append(*builder, ";\n");
            }
        }

        append(*builder, "}\n");

        print("\n%\n\n", builder_to_string(*builder, do_reset = false));

        return builder_to_string(*builder);
    }();

    return generated;
}

#scope_file

// capture_entries: [13] *void;

// capture_mutex_initialized: bool;
// capture_mutex: Mutex;
capture_entries: [] [] u8;
#no_reset capture_entries_count: int;

/*
#add_context caller_stack_offset: *u8;

capture :: ($function: $F, $caller := #caller_code) -> F #expand {

/*
    #run {
        // TODO I would like to go through all the code declarations, accumulate them,
        // TODO and at runtime calculate the actual stack offset between the capture variables
        // TODO and the assigned capture variables, but I don't have even the slightest amount of
        // TODO confidence that I could accurately and reliably do this without bugs, so instead
        // TODO by using this module I'm going to add some values into the context, and write/lookup
        // TODO each time this is called as a way of quick cheating




        print("\n");
        root, expressions := compiler_get_nodes(caller);
        // assert(nodes.)
        for expression: expressions {
            if expression.kind == .DECLARATION {
                declaration := cast(*Code_Declaration) expression;
                // print("declaration %\n\n", declaration.name);
                if declaration.type_inst {
                    // print("declaration.type_inst %\n\n", declaration.type_inst.*);
                }
            } else {
                print("kind %\n", expression.kind);
                if expression.kind == .PROCEDURE_CALL {
                    call := cast(*Code_Procedure_Call) expression;
                    print("call %\n\n", call.*);
                }
            }
        }

        function_capture_offsets: Table(string, int);

        function_code := code_of(function);
        function_root, function_expressions := compiler_get_nodes(function_code);
        assert(function_root.kind == .PROCEDURE_HEADER);
        header := cast(*Code_Procedure_Header) function_root;

        assert(!!header.body_or_null);
        if header.body_or_null {
            assert(!!header.body_or_null.block);

            code_block := header.body_or_null.block;
            stack_offset := 0;
            
            for statement: code_block.statements {
                print("statement %\n\n", statement.*);
                if statement.kind == .DECLARATION {
                    declaration := cast(*Code_Declaration) statement;

                    for note: declaration.notes {
                        if note.text == "capture" {
                            assert(!table_find_pointer(*function_capture_offsets, declaration.name), "The captured variable cannot already have been found.");

                            table_set(*function_capture_offsets, declaration.name, stack_offset);
                        }
                    }

                    assert(!!declaration.type_inst);
                    assert(!!declaration.type_inst.result);

                    stack_offset += declaration.type_inst.result.runtime_size;
                }
            }
        }
        // for expression: function_expressions {
        //     if expression.kind == .BLOCK {
        //         block := cast(*Code_Block) expression;
        //         print("block %\n", block.*);
        //     }
        // }
        // funciton_resolved := function_ident.resolved_declaration;
        // print("%\n", funciton_resolved.*);
        // for expression: function_expressions {
        //     if expression.kind == .IDENT {
        //         ident := cast(*Code_Ident) expression;
        //         print("ident %\n", ident.*);
        //     }
        // }
        print("\n");
    }
    */

    #insert #run () -> string {
        function_capture_offsets: Table(string, int);
        caller_capture_offsets: Table(string, int);
        function_call_offset: int;

        // get the function capture offsets
        function_code := code_of(function);
        function_root, function_expressions := compiler_get_nodes(function_code);
        header := cast(*Code_Procedure_Header) function_root;

        stack_offset := 0;
        for statement: header.body_or_null.block.statements {
            if statement.kind == .DECLARATION {
                declaration := cast(*Code_Declaration) statement;

                for note: declaration.notes {
                    if note.text == "capture" {
                        assert(!table_find_pointer(*function_capture_offsets, declaration.name), "The captured variable cannot already have been found.");

                        table_set(*function_capture_offsets, declaration.name, stack_offset);
                        print("Found function capture for %\n", declaration.name);
                    }
                }

                assert(!!declaration.type_inst);
                assert(!!declaration.type_inst.result);

                stack_offset += declaration.type_inst.result.runtime_size;
            }
        }

        something_root, something_expressions := compiler_get_nodes(something);
        print("something % %\n", something_root.*, something_expressions);
        something_ident := cast(*Code_Ident) something_root;
        print("ident %\n", something_ident.resolved_declaration.expression.*);


        // caller_code := code_of(caller);
        caller_root, caller_expressions := compiler_get_nodes(caller);
        caller_proc := cast(*Code_Procedure_Call) caller_root;
        // caller_header := cast(*Code_Procedure_Header) caller_root;
        print("caller_root %\n", caller_root.*);
        print("caller_proc %\n", caller_proc.*);
        print("procedure_expression %\n", caller_proc.procedure_expression.*);
        caller_ident := cast(*Code_Ident) caller_proc.procedure_expression;
        print("caller_ident %\n", caller_ident.*);
        caller_declaration := cast(*Code_Declaration) caller_ident.resolved_declaration;
        print("caller_declaration %\n", caller_declaration.*);
        caller_header := cast(*Code_Procedure_Header) caller_declaration.expression;
        print("caller_header %\n", caller_header.*);

        // print("resolved_procedure_expression %\n", caller_proc.resolved_procedure_expression.*);
        // caller_header := cast(*Code_Procedure_Header) caller_proc.resolved_procedure_expression;
        // print("caller_header %\n", caller_header.*);
        // print("caller_header.constants_block %\n", caller_header.constants_block.*);
        // print("caller_header.constants_block.owning_statement %\n", (cast(*Code_Declaration) caller_header.constants_block.owning_statement).*);
        // print("caller_header.constants_block.owning_statement.import_target %\n", (cast(*Code_Declaration) caller_header.constants_block.owning_statement).import_target);

        test: String_Builder;
        print_expression(*test, something_root);
        // for expression: something_expressions {
        //     print_expression(*test, expression);
        // }
        print("test %\n", builder_to_string(*test));
        
        // assert(caller_expressions[0].kind == .BLOCK);
        // caller_block := cast(*Code_Block) caller_expressions[2];
        // print("%\n", caller_block.*);
        
        // for statement: caller_block.statements {
        //     print("statement %\n", statement.*);
        // }



        // get the caller capture offsets and the function call offset
        // caller_root, caller_expressions := compiler_get_nodes(caller);
        // caller_header := cast(*Code_Procedure_Header) caller_proc.resolved_procedure_expression;
        // print("%\n", caller_header.*);

        // for statement: caller_header.body_or_null.block.statements {
        //     print("statement %\n", statement.*);
        // }
        // test: String_Builder;
        stack_offset = 0;
        for expression: caller_expressions {
            // print("expression %\n", expression.*);
            if expression.kind == .DECLARATION {
                declaration := cast(*Code_Declaration) expression;
                // print("%\n", declaration.name);

                if table_contains(*function_capture_offsets, declaration.name) && !table_contains(*caller_capture_offsets, declaration.name) {
                    table_set(*caller_capture_offsets, declaration.name, stack_offset);
                    print("Found caller capture for %\n", declaration.name);
                }

                if declaration.type_inst && declaration.type_inst.result {
                    stack_offset += declaration.type_inst.result.runtime_size;
                }

                // print_expression(*test, expression);
                // append(*test, "\n");
            }
            // print("expression %\n", expression.*);
        }
        // print("test %\n", builder_to_string(*test));


/*
        builder: String_Builder;

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

        append(*builder, "stack_offset_value: u8;");
        // append(*builder, "stack_offset_value: u8 = ---;");
        append(*builder, "context.caller_stack_offset = *stack_offset_value + 1;\n");

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
                // TODO if you're capturing something that's 1 more of a pointer than the original, we will actually point to it in memory instead of dereference
                offset := table_find_pointer(*function_capture_offsets, capture_name).*;
                offset += function_call_offset - table_find_pointer(*caller_capture_offsets, capture_name).*;
                // name = ---;
                // name = (cast(*Type) ((cast(*u8) *name) - offset)).*;
                append(*builder, " = ---;\n");
                append(*builder, capture_name);
                append(*builder, " = (cast(*");
                print_expression(*builder, type_inst);
                append(*builder, ") ((cast(*u8) *");
                append(*builder, capture_name);
                append(*builder, ") - ");
                append(*builder, tprint("%", offset));
                append(*builder, ")).*");
            } else {
                append(*builder, ";\n");
            }
        }

        append(*builder, "}\n");

        print("\n%\n\n", builder_to_string(*builder, do_reset = false));

        return builder_to_string(*builder);
    */
        return "";
    }();

    // return generated;

    return function;
}

#scope_file

*/

#import "Basic";
#import "Compiler";
#import "Hash_Table";
#import "Program_Print";
