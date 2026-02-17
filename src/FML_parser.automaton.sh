#***************************************************************************#
#                                                                           #
#    natural-deduction: a basic proof assistant for natural deduction in    #
#    first-order logic.                                                     #
#                                                                           #
#    Copyright (C) 2026  Eric Johannesson, eric@ericjohannesson.com         #
#                                                                           #
#    This program is free software: you can redistribute it and/or modify   #
#    it under the terms of the GNU General Public License as published by   #
#    the Free Software Foundation, either version 3 of the License, or      #
#    (at your option) any later version.                                    #
#                                                                           #
#    This program is distributed in the hope that it will be useful,        #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
#    GNU General Public License for more details.                           #
#                                                                           #
#    You should have received a copy of the GNU General Public License      #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>. #
#                                                                           #
#***************************************************************************#

automaton=$1


print_state(){
        sed -n "/^State $1:$/,/^$/p" $2
}

get_last_state(){
        grep 'State' $1 | tail -1 | cut -f 2 -d ' ' | cut -f 1 -d ':'
}

print_states(){
        for i in $(seq 0 $1)
        do
                echo '|' $i '->' 
                echo '"'"$(print_state $i $2)"'"'
        done
}

last_state="$(get_last_state $automaton)"

echo 'let state (n:int) : string ='
echo 'match n with' 
echo "$(print_states $last_state $automaton)"
echo '| _ -> ""'
