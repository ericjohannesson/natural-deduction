.ONESHELL:

default:
	@echo 'no default target'

clean:
	# remove anything in .gitignore, including directories
	git clean -fdX

install: build src/nd.ml
	ocamlfind install natural-deduction build/*
	ocamlfind ocamlopt -o ~/.opam/default/bin/nd -linkpkg -package uuseg -package natural-deduction src/nd.ml

build: build_native build_byte opam
	mkdir -p build
	cp build_native/natural_deduction.* build/
	cp build_byte/natural_deduction.cma build/
	cp opam/natural-deduction.opam build/opam
	cp opam/META build/

nd: build_native
	mkdir -p build_nd
	cp -f build_native/* build_nd/
	cd build_nd
	ocamlfind ocamlopt -o nd -linkpkg -package uuseg natural_deduction.cmx nd.ml
	cd -
	mv build_nd/nd .

test: tests/test.bc tests/test.sh nd
	cd tests
	ocamlrun test.bc
	bash test.sh
	cd -

docs: src build_byte
	cd build_byte
	ocamlfind ocamldoc -colorize-code -d ../docs -package menhir -package uuseg -html IO.mli FML_types.ml ../src/FML_parser.mli FML_lexer.mli FML_main.mli UTF8_segmenter.mli PRF_sequencer.mli PRF_types.ml ../src/PRF_parser.mli PRF_lexer.mli PRF_main.mli ITM_types.ml ../src/ITM_parser.mli ITM_lexer.mli ITM_main.mli main.mli cli.mli cli.ml
	cd -


build_native: build_byte
	mkdir -p build_native
	cp -f build_byte/*.ml build_native/
	cp -f build_byte/*.mli build_native/
	cd build_native
	ocamlfind ocamlopt -c -for-pack Natural_deduction -I ../build_byte -linkpkg -package uuseg IO.mli IO.ml FML_types.ml FML_parser.mli FML_parser.ml FML_lexer.mli FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_types.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.mli PRF_parser.ml PRF_lexer.mli PRF_lexer.ml PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.mli ITM_parser.ml ITM_lexer.mli ITM_lexer.ml ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	ocamlfind ocamlopt -pack -o natural_deduction.cmx -package uuseg IO.cmx FML_types.cmx FML_parser.cmx FML_lexer.cmx FML_parser_automaton.cmx FML_main.cmx UTF8_segmenter.cmx PRF_sequencer.cmx PRF_types.cmx PRF_parser.cmx PRF_lexer.cmx PRF_main.cmx ITM_types.cmx ITM_parser.cmx ITM_lexer.cmx ITM_main.cmx main.cmx cli.cmx
	ocamlopt -a -o natural_deduction.cmxa natural_deduction.cmx
	ocamlopt -shared -o natural_deduction.cmxs natural_deduction.cmxa
	cd -

build_byte: src
	mkdir -p build_byte
	cp -f src/* build_byte
	cd build_byte
	ocamlc -c FML_types.ml
	ocamllex FML_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state FML_parser.mly
	bash FML_parser.automaton.sh FML_parser.automaton.resolved > FML_parser_automaton.ml 
	ocamlc -c FML_parser.mli
	ocamlc -c PRF_types.ml
	ocamllex PRF_lexer.mll
	menhir --infer --explain --dump --dump-resolved --exn-carries-state PRF_parser.mly
	ocamlc -c PRF_parser.mli
	ocamlc -c ITM_types.ml
	ocamllex ITM_lexer.mll
	ocamlyacc --strict ITM_parser.mly
	ocamlc -c ITM_parser.mli
	ocamlfind ocamlc -c -for-pack Natural_deduction -linkpkg -package uuseg IO.mli IO.ml FML_types.ml FML_parser.ml FML_lexer.mli FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.ml PRF_lexer.mli PRF_lexer.ml PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.ml ITM_lexer.mli ITM_lexer.ml ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	ocamlfind ocamlc -pack -o natural_deduction.cmo -package uuseg IO.cmo FML_types.cmo FML_parser.cmo FML_lexer.cmo FML_parser_automaton.cmo FML_main.cmo UTF8_segmenter.cmo PRF_sequencer.cmo PRF_types.cmo PRF_parser.cmo PRF_lexer.cmo PRF_main.cmo ITM_types.cmo ITM_parser.cmo ITM_lexer.cmo ITM_main.cmo main.cmo cli.cmo
	ocamlc -a -o natural_deduction.cma natural_deduction.cmo
	cd -

tests/test.bc: build_byte
	mkdir -p build_test
	cp tests/test.ml build_test/
	cp -f build_byte/* build_test/
	cd build_test
	ocamlfind ocamlc -o test.bc -linkpkg -package uuseg natural_deduction.cmo test.ml
	cd -
	mv build_test/test.bc tests/



utop: build_byte
	utop -I $(realpath build_byte) $(realpath build_byte/natural_deduction.cmo)
