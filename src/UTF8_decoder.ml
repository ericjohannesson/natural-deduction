(*****************************************************************************)
(*                                                                           *)
(*    natural-deduction: a basic proof assistant for natural deduction in    *)
(*    first-order logic.                                                     *)
(*                                                                           *)
(*    Copyright (C) 2026  Eric Johannesson, eric@ericjohannesson.com         *)
(*                                                                           *)
(*    This program is free software: you can redistribute it and/or modify   *)
(*    it under the terms of the GNU General Public License as published by   *)
(*    the Free Software Foundation, either version 3 of the License, or      *)
(*    (at your option) any later version.                                    *)
(*                                                                           *)
(*    This program is distributed in the hope that it will be useful,        *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of         *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *)
(*    GNU General Public License for more details.                           *)
(*                                                                           *)
(*    You should have received a copy of the GNU General Public License      *)
(*    along with this program.  If not, see <https://www.gnu.org/licenses/>. *)
(*                                                                           *)
(*****************************************************************************)
let utf_8_segments seg s =
        let flush_segment buf acc =
                let segment = Buffer.contents buf in
                let _ : unit = Buffer.clear buf in
                if segment = "" then acc else segment :: acc
        in
        let rec add buf acc segmenter v =
                match Uuseg.add segmenter v with
                | `Uchar u ->
                        let _ : unit = Buffer.add_utf_8_uchar buf u in
                        add buf acc segmenter `Await
                | `Boundary -> add buf (flush_segment buf acc) segmenter `Await
                | `Await 
                | `End -> acc
        in
        let rec loop buf acc s i max segmenter =
                if i > max then flush_segment buf (add buf acc segmenter `End) else
                let dec = String.get_utf_8_uchar s i in
                let acc = add buf acc segmenter (`Uchar (Uchar.utf_decode_uchar dec)) in
                loop buf acc s (i + Uchar.utf_decode_length dec) max segmenter
        in
        let buf = Buffer.create 42 in
        let segmenter = Uuseg.create seg in
        List.rev (loop buf [] s 0 (String.length s - 1) segmenter)

let string_list_of_string (s : string) : string list =
        utf_8_segments `Grapheme_cluster s


