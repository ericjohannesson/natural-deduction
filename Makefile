.ONESHELL:

default:
	@echo 'no default target'

install: build
	ocamlfind install natural-deduction build/*


build: native opam
	mkdir -p build
	cp -f native/*.ml build
	cp -f native/*.mli build
	cp -f native/*.cmx build
	cp -f native/*.cmi build
	cp -f native/*.cmt build
	cp -f native/*.cmti build
	cp native/natural_deduction.a build
	cp byte/natural_deduction.cma build
	cp native/natural_deduction.cmxa build
	cp native/natural_deduction.cmxs build
	cp opam/natural-deduction.opam build/opam
	cp opam/META build/

nd: native
	mkdir -p build_nd
	cp -f native/* build_nd/
	cd build_nd
	ocamlfind ocamlopt -o nd -linkpkg -package uuseg natural_deduction.cmxa nd.ml
	cd -
	mv build_nd/nd .

test: tests/test.bc tests/test.sh nd
	cd tests
	ocamlrun test.bc
	bash test.sh
	cd -

doc: src byte
	mkdir -p doc
	cd byte
	ocamlfind ocamldoc -colorize-code -d ../doc -package menhir -package uuseg -html IO.mli FML_types.ml ../src/FML_parser.mli FML_lexer.mli FML_main.mli UTF8_segmenter.mli PRF_sequencer.mli PRF_types.ml ../src/PRF_parser.mli PRF_lexer.mli PRF_main.mli ITM_types.ml ../src/ITM_parser.mli ITM_lexer.mli ITM_main.mli main.mli cli.mli cli.ml
	cd -


native: byte
	mkdir -p native
	cp -f byte/*.ml native
	cp -f byte/*.mli native
	cd native
	ocamlfind ocamlopt -a -o natural_deduction.cmxa -I ../byte -bin-annot -package uuseg IO.mli IO.ml FML_types.ml FML_parser.mli FML_parser.ml FML_lexer.mli FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_types.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.mli PRF_parser.ml PRF_lexer.mli PRF_lexer.ml PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.mli ITM_parser.ml ITM_lexer.mli ITM_lexer.ml ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	ocamlopt -shared -o natural_deduction.cmxs natural_deduction.cmxa
	cd -

byte: src
	mkdir -p byte
	cp -f src/* byte
	cd byte
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
	ocamlfind ocamlc -a -o natural_deduction.cma -linkpkg -package uuseg IO.mli IO.ml FML_types.ml FML_parser.ml FML_lexer.mli FML_lexer.ml FML_parser_automaton.ml FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.ml PRF_lexer.mli PRF_lexer.ml PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.ml ITM_lexer.mli ITM_lexer.ml ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	cd -

tests/test.bc: byte
	mkdir -p build_test
	cp tests/test.ml build_test/
	cp -f byte/* build_test/
	cd build_test
	ocamlfind ocamlc -o test.bc -linkpkg -package uuseg natural_deduction.cma test.ml
	cd -
	mv build_test/test.bc tests/

clean:
	# remove anything in .gitignore, including directories
	git clean -fdX


utop: byte
	utop -I $(realpath byte) $(realpath byte/natural_deduction.cma)
