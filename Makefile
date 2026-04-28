.ONESHELL:

default:
	@echo 'no default target'

clean:
	# remove anything in .gitignore, including directories
	git clean -fdX

install-opam_package: opam_package src/nd.ml
	ocamlfind install natural-deduction opam_package/*
	ocamlfind ocamlopt -o ~/.opam/default/bin/nd -linkpkg -package uuseg -package natural-deduction src/nd.ml

opam_package: native byte opam
	mkdir -p opam_package
	cp native/natural_deduction.* opam_package/
	cp byte/natural_deduction.cma opam_package/
	cp opam/natural-deduction.opam opam_package/opam
	cp opam/META opam_package/

install-nd: nd
	mkdir -p ~/bin
	cp nd ~/bin/

nd: native
	cd native
	ocamlfind ocamlopt -o nd -linkpkg -package uuseg natural_deduction.cmx nd.ml
	cd -
	mv native/nd .

test: tests/test.bc tests/test.sh nd
	cd tests
	ocamlrun test.bc
	bash test.sh
	cd -

docs: src byte
	cd byte
	ocamlfind ocamldoc -t 'Natural_deduction' -keep-code -colorize-code -d ../docs -package uuseg -html IO.mli IO.ml FML_types.ml FML_parser.mli  FML_lexer.mli FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_sequencer.mli PRF_sequencer.ml PRF_types.ml PRF_parser.mli PRF_lexer.mli PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.mli ITM_lexer.mli ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	cd -
	cp src/FML_lexer.mll docs/specs/FML_lexer.mll.txt
	cp src/FML_parser.mly docs/specs/FML_parser.mly.txt
	cp src/PRF_lexer.mll docs/specs/PRF_lexer.mll.txt
	cp src/PRF_parser.mly docs/specs/PRF_parser.mly.txt
	cp src/ITM_lexer.mll docs/specs/ITM_lexer.mll.txt
	cp src/ITM_parser.mly docs/specs/ITM_parser.mly.txt

native: src
	mkdir -p native
	cp -f src/* native
	cd native
	ocamlopt -c FML_types.ml
	ocamllex FML_lexer.mll
	cp ../src/FML_lexer.mli .
	ocamlyacc --strict FML_parser.mly
	cp ../src/FML_parser.mli .
	ocamlopt -c FML_parser.mli
	ocamlopt -c PRF_types.ml
	ocamllex PRF_lexer.mll
	cp ../src/PRF_lexer.mli .
	ocamlyacc --strict PRF_parser.mly
	cp ../src/PRF_parser.mli .
	ocamlopt -c PRF_parser.mli
	ocamlopt -c ITM_types.ml
	ocamllex ITM_lexer.mll
	cp ../src/ITM_lexer.mli .
	ocamlyacc --strict ITM_parser.mly
	cp ../src/ITM_parser.mli .
	ocamlopt -c ITM_parser.mli
	ocamlfind ocamlopt -c -for-pack Natural_deduction -linkpkg -package uuseg IO.mli IO.ml FML_types.ml FML_parser.mli FML_parser.ml FML_lexer.mli FML_lexer.ml FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_types.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.mli PRF_parser.ml PRF_lexer.mli PRF_lexer.ml PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.mli ITM_parser.ml ITM_lexer.mli ITM_lexer.ml ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	ocamlfind ocamlopt -pack -o natural_deduction.cmx -package uuseg IO.cmx FML_types.cmx FML_parser.cmx FML_lexer.cmx FML_main.cmx UTF8_segmenter.cmx PRF_sequencer.cmx PRF_types.cmx PRF_parser.cmx PRF_lexer.cmx PRF_main.cmx ITM_types.cmx ITM_parser.cmx ITM_lexer.cmx ITM_main.cmx main.cmx cli.cmx
	ocamlopt -a -o natural_deduction.cmxa natural_deduction.cmx
	ocamlopt -shared -o natural_deduction.cmxs natural_deduction.cmxa
	cd -

byte: src
	mkdir -p byte
	cp -f src/* byte
	cd byte
	ocamlc -c FML_types.ml
	ocamllex FML_lexer.mll
	cp ../src/FML_lexer.mli .
	ocamlyacc --strict FML_parser.mly
	cp ../src/FML_parser.mli .
	ocamlc -c FML_parser.mli
	ocamlc -c PRF_types.ml
	ocamllex PRF_lexer.mll
	cp ../src/PRF_lexer.mli .
	ocamlyacc --strict PRF_parser.mly
	cp ../src/PRF_parser.mli .
	ocamlc -c PRF_parser.mli
	ocamlc -c ITM_types.ml
	ocamllex ITM_lexer.mll
	cp ../src/ITM_lexer.mli .
	ocamlyacc --strict ITM_parser.mly
	cp ../src/ITM_parser.mli .
	ocamlc -c ITM_parser.mli
	ocamlfind ocamlc -c -for-pack Natural_deduction -linkpkg -package uuseg IO.mli IO.ml FML_types.ml FML_parser.ml FML_lexer.mli FML_lexer.ml FML_main.mli FML_main.ml UTF8_segmenter.mli UTF8_segmenter.ml PRF_sequencer.mli PRF_sequencer.ml PRF_parser.ml PRF_lexer.mli PRF_lexer.ml PRF_main.mli PRF_main.ml ITM_types.ml ITM_parser.ml ITM_lexer.mli ITM_lexer.ml ITM_main.mli ITM_main.ml main.mli main.ml cli.mli cli.ml
	ocamlfind ocamlc -pack -o natural_deduction.cmo -package uuseg IO.cmo FML_types.cmo FML_parser.cmo FML_lexer.cmo FML_main.cmo UTF8_segmenter.cmo PRF_sequencer.cmo PRF_types.cmo PRF_parser.cmo PRF_lexer.cmo PRF_main.cmo ITM_types.cmo ITM_parser.cmo ITM_lexer.cmo ITM_main.cmo main.cmo cli.cmo
	ocamlc -a -o natural_deduction.cma natural_deduction.cmo
	cd -

tests/test.bc: byte
	cp tests/test.ml byte/
	cd byte
	ocamlfind ocamlc -o test.bc -linkpkg -package uuseg natural_deduction.cmo test.ml
	cd -
	mv byte/test.bc tests/

utop: opam_package
	utop -I $(realpath opam_package) $(realpath opam_package/natural_deduction.cma)
