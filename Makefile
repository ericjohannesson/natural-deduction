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
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state ND_parser.mly
	ocamlc -c FML_types.cmo ND_types.cmo ND_parser.mli
	ocamlfind ocamlopt -o nd -linkpkg -package uuseg IO.ml FML_types.ml FML_parser.ml FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_decoder.mli UTF8_decoder.ml ND_sequencer.mli ND_sequencer.ml ND_parser.ml ND_lexer.ml ND_main.mli ND_main.ml main.mli main.ml cli.ml
	mv nd ..
	cd -

test: nd
	cd compilation_for_nd
	ocamlfind ocamlopt -o test.exe -linkpkg -package uuseg IO.ml FML_types.ml FML_parser.ml FML_lexer.ml FML_parser_automaton.ml FML_main.ml UTF8_decoder.mli UTF8_decoder.ml ND_sequencer.mli ND_sequencer.ml ND_parser.ml ND_lexer.ml ND_main.mli ND_main.ml main.mli main.ml test.ml
	./test.exe
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
	ocamlc -c FML_types.ml
	ocamllex FML_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FML_parser.mly
	# generate FML_parser_automaton.ml:
	bash FML_parser.automaton.sh FML_parser.automaton.resolved > FML_parser_automaton.ml 
	ocamlc -c FML_types.cmo FML_parser.mli
	ocamlc -c ND_types.ml
	ocamllex ND_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state ND_parser.mly
	ocamlc -c FML_types.cmo ND_types.cmo ND_parser.mli
	ocamlfind ocamlc -a -o ND_lib.cma -linkpkg -package uuseg IO.ml FML_types.ml FML_parser.ml FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_decoder.mli UTF8_decoder.ml ND_sequencer.mli ND_sequencer.ml ND_parser.ml ND_lexer.ml ND_main.mli ND_main.ml main.mli main.ml
	cd -

DEF_main: compilation_for_utop
	cd compilation_for_utop
	ocamllex DEF_lexer.mll
	menhir --infer --explain --dump DEF_parser.mly
	ocamlc -c DEF_parser.mli
	ocamlc -c IO.ml FML_parser_automaton.ml FML_parser.ml FML_lexer.ml FML_main.ml DEF_parser.ml DEF_lexer.ml DEF_main.ml
	cd -

DEF_utop: DEF_main
	cd compilation_for_utop
	utop IO.cmo FML_parser_automaton.cmo FML_parser.cmo FML_lexer.cmo FML_main.cmo DEF_lexer.cmo DEF_parser.cmo DEF_main.cmo

DEF_test: DEF_main
	cd compilation_for_utop
	ocamlopt -o DEF_test.exe IO.ml FML_parser_automaton.ml FML_parser.ml FML_lexer.ml FML_main.ml DEF_parser.ml DEF_lexer.ml DEF_main.ml DEF_test.ml
	./DEF_test.exe
	cd -
