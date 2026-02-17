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

for file in $(ls examples/*); do echo $file; ../nd $file; done 1> output 2> /dev/null

diff --color exp_output output

for file in $(ls examples/*); do echo $file; ../nd -d $file; done 1> output_d 2> /dev/null

diff --color exp_output_d output_d


for file in $(ls examples/*); do echo $file; ../nd -u $file; done 1> output_u 2> /dev/null

diff --color exp_output_u output_u


for file in $(ls examples/*); do echo $file; ../nd -d -u $file; done 1> output_d_u 2> /dev/null

diff --color exp_output_d_u output_d_u

