.ONESHELL:

install: nd
	mkdir -p ~/bin
	cp nd ~/bin/

nd: src/*
	mkdir -p compilation_for_cli
	cp -f src/* compilation_for_cli
	cd compilation_for_cli
	ocamlc -c FOL_types.ml
	ocamllex FOL_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FOL_parser.mly
	# generate FOL_parser_automaton.ml:
	bash FOL_parser.automaton.sh FOL_parser.automaton.resolved > FOL_parser_automaton.ml 
	ocamlc -c FOL_types.cmo FOL_parser.mli
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state ND_parser.mly
	ocamlc -c FOL_types.cmo ND_types.cmo ND_parser.mli
	ocamlfind ocamlopt -o nd -linkpkg -package uuseg IO.ml FOL_types.ml FOL_parser.ml FOL_lexer.ml FOL_parser_automaton.ml FOL_main.ml UTF8_decoder.ml ND_sequencer.ml ND_parser.ml ND_lexer.ml ND_main.ml main.mli main.ml cli.ml
	mv nd ..
	cd -

test: compilation_for_test
	cd compilation_for_test
	./test.exe
	cd -

compilation_for_test: src/*
	mkdir -p compilation_for_test
	cp -f src/* compilation_for_test
	cd compilation_for_test
	ocamlc -c FOL_types.ml
	ocamllex FOL_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FOL_parser.mly
	# generate FOL_parser_automaton.ml:
	bash FOL_parser.automaton.sh FOL_parser.automaton.resolved > FOL_parser_automaton.ml 
	ocamlc -c FOL_types.cmo FOL_parser.mli
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state ND_parser.mly
	ocamlc -c FOL_types.cmo ND_types.cmo ND_parser.mli
	ocamlfind ocamlopt -o test.exe -linkpkg -package uuseg IO.ml FOL_types.ml FOL_parser.ml FOL_lexer.ml FOL_parser_automaton.ml FOL_main.ml UTF8_decoder.ml ND_sequencer.ml ND_parser.ml ND_lexer.ml ND_main.ml main.mli main.ml test.ml
	cd -

clean:
	# remove anything in .gitignore, including directories
	git clean -fdX


utop: compilation_for_utop
	cd compilation_for_utop
	utop ND_lib.cma -init utop.ml


compilation_for_utop: src/*
	mkdir -p compilation_for_utop
	cp -f src/* compilation_for_utop
	cd compilation_for_utop
	ocamlc -c FOL_types.ml
	ocamllex FOL_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FOL_parser.mly
	# generate FOL_parser_automaton.ml:
	bash FOL_parser.automaton.sh FOL_parser.automaton.resolved > FOL_parser_automaton.ml 
	ocamlc -c FOL_types.cmo FOL_parser.mli
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state ND_parser.mly
	ocamlc -c FOL_types.cmo ND_types.cmo ND_parser.mli
	ocamlfind ocamlc -a -o ND_lib.cma -linkpkg -package uuseg IO.ml FOL_types.ml FOL_parser.ml FOL_lexer.ml FOL_parser_automaton.ml FOL_main.ml UTF8_decoder.ml ND_sequencer.ml ND_parser.ml ND_lexer.ml ND_main.ml main.mli main.ml
	cd -


