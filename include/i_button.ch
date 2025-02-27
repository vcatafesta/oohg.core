/*
 * $Id: i_button.ch $
 */
/*
 * ooHG source code:
 * Button definitions
 *
 * Copyright 2005-2021 Vicente Guerra <vicente@guerra.com.mx> and contributors of
 * the Object Oriented (x)Harbour GUI (aka OOHG) Project, https://oohg.github.io/
 *
 * Portions of this project are based upon:
 *    "Harbour MiniGUI Extended Edition Library"
 *       Copyright 2005-2021 MiniGUI Team, http://hmgextended.com
 *    "Harbour GUI framework for Win32"
 *       Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 *       Copyright 2001 Antonio Linares <alinares@fivetech.com>
 *    "Harbour MiniGUI"
 *       Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
 *    "Harbour Project"
 *       Copyright 1999-2021 Contributors, https://harbour.github.io/
 */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file LICENSE.txt. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1335, USA (or download from http://www.gnu.org/licenses/).
 *
 * As a special exception, the ooHG Project gives permission for
 * additional uses of the text contained in its release of ooHG.
 *
 * The exception is that, if you link the ooHG libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the ooHG library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the ooHG
 * Project under the name ooHG. If you copy code from other
 * ooHG Project or Free Software Foundation releases into a copy of
 * ooHG, as the General Public License permits, the exception does
 * not apply to the code that you add in this way. To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for ooHG, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 */


#xcommand @ <row>, <col> BUTTON <name> ;
      [ OBJ <obj> ] ;
      [ <dummy: OF, PARENT> <parent> ] ;
      [ <dummy: ACTION, ON CLICK, ONCLICK> <action> ] ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold: BOLD> ] ;
      [ <italic: ITALIC> ] ;
      [ <underline: UNDERLINE> ] ;
      [ <strikeout: STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <dummy: ONGOTFOCUS, ON GOTFOCUS> <gotfocus> ] ;
      [ <dummy: ONLOSTFOCUS, ON LOSTFOCUS> <lostfocus> ] ;
      [ <dummy: ONMOUSEMOVE, ON MOUSEMOVE, ONMOUSEHOVER, ON MOUSEHOVER> <onmousemove> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <rtl: RTL> ] ;
      [ <noprefix: NOPREFIX> ] ;
      [ SUBCLASS <subclass> ] ;
      [ <disabled: DISABLED> ] ;
      [ CAPTION <caption> ] ;
      [ <dummy: PICTURE, ICON> <bitmap> ] ;
      [ BUFFER <buffer> ] ;
      [ HBITMAP <hbitmap> [ <nodestroy: NODESTROY> ] ] ;
      [ <lnoldtr: NOLOADTRANSPARENT> ] ;
      [ <stretch: STRETCH> ] ;
      [ <cancel: CANCEL> ] ;
      [ [ <dummy: IMAGEALIGN> ] <imgalign: LEFT, RIGHT, TOP, BOTTOM, CENTER> ] ;
      [ <multiline: MULTILINE> ] ;
      [ <drawby: OOHGDRAW, WINDRAW> ] ;
      [ IMAGEMARGIN <aimagemargin> ] ;
      [ <fitimg: FITIMG> ] ;
      [ <no3dcolors: NO3DCOLORS> ] ;
      [ <autofit: AUTOFIT, ADJUST, FORCESCALE> ] ;
      [ <ldib: DIBSECTION> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ <solidbk: SOLID> ] ;
      [ <nohotlight: NOHOTLIGHT> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ TEXTALIGNH <txth: LEFT, RIGHT, CENTER> ] ;
      [ TEXTALIGNV <txtv: TOP, BOTTOM, VCENTER> ] ;
      [ <noover: NOPRINTOVER> ] ;
      [ TEXTMARGIN <atextmargin> ] ;
      [ <fittxt: FITTXT> ] ;
      [ <imgsize: IMAGESIZE> ] ;
      [ <ltransp: TRANSPARENT> ] ;
      [ <lnofocus: NOFOCUSRECT> ] ;
      [ <lnoimglst: NOIMAGELIST> ] ;
      [ <lhand: HANDCURSOR> ] ;
      [ <ldefault: DEFAULT> ] ;
   => ;
      [ <obj> := ] _OOHG_SelectSubClass( TButton(), [ <subclass>() ] ): ;
            Define( <(name)>, <(parent)>, <col>, <row>, <caption>, <{action}>, ;
            <width>, <height>, <fontname>, <fontsize>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
            <.flat.>, <.notabstop.>, <helpid>, <.invisible.>, <.bold.>, ;
            <.italic.>, <.underline.>, <.strikeout.>, <.rtl.>, <.noprefix.>, ;
            <.disabled.>, <buffer>, <hbitmap>, <bitmap>, <.lnoldtr.>, ;
            <.stretch.>, <.cancel.>, <"imgalign">, <.multiline.>, ;
            iif( #<drawby> == "OOHGDRAW", .T., iif( #<drawby> == "WINDRAW", .F., NIL ) ), ;
            <aimagemargin>, <{onmousemove}>, <.no3dcolors.>, <.autofit.>, ;
            ! <.ldib.>, <backcolor>, <.nohotlight.>, <.solidbk.>, <fontcolor>, ;
            {<"txth">, <"txtv">}, <.noover.>, <atextmargin>, <.fittxt.>, <.fitimg.>, ;
            <.imgsize.>, <.ltransp.>, <.lnofocus.>, <.lnoimglst.>, <.nodestroy.>, ;
            <.lhand.>, <.ldefault.> )

#xtranslate BUTTON [ <x> ] FOCUSRECT ;
   => ;
      BUTTON [ <x> ]

#command @ <row>, <col> CHECKBUTTON <name> ;
      [ OBJ <obj> ] ;
      [ <dummy: OF, PARENT> <parent> ] ;
      [ CAPTION <caption> ] ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold: BOLD> ] ;
      [ <italic: ITALIC> ] ;
      [ <underline: UNDERLINE> ] ;
      [ <strikeout: STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <dummy: ONGOTFOCUS, ON GOTFOCUS> <gotfocus> ] ;
      [ <dummy: ONCHANGE, ON CHANGE> <change> ] ;
      [ <dummy: ONLOSTFOCUS, ON LOSTFOCUS> <lostfocus> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ SUBCLASS <subclass> ] ;
      [ <rtl: RTL> ] ;
      [ <dummy: PICTURE, ICON> <bitmap> ] ;
      [ BUFFER <buffer> ] ;
      [ HBITMAP <hbitmap> [ <nodestroy: NODESTROY> ] ] ;
      [ <lnoldtr: NOLOADTRANSPARENT> ] ;
      [ <stretch: STRETCH> ] ;
      [ FIELD <field> ] ;
      [ <no3dcolors: NO3DCOLORS> ] ;
      [ <autofit: AUTOFIT, ADJUST, FORCESCALE> ] ;
      [ <ldib: DIBSECTION> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ <solidbk: SOLID> ] ;
      [ <disabled: DISABLED> ] ;
      [ <drawby: OOHGDRAW, WINDRAW> ] ;
      [ IMAGEMARGIN <aimagemargin> ] ;
      [ <fitimg: FITIMG> ] ;
      [ <dummy: ONMOUSEMOVE, ON MOUSEMOVE, ONMOUSEHOVER, ON MOUSEHOVER> <onmousemove> ] ;
      [ [ <dummy: IMAGEALIGN> ] <imgalign: LEFT, RIGHT, TOP, BOTTOM, CENTER> ] ;
      [ <multiline: MULTILINE> ] ;
      [ <flat: FLAT> ] ;
      [ <nohotlight: NOHOTLIGHT> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ TEXTALIGNH <txth: LEFT, RIGHT, CENTER> ] ;
      [ TEXTALIGNV <txtv: TOP, BOTTOM, VCENTER> ] ;
      [ <noover: NOPRINTOVER> ] ;
      [ TEXTMARGIN <atextmargin> ] ;
      [ <fittxt: FITTXT> ] ;
      [ <imgsize: IMAGESIZE> ] ;
      [ <ltransp: TRANSPARENT> ] ;
      [ <lnofocus: NOFOCUSRECT> ] ;
      [ <lnoimglst: NOIMAGELIST> ] ;
      [ <lhand: HANDCURSOR> ] ;
   => ;
      [ <obj> := ] _OOHG_SelectSubClass( TButtonCheck(), [ <subclass>() ] ): ;
            Define( <(name)>, <(parent)>, <col>, <row>, <caption>, <value>, ;
            <fontname>, <fontsize>, <tooltip>, <{change}>, <width>, <height>, <{lostfocus}>, ;
            <{gotfocus}>, <helpid>, <.invisible.>, <.notabstop.>, <.bold.>, ;
            <.italic.>, <.underline.>, <.strikeout.>, <(field)>, <.rtl.>, ;
            <bitmap>, <buffer>, <hbitmap>, <.lnoldtr.>, <.stretch.>, ;
            <.no3dcolors.>, <.autofit.>, ! <.ldib.>, <backcolor>, <.disabled.>, ;
            iif( #<drawby> == "OOHGDRAW", .T., iif( #<drawby> == "WINDRAW", .F., NIL ) ), ;
            <aimagemargin>, <{onmousemove}>, <"imgalign">, <.multiline.>, ;
            <.flat.>, <.nohotlight.>, <.solidbk.>, <fontcolor>, {<"txth">, <"txtv">}, ;
            <.noover.>, <atextmargin>, <.fittxt.>, <.fitimg.>, <.imgsize.>, ;
            <.ltransp.>, <.lnofocus.>, <.lnoimglst.>, <.nodestroy.>, <.lhand.> )

#xtranslate CHECKBUTTON [ <x> ] FOCUSRECT ;
   => ;
      CHECKBUTTON [ <x> ]
