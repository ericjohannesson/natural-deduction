for file in $(ls examples/*); do echo $file; ../nd $file; done 1> cli_output 2> /dev/null

diff --color exp_cli_output cli_output

for file in $(ls examples/*); do echo $file; ../nd -d $file; done 1> cli_output_d 2> /dev/null

diff --color exp_cli_output_d cli_output_d


for file in $(ls examples/*); do echo $file; ../nd -u $file; done 1> cli_output_u 2> /dev/null

diff --color exp_cli_output_u cli_output_u


for file in $(ls examples/*); do echo $file; ../nd -d -u $file; done 1> cli_output_d_u 2> /dev/null

diff --color exp_cli_output_d_u cli_output_d_u

