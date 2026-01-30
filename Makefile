.ONESHELL:

install: nd
	mkdir -p ~/bin
	cp nd ~/bin/

nd: src/*
	mkdir -p compilation_for_nd
	cp -f src/* compilation_for_nd
	cd compilation_for_nd
	ocamlc -c FML_types.ml
	ocamllex FML_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FML_parser.mly
	# generate FML_parser_automaton.ml:
	bash FML_parser.automaton.sh FML_parser.automaton.resolved > FML_parser_automaton.ml 
	ocamlc -c FML_types.cmo FML_parser.mli
	ocamlc -c PRF_types.ml
	ocamllex PRF_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state PRF_parser.mly
	ocamlc -c FML_types.cmo PRF_types.cmo PRF_parser.mli
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	ocamlyacc --strict ND_parser.mly
	ocamlc -c ND_parser.mli
	ocamlfind ocamlopt -o nd -linkpkg -package uuseg IO.ml FML_types.ml FML_parser.ml FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_decoder.mli UTF8_decoder.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.ml PRF_lexer.ml PRF_main.mli PRF_main.ml PRF_edit.mli PRF_edit.ml ND_types.ml ND_parser.ml ND_lexer.ml ND_main.mli ND_main.ml main.mli main.ml cli.ml
	mv nd ..
	cd -

test: tests/test.exe nd
	cd tests
	./test.exe
	bash test_cli.sh
	cd -

tests/test.exe: nd
	cd compilation_for_nd
	ocamlfind ocamlopt -o test.exe -linkpkg -package uuseg IO.ml FML_types.ml FML_parser.ml FML_lexer.ml FML_parser_automaton.ml FML_main.ml  UTF8_decoder.mli UTF8_decoder.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.ml PRF_lexer.ml PRF_main.mli PRF_main.ml PRF_edit.mli PRF_edit.ml ND_parser.ml ND_types.ml ND_lexer.ml ND_main.mli ND_main.ml main.mli main.ml test.ml
	cd -
	mv compilation_for_nd/test.exe tests

clean:
	# remove anything in .gitignore, including directories
	git clean -fdX


utop: compilation_for_utop
	cd compilation_for_utop
	utop PRF_lib.cma -init utop.ml


compilation_for_utop: src/*
	mkdir -p compilation_for_utop
	cp -f src/* compilation_for_utop
	cd compilation_for_utop
	ocamlc -c FML_types.ml
	ocamllex FML_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FML_parser.mly
	# generate FML_parser_automaton.ml:
	bash FML_parser.automaton.sh FML_parser.automaton.resolved > FML_parser_automaton.ml 
	ocamlc -c FML_types.cmo FML_parser.mli
	ocamlc -c PRF_types.ml
	ocamllex PRF_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state PRF_parser.mly
	ocamlc -c FML_types.cmo PRF_types.cmo PRF_parser.mli
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	ocamlyacc --strict ND_parser.mly
	ocamlc -c ND_parser.mli
	ocamlfind ocamlc -a -o PRF_lib.cma -linkpkg -package uuseg IO.ml FML_types.ml FML_parser.ml FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_decoder.mli UTF8_decoder.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.ml PRF_lexer.ml PRF_main.mli PRF_main.ml PRF_edit.mli PRF_edit.ml ND_types.ml ND_parser.ml ND_lexer.ml ND_main.mli ND_main.ml main.mli main.ml
	cd -


