/*
 * $Id: h_browse.prg,v 1.2 2005-08-09 04:19:27 guerra000 Exp $
 */
/*
 * ooHG source code:
 * PRG browse functions
 *
 * Copyright 2005 Vicente Guerra <vicente@guerra.com.mx>
 * www - http://www.guerra.com.mx
 *
 * Portions of this code are copyrighted by the Harbour MiniGUI library.
 * Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 *
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
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
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
 *
 */
/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 http://www.geocities.com/harbour_minigui/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

	"Harbour GUI framework for Win32"
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://www.harbour-project.org

	"Harbour Project"
	Copyright 1999-2003, http://www.harbour-project.org/
---------------------------------------------------------------------------*/
#include 'oohg.ch'
#include "hbclass.ch"
#include "i_windefs.ch"

STATIC _OOHG_BrowseSyncStatus := .F.
STATIC _OOHG_IPE_COL := 1   // ???
STATIC _OOHG_IPE_ROW := 1   // ???
STATIC _OOHG_IPE_CANCELLED := .F.   // ???

memvar aresult

CLASS TBrowse FROM TGrid
   DATA Type      INIT "BROWSE" READONLY
   DATA Lock      INIT .F.
   DATA WorkArea  INIT ""
   DATA VScroll   INIT nil
   DATA nValue    INIT 0
   DATA aRecMap   INIT {}
   DATA ScrollBarButtonHandle INIT 0
   DATA AllowAppend     INIT .F.
   DATA readonly        INIT .F.
   DATA valid           INIT .F.
   DATA validmessages   INIT .F.
   DATA AllowDelete     INIT .F.
   DATA InPlace         INIT .F.
   DATA RecCount        INIT 0
   DATA aWidths         INIT {}
   DATA aFields         INIT {}
   DATA lEof            INIT .F.
   DATA aControls       INIT {}
   DATA nButtonActive   INIT 0
   DATA aWhen           INIT {}

   METHOD Define
   METHOD Refresh
   METHOD Release
   METHOD SizePos
   METHOD Value               SETGET
   METHOD Enabled             SETGET
   METHOD Visible             SETGET
   METHOD RefreshData

   METHOD IsHandle

   METHOD Events_Enter
   METHOD Events_Notify

   METHOD Sync
   METHOD BrowseOnChange
   METHOD FastUpdate
   METHOD ScrollUpdate
   METHOD EditItem
   METHOD ProcessInPlaceKbdEdit
   METHOD SetValue
   METHOD Delete
   METHOD UpDate
   METHOD InPlaceAppend
   METHOD InPlaceEdit
   METHOD InPlaceEditOk
   METHOD AdjustRightScroll

   METHOD Home
   METHOD End
   METHOD PageUp
   METHOD PageDown
   METHOD Up
   METHOD Down
   METHOD SetScrollPos
ENDCLASS

*-----------------------------------------------------------------------------*
METHOD Define( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, aFields ,value,fontname,fontsize , tooltip , change , dblclick , aHeadClick , gotfocus , lostfocus , WorkArea , AllowDelete, nogrid, aImage, aJust , HelpId , bold , italic , underline , strikeout , break , backcolor , fontcolor , lock , inplace , novscroll , AllowAppend , readonly , valid , validmessages , edit , dynamicbackcolor , aWhenFields , dynamicforecolor ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local wBitmap , ScrollBarHandle , DeltaWidth
Local ControlHandle
Local hsum
Local ScrollBarButtonHandle

   ::SetForm( ControlName, ParentForm, FontName, FontSize )

   if valtype(w) != "N"
		w := 240
	endif
   if valtype(h) != "N"
		h := 120
	endif
   if valtype(value) != "N"
		value := 0
	endif
   if valtype(aFields) != "A"
		aFields := {}
	endif
   if valtype(aJust) != "A"
		aJust := Array( len( aFields ) )
		aFill( aJust, 0 )
	else
		aSize( aJust, len( aFields) )
		aEval( aJust, { |x| x := iif( x == NIL, 0, x ) } )
	endif
   if valtype(aImage) != "A"
		aImage := {}
	endif

	// If splitboxed force no vertical scrollbar

   if valtype(x) != "N" .or. valtype(y) != "N"
		novscroll := .T.
	endif

	if novscroll == .F.
		DeltaWidth := GETVSCROLLBARWIDTH()
	Else
		DeltaWidth := 0
	EndIf

   if valtype(x) != "N" .or. valtype(y) != "N"

      If _OOHG_SplitLastControl == "TOOLBAR"
			Break := .T.
		EndIf

      _OOHG_SplitLastControl   := "GRID"

         ControlHandle := InitBrowse ( ::Parent:hWnd, 0, x, y, w - DeltaWidth , h , '', 0, iif( nogrid, 0, 1 ) ) // Browse+

			x := GetWindowCol ( Controlhandle )
			y := GetWindowRow ( Controlhandle )

         AddSplitBoxItem ( Controlhandle, ::Parent:ReBarHandle, w , break , , , , _OOHG_ActiveSplitBoxInverted )

	Else

      ControlHandle := InitBrowse ( ::Parent:hWnd, 0, x, y, w - DeltaWidth , h , '', 0, iif( nogrid, 0, 1 ) ) // Browse+

	endif

	If ValType (backcolor) != 'U'
		ListView_SetBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
		ListView_SetTextBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3]  )
	EndIf

	If ValType (fontcolor) != 'U'
		ListView_SetTextColor ( ControlHandle , fontcolor[1] , fontcolor[2] , fontcolor[3]  )
	EndIf

	wBitmap := iif( len( aImage ) > 0, AddListViewBitmap( ControlHandle, aImage ), 0 ) //Add Bitmap Column
   aWidths[1] := max ( aWidths[1], wBitmap + 2 ) // Set Column 1 width to Bitmap width

   if valtype(aHeadClick) != "A"
		aHeadClick := {}
	endif

   if valtype(change) != "B"
		change := ""
	endif

   if valtype(dblclick) != "B"
		dblclick := ""
	endif

   InitListViewColumns( ControlHandle , aHeaders , aWidths, aJust ) // Browse+

   ::New( ControlHandle, ControlName, HelpId,, ToolTip )
   ::SetFont( , , bold, italic, underline, strikeout )
   ::SizePos( y, x, w, h )

   ::aWidths :=  aWidths
   ::aHeaders := aHeaders
   ::nValue := Value
   ::Lock := Lock
   ::OnLostFocus := LostFocus
   ::OnGotFocus :=  GotFocus
   ::OnChange   :=  Change
   ::aImages :=  aImage // Browse+
   ::InPlace := inplace
   ::OnDblClick := dblclick
   ::aHeadClick := aHeadClick
   ::WorkArea := WorkArea
   ::AllowDelete := AllowDelete
   ::aFields := aFields
   ::aRecMap :=  {}
   ::ScrollBarButtonHandle := 0
   ::AllowAppend := AllowAppend
   ::readonly := readonly
   ::valid := valid
   ::validmessages := validmessages
   ::AllowEdit := edit
   ::nButtonActive := 0
   ::aWhen := aWhenFields
   ::DynamicForeColor := dynamicforecolor
   ::DynamicBackColor := dynamicbackcolor

	// Add to browselist array to update on window activation

   aAdd ( ::Parent:BrowseList, Self )

   hsum := 0
   AEVAL( ::aWidths, { |a,i| hsum += ( ::aWidths[ i ] := ListView_GetColumnWidth( ControlHandle, i - 1 ) ), a } )

	// Add Vertical scrollbar

	if novscroll == .F.

		if hsum > w - GETVSCROLLBARWIDTH() - 4
         ScrollBarHandle := InitVScrollBar ( ::Parent:hWnd, x + w - GETVSCROLLBARWIDTH() , y , GETVSCROLLBARWIDTH() , h - GETHSCROLLBARHEIGHT() )
         ScrollBarButtonHandle := InitVScrollBarButton ( ::Parent:hWnd, x + w - GETVSCROLLBARWIDTH() , y + h - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() )
         ::nButtonActive := 1
		Else
         ScrollBarHandle := InitVScrollBar ( ::Parent:hWnd, x + w - GETVSCROLLBARWIDTH() , y , GETVSCROLLBARWIDTH() , h )
         ScrollBarButtonHandle := InitVScrollBarButton ( ::Parent:hWnd, x + w - GETVSCROLLBARWIDTH() , y + h - GETHSCROLLBARHEIGHT() , 0 , 0 )
         ::nButtonActive := 0
		EndIf

      ::VScroll := TScrollBar():SetContainer( Self, "" )
      ::VScroll:New( ScrollBarHandle,, HelpId,, ToolTip, ScrollBarHandle )
      ::VScroll:RangeMin := 1
      ::VScroll:RangeMax := 100
      ::VScroll:OnLineUp   := { || ::SetFocus(), ::Up() }
      ::VScroll:OnLineDown := { || ::SetFocus(), ::Down() }
      ::VScroll:OnPageUp   := { || ::SetFocus(), ::PageUp() }
      ::VScroll:OnPageDown := { || ::SetFocus(), ::PageDown() }
      ::VScroll:OnThumb    := { |VScroll,Pos| empty(VScroll), ::SetFocus(), ::SetScrollPos( Pos ) }
// cambiar TOOLTIP si cambia el del BROWSE
// Cambiar HelpID si cambia el del BROWSE

	EndIf

   ::ScrollBarButtonHandle := ScrollBarButtonHandle

   ::SizePos()

Return Self

*-----------------------------------------------------------------------------*
METHOD UpDate() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local PageLength , aTemp := {} , uTemp , _BrowseRecMap := {} , x , j , First , Image , _Rec
Local cType, nCurrentLength

   If Select( ::WorkArea ) == 0
      Return nil
	EndIf

   ::lEof := .F.

   First   := iif( len( ::aImages ) == 0, 1, 2 ) // Browse+ ( 2= bitmap definido, se cargan campos a partir de 2� )

   PageLength := ListViewGetCountPerPage ( ::hWnd )

   ::GridForeColor := ARRAY( PageLength )
   ::GridBackColor := ARRAY( PageLength )

   x := 1
   nCurrentLength := ::ItemCount()

   Do While x <= PageLength .AND. ! ( ::WorkArea )->( Eof() )

      aTemp := ARRAY( LEN( ::aFields ) )
      AFILL( aTemp, NIL )

		If First == 2						// Browse+
         uTemp := ( ::WorkArea )->( &( ::aFields[ 1 ] ) )
         cType := ValType( uTemp )

         if cType == 'N'           // ..
            image := uTemp

         elseif cType == 'L'       // ..
            image := iif( uTemp, 1, 0 )

			else						// ..
				image := 0

			endif						// ..

		EndIf							// Browse+

      For j := First To Len( ::aFields )
         uTemp := ( ::WorkArea )->( &( ::aFields[ j ] ) )

         cType := ValType( uTemp )
         If cType == 'N'
            aTemp[ j ] := lTrim ( Str ( uTemp ) )
         ElseIf cType == 'D'
            aTemp[ j ] := Dtoc( uTemp )
         ElseIf cType == 'L'
            aTemp[ j ] := IIF ( uTemp, '.T.', '.F.' )
         ElseIf cType == 'C'
            aTemp[ j ] := rTrim( uTemp )
         ElseIf cType == 'M'
            aTemp[ j ] := '<Memo>'
			Else
            aTemp[ j ] := 'Nil'
			EndIf

		Next j

      ( ::WorkArea )->( ::SetItemColor( x,,, aTemp ) )

      IF nCurrentLength < x
         AddListViewItems ( ::hWnd, aTemp , Image )
         nCurrentLength++
      Else
         ListViewSetItem( ::hWnd, aTemp, x )
         if First == 2
            SetImageListViewItems( ::hWnd, x, aTemp[1] )
         EndIf
      ENDIF

      _Rec := ( ::WorkArea )->( RecNo() )

		aadd ( _BrowseRecMap , _Rec )

      ( ::WorkArea )->( DbSkip() )
      x++
   EndDo

   IF nCurrentLength > Len( _BrowseRecMap )
      Do While nCurrentLength > Len( _BrowseRecMap )
         ::DeleteItem( nCurrentLength )
         nCurrentLength--
      Enddo
   ENDIF

   IF ( ::WorkArea )->( Eof() )
*      _BrowseRecMap[ len( _BrowseRecMap ) ] := 0
      ::lEof := .T.
   EndIf

   ::aRecMap := _BrowseRecMap

Return nil

*-----------------------------------------------------------------------------*
METHOD PageDown() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local PageLength , _RecNo , _DeltaScroll := { Nil , Nil , Nil , Nil } , s

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   PageLength := LISTVIEWGETCOUNTPERPAGE ( ::hWnd )

   s := LISTVIEW_GETFIRSTITEM ( ::hWnd )

	If  s == PageLength

      if ::lEof
         Return nil
      EndIf

      If Select( ::WorkArea ) == 0
         Return nil
		EndIf
      _RecNo := ( ::WorkArea )->( RecNo() )

      ( ::WorkArea )->( DbGoTo( ::aRecMap[ Len( ::aRecMap ) ] ) )
      ::Update()
      ( ::WorkArea )->( DbGoTo( ::aRecMap[ Len( ::aRecMap ) ] ) )
      ::scrollUpdate()
      ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
      ListView_SetCursel ( ::hWnd, Len( ::aRecMap ) )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )

	Else

      ListView_SetCursel ( ::hWnd, Len( ::aRecMap ) )
      ::FastUpdate( PageLength - s )

	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD PageUp() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _DeltaScroll := { Nil , Nil , Nil , Nil }

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   If LISTVIEW_GETFIRSTITEM ( ::hWnd ) == 1
      If Select( ::WorkArea ) == 0
         Return nil
		EndIf
      _RecNo := ( ::WorkArea )->( RecNo() )
      ( ::WorkArea )->( DbGoTo( ::aRecMap[ 1 ] ) )
      ( ::WorkArea )->( DbSkip( - LISTVIEWGETCOUNTPERPAGE ( ::hWnd ) + 1 ) )
      ::scrollUpdate()
      ::Update()
      ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )

	Else

      ::FastUpdate( 1 - LISTVIEW_GETFIRSTITEM ( ::hWnd ) )

	EndIf

   ListView_SetCursel ( ::hWnd, 1 )

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD Home() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _DeltaScroll := { Nil , Nil , Nil , Nil }

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   If Select( ::WorkArea ) == 0
      Return nil
	EndIf
   _RecNo := ( ::WorkArea )->( RecNo() )
   ( ::WorkArea )->( DbGoTop() )
   ::scrollUpdate()
   ::Update()
   ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
   ( ::WorkArea )->( DbGoTo( _RecNo ) )

   ListView_SetCursel ( ::hWnd, 1 )

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD End() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _DeltaScroll , _BottomRec

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   If Select( ::WorkArea ) == 0
      Return nil
	EndIf
   _RecNo := ( ::WorkArea )->( RecNo() )
   ( ::WorkArea )->( DbGoBottom() )
   _BottomRec := ( ::WorkArea )->( RecNo() )
   ::scrollUpdate()

   ( ::WorkArea )->( DbSkip( - LISTVIEWGETCOUNTPERPAGE ( ::hWnd ) + 1 ) )
   ::Update()
   ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
   ( ::WorkArea )->( DbGoTo( _RecNo ) )

   ListView_SetCursel( ::hWnd, ascan ( ::aRecMap, _BottomRec ) )

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD Up() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local s  , _RecNo , _DeltaScroll := { Nil , Nil , Nil , Nil }

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   s := LISTVIEW_GETFIRSTITEM ( ::hWnd )

	If s == 1
      If Select( ::WorkArea ) == 0
         Return nil
      EndIf
      _RecNo := ( ::WorkArea )->( RecNo() )
      ( ::WorkArea )->( DbGoTo( ::aRecMap[ 1 ] ) )
      ( ::WorkArea )->( DbSkip( -1 ) )
      ::scrollUpdate()
      ::Update()
      ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )
      ListView_SetCursel ( ::hWnd, 1 )

	Else
      ListView_SetCursel ( ::hWnd, s - 1 )
      ::FastUpdate( -1 )
	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD Down() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local PageLength , s , _RecNo , _DeltaScroll := { Nil , Nil , Nil , Nil }

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   s := LISTVIEW_GETFIRSTITEM ( ::hWnd )

   PageLength := LISTVIEWGETCOUNTPERPAGE ( ::hWnd )

	If s == PageLength

      if ::lEof
         Return nil
      EndIf

      If Select( ::WorkArea ) == 0
         Return nil
      EndIf
      _RecNo := ( ::WorkArea )->( RecNo() )

      ( ::WorkArea )->( DbGoTo( ::aRecMap[ 1 ] ) )
      ( ::WorkArea )->( DbSkip() )
      ::scrollUpdate()
      ::Update()
      ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )

      ListView_SetCursel ( ::hWnd, Len( ::aRecMap ) )

	Else

      ListView_SetCursel ( ::hWnd, s+1 )
      ::FastUpdate( 1 )

	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD SetValue( Value, mp ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _BrowseRecMap , NewPos := 50, _DeltaScroll := { Nil , Nil , Nil , Nil } , m
// Local cMacroVar

	If Value <= 0
      Return nil
	EndIf

   If _OOHG_ThisEventType == 'BROWSE_ONCHANGE'
      If ::hWnd == _OOHG_ThisControl:hWnd
         MsgOOHGError ("BROWSE: Value property can't be changed inside ONCHANGE event. Program Terminated" )
		EndIf
	EndIf

   If Select( ::WorkArea ) == 0
      Return nil
	EndIf

   If Value > ( ::WorkArea )->( RecCount() )
      ::nValue := 0
      ListViewReset ( ::hWnd )
      ::BrowseOnChange()
      Return nil
	EndIf

	If valtype ( mp ) == 'U'
      m := int ( ListViewGetCountPerPage ( ::hWnd ) / 2 )
	else
		m := mp
	endif

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )
   _BrowseRecMap := ::aRecMap

   _RecNo := ( ::WorkArea )->( RecNo() )

   ( ::WorkArea )->( DbGoTo( Value ) )

   If ( ::WorkArea )->( Eof() )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )
      Return nil
	EndIf

// Sin usar DBFILTER()
   ( ::WorkArea )->( DBSkip() )
   ( ::WorkArea )->( DBSkip( -1 ) )
   IF ( ::WorkArea )->( RecNo() ) != Value
      ( ::WorkArea )->( DbGoTo( _RecNo ) )
      Return nil
   ENDIF
/*
// Usando DBFILTER()
   cMacroVar := ( ::WorkArea )->( dbfilter() )
   If ! Empty( cMacroVar )
      If ! ( ::WorkArea )->( &cMacroVar )
         ( ::WorkArea )->( DbGoTo( _RecNo ) )
         Return nil
		EndIf
	EndIf
*/

   if pcount() < 2
      ::scrollUpdate()
   EndIf
   ( ::WorkArea )->( DbSkip( -m + 1 ) )

   ::nValue := Value
   ( ::WorkArea )->( ::Update() )
   ( ::WorkArea )->( DbGoTo( _RecNo ) )

   ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
   ListView_SetCursel ( ::hWnd, ascan ( ::aRecMap, Value ) )

   _OOHG_ThisEventType := 'BROWSE_ONCHANGE'
   ::BrowseOnChange()
   _OOHG_ThisEventType := ''

Return nil

*-----------------------------------------------------------------------------*
METHOD Delete() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _BrowseRecMap , Value , _Alias , _RecNo , _BrowseArea

   If LISTVIEW_GETFIRSTITEM ( ::hWnd ) == 0
		Return Nil
	EndIf

   _BrowseRecMap := ::aRecMap

   Value := _BrowseRecMap [ LISTVIEW_GETFIRSTITEM ( ::hWnd ) ]

	If Value == 0
		Return Nil
	EndIf

	_Alias := Alias()
   _BrowseArea := ::WorkArea
   If Select( ::WorkArea ) == 0
		Return Nil
	EndIf
	Select &_BrowseArea
	_RecNo := RecNo()

	Go Value

   If ::Lock
		If Rlock()
			Delete
			Skip
			if eof()
				Go Bottom
			EndIf

         If Set ( _SET_DELETED )
            ::SetValue( RecNo() , LISTVIEW_GETFIRSTITEM ( ::hWnd ) )
			EndIf

		Else

			MsgStop('Record is being editied by another user. Retry later','Delete Record')

		EndIf

	Else

		Delete
		Skip
		if eof()
			Go Bottom
		EndIf
      If Set ( _SET_DELETED )
         ::SetValue( RecNo() , LISTVIEW_GETFIRSTITEM ( ::hWnd ) )
		EndIf

	EndIf

	Go _RecNo
	if Select( _Alias ) != 0
		Select &_Alias
	Else
		Select 0
	Endif

Return Nil

*-----------------------------------------------------------------------------*
METHOD EditItem( append ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local g,a,l,actpos:={0,0,0,0},GRow,GCol,GWidth,Col,IRow, item
Local Title , aLabels , aInitValues := {} , aFormats := {} , aResults , z , tvar , BackRec , aStru , y , svar , q , BackArea , BrowseArea , TmpNames := {} , NewRec := 0 , MixedFields := .f.

   If LISTVIEW_GETFIRSTITEM ( ::hWnd ) == 0
      If Valtype (append) == 'L'
         If ! append
				Return Nil
			EndIf
		EndIf
	EndIf

   If ::InPlace
      ::InPlaceEdit( append )
		Return Nil
	EndIf

   _OOHG_ActiveFormBak := _OOHG_ActiveForm

   a := ::aHeaders

   item := ::Value

	l := Len(a)

   g := ::Item( Item )

   IRow := ListViewGetItemRow( ::hWnd, LISTVIEW_GETFIRSTITEM( ::hWnd ) )

   GetWindowRect( ::hWnd, actpos )

	GRow 	:= actpos [2]
	GCol 	:= actpos [1]
	GWidth 	:= actpos [3] - actpos [1]

	Col := GCol + ( ( GWidth - 310 ) / 2 )

   If Valtype (append) == 'L'
      If append
         Title := _OOHG_BRWLangButton[1]
		Else
         Title := _OOHG_BRWLangButton[2]
		EndIf
	ELse
      Title := _OOHG_BRWLangButton[2]
	EndIf

   aLabels  := ::aHeaders

	BackArea := Alias()

   BrowseArea := ::WorkArea
	Select &BrowseArea

   BackRec := ( ::WorkArea )->( RecNo() )

   If Valtype (append) == 'L'
      If append
         ( ::WorkArea )->( DbGoTo( 0 ) )
		Else
         ( ::WorkArea )->( DbGoTo( item ) )
		EndIf
   Else
      ( ::WorkArea )->( DbGoTo( item ) )
	EndIf

   For z := 1 To Len ( ::aFields )

      tvar := ( ::WorkArea )->( &( ::aFields[ z ] ) )

      if valtype( tvar ) == 'C'

         Aadd ( aInitValues , Alltrim(tvar) )

		Else

         Aadd ( aInitValues , tvar )

		EndIf

	Next z

   For z := 1 To Len ( ::aFields )

      tvar := Upper ( ::aFields [z] )

		q := at ( '>' , tvar )

		if q == 0

		        Select &BrowseArea
			aStru := DbStruct ()

			aAdd ( TmpNames , 'MemVar' + BrowseArea + tvar )

		Else

			svar := Left ( tvar , q-2 )
		        Select &svar
			aStru := DbStruct()

			tvar := Right ( tvar , Len (tvar) - q )

			aAdd ( TmpNames , 'MemVar' + svar + tvar )

			If Upper(svar) != Upper(BrowseArea)
				MixedFields := .t.
			EndIf

		EndIf

      If Valtype (append) == 'L'
         If append
            If MixedFields
               MsgOOHGError(_OOHG_BRWLangError[8],_OOHG_BRWLangError[3])
				EndIf
			EndIf
		EndIf

		For y := 1 To Len (aStru)

			If Upper (aStru [y] [1]) == tvar

				If aStru [y] [2] == 'N' .And. aStru [y] [4] == 0
					Aadd ( aFormats , Replicate('9', aStru [y] [3] ) )
				ElseIf aStru [y] [2] == 'N' .And. aStru [y] [4] > 0
					Aadd ( aFormats , Replicate('9', (aStru [y] [3] - aStru [y] [4] - 1) ) +'.'+Replicate('9', aStru [y] [4]) )
				ElseIf aStru [y] [2] == 'C'
					Aadd ( aFormats , aStru [y] [3] )
				ElseIf aStru [y] [2] == 'D'
					Aadd ( aFormats , Nil )
				ElseIf aStru [y] [2] == 'L'
					Aadd ( aFormats , Nil )
				EndIf
			EndIf

		Next y
											// Browse+
	Next z

	Select &BrowseArea

   If ::lock == .t.

		If Rlock() == .F.
         MsgExclamation(_OOHG_BRWLangError[9],_OOHG_BRWLangError[10])
			Go BackRec
			If Select (BackArea) != 0
				Select &BackArea
			Else
				Select 0
			EndIf
         _OOHG_ActiveForm := _OOHG_ActiveFormBak
         ::SetFocus()
			Return Nil
		EndIf

	EndIf

   aResults := _EditRecord( Title , aLabels , aInitValues , aFormats , GRow , Col , ::Valid , TmpNames , ::ValidMessages , ::ReadOnly , actpos [4] - actpos [2] )
	tvar := aResults [1]
	If ValType ( tvar ) != 'U'

      If Valtype (append) == 'L'
         If append
            ( ::WorkArea )->( DBAppend() )
            NewRec := ( ::WorkArea )->( RecNo() )
			EndIf
		EndIf

		For z := 1 To Len ( aResults )

         tvar := ::aFields [z]

         If ValType (::ReadOnly) == 'U'

				Replace &tvar With aResults [z]

			Else

            If ::ReadOnly [z] == .F.

					Replace &tvar With aResults [z]

				EndIf

			EndIf

		Next z

      ::Refresh()

	EndIf

   If ::lock
      ( ::WorkArea )->( DbUnlock() )
	EndIf

   ( ::WorkArea )->( DbGoTo( BackRec ) )

	If Select (BackArea) != 0
		Select &BackArea
	Else
		Select 0
	EndIf

   _OOHG_ActiveForm := _OOHG_ActiveFormBak

   ::SetFocus()

   If Valtype (append) == 'L'
      If append
			If NewRec != 0
            ::Value := NewRec
			EndIf
		EndIf
	EndIf

Return Nil

*-----------------------------------------------------------------------------*
Function _EditRecord( Title , aLabels , aValues , aFormats , row , col , aValid , TmpNames , aValidMessages , aReadOnly , h , aWhen )
*-----------------------------------------------------------------------------*
Local i , l , ControlRow , e := 0 ,LN , CN , th, oWnd, oControl, aControls

	l := Len ( aLabels )

	Private aResult [l]

   aControls := ARRAY( l )

	For i := 1 to l

		if ValType ( aValues[i] ) == 'C'

			if ValType ( aFormats[i] ) == 'N'

				If aFormats[i] > 32
					e++
				Endif

			EndIf

		EndIf

		if ValType ( aValues[i] ) == 'M'
			e++
		EndIf

	Next i

	th := (l*30) + (e*60) + 30

	IF TH < H
		TH := H + 1
	ENDIF

   DEFINE WINDOW _EditRecord;
		AT row,col ;
		WIDTH 310 ;
		HEIGHT h - 19 + GetTitleHeight() ;
		TITLE Title ;
		MODAL NOSIZE

      ON KEY ALT+O ACTION _EditRecordOk( aValid , TmpNames , aValidMessages )
      ON KEY ALT+C ACTION _EditRecordCancel()

		DEFINE SPLITBOX

         DEFINE WINDOW _Split_1 OBJ oWnd;
				WIDTH 310 ;
				HEIGHT H - 90 ;
				VIRTUAL HEIGHT TH ;
				SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK FOCUSED

            ON KEY ALT+O ACTION _EditRecordOk( aValid , TmpNames , aValidMessages )
            ON KEY ALT+C ACTION _EditRecordCancel()

				ControlRow :=  10

				For i := 1 to l

					LN := 'Label_' + Alltrim(Str(i))
					CN := 'Control_' + Alltrim(Str(i))

					@ ControlRow , 10 LABEL &LN OF _Split_1 VALUE aLabels [i] WIDTH 90

					do case
					case ValType ( aValues [i] ) == 'L'

						@ ControlRow , 120 CHECKBOX &CN OF _Split_1 CAPTION '' VALUE aValues[i]
						ControlRow := ControlRow + 30

					case ValType ( aValues [i] ) == 'D'

						@ ControlRow , 120 DATEPICKER &CN  OF _Split_1 VALUE aValues[i] WIDTH 140
						ControlRow := ControlRow + 30

					case ValType ( aValues [i] ) == 'N'

						If ValType ( aFormats [i] ) == 'A'
							@ ControlRow , 120 COMBOBOX &CN  OF _Split_1 ITEMS aFormats[i] VALUE aValues[i] WIDTH 140  FONT 'Arial' SIZE 10
							ControlRow := ControlRow + 30

						ElseIf  ValType ( aFormats [i] ) == 'C'

							If AT ( '.' , aFormats [i] ) > 0
								@ ControlRow , 120 TEXTBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10 NUMERIC INPUTMASK aFormats [i]
							Else
								@ ControlRow , 120 TEXTBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10 MAXLENGTH Len(aFormats [i]) NUMERIC
							EndIf

							ControlRow := ControlRow + 30
						Endif

					case ValType ( aValues [i] ) == 'C'

						If ValType ( aFormats [i] ) == 'N'
							If  aFormats [i] <= 32
								@ ControlRow , 120 TEXTBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10 MAXLENGTH aFormats [i]
								ControlRow := ControlRow + 30
							Else
								@ ControlRow , 120 EDITBOX &CN  OF _Split_1 WIDTH 140 HEIGHT 90 VALUE aValues[i] FONT 'Arial' SIZE 10 MAXLENGTH aFormats[i]
								ControlRow := ControlRow + 94
							EndIf
						EndIf

					case ValType ( aValues [i] ) == 'M'

						@ ControlRow , 120 EDITBOX &CN  OF _Split_1 WIDTH 140 HEIGHT 90 VALUE aValues[i] FONT 'Arial' SIZE 10
						ControlRow := ControlRow + 94

					endcase

               oControl := oWnd:Control( CN )
               oControl:OnLostFocus := { || _WHENEVAL( aControls ) }
               oControl:Block := &( "{ |x| IF( PCOUNT() == 1, " + TmpNames[ i ] + " :=  x, " + TmpNames[ i ] + " ) }" )
               IF ValType( aWhen ) == "A" .AND. Len( aWhen ) >= i
                  oControl:Cargo := aWhen[ i ]
               ENDIF
               aControls[ i ] := oControl

               If ValType ( aReadOnly ) == 'A'

                  If aReadOnly[ i ]

                       oWnd:Control( CN ):Disabled()

						EndIf

					EndIf

				Next i

			END WINDOW

			DEFINE WINDOW _Split_2 ;
				WIDTH 300 ;
				HEIGHT 50 ;
				SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK

				@ 10 , 40 BUTTON BUTTON_1 ;
				OF _Split_2 ;
            CAPTION _OOHG_BRWLangButton[4] ;
            ACTION _EditRecordOk( aValid , TmpNames , aValidMessages )

				@ 10 , 150 BUTTON BUTTON_2 ;
				OF _Split_2 ;
            CAPTION _OOHG_BRWLangButton[3] ;
				ACTION _EditRecordCancel()

			END WINDOW

		END SPLITBOX

	END WINDOW

   oWnd:Control_1:SetFocus()

	ACTIVATE WINDOW _EditRecord

Return ( aResult )

*-----------------------------------------------------------------------------*
PROCEDURE _WHENEVAL( aControls )
*-----------------------------------------------------------------------------*

   AEVAL( aControls, { |o| o:SaveData() } )

   AEVAL( aControls, { |o| IF( VALTYPE( o:Cargo ) == "B", o:Enabled := EVAL( o:Cargo ),  ) } )

RETURN

*-----------------------------------------------------------------------------*
Function _EditRecordOk( aValid , TmpNames , aValidMessages )
*-----------------------------------------------------------------------------*
Local i , ControlName , l , b , mVar

	l := len (aResult)

	For i := 1 to l

		ControlName := 'Control_' + Alltrim ( Str ( i ) )
		aResult [i] := _GetValue ( ControlName , '_Split_1' )

		If ValType (aValid) != 'U'

			mVar := TmpNames [i]
			&mVar := aResult [i]

		EndIf

	Next i

	If ValType (aValid) != 'U'

		For i := 1 to l

			If ValType ( aValid [i] ) == 'B'

				b := Eval ( aValid [i] )

				If b == .f.

				        If ValType ( aValidMessages ) != 'U'

						If ValType ( aValidMessages [i] ) != 'U'

							MsgExclamation ( aValidMessages[i] )

						Else

                     MsgExclamation (_OOHG_BRWLangError[11])

						EndIf

					Else

                  MsgExclamation (_OOHG_BRWLangError[11])

					EndIf


               GetControlObject( 'Control_' + Alltrim(Str(i)) , '_Split_1' ):SetFocus()

					Return Nil

				EndIf

			EndIf

		Next i

	EndIf

	RELEASE WINDOW _EditRecord

Return Nil

*-----------------------------------------------------------------------------*
Function _EditRecordCancel
*-----------------------------------------------------------------------------*
Local i , l

	l := len (aResult)

	For i := 1 to l

		aResult [i] := Nil

	Next i

	RELEASE WINDOW _EditRecord

Return Nil

*------------------------------------------------------------------------------*
METHOD InPlaceEdit( append ) CLASS TBrowse
*------------------------------------------------------------------------------*
Local GridCol , GridRow , i , nrec , BackArea , BackRec , _GridFields , FieldName , CellData  := '' , CellColIndex , x
Local aFieldNames
Local aTypes
Local aWidths
Local aDecimals
Local Type
Local Width
Local Decimals
Local sFieldname
Local r
Local ControlType
Local Ldelta := 0

	If append

      ::InPlaceAppend()

		Return Nil

	EndIf

   If This.CellRowIndex != LISTVIEW_GETFIRSTITEM( ::hWnd )
		Return Nil
	EndIf

   _GridFields := ::aFields

	CellColIndex := This.CellColIndex

	If CellColIndex < 1 .or. CellColIndex > Len (_GridFields)
		Return Nil
	EndIf

   if Len ( ::aImages ) > 0 .And. CellColIndex == 1
		PlayHand()
		Return Nil
	EndIf

   If ValType ( ::ReadOnly ) == 'A'
      If Len ( ::ReadOnly ) >= CellColIndex
         If ::ReadOnly [ CellColIndex ] != Nil
            If ::ReadOnly [ CellColIndex ] == .T.
*					PlayHand()
               _OOHG_IPE_CANCELLED := .F.
*
					Return Nil
				EndIf
			EndIf
		EndIf
	EndIf

	FieldName := _GridFields [  CellColIndex ]

	// It the specified area does not exists, set recorcount to 0 and
	// return

   If Select( ::WorkArea ) == 0
		Return Nil
	EndIf

	// Save Original WorkArea
	BackArea := Alias()

	// Save Original Record Pointer
	BackRec := RecNo()

	// Selects Grid's WorkArea

   Select &( ::WorkArea )

	nRec := _GetValue ( '','',i )
	Go nRec

	// If LOCK clause is present, try to lock.

   If ::lock == .T.
		If Rlock() == .F.
         MsgExclamation(_OOHG_BRWLangError[9],_OOHG_BRWLangError[10])
			// Restore Original Record Pointer
			Go BackRec
			// Restore Original WorkArea
			If Select (BackArea) != 0
				Select &BackArea
			Else
				Select 0
			EndIf
			Return Nil
		EndIf
	EndIf

	CellData := &FieldName

        aFieldNames	:= ARRAY(FCOUNT())
        aTypes		:= ARRAY(FCOUNT())
        aWidths		:= ARRAY(FCOUNT())
        aDecimals	:= ARRAY(FCOUNT())

        AFIELDS(aFieldNames, aTypes, aWidths, aDecimals)

	r := at ('>',FieldName)

	if r != 0
		sFieldName := Right ( FieldName, Len(Fieldname) - r )
	Else
		sFieldName := FieldName
	EndIf

	x := FieldPos ( sFieldName )

	If x > 0
        	Type		:= aTypes [x]
	        Width		:= aWidths [x]
        	Decimals	:= aDecimals [x]
	EndIf

   GridRow := GetWindowRow( ::hWnd )
   GridCol := GetWindowCol( ::hWnd )

	If Type (FieldName) == 'C'
		ControlType := 'C'
	ElseIf Type (FieldName) == 'D'
		ControlType := 'D'
	ElseIf Type (FieldName) == 'L'
		ControlType := 'L'
		Ldelta := 1
	ElseIf Type (FieldName) == 'M'
		ControlType := 'M'
	ElseIf Type (FieldName) == 'N'
		If Decimals == 0
			ControlType := 'I'
		Else
			ControlType := 'F'
		EndIf
	EndIf

	If ControlType == 'M'

// JK
		r := InputBox ( '' , 'Edit Memo' , STRTRAN(CellData,chr(141),' ') , , , .T. )

      If _OOHG_DialogCancelled == .F.
			Replace &FieldName With r
         _OOHG_IPE_CANCELLED := .F.
		Else
         _OOHG_IPE_CANCELLED := .T.
		EndIf

	Else

		DEFINE WINDOW _InPlaceEdit ;
         AT This.CellRow + GridRow - ::ContainerRow - 1 , This.CellCol + GridCol - ::ContainerCol + 2 ;
			WIDTH This.CellWidth ;
			HEIGHT This.CellHeight + 6 + Ldelta ;
			MODAL ;
			NOCAPTION ;
			NOSIZE

         ON KEY RETURN ACTION ::InPlaceEditOk( i , Fieldname , _InPlaceEdit.Control_1.Value , ControlType , CellColIndex , sFieldName )
         ON KEY ESCAPE ACTION ( _OOHG_IPE_CANCELLED := .T. , dbrunlock() , _InPlaceEdit.Release , ::setfocus() )

			If ControlType == 'C'
				CellData := rtrim ( CellData )

				DEFINE TEXTBOX Control_1
					ROW 0
					COL 0
					WIDTH This.CellWidth
					HEIGHT This.CellHeight + 6
					VALUE CellData
					MAXLENGTH Width
				END TEXTBOX

			ElseIf ControlType == 'D'

				DEFINE DATEPICKER Control_1
					ROW 0
					COL 0
					HEIGHT This.CellHeight + 6
					WIDTH This.CellWidth
					VALUE CellData
					UPDOWN .T.
				END DATEPICKER

			ElseIf ControlType == 'L'

				DEFINE COMBOBOX Control_1
					ROW 0
					COL 0
					ITEMS { '.T.','.F.' }
					WIDTH This.CellWidth
					VALUE If ( CellData , 1 , 2 )
				END COMBOBOX

			ElseIf ControlType == 'I'

				DEFINE TEXTBOX Control_1
					ROW 0
					COL 0
					NUMERIC	.T.
					WIDTH This.CellWidth
					HEIGHT This.CellHeight + 6
					VALUE CellData
					MAXLENGTH Width
				END TEXTBOX

			ElseIf ControlType == 'F'

				DEFINE TEXTBOX Control_1
					ROW 0
					COL 0
					NUMERIC	.T.
					INPUTMASK Replicate ( '9', Width - Decimals - 1 ) + '.' + Replicate ( '9', Decimals )
					WIDTH This.CellWidth
					HEIGHT This.CellHeight + 6
					VALUE CellData
				END TEXTBOX

			EndIf

		END WINDOW

		ACTIVATE WINDOW _InPlaceEdit

	EndIf

	// Restore Original Record Pointer
	Go BackRec

	// Restore Original WorkArea
	If Select (BackArea) != 0
		Select &BackArea
	Else
		Select 0
	EndIf

Return Nil

*------------------------------------------------------------------------------*
METHOD InPlaceEditOk( i , Fieldname , r , ControlType , CellColIndex , sFieldName ) CLASS TBrowse
*------------------------------------------------------------------------------*
Local b , Result , mVar , TmpName

I++
   If ValType ( ::Valid ) == 'A'
      If Len ( ::Valid ) >= CellColIndex
         If ::Valid [ CellColIndex ] != Nil

				Result := _GetValue ( 'Control_1' , '_InPlaceEdit' )

				If ControlType == 'L'
					Result := if ( Result == 0 .or. Result == 2 , .F. , .T. )
				EndIf

            TmpName := 'MemVar' + ::WorkArea + sFieldname

				mVar := TmpName
				&mVar := Result

            b := Eval ( ::Valid [ CellColIndex ] )
				If b == .f.

               If ValType ( ::ValidMessages ) == 'A'

                  If Len ( ::ValidMessages ) >= CellColIndex

                     If ::ValidMessages [CellColIndex] != Nil

                        MsgExclamation ( ::ValidMessages [CellColIndex] )

							Else

                        MsgExclamation (_OOHG_BRWLangError[11])

							EndIf

						Else

                     MsgExclamation (_OOHG_BRWLangError[11])

						EndIf

					Else

                  MsgExclamation (_OOHG_BRWLangError[11])

					EndIf

				Else

					If ControlType == 'L'
						r := if ( r == 0 .or. r == 2 , .F. , .T. )
					EndIf

               If ::lock == .t.
						Replace &FieldName With r
						Unlock

                  ::Refresh()

						_InPlaceEdit.Release
					Else
						Replace &FieldName With r

                  ::Refresh()

						_InPlaceEdit.Release
					EndIf

				EndIf

			Else

				If ControlType == 'L'
					r := if ( r == 0 .or. r == 2 , .F. , .T. )
				EndIf

            If ::lock == .t.

					Replace &FieldName With r
					Unlock

               ::Refresh()

					_InPlaceEdit.Release

				Else

					Replace &FieldName With r

               ::Refresh()

					_InPlaceEdit.Release

				EndIf

			EndIf

		EndIf

	Else

		If ControlType == 'L'
			r := if ( r == 0 .or. r == 2 , .F. , .T. )
		EndIf

      If ::lock == .t.

			Replace &FieldName With r
			Unlock

         ::Refresh()

			_InPlaceEdit.Release

		Else

			Replace &FieldName With r

         ::Refresh()

			_InPlaceEdit.Release

		EndIf

	EndIf

   _OOHG_IPE_CANCELLED := .F.

   ::SetFocus()

Return NIL

*-----------------------------------------------------------------------------*
METHOD AdjustRightScroll() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local hws, x, lRet, nButton
   lRet := .F.
   hws := 0
   For x := 1 To Len ( ::aWidths )
      hws := hws + ListView_GetColumnWidth ( ::hWnd , x - 1 )
      If ::aWidths [x] != ListView_GetColumnWidth ( ::hWnd, x - 1 )
         ::aWidths [x] := ListView_GetColumnWidth ( ::hWnd, x - 1 )
      EndIf
   Next x
   If ::VScroll != nil
      nButton := IF( ( hws > ::Width - GETVSCROLLBARWIDTH() - 4 ), 1, 0 )
      IF ::nButtonActive != nButton
         ::nButtonActive := nButton
*         ::Refresh()
         if nButton == 1
            ::VScroll:SizePos( 0, ::Width - GETVSCROLLBARWIDTH() , GETVSCROLLBARWIDTH() , ::Height - GETHSCROLLBARHEIGHT() )
            MoveWindow( ::ScrollBarButtonHandle, ::ContainerCol + ::Width - GETVSCROLLBARWIDTH() , ::ContainerRow + ::Height - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() , .t. )
         Else
            ::VScroll:SizePos( 0, ::Width - GETVSCROLLBARWIDTH() , GETVSCROLLBARWIDTH() , ::Height )
            MoveWindow( ::ScrollBarButtonHandle, ::ContainerCol + ::Width - GETVSCROLLBARWIDTH() , ::ContainerRow + ::Height - GETHSCROLLBARHEIGHT() , 0 , 0 , .t. )
         EndIf
*         ReDrawWindow( ::VScroll:hWnd )
*         ReDrawWindow( ::ScrollBarButtonHandle )
         lRet := .T.
      ENDIF
   EndIf
Return lRet

*-----------------------------------------------------------------------------*
METHOD ProcessInPlaceKbdEdit() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local r
Local IPE_MAXCOL
Local TmpRow
Local xs,xd

   If ! ::InPlace
      Return nil
	EndIf

   if LISTVIEW_GETFIRSTITEM ( ::hWnd ) == 0
      Return nil
	EndIf

   IPE_MAXCOL := Len ( ::aFields )

	Do While .T.

      TmpRow := LISTVIEW_GETFIRSTITEM ( ::hWnd )

      If TmpRow != _OOHG_IPE_ROW

         _OOHG_IPE_ROW := TmpRow

         if Len ( ::aImages ) > 0
            _OOHG_IPE_COL := 2
			Else
            _OOHG_IPE_COL := 1
			EndIf

		EndIf

      _OOHG_ThisItemRowIndex := _OOHG_IPE_ROW
      _OOHG_ThisItemColIndex := _OOHG_IPE_COL

      If _OOHG_IPE_COL == 1
         r := LISTVIEW_GETITEMRECT ( ::hWnd, _OOHG_IPE_ROW - 1 )
		Else
         r := LISTVIEW_GETSUBITEMRECT ( ::hWnd, _OOHG_IPE_ROW - 1 , _OOHG_IPE_COL - 1 )
		EndIf

      xs := ( ( ::ContainerCol + r [2] ) +( r[3] ))  -  ( ::ContainerCol + ::Width )

		xd := 20

		If xs > -xd
         ListView_Scroll( ::hWnd,  xs + xd , 0 )
		Else

         If r [2] < 0
            ListView_Scroll( ::hWnd, r[2] , 0 )
         EndIf

		endIf

      If _OOHG_IPE_COL == 1
         r := LISTVIEW_GETITEMRECT ( ::hWnd, _OOHG_IPE_ROW - 1 )
		Else
         r := LISTVIEW_GETSUBITEMRECT ( ::hWnd, _OOHG_IPE_ROW - 1 , _OOHG_IPE_COL - 1 )
		EndIf

      _OOHG_ThisItemCellRow := ::ContainerRow + r [1]
      _OOHG_ThisItemCellCol := ::ContainerCol + r [2]
      _OOHG_ThisItemCellWidth := r[3]
      _OOHG_ThisItemCellHeight := r[4]
      ::EditItem( .f. )
      _OOHG_ThisType := ''

      _OOHG_ThisItemRowIndex := 0
      _OOHG_ThisItemColIndex := 0
      _OOHG_ThisItemCellRow := 0
      _OOHG_ThisItemCellCol := 0
      _OOHG_ThisItemCellWidth := 0
      _OOHG_ThisItemCellHeight := 0

      If _OOHG_IPE_CANCELLED == .T.

         If _OOHG_IPE_COL == IPE_MAXCOL

            if Len ( ::aImages ) > 0
               _OOHG_IPE_COL := 2
				Else
               _OOHG_IPE_COL := 1
				EndIf

            ListView_Scroll( ::hWnd,  -10000  , 0 )
			EndIf

			Exit

		Else

         _OOHG_IPE_COL++

         If _OOHG_IPE_COL > IPE_MAXCOL

            if Len ( ::aImages ) > 0
               _OOHG_IPE_COL := 2
				Else
               _OOHG_IPE_COL := 1
				EndIf

            ListView_Scroll( ::hWnd,  -10000  , 0 )
				Exit
			EndIf

		EndIf

	EndDo

Return nil

*-----------------------------------------------------------------------------*
METHOD Sync() CLASS TBrowse
*-----------------------------------------------------------------------------*

   If _OOHG_BrowseSyncStatus

      If ( ::WorkArea )->( RecNo() ) != ::Value

         ( ::WorkArea )->( DbGoTo( ::Value ) )

		EndIf

	EndIf

Return nil

*-----------------------------------------------------------------------------*
METHOD BrowseOnChange() CLASS TBrowse
*-----------------------------------------------------------------------------*

   ::Sync()

   ::DoEvent( ::OnChange )

Return nil

*-----------------------------------------------------------------------------*
METHOD FastUpdate( d ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local ActualRecord , RecordCount

	// If vertical scrollbar is used it must be updated
   If ::VScroll != nil

      RecordCount := ::RecCount

		If RecordCount == 0
         Return nil
		EndIf

		If RecordCount < 100
         ActualRecord := ::VScroll:Value + d
         ::VScroll:RangeMax := RecordCount
         ::VScroll:Value := ActualRecord
		EndIf

	EndIf

Return nil

*-----------------------------------------------------------------------------*
METHOD InPlaceAppend() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _Alias , _RecNo , _BrowseArea , _BrowseRecMap   , _DeltaScroll := { Nil , Nil , Nil , Nil } , _NewRec , aTemp

   _BrowseRecMap := ::aRecMap

	_Alias := Alias()
   _BrowseArea := ::WorkArea
	If Select (_BrowseArea) == 0
      Return nil
	EndIf
	Select &_BrowseArea
	_RecNo := RecNo()
	Go Bottom

	_NewRec := RecCount() + 1

   if LISTVIEWGETITEMCOUNT( ::hWnd ) != 0
      ::scrollUpdate()
      Skip - LISTVIEWGETCOUNTPERPAGE ( ::hWnd ) + 2
      ::Update()
	endif

	append blank

	Go _RecNo
	if Select( _Alias ) != 0
		Select &_Alias
	Else
		Select 0
	Endif

   aTemp := array ( Len ( ::aFields ) )
	afill ( aTemp , '' )
   aadd ( ::aRecMap, _NewRec )

   AddListViewItems ( ::hWnd, aTemp , 0 )

   ListView_SetCursel ( ::hWnd, Len ( ::aRecMap ) )

   ::BrowseOnChange()

   _OOHG_IPE_ROW := 1
   _OOHG_IPE_COL := 1

Return nil

*-----------------------------------------------------------------------------*
METHOD ScrollUpdate() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local ActualRecord , RecordCount , KeyCount

	// If vertical scrollbar is used it must be updated
   If ::VScroll != nil

      KeyCount := ( ::WorkArea )->( OrdKeyCount() )
		If KeyCount > 0
         ActualRecord := ( ::WorkArea )->( OrdKeyNo() )
			RecordCount := KeyCount
		Else
         ActualRecord := ( ::WorkArea )->( RecNo() )
         RecordCount := ( ::WorkArea )->( RecCount() )
		EndIf

      ::RecCount := RecordCount

		If RecordCount < 100
         ::VScroll:RangeMax := RecordCount
         ::VScroll:Value := ActualRecord
		Else
         ::VScroll:RangeMax := 100
         ::VScroll:Value := Int ( ActualRecord * 100 / RecordCount )
		EndIf

	EndIf

Return NIL





*-----------------------------------------------------------------------------*
METHOD Refresh() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local s , _RecNo , _DeltaScroll
Local v

   If Select( ::WorkArea ) == 0
      ListViewReset( ::hWnd )
      Return nil
	EndIf

   v := ::Value

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   s := LISTVIEW_GETFIRSTITEM ( ::hWnd )

   _RecNo := ( ::WorkArea )->( RecNo() )

   if v <= 0
		v := _RecNo
	EndIf

   ( ::WorkArea )->( DbGoTo( v ) )

***************************

	if s == 1 .or. s == 0
// Sin usar DBFILTER()
      ( ::WorkArea )->( DBSkip() )
      ( ::WorkArea )->( DBSkip( -1 ) )
      IF ( ::WorkArea )->( RecNo() ) != v
         ( ::WorkArea )->( DbSkip() )
      ENDIF
/*
// Usando DBFILTER()
      cMacroVar := ( ::WorkArea )->( dbfilter() )
      If ! Empty( cMacroVar )
         If ! ( ::WorkArea )->( &cMacroVar )
            ( ::WorkArea )->( DbSkip() )
         EndIf
      EndIf
*/
	EndIf

***************************

	if s == 0
      if ( ::WorkArea )->( INDEXORD() ) != 0
         if ( ::WorkArea )->( ORDKEYVAL() ) == Nil
            ( ::WorkArea )->( DbGoTop() )
			endif
		EndIf
	endif

	if s == 0
      if Set( _SET_DELETED )
         if ( ::WorkArea )->( Deleted() )
            ( ::WorkArea )->( DbGoTop() )
			endif
		EndIf
	endif

   If ( ::WorkArea )->( Eof() )

      ListViewReset ( ::hWnd )

      ( ::WorkArea )->( DbGoTo( _RecNo ) )

      Return nil

	EndIf

   ::scrollUpdate()

	if s != 0
      ( ::WorkArea )->( DbSkip( -s+1 ) )
	EndIf

   ::Update()

   ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
   ListView_SetCursel ( ::hWnd, ascan ( ::aRecMap, v ) )

   ( ::WorkArea )->( DbGoTo( _RecNo ) )

Return nil

*-----------------------------------------------------------------------------*
METHOD Release() CLASS TBrowse
*-----------------------------------------------------------------------------*
   if ::VScroll != nil
      ::VScroll:Release()
   endif
   if ::ScrollBarButtonHandle != 0
      ReleaseControl( ::ScrollBarButtonHandle )
   endif
Return ::Super:Release()

*-----------------------------------------------------------------------------*
METHOD SizePos( Row, Col, Width, Height ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local uRet

   IF VALTYPE( Row ) == "N"
      ::nRow := Row
   ENDIF
   IF VALTYPE( Col ) == "N"
      ::nCol := Col
   ENDIF
   IF VALTYPE( Width ) == "N"
      ::nWidth := Width
   ENDIF
   IF VALTYPE( Height ) == "N"
      ::nHeight := Height
   ENDIF

   If ::VScroll != nil
      uRet := MoveWindow( ::hWnd, ::ContainerCol, ::ContainerRow, ::Width - GETVSCROLLBARWIDTH(), ::Height , .t. )

      // Force button move/resize and browse refresh
      ::nButtonActive := 2
      ::AdjustRightScroll()

   else

      uRet := MoveWindow( ::hWnd, ::ContainerCol, ::ContainerRow, ::nWidth, ::nHeight , .T. )

   EndIf
*   ReDrawWindow( ::hWnd )
   ::Refresh()
Return uRet

*-----------------------------------------------------------------------------*
METHOD Value( uValue ) CLASS TBrowse
*-----------------------------------------------------------------------------*
   IF VALTYPE( uValue ) == "N"
      ::SetValue( uValue )
   ENDIF
   If SELECT( ::WorkArea ) == 0 .OR. LISTVIEW_GETFIRSTITEM ( ::hWnd ) == 0
      uValue := 0
	Else
      uValue := ::aRecMap[ LISTVIEW_GETFIRSTITEM ( ::hWnd ) ]
	EndIf
RETURN uValue

*------------------------------------------------------------------------------*
METHOD Enabled( lEnabled ) CLASS TBrowse
*------------------------------------------------------------------------------*
   IF VALTYPE( lEnabled ) == "L"
      ::Super:Enabled := lEnabled
      If ::VScroll != nil
         ::VScroll:Enabled := lEnabled
      ENDIF
      If ::ScrollBarButtonHandle != 0
         IF ::Super:Enabled
            EnableWindow( ::ScrollBarButtonHandle )
         ELSE
            DisableWindow( ::ScrollBarButtonHandle )
         EndIf
      ENDIF
   ENDIF
RETURN ::Super:Enabled

*------------------------------------------------------------------------------*
METHOD Visible( lVisible ) CLASS TBrowse
*------------------------------------------------------------------------------*
   IF VALTYPE( lVisible ) == "L"
      ::Super:Visible := lVisible
      If ::VScroll != nil
         ::VScroll:Visible := ::VScroll:Visible
		EndIf
      If ::ScrollBarButtonHandle != 0
         IF ::ContainerVisible
            CShowControl( ::ScrollBarButtonHandle )
         ELSE
            HideWindow( ::ScrollBarButtonHandle )
         ENDIF
		EndIf
      ProcessMessages()
   ENDIF
RETURN ::Super:Visible

*-----------------------------------------------------------------------------*
METHOD RefreshData() CLASS TBrowse
*-----------------------------------------------------------------------------*
   ::Refresh()
   ::Value := ::nValue
RETURN nil

*-----------------------------------------------------------------------------*
METHOD IsHandle( hWnd ) CLASS TBrowse
*-----------------------------------------------------------------------------*
RETURN ( hWnd == ::hWnd ) .OR. ;
       ( ::VScroll != nil .AND. hWnd == ::VScroll:hWnd ) .OR. ;
       ( ::ScrollBarButtonHandle != 0 .AND. hWnd == ::ScrollBarButtonHandle )

*-----------------------------------------------------------------------------*
METHOD Events_Enter() CLASS TBrowse
*-----------------------------------------------------------------------------*

   if ::AllowEdit
      if ::InPlace
         ::ProcessInPlaceKbdEdit()
      Else
         ::EditItem( .f. )
      EndIf
   Else

      ::DoEvent( ::OnDblClick )

   Endif

Return 0

*-----------------------------------------------------------------------------*
METHOD Events_Notify( wParam, lParam ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nNotify := GetNotifyCode( lParam )
Local xs , xd, nvKey
Local r, DeltaSelect

   If nNotify == NM_CLICK  .or. nNotify == LVN_BEGINDRAG

      If LISTVIEW_GETFIRSTITEM ( ::hWnd ) > 0
         DeltaSelect := LISTVIEW_GETFIRSTITEM ( ::hWnd ) - ascan ( ::aRecMap, ::nValue )
         ::nValue := ::aRecMap [ LISTVIEW_GETFIRSTITEM ( ::hWnd ) ]
         ::FastUpdate( DeltaSelect )
         ::BrowseOnChange()
      EndIf

      Return 0

   elseIf nNotify == LVN_KEYDOWN

      nvKey := GetGridvKey( lParam )

      Do Case

      Case nvKey == 65 // A

         if GetAltState() == -127 ;
            .or.;
            GetAltState() == -128   // ALT

            if ::AllowAppend
               ::EditItem( .t. )
            EndIf

         EndIf

      Case nvKey == 46 // DEL

         If ::AllowDelete
            If MsgYesNo( _OOHG_BRWLangMessage [1] , _OOHG_BRWLangMessage [2] )
               ::Delete()
            EndIf
         EndIf

      Case nvKey == 36 // HOME

         ::Home()
         Return 1

      Case nvKey == 35 // END

         ::End()
         Return 1

      Case nvKey == 33 // PGUP

         ::PageUp()
         Return 1

      Case nvKey == 34 // PGDN

         ::PageDown()
         Return 1

      Case nvKey == 38 // UP

         ::Up()
         Return 1

      Case nvKey == 40 // DOWN

         ::Down()
         Return 1

      EndCase

      Return 0

   elseIf nNotify == NM_DBLCLK

      _PushEventInfo()
      _OOHG_ThisForm := ::Parent
      _OOHG_ThisType := 'C'
      _OOHG_ThisControl := Self

      r := ListView_HitTest ( ::hWnd, GetCursorRow() - GetWindowRow ( ::hWnd )  , GetCursorCol() - GetWindowCol ( ::hWnd ) )
      If r [2] == 1
         ListView_Scroll( ::hWnd,  -10000  , 0 )
         r := ListView_HitTest ( ::hWnd, GetCursorRow() - GetWindowRow ( ::hWnd )  , GetCursorCol() - GetWindowCol ( ::hWnd ) )
      Else
         r := LISTVIEW_GETSUBITEMRECT ( ::hWnd, r[1] - 1 , r[2] - 1 )

                                           *  CellCol           CellWidth
         xs := ( ( ::ContainerCol + r [2] ) +( r[3] ))  -  ( ::ContainerCol + ::Width )
         xd := 20
         If xs > -xd
            ListView_Scroll( ::hWnd,  xs + xd , 0 )
         Else
            If r [2] < 0
               ListView_Scroll( ::hWnd, r[2]   , 0 )
            EndIf
         EndIf
         r := ListView_HitTest ( ::hWnd, GetCursorRow() - GetWindowRow ( ::hWnd )  , GetCursorCol() - GetWindowCol ( ::hWnd ) )
      EndIf

      _OOHG_ThisItemRowIndex := r[1]
      _OOHG_ThisItemColIndex := r[2]
      If r [2] == 1
         r := LISTVIEW_GETITEMRECT ( ::hWnd, r[1] - 1 )
      Else
         r := LISTVIEW_GETSUBITEMRECT ( ::hWnd, r[1] - 1 , r[2] - 1 )
      EndIf
      _OOHG_ThisItemCellRow := ::ContainerRow + r [1]
      _OOHG_ThisItemCellCol := ::ContainerCol + r [2]
      _OOHG_ThisItemCellWidth := r[3]
      _OOHG_ThisItemCellHeight := r[4]

      if ::AllowEdit
         ::EditItem( .f. )
      Else
         if valtype( ::OnDblClick )=='B'
            Eval( ::OnDblClick )
         EndIf
      Endif

      _PopEventInfo()
      _OOHG_ThisItemRowIndex := 0
      _OOHG_ThisItemColIndex := 0
      _OOHG_ThisItemCellRow := 0
      _OOHG_ThisItemCellCol := 0
      _OOHG_ThisItemCellWidth := 0
      _OOHG_ThisItemCellHeight := 0

      Return 0

   EndIf

Return ::Super:Events_Notify( wParam, lParam )

*-----------------------------------------------------------------------------*
METHOD SetScrollPos( nPos ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nr , RecordCount , SkipCount , BackRec

   If Select( ::WorkArea ) != 0

      BackRec := ( ::WorkArea )->( RecNo() )

      If ( ::WorkArea )->( OrdKeyCount() ) > 0
         RecordCount := ( ::WorkArea )->( OrdKeyCount() )
      Else
         RecordCount := ( ::WorkArea )->( RecCount() )
      EndIf

      SkipCount := Int ( nPos * RecordCount / ::VScroll:RangeMax )

      If SkipCount > ( RecordCount / 2 )
         ( ::WorkArea )->( DbGoBottom() )
         ( ::WorkArea )->( DbSkip( - ( RecordCount - SkipCount ) ) )
      Else
         ( ::WorkArea )->( DbGoTop() )
         ( ::WorkArea )->( DbSkip( SkipCount ) )
      EndIf

      If ( ::WorkArea )->( Eof() )
         ( ::WorkArea )->( DbSkip( -1 ) )
      EndIf

      nr := ( ::WorkArea )->( RecNo() )

      ::VScroll:Value := nPos

      ( ::WorkArea )->( DbGoTo( BackRec ) )

      ::Value := nr

   EndIf

Return nr

Function SetBrowseSync( lValue )
   IF valtype( lValue ) == "L"
      _OOHG_BrowseSyncStatus := lValue
   ENDIF
Return _OOHG_BrowseSyncStatus












/// TEMP!!! CLASE SCROLLBARBUTTON!!!