# natural-deduction

A basic proof assistant for natural deduction in first-order logic.

## Command-line interface

```
USAGE:

  nd [ <options> ] <path-to-file>

        Expands proofs in file according to definitions in file and checks
        validity of each expanded proof according to options.

        Prints a report to stdout.

  OPTIONS:

    --discharge, -d

        Checks a version of the proof where all dischargeable assumptions are
        discharged.

    --undischarge, -u

        Checks a version of the proof where all non-dischargeable assumptions
        are undischarged.

    --intuitionistic, -i

        Uses EFQ (ex falso quodlibet) instead of negation elimination.

    --minimal, -m

        Uses neither EFQ nor negation elimination.

    --verbose, -v

        Prints information to stderr about discharged assumptions that may not
        be discharged, undischarged assumptions that may be discharged, and
        sub-proofs not satisfying the conditions of any inferential rule.
```

### Examples

#### Propositional logic

<details open>
<summary>input</summary>

```
$ cat examples/prop.txt

     -----1
       P
----------------  ----------------------2
P \lor \neg P      \neg (P \lor \neg P)
----------------------------------------¬I,1
            \neg P
-----------------------------      ----------------------2
           P \lor \neg P            \neg (P \lor \neg P)
        ---------------------------------------------------¬E,2
                    P \lor \neg P
```

</details>

<details open>
<summary>output</summary>

```
$ nd examples/prop.txt

-----1                                      
  P                                         
------∨I    ---------0                      
P ∨ ¬P      ¬(P ∨ ¬P)                       
----------------------¬I1                   
          ¬P                                
-------------------------∨I    ---------0   
         P ∨ ¬P                ¬(P ∨ ¬P)    
-----------------------------------------¬E0
                 P ∨ ¬P                     

# Proof is VALID.
# PROVES  ⊢ P ∨ ¬P.
```
</details>

#### Predicate logic

<details>
<summary>input</summary>

```
$ cat examples/pred.txt

\forall x (P(x) -> Q(x))
--------------------------        -----
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
<summary>output</summary>

```
$ nd examples/pred.txt

∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
  P(c) → Q(c)         P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     

# Proof is VALID.
# PROVES ∀x (P(x) → Q(x)), ∃x P(x) ⊢ ∃x Q(x).
```
</details>

#### Peano arithmetic


<details>
<summary>input</summary>

```
$ cat examples/peano.txt

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
<summary>output</summary>

```
$ nd examples/peano.txt

                  ∀x ∀y x + y' = (x + y)'      
                  -----------------------∀E    
∀x x + 0 = x      ∀y 0' + y' = (0' + y)'       
------------∀E    -------------------------∀E  
0' + 0 = 0'          0' + 0' = (0' + 0)'       
---------------------------------------------=E
                0' + 0' = 0''                  

# Proof is VALID.
# PROVES ∀x x + 0 = x, ∀x ∀y x + y' = (x + y)' ⊢ 0' + 0' = 0''.
```

</details>

#### Defining sub-formulas

<details>
<summary>input</summary>

```
$ cat examples/ind.txt

I(z) := T(0,z) ∧ ∀y(T(y,z) → T(y',z))

P(x) := ∀z(I(z) → T(x,z))

Prf :=

-----1                          --------0
P(a)                              I(b)
---------------∀E    ----0      ---------------------∧E
I(b) → T(a,b)        I(b)       ∀y (T(y,b) → T(y',b))
--------------------------→E    -----------------------∀E
          T(a,b)                  T(a,b) → T(a',b)
---------------------------------------------------→E
T(a',b)
---------------→I0
I(b) → T(a',b)
---------------∀I
P(a')
-------------→I1
P(a) → P(a')
-------------------∀I
∀x (P(x) → P(x'))
```
</details>

<details>
<summary>output</summary>

```
$ nd examples/ind.txt

I(z) := T(0,z) ∧ ∀y (T(y,z) → T(y',z))

P(x) := ∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(x,z))

Prf :=

----------------------------------------------0                                           ------------------------------1                
∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(a,z))                                            T(0,b) ∧ ∀y (T(y,b) → T(y',b))                 
-----------------------------------------------∀E    ------------------------------1      -------------------------------∧E              
   (T(0,b) ∧ ∀y (T(y,b) → T(y',b))) → T(a,b)         T(0,b) ∧ ∀y (T(y,b) → T(y',b))            ∀y (T(y,b) → T(y',b))                     
------------------------------------------------------------------------------------→E    ---------------------------------∀E            
                                       T(a,b)                                                     T(a,b) → T(a',b)                       
-----------------------------------------------------------------------------------------------------------------------------→E          
                                                           T(a',b)                                                                       
-------------------------------------------------------------------------------------------------------------------------------→I1       
                                          (T(0,b) ∧ ∀y (T(y,b) → T(y',b))) → T(a',b)                                                     
----------------------------------------------------------------------------------------------------------------------------------∀I     
                                         ∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(a',z))                                                 
------------------------------------------------------------------------------------------------------------------------------------→I0  
                  ∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(a,z)) → ∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(a',z))                       
---------------------------------------------------------------------------------------------------------------------------------------∀I
                 ∀x (∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(x,z)) → ∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(x',z)))                   

# Prf is VALID.
# PROVES  ⊢ ∀x (∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(x,z)) → ∀z ((T(0,z) ∧ ∀y (T(y,z) → T(y',z))) → T(x',z))).
```
</details>


#### Defining sub-proofs

<details>
<summary>input</summary>

```
$ cat examples/discharge.txt

Sub :=

\forall x (P(x) -> Q(x))
--------------------------
      P(c) -> Q(c)          P(c)
---------------------------------
      Q(c)
---------------
\exists x Q(x)


Sub   \exists x P(x)
---------------------EE
  \exists x Q(x)
```
</details>

<details>
<summary>output</summary>

```
$ nd examples/discharge.txt

Sub :=

∀x (P(x) → Q(x))              
----------------∀E            
  P(c) → Q(c)         P(c)    
--------------------------→E  
           Q(c)               
----------------------------∃I
          ∃x Q(x)             

# Sub is VALID.
# PROVES ∀x (P(x) → Q(x)), P(c) ⊢ ∃x Q(x).


∀x (P(x) → Q(x))                            
----------------∀E                          
  P(c) → Q(c)         P(c)                  
--------------------------→E                
           Q(c)                             
----------------------------∃I              
          ∃x Q(x)                 ∃x P(x)   
-----------------------------------------∃E0
                 ∃x Q(x)                    

# Proof is VALID.
# PROVES ∀x (P(x) → Q(x)), P(c), ∃x P(x) ⊢ ∃x Q(x).
```
</details>


#### Discharge dischargeable assumptions

<details>
<summary>input</summary>

```
$ cat examples/discharge.txt

Sub :=

\forall x (P(x) -> Q(x))
--------------------------
      (P(c) -> Q(c))        P(c)
---------------------------------
      Q(c)
---------------
\exists x Q(x)


Sub   \exists x P(x)
---------------------EE
  \exists x Q(x)
```
</details>

<details>
<summary>output with option -d</summary>

```
$ nd -d examples/discharge.txt

Sub :=

∀x (P(x) → Q(x))              
----------------∀E            
  P(c) → Q(c)         P(c)    
--------------------------→E  
           Q(c)               
----------------------------∃I
          ∃x Q(x)             

# Sub is VALID.
# PROVES ∀x (P(x) → Q(x)), P(c) ⊢ ∃x Q(x).


∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
  P(c) → Q(c)         P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     

# Proof is VALID.
# PROVES ∀x (P(x) → Q(x)), ∃x P(x) ⊢ ∃x Q(x).
```
</details>

#### Undischarge non-dischargeable assumptions

<details>
<summary>input</summary>

```
$ cat examples/undischarge.txt

Sub :=

\forall x (P(x) -> Q(x))
--------------------------   ----
      P(c) -> Q(c)           P(c)
----------------------------------
      Q(c)
---------------
\exists x Q(x)


Sub    \exists x P(x)
----------------------EE
    \exists x Q(x)
```

</details>

<details>
<summary>output</summary>

```
$ nd examples/undischarge.txt

Sub :=

∀x (P(x) → Q(x))        
----------------    ----
  P(c) → Q(c)       P(c)
------------------------
          Q(c)          
------------------------
        ∃x Q(x)         

# Sub is NOT valid.
# Does NOT prove ∀x (P(x) → Q(x)) ⊢ ∃x Q(x).


∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
  P(c) → Q(c)         P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     

# Proof is VALID.
# PROVES ∀x (P(x) → Q(x)), ∃x P(x) ⊢ ∃x Q(x).
```
</details>

<details>
<summary>output with option -u</summary>

```
$ nd -u examples/undischarge.txt

Sub :=

∀x (P(x) → Q(x))              
----------------∀E            
  P(c) → Q(c)         P(c)    
--------------------------→E  
           Q(c)               
----------------------------∃I
          ∃x Q(x)             

# Sub is VALID.
# PROVES ∀x (P(x) → Q(x)), P(c) ⊢ ∃x Q(x).


∀x (P(x) → Q(x))                             
----------------∀E    ----0                  
  P(c) → Q(c)         P(c)                   
---------------------------→E                
           Q(c)                              
-----------------------------∃I              
           ∃x Q(x)                 ∃x P(x)   
------------------------------------------∃E0
                 ∃x Q(x)                     

# Proof is VALID.
# PROVES ∀x (P(x) → Q(x)), ∃x P(x) ⊢ ∃x Q(x).
```
</details>

</details>

## Build instructions

Clone this repository. In the root directory of the clone, follow either of the instructions below.

### Alternative 1 (opam)

For installing the opam package manager, see https://opam.ocaml.org/

Install required packages:
```bash
opam install ocaml ocamlfind uuseg menhir
```

Build executable:
```bash
make nd
```

Install natural-deduction as a local opam package:
```bash
opam install .
```

### Alternative 2 (nix)

For installing the nix package manager, see https://nixos.org/

Open a nix-shell with the required packages:
```bash
nix-shell -p ocaml ocamlPackages.findlib ocamlPackages.uuseg ocamlPackages.menhir
```

In that shell, build executable:
```bash
make nd
```
