# natural-deduction

A basic proof assistant for natural deduction proofs in classical first-order logic.

## Command-line interface

```
USAGE:

  nd <command>

  COMMANDS:

    validate [ <options> ] { <path-to-file> | - }

        Prints an annotated and formatted version of proof contained in file
        to stdout, and a report to stderr, if proof is valid.

        Otherwise prints a report to stderr.

    show [ <directions> ] { <path-to-file> | - }

        Prints a formatted version of proof contained in file to stdout, or
        sub-proof thereof specified by directions.

        Prints message to stderr if no sub-proof matches directions.

    edit [ <directions> ] <path-to-file>

        Opens a formatted version of proof contained in file in nano, or
        sub-proof thereof specified by directions. Writes any changes to file.

    replace <path-to-file> [ <directions> ] <path-to-file>

        Prints to stdout result of replacing proof contained in second file
        (or sub-proof thereof specified by directions) with proof contained
        in first file.

    decompose [ <path-to-directory> ] [ -R ] <path-to-file>

        Parses proof contained in file and creates a directory for each
        immediate sub-proof containing a file called 'proof.txt'. Also prints
        main proof to 'proof.txt', and puts everything either in directory of
        file (default), or in path-to-directory.

        Does it recursively for each sub-proof if '-R' is provided.

    compose [ -R ] <path-to-directory>

        Assumes that a proof has been decomposed in directory, and composes a
        proof from its immediate sub-proofs. Prints the result to stdout and
        to the file 'proof.txt' located in directory.

        Does it recursively for each sub-proof if '-R' is provided.

    help

        Prints this manual to stdout.

    Reads from stdin if '-' is provided instead of a path (and if it may be so
    provided).

  OPTIONS:

    --discharge, -d

        Checks a version of the proof where all dischargeable assumptions are
        discharged.

    --undischarge, -u

        Checks a version of the proof where all undischargeable assumptions
        are undischarged.

    --verbose, -v

        Prints information to stderr about discharged assumptions that may not
        be discharged, undischarged assumptions that may be discharged, and
        sub-proofs not satisfying the conditions of any inferential rule.

  DIRECTIONS:

    --sub-only, -o

        Targets the (only) sub-proof of a unary proof.

    --sub-left, -l

        Targets the left sub-proof of a binary or trinary proof.

    --sub-right, -r

        Targets the right sub-proof of a binary or trinary proof.

    --sub-center, -c

        Targets the center sub-proof of a trinary proof.

    A space-separated list of directions is interpreted from left to right,
    in such a way that 

        nd show <directions> <direction> <path-to-file>

    is equivalent to

        nd show <directions> <path-to-file> | nd show <direction> -
```

### Examples

#### Peano arithmetic


<details>
<summary><b>input</b></summary>

content of `examples/proof1.txt`:

```
                  ∀x∀y(x+y'=(x+y)')
                ----------------------
 ∀x(x+0=x)       ∀y(0'+y'=(0'+y)')
------------    --------------------
    0'+0=0'          0'+0'=(0'+0)'
-----------------------------------
          0'+0'=0''
```
</details>

<details>
<summary><b>output</b></summary>

output of `nd validate examples/proof1.txt` to stdout:

```
                    ∀x ∀y (x + y') = (x + y)'      
                    -------------------------∀E    
∀x (x + 0) = x      ∀y (0' + y') = (0' + y)'       
--------------∀E    ---------------------------∀E  
(0' + 0) = 0'          (0' + 0') = (0' + 0)'       
-------------------------------------------------=E
                 (0' + 0') = 0''                   
```
and to stderr:
```
Proof is VALID:

                    ∀x ∀y (x + y') = (x + y)'      
                    -------------------------∀E    
∀x (x + 0) = x      ∀y (0' + y') = (0' + y)'       
--------------∀E    ---------------------------∀E  
(0' + 0) = 0'          (0' + 0') = (0' + 0)'       
-------------------------------------------------=E
                 (0' + 0') = 0''                   

PROVES: ∀x (x + 0) = x, ∀x ∀y (x + y') = (x + y)' ⊢ (0' + 0') = 0''.
```
</details>


#### Predicate logic

<details>
<summary><b>input</b></summary>

content of `examples/proof2.txt`:
```
\forall x (P(x) -> Q(x))
--------------------------        -----(1)
      P(c) -> Q(c)                 P(c)
-----------------------------------------
      Q(c)
---------------
\exists x Q(x)        \exists x P(x)
--------------------------------------(EE,1)
            \exists x Q(x)
```
</details>

<details>
<summary><b>output</b></summary>

output of `nd show examples/proof2.txt` to stdout:
```
∀x (P(x) → Q(x))                     
----------------    ----             
 (P(c) → Q(c))      P(c)             
------------------------             
          Q(c)                       
------------------------             
        ∃x Q(x)             ∃x P(x)  
-----------------------------------EE
              ∃x Q(x)                
```

output of `nd validate examples/proof2.txt` to stdout:
```
∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
 (P(c) → Q(c))        P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     
```
and to stderr:
```
Proof is VALID:

∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
 (P(c) → Q(c))        P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     

PROVES: ∀x (P(x) → Q(x)), ∃x P(x) ⊢ ∃x Q(x).
```

output of `nd show --sub-left --sub-only examples/proof2.txt` to stdout:
```
∀x (P(x) → Q(x))        
----------------    ----
 (P(c) → Q(c))      P(c)
------------------------
          Q(c)          
```

</details>

#### Discharge dischargeable assumptions

<details>
<summary><b>input</b></summary>

content of `examples/proof3.txt`:
```
\forall x (P(x) -> Q(x))
--------------------------        
      P(c) -> Q(c)                 P(c)
-----------------------------------------
      Q(c)
---------------
\exists x Q(x)        \exists x P(x)
--------------------------------------EE
            \exists x Q(x)
```
</details>

<details>
<summary><b>output</b></summary>

output of `nd validate --verbose examples/proof3.txt` to stderr:
```
GOOD NEWS: Undischarged assumption 'P(c)' may be discharged on the following branch:

P(c)

which is part of

∀x (P(x) → Q(x))        
----------------        
 (P(c) → Q(c))      P(c)
------------------------
          Q(c)          

which is part of

∀x (P(x) → Q(x))        
----------------        
 (P(c) → Q(c))      P(c)
------------------------
          Q(c)          
------------------------
        ∃x Q(x)         

which is part of

∀x (P(x) → Q(x))                     
----------------                     
 (P(c) → Q(c))      P(c)             
------------------------             
          Q(c)                       
------------------------             
        ∃x Q(x)             ∃x P(x)  
-----------------------------------EE
              ∃x Q(x)                


Proof is VALID:

∀x (P(x) → Q(x))                            
----------------∀E                          
 (P(c) → Q(c))        P(c)                  
--------------------------→E                
           Q(c)                             
----------------------------∃I              
          ∃x Q(x)                 ∃x P(x)   
-----------------------------------------∃E0
                 ∃x Q(x)                    

PROVES: ∀x (P(x) → Q(x)), P(c), ∃x P(x) ⊢ ∃x Q(x).
```

output of `nd validate --discharge examples/proof3.txt` to stdout:
```
∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
 (P(c) → Q(c))        P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     
```
</details>

#### Undischarge undischargeable assumptions

<details>
<summary><b>input</b></summary>

content of `examples/proof4.txt`:
```
-
P     Q
---------
(P ∧ Q)
```

</details>

<details>
<summary><b>output</b></summary>

output of `nd validate --verbose examples/proof4.txt` to stderr:
```
BAD NEWS: Discharged assumption 'P' may not be discharged on the following branch:

-
P

which is part of

-      
P     Q
-------
(P ∧ Q)


BAD NEWS: The following branch does not satisfy the conditions of any binary rule:

-      
P     Q
-------
(P ∧ Q)


Proof is NOT valid:

-      
P     Q
-------
(P ∧ Q)

Does NOT prove: Q ⊢ (P ∧ Q).
```

output of `nd validate --undischarge examples/proof4.txt` to stdout:
```
P     Q  
-------∧I
(P ∧ Q)  
```
and to stderr:
```
Proof is VALID:

P     Q  
-------∧I
(P ∧ Q)  

PROVES: P, Q ⊢ (P ∧ Q).
```
</details>

## Installation

Clone this repository. In the root directory of the clone, follow either of the instructions below.

### Alternative 1: with opam

For installing the opam package manager, see https://opam.ocaml.org/

Install required packages:
```bash
opam install ocaml ocamlfind uuseg menhir
```

Build executable:
```bash
make nd
```

### Alternative 2: with nix

For installing the nix package manager, see https://nixos.org/

Open a nix-shell with the required packages:
```bash
nix-shell -p ocaml ocamlPackages.findlib ocamlPackages.uuseg ocamlPackages.menhir
```

In that shell, build executable:
```bash
make nd
```
