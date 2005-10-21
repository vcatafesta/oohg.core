/*
 * $Id: h_browse.prg,v 1.27 2005-10-21 05:18:38 guerra000 Exp $
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

#include "oohg.ch"
#include "hbclass.ch"
#include "i_windefs.ch"

STATIC _OOHG_BrowseSyncStatus := .F.

CLASS TBrowse FROM TGrid
   DATA Type            INIT "BROWSE" READONLY
   DATA Lock            INIT .F.
   DATA WorkArea        INIT ""
   DATA VScroll         INIT nil
   DATA nValue          INIT 0
   DATA aRecMap         INIT {}
   DATA AllowAppend     INIT .F.
   DATA AllowDelete     INIT .F.
   DATA RecCount        INIT 0
   DATA aFields         INIT {}
   DATA lEof            INIT .F.
   DATA nButtonActive   INIT 0
   DATA OnAppend        INIT {}
   DATA aReplaceField   INIT {}

   METHOD Define
   METHOD Refresh
   METHOD SizePos
   METHOD Value               SETGET
   METHOD Enabled             SETGET
   METHOD Visible             SETGET
   METHOD ForceHide
   METHOD RefreshData

   METHOD IsHandle

   METHOD Events_Enter
   METHOD Events_Notify

   METHOD EditCell
   METHOD EditItem
   METHOD GetCellType

   METHOD BrowseOnChange
   METHOD FastUpdate
   METHOD ScrollUpdate
   METHOD SetValue
   METHOD Delete
   METHOD UpDate
   METHOD AdjustRightScroll

   METHOD ColumnWidth
   METHOD ColumnAutoFit
   METHOD ColumnAutoFitH
   METHOD ColumnsAutoFit
   METHOD ColumnsAutoFitH

   METHOD Home
   METHOD End
   METHOD PageUp
   METHOD PageDown
   METHOD Up
   METHOD Down
   METHOD SetScrollPos
ENDCLASS

*-----------------------------------------------------------------------------*
METHOD Define( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, ;
               aFields, value, fontname, fontsize, tooltip, change, ;
               dblclick, aHeadClick, gotfocus, lostfocus, WorkArea, ;
               AllowDelete, nogrid, aImage, aJust, HelpId, bold, italic, ;
               underline, strikeout, break, backcolor, fontcolor, lock, ;
               inplace, novscroll, AllowAppend, readonly, valid, ;
               validmessages, edit, dynamicbackcolor, aWhenFields, ;
               dynamicforecolor, aPicture, lRtl, editcell, editcontrols, ;
               replacefields ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local ScrollBarHandle, hsum, ScrollBarButtonHandle := 0, nWidth2, nCol2

   IF ! ValType( WorkArea ) $ "CM" .OR. Empty( WorkArea )
      WorkArea := ALIAS()
   ENDIF
   if valtype( aFields ) != "A"
      aFields := ( WorkArea )->( DBSTRUCT() )
      AEVAL( aFields, { |x,i| aFields[ i ] := WorkArea + "->" + x[ 1 ] } )
	endif

   if valtype( aHeaders ) != "A"
      aHeaders := Array( len( aFields ) )
	else
      aSize( aHeaders, len( aFields ) )
	endif
   aEval( aHeaders, { |x,i| aHeaders[ i ] := iif( ! ValType( x ) $ "CM", aFields[ i ], x ) } )

	// If splitboxed force no vertical scrollbar

   if valtype(x) != "N" .or. valtype(y) != "N"
		novscroll := .T.
	endif

   IF valtype( w ) != "N"
      w := 240
   ENDIF
   IF novscroll
      nWidth2 := w
   Else
      nWidth2 := w - GETVSCROLLBARWIDTH()
   ENDIF

   ::Super:Define( ControlName, ParentForm, x, y, nWidth2, h, aHeaders, aWidths, {}, nil, ;
                   fontname, fontsize, tooltip, , , aHeadClick, , , ;
                   nogrid, aImage, aJust, break, HelpId, bold, italic, underline, strikeout, nil, ;
                   nil, nil, edit, backcolor, fontcolor, dynamicbackcolor, dynamicforecolor, aPicture, ;
                   lRtl, InPlace, editcontrols, readonly, valid, validmessages, editcell, ;
                   aWhenFields )

   ::nWidth := w

   IF ValType( Value ) == "N"
      ::nValue := Value
   ENDIF
   ::Lock := Lock
   ::WorkArea := WorkArea
   ::AllowDelete := AllowDelete
   ::aFields := aFields
   ::aRecMap :=  {}
   ::AuxHandle := 0
   ::AllowAppend := AllowAppend
   ::aReplaceFields := replacefields

   if ! novscroll

      hsum := _OOHG_GridArrayWidths( ::hWnd, ::aWidths )

      nCol2 := x + nWidth2
      IF lRtl .AND. ! ::Parent:lRtl
         ::nCol := x + GETVSCROLLBARWIDTH()
         nCol2 := x
      ENDIF

		if hsum > w - GETVSCROLLBARWIDTH() - 4
         ScrollBarHandle := InitVScrollBar ( ::ContainerhWnd, nCol2, y , GETVSCROLLBARWIDTH() , h - GETHSCROLLBARHEIGHT() )
         ScrollBarButtonHandle := InitVScrollBarButton ( ::ContainerhWnd, nCol2, y + h - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() )
         ::nButtonActive := 1
		Else
         ScrollBarHandle := InitVScrollBar ( ::ContainerhWnd, nCol2, y , GETVSCROLLBARWIDTH() , h )
         ScrollBarButtonHandle := InitVScrollBarButton ( ::ContainerhWnd, nCol2, y + h - GETHSCROLLBARHEIGHT() , 0 , 0 )
         ::nButtonActive := 0
		EndIf

      ::VScroll := TScrollBar():SetContainer( Self, "" )
      ::VScroll:New( ScrollBarHandle,, HelpId,, ToolTip, ScrollBarHandle )
      ::VScroll:RangeMin := 1
      ::VScroll:RangeMax := 100
      ::VScroll:OnLineUp   := { || ::SetFocus():Up() }
      ::VScroll:OnLineDown := { || ::SetFocus():Down() }
      ::VScroll:OnPageUp   := { || ::SetFocus():PageUp() }
      ::VScroll:OnPageDown := { || ::SetFocus():PageDown() }
      ::VScroll:OnThumb    := { |VScroll,Pos| ::SetFocus():SetScrollPos( Pos, VScroll ) }
// cambiar TOOLTIP si cambia el del BROWSE
// Cambiar HelpID si cambia el del BROWSE

	EndIf

	// Add to browselist array to update on window activation

   aAdd ( ::Parent:BrowseList, Self )

   // Add Vertical scrollbar button

   ::AuxHandle := ScrollBarButtonHandle

   ::SizePos()

   // Must be set after control is initialized
   ::OnLostFocus := lostfocus
   ::OnGotFocus :=  gotfocus
   ::OnChange   :=  change
   ::OnDblClick := dblclick

Return Self

*-----------------------------------------------------------------------------*
METHOD UpDate() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local PageLength , aTemp, _BrowseRecMap := {} , x
Local nCurrentLength
Local lColor, aFields, cWorkArea, hWnd, nWidth
MEMVAR __aPicture
PRIVATE __aPicture

   cWorkArea := ::WorkArea

   If Select( cWorkArea ) == 0
      ::RecCount := 0
      Return nil
   EndIf

   lColor := ! ( Empty( ::DynamicForeColor ) .AND. Empty( ::DynamicBackColor ) )
   __aPicture := ::Picture
   nWidth := LEN( ::aFields )
   aFields := ARRAY( nWidth )
   AEVAL( ::aFields, { |c,i| aFields[ i ] := TBrowse_UpDate_Block( Self, i, c ) } )
   hWnd := ::hWnd

   ::lEof := .F.

   PageLength := ListViewGetCountPerPage( hWnd )

   If lColor
      ::GridForeColor := ARRAY( PageLength )
      ::GridBackColor := ARRAY( PageLength )
   Else
      ::GridForeColor := nil
      ::GridBackColor := nil
   EndIf

   x := 1
   nCurrentLength := ::ItemCount()

   Do While x <= PageLength .AND. ! ( cWorkArea )->( Eof() )

      aTemp := ARRAY( nWidth )

      AEVAL( aFields, { |b,i| aTemp[ i ] := EVAL( b ) } )

      If lColor
         ( cWorkArea )->( ::SetItemColor( x,,, aTemp ) )
      EndIf

      IF nCurrentLength < x
         AddListViewItems( hWnd, aTemp )
         nCurrentLength++
      Else
         ListViewSetItem( hWnd, aTemp, x )
      ENDIF

      aadd( _BrowseRecMap , ( cWorkArea )->( RecNo() ) )

      ( cWorkArea )->( DbSkip() )
      x++
   EndDo

   Do While nCurrentLength > Len( _BrowseRecMap )
      ListViewDeleteString( hWnd, nCurrentLength )
      nCurrentLength--
   EndDo

   IF ( cWorkArea )->( Eof() )
      ::lEof := .T.
   EndIf

   ::aRecMap := _BrowseRecMap

Return nil

Static Function TBrowse_UpDate_Block( Self, nColumn, cValue )
Local bBlock
Private oEditControl
MemVar oEditControl, __aPicture
   oEditControl := GetEditControlFromArray( NIL, ::EditControls, nColumn, Self )
   If ValType( oEditControl ) == "O"
      bBlock := &( "{ || oEditControl:GridValue( " + cValue + " ) }" )
   ElseIf ValType( __aPicture[ nColumn ] ) $ "CM"
      bBlock := &( "{ || Trim( Transform( " + ::WorkArea + "->( " + cValue + " ), __aPicture[ " + LTRIM( STR( nColumn ) ) + " ] ) ) }" )
   ElseIf ValType( __aPicture[ nColumn ] ) == "L" .AND. __aPicture[ nColumn ]
      bBlock := &( "{ || " + ::WorkArea + "->( " + cValue + " ) }" )
   Else
      bBlock := &( "{ || TBrowse_UpDate_PerType( " + ::WorkArea + "->( " + cValue + " ) ) }" )
   EndIf
Return bBlock

Function TBrowse_UpDate_PerType( uValue )
Local cType := ValType( uValue )
   If     cType == 'C'
      uValue := rTrim( uValue )
   ElseIf cType == 'N'
      uValue := lTrim( Str( uValue ) )
   ElseIf cType == 'L'
      uValue := IIF( uValue, '.T.', '.F.' )
   ElseIf cType == 'D'
      uValue := Dtoc( uValue )
   ElseIf cType == 'M'
      uValue := '<Memo>'
   ElseIf cType == 'A'
      uValue := "<Array>"
   Else
      uValue := 'Nil'
   EndIf
Return uValue

*-----------------------------------------------------------------------------*
METHOD PageDown() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _DeltaScroll, s

   _DeltaScroll := ListView_GetSubItemRect( ::hWnd, 0 , 0 )

   s := LISTVIEW_GETFIRSTITEM( ::hWnd )

   If  s >= Len( ::aRecMap )

      If Select( ::WorkArea ) == 0
         ::RecCount := 0
         Return nil
		EndIf

      if ::lEof
         If ::AllowAppend
            ::EditItem( .t. )
         Endif
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

      ::FastUpdate( LISTVIEWGETCOUNTPERPAGE( ::hWnd ) - s, Len( ::aRecMap ) )

	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD PageUp() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _DeltaScroll

   _DeltaScroll := ListView_GetSubItemRect( ::hWnd, 0 , 0 )

   If LISTVIEW_GETFIRSTITEM( ::hWnd ) == 1
      If Select( ::WorkArea ) == 0
         ::RecCount := 0
         Return nil
		EndIf
      _RecNo := ( ::WorkArea )->( RecNo() )
      ( ::WorkArea )->( DbGoTo( ::aRecMap[ 1 ] ) )
      ( ::WorkArea )->( DbSkip( - LISTVIEWGETCOUNTPERPAGE ( ::hWnd ) + 1 ) )
      ::scrollUpdate()
      ::Update()
      ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )
      ListView_SetCursel ( ::hWnd, 1 )

	Else

      ::FastUpdate( 1 - LISTVIEW_GETFIRSTITEM ( ::hWnd ), 1 )

	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD Home() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , _DeltaScroll

   _DeltaScroll := ListView_GetSubItemRect ( ::hWnd, 0 , 0 )

   If Select( ::WorkArea ) == 0
      ::RecCount := 0
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
      ::RecCount := 0
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
         ::RecCount := 0
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

      ::FastUpdate( -1, s - 1 )

	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD Down() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local s , _RecNo , _DeltaScroll

   s := LISTVIEW_GETFIRSTITEM( ::hWnd )

   If s >= Len( ::aRecMap )

      _DeltaScroll := ListView_GetSubItemRect( ::hWnd, 0 , 0 )

      If Select( ::WorkArea ) == 0
         ::RecCount := 0
         Return nil
      EndIf

      if ::lEof
         If ::AllowAppend
            ::EditItem( .t. )
         Endif
         Return nil
      EndIf

      _RecNo := ( ::WorkArea )->( RecNo() )

      ( ::WorkArea )->( DbGoTo( ::aRecMap[ 1 ] ) )
      ( ::WorkArea )->( DbSkip() )
      ::Update()
      ( ::WorkArea )->( DbGoTo( ATail( ::aRecMap ) ) )
      ::scrollUpdate()
      ListView_Scroll( ::hWnd, _DeltaScroll[2] * (-1) , 0 )
      ( ::WorkArea )->( DbGoTo( _RecNo ) )

      ListView_SetCursel( ::hWnd, Len( ::aRecMap ) )

	Else

      ::FastUpdate( 1, s + 1 )

	EndIf

   ::BrowseOnChange()

Return nil

*-----------------------------------------------------------------------------*
METHOD SetValue( Value, mp ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local _RecNo , NewPos := 50, _DeltaScroll , m , hWnd, cWorkArea

   cWorkArea := ::WorkArea

   If Select( cWorkArea ) == 0
      ::RecCount := 0
      Return nil
	EndIf

	If Value <= 0
      Return nil
	EndIf

   hWnd := ::hWnd

   If _OOHG_ThisEventType == 'BROWSE_ONCHANGE'
      If hWnd == _OOHG_ThisControl:hWnd
         MsgOOHGError( "BROWSE: Value property can't be changed inside ONCHANGE event. Program Terminated" )
		EndIf
	EndIf

   If Value > ( cWorkArea )->( RecCount() )
      ::nValue := 0
      ListViewReset( hWnd )
      ::BrowseOnChange()
      Return nil
	EndIf

   If valtype ( mp ) != "N"
      m := int( ListViewGetCountPerPage( hWnd ) / 2 )
	else
		m := mp
	endif

   _DeltaScroll := ListView_GetSubItemRect( hWnd, 0 , 0 )

   _RecNo := ( cWorkArea )->( RecNo() )

   ( cWorkArea )->( DbGoTo( Value ) )

   If ( cWorkArea )->( Eof() )
      ( cWorkArea )->( DbGoTo( _RecNo ) )
      Return nil
	EndIf

// Sin usar DBFILTER()
   ( cWorkArea )->( DBSkip() )
   ( cWorkArea )->( DBSkip( -1 ) )
   IF ( cWorkArea )->( RecNo() ) != Value
      ( cWorkArea )->( DbGoTo( _RecNo ) )
      Return nil
   ENDIF
/*
// Usando DBFILTER()
   cMacroVar := ( cWorkArea )->( dbfilter() )
   If ! Empty( cMacroVar )
      If ! ( cWorkArea )->( &cMacroVar )
         ( cWorkArea )->( DbGoTo( _RecNo ) )
         Return nil
		EndIf
	EndIf
*/

   if pcount() < 2
      ::scrollUpdate()
   EndIf
   ( cWorkArea )->( DbSkip( -m + 1 ) )

   ::nValue := Value
   ::Update()
   ( cWorkArea )->( DbGoTo( _RecNo ) )

   ListView_Scroll( hWnd, _DeltaScroll[ 2 ] * ( -1 ) , 0 )
   ListView_SetCursel ( hWnd, ascan( ::aRecMap, Value ) )

   _OOHG_ThisEventType := 'BROWSE_ONCHANGE'
   ::BrowseOnChange()
   _OOHG_ThisEventType := ''

Return nil

*-----------------------------------------------------------------------------*
METHOD Delete() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local Value, nRecNo

   Value := ::Value

	If Value == 0
		Return Nil
	EndIf

   nRecNo := ( ::WorkArea )->( RecNo() )

   ( ::WorkArea )->( DbGoTo( Value ) )

   If ::Lock .AND. ! ( ::WorkArea )->( Rlock() )

      MsgStop('Record is being editied by another user. Retry later','Delete Record')

   Else

      ( ::WorkArea )->( DbDelete() )
      ( ::WorkArea )->( DbSkip() )
      if ( ::WorkArea )->( Eof() )
         ( ::WorkArea )->( DbGoBottom() )
      EndIf

      If Set( _SET_DELETED )
         ::SetValue( ( ::WorkArea )->( RecNo() ) , LISTVIEW_GETFIRSTITEM( ::hWnd ) )
		EndIf

	EndIf

   ( ::WorkArea )->( DbGoTo( nRecNo ) )

Return Nil

*-----------------------------------------------------------------------------*
METHOD EditItem( append ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nOldRecNo, nNewRecNo, nItem, z, cTitle
Local aItems, aEditControls, aMemVars, aReplaceFields
Local oEditControl, uOldValue, cMemVar, bReplaceField

   IF ValType( append ) != "L"
      append := .F.
   ENDIF

   If Select( ::WorkArea ) == 0
      ::RecCount := 0
      Return nil
	EndIf

   nItem := LISTVIEW_GETFIRSTITEM( ::hWnd )

   If nItem == 0 .AND. ! append
      Return Nil
   EndIf

   nOldRecNo := ( ::WorkArea )->( RecNo() )

   If ::InPlace

      If append
         ( ::WorkArea )->( DbAppend() )
         nNewRecNo := ( ::WorkArea )->( RecNo() )
         ::scrollUpdate()
         ( ::WorkArea )->( _OOHG_Eval( ::OnAppend ) )
         ( ::WorkArea )->( DbSkip( - LISTVIEWGETCOUNTPERPAGE( ::hWnd ) + 1 ) )
         ::Update()
         ( ::WorkArea )->( DbGoTo( nOldRecNo ) )
         ListView_SetCursel( ::hWnd, ASCAN( ::aRecMap, nNewRecNo ) )
         ::BrowseOnChange()
      EndIf

      Return ::EditAllCells()

   EndIf

   If append
      cTitle := _OOHG_BRWLangButton[ 1 ]
      ( ::WorkArea )->( DbGoTo( ::aRecMap[ nItem ] ) )
   Else
      cTitle := _OOHG_BRWLangButton[ 2 ]
      ( ::WorkArea )->( DbGoTo( 0 ) )
   EndIf

   aItems := ARRAY( Len( ::aHeaders ) )
   aEditControls := ARRAY( Len( aItems ) )
   aMemVars := ARRAY( Len( aItems ) )
   aReplaceFields := ARRAY( Len( aItems ) )

   For z := 1 To Len( aItems )

      ::GetCellType( z, @oEditControl, @uOldValue, @cMemVar, @bReplaceField )
      If ValType( uOldValue ) $ "CM"
         uOldValue := AllTrim( uOldValue )
      EndIf
      // MixedFields??? If field is from other workarea...
      aEditControls[ z ] := oEditControl
      aItems[ z ] := uOldValue
      aMemVars[ z ] := cMemVar
      aReplaceFields[ z ] := bReplaceField

// MIXEDFIELDS!!!!
//      If append .AND. MixedFields
//         MsgOOHGError( _OOHG_BRWLangError[ 8 ], _OOHG_BRWLangError[ 3 ] )
//      EndIf

   Next z

   If ::lock .AND. ! append
      If ! ( ::WorkArea )->( RLock() )
         MsgExclamation( _OOHG_BRWLangError[ 9 ], _OOHG_BRWLangError[ 10 ] )
         ( ::WorkArea )->( DbGoTo( nOldRecNo ) )
         ::SetFocus()
         Return Nil
      EndIf
   EndIf

   aItems := ( ::WorkArea )->( ::EditItem2( nItem, aItems, aEditControls, aMemVars, cTitle ) )

   If ! Empty( aItems )

      If append
         ( ::WorkArea )->( DBAppend() )
         nNewRecNo := ( ::WorkArea )->( RecNo() )
         ( ::WorkArea )->( _OOHG_Eval( ::OnAppend ) )
      EndIf

      For z := 1 To Len( aItems )

         If ValType( ::ReadOnly ) == 'A' .AND. Len( ::ReadOnly ) >= z .AND. ValType( ::ReadOnly[ z ] ) == "L" .AND. ! ::ReadOnly[ z ]
            // Readonly field
         Else
            _OOHG_EVAL( aReplaceFields[ z ], aItems[ z ] )
         EndIf

      Next z

      If append
         ::Value := nNewRecNo
      Else
         ::Refresh()
      EndIf

      _OOHG_Eval( ::OnEditCell, 0, 0 )

   EndIf

   If ::Lock
      ( ::WorkArea )->( DbUnlock() )
   EndIf

   ( ::WorkArea )->( DbGoTo( nOldRecNo ) )

   ::SetFocus()

Return Nil

/*
   DEFINE WINDOW _EditRecord OBJ oEditRecord ;
                 AT row,col ;
                 WIDTH 310 ;
                 HEIGHT h - 19 + GetTitleHeight() ;
                 TITLE Title ;
                 MODAL NOSIZE ;
                 ON INIT oWnd:Control_1:SetFocus() ;

      ON KEY ALT+O ACTION ( aResults := _EditRecordOk( aControls, aValid, aValidMessages, oEditRecord ) )
      ON KEY ALT+C ACTION oEditRecord:Release()

      DEFINE SPLITBOX

         DEFINE WINDOW _Split_1 OBJ oWnd;
				WIDTH 310 ;
				HEIGHT H - 90 ;
				VIRTUAL HEIGHT TH ;
				SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK FOCUSED

            ON KEY ALT+O ACTION ( aResults := _EditRecordOk( aControls, aValid, aValidMessages, oEditRecord ) )
            ON KEY ALT+C ACTION oEditRecord:Release()

            ControlRow :=  10

            For i := 1 to l

               LN := 'Label_' + Alltrim(Str(i))
               CN := 'Control_' + Alltrim(Str(i))

               @ ControlRow , 10 LABEL &LN OF _Split_1 VALUE aLabels [i] WIDTH 90

               do case
// *
               case ValType( ::Picture ) == 'A' .AND. Len( ::Picture ) >= i .AND. ValType( ::Picture[ i ] ) $ "CM"

                  @ ControlRow , 120 TEXTBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10 PICTURE ::Picture[ i ]
                  ControlRow := ControlRow + 30
** /

               case ValType ( aValues [i] ) == 'L'

                  @ ControlRow , 120 CHECKBOX &CN OF _Split_1 CAPTION '' VALUE aValues[i]
                  ControlRow := ControlRow + 30

               case ValType ( aValues [i] ) == 'D'

                  @ ControlRow , 120 TEXTBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 DATE
                  ControlRow := ControlRow + 30

               case ValType ( aValues [i] ) == 'N'

                  If ValType ( aFormats [i] ) == 'A'
                     @ ControlRow , 120 COMBOBOX &CN  OF _Split_1 ITEMS aFormats[i] VALUE aValues[i] WIDTH 140  FONT 'Arial' SIZE 10
                     ControlRow := ControlRow + 30

                  ElseIf  ValType ( aFormats [i] ) $ 'CM'

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
                  ElseIf ValType ( aFormats [i] ) == 'C' .OR. aFormats [i] == "M"
                     @ ControlRow , 120 EDITBOX &CN  OF _Split_1 WIDTH 140 HEIGHT 90 VALUE aValues[i] FONT 'Arial' SIZE 10 MAXLENGTH aFormats[i]
                     ControlRow := ControlRow + 94
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

               If ValType( aReadOnly ) == 'A' .AND. Len( aReadOnly ) >= i .AND. ValType( aReadOnly[ i ] ) == "L" .AND. aReadOnly[ i ]
                  oControl:Disabled()
                  oControl:Cargo := { || .F. }
					EndIf

				Next i

			END WINDOW

         _WHENEVAL( aControls )

			DEFINE WINDOW _Split_2 ;
				WIDTH 300 ;
				HEIGHT 50 ;
				SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK

				@ 10 , 40 BUTTON BUTTON_1 ;
				OF _Split_2 ;
            CAPTION _OOHG_BRWLangButton[4] ;
            ACTION ( aResults := _EditRecordOk( aControls, aValid, aValidMessages, oEditRecord ) )

				@ 10 , 150 BUTTON BUTTON_2 ;
				OF _Split_2 ;
            CAPTION _OOHG_BRWLangButton[3] ;
            ACTION oEditRecord:Release()

			END WINDOW

		END SPLITBOX

	END WINDOW
*/

*-----------------------------------------------------------------------------*
METHOD EditCell( nRow, nCol, EditControl, uOldValue, uValue, cMemVar ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local lRet, BackRec, bReplaceField
   IF ValType( nRow ) != "N"
      nRow := LISTVIEW_GETFIRSTITEM( ::hWnd )
   ENDIF
   IF ValType( nCol ) != "N"
      nCol := 1
   ENDIF
   If nRow < 1 .OR. nRow > ::ItemCount() .OR. nCol < 1 .OR. nCol > Len( ::aHeaders )
      // Cell out of range
      lRet := .F.
   ElseIf Select( ::WorkArea ) == 0
      // It the specified area does not exists, set recordcount to 0 and return
      ::RecCount := 0
      lRet := .F.
   ElseIf VALTYPE( ::ReadOnly ) == "A" .AND. Len( ::ReadOnly ) >= nCol .AND. ValType( ::ReadOnly[ nCol ] ) == "L" .AND. ::ReadOnly[ nCol ]
      // Read only column
      PlayHand()
      lRet := .F.
   Else

      BackRec := ( ::WorkArea )->( RecNo() )
      ( ::WorkArea )->( DbGoTo( ::aRecMap[ nRow ] ) )

      // If LOCK clause is present, try to lock.
      If ::Lock .AND. ! ( ::WorkArea )->( RLock() )
         MsgExclamation( _OOHG_BRWLangError[ 9 ], _OOHG_BRWLangError[ 10 ] )
         ( ::WorkArea )->( DbGoTo( BackRec ) )
         Return .F.
      EndIf

      ::GetCellType( nCol, @EditControl, @uOldValue, @cMemVar, @bReplaceField )

      lRet := ::EditCell2( @nRow, @nCol, EditControl, uOldValue, @uValue, cMemVar )
      If lRet
         _OOHG_EVAL( bReplaceField, uValue )
         ::Refresh()
         _OOHG_Eval( ::OnEditCell, nRow, nCol )
      EndIf
      If ::Lock
         ( ::WorkArea )->( DbUnLock() )
      EndIf
      ( ::WorkArea )->( DbGoTo( BackRec ) )
   Endif
Return lRet

*-----------------------------------------------------------------------------*
METHOD GetCellType( nCol, EditControl, uOldValue, cMemVar, bReplaceField ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local cField, cArea, nPos, aStruct

   If ValType( nCol ) != "N"
      nCol := 1
   EndIf
   If nCol < 1 .OR. nCol > Len( ::aHeaders )
      // Cell out of range
      Return .F.
   EndIf

   If ValType( uOldValue ) == "U"
      uOldValue := &( ::aFields[ nCol ] )
   EndIf

   If ValType( ::aRepalceField ) == "A" .AND. Len( ::aReplaceField ) >= nCol
      bReplaceField := ::aReplaceField[ nCol ]
   Else
      bReplaceField := nil
   EndIf

   // Default cMemVar & bReplaceField
   cField := Upper( AllTrim( ::aFields[ nCol ] ) )
   nPos := At( '->', cField )
   If nPos != 0 .AND. Select( Trim( Left( cField, nPos - 1 ) ) ) != 0
      cArea := Trim( Left( cField, nPos - 1 ) )
      cField := Ltrim( SubStr( cField, nPos + 2 ) )
   Else
      cArea := ::WorkArea
   EndIf
   aStruct := ( cArea )->( DbStruct() )
   nPos := aScan( aStruct, { |a| a[ 1 ] == cField } )
   If nPos == 0
      cArea := cField := ""
      If ValType( bReplaceField ) != "B"
         bReplaceField := { || .F. }
      EndIf
   Else
      If ! ValType( cMemVar ) $ "CM" .OR. Empty( cMemVar )
         cMemVar := "MemVar" + cArea + cField
      EndIf
      If ValType( bReplaceField ) != "B"
         bReplaceField := FieldWBlock( cField, cArea )
      EndIf
   EndIf

   // Determines control type
   EditControl := GetEditControlFromArray( EditControl, ::EditControls, nCol, Self )
   If ValType( EditControl ) != "O"
      If ValType( ::Picture ) == "A" .AND. Len( ::Picture ) >= nCol
         If ValType( ::Picture[ nCol ] ) $ "CM"
            EditControl := TGridControlTextBox():New( ::Picture[ nCol ],, ValType( uOldValue ) )
         ElseIf ValType( ::Picture[ nCol ] ) == "L" .AND. ::Picture[ nCol ]
            EditControl := TGridControlImageList():New( Self )
         EndIf
      EndIf
      If ValType( EditControl ) != "O" .AND. nPos != 0
         // Checks according to field type
         Do Case
            Case aStruct[ nPos ][ 2 ] == "N"
               If aStruct[ nPos ][ 4 ] == 0
                  EditControl := TGridControlTextBox():New( Replicate( "9", aStruct[ nPos ][ 3 ] ),, "N" )
               Else
                  EditControl := TGridControlTextBox():New( Replicate( "9", aStruct[ nPos ][ 3 ] - aStruct[ nPos ][ 4 ] - 1 ) + "." + Replicate( "9", aStruct[ nPos ][ 4 ] ),, "N" )
               EndIf
            Case aStruct[ nPos ][ 2 ] == "L"
               // EditControl := TGridControlCheckBox():New()
               EditControl := TGridControlLComboBox():New()
            Case aStruct[ nPos ][ 2 ] == "M"
               EditControl := TGridControlMemo():New()
            Case aStruct[ nPos ][ 2 ] == "D"
               // EditControl := TGridControlDatePicker():New( .T. )
               EditControl := TGridControlTextBox():New( "@D",, "D" )
            Case aStruct[ nPos ][ 2 ] == "C"
               EditControl := TGridControlTextBox():New( "S" + Ltrim( Str( aStruct[ nPos ][ 3 ] ) ),, "C" )
            OtherWise
               // Non-implemented field type!!!
         EndCase
      EndIf
      If ValType( EditControl ) != "O"
         EditControl := GridControlObjectByType( uOldValue )
      EndIf
   EndIf
Return .T.

*-----------------------------------------------------------------------------*
METHOD AdjustRightScroll() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local hws, lRet, nButton, nCol
   lRet := .F.
   If ::VScroll != nil
      hws := _OOHG_GridArrayWidths( ::hWnd, ::aWidths )
      nButton := IF( ( hws > ::Width - GETVSCROLLBARWIDTH() - 4 ), 1, 0 )
      IF ::nButtonActive != nButton
         ::nButtonActive := nButton
*         ::Refresh()
         nCol := if( ::lRtl .AND. ! ::Parent:lRtl, 0, ::Width - GETVSCROLLBARWIDTH() )
         if nButton == 1
            ::VScroll:SizePos( 0, nCol, GETVSCROLLBARWIDTH() , ::Height - GETHSCROLLBARHEIGHT() )
            MoveWindow( ::AuxHandle, ::ContainerCol + nCol, ::ContainerRow + ::Height - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() , .t. )
         Else
            ::VScroll:SizePos( 0, nCol, GETVSCROLLBARWIDTH() , ::Height )
            MoveWindow( ::AuxHandle, ::ContainerCol + nCol, ::ContainerRow + ::Height - GETHSCROLLBARHEIGHT() , 0 , 0 , .t. )
         EndIf
*         ReDrawWindow( ::VScroll:hWnd )
*         ReDrawWindow( ::AuxHandle )
         lRet := .T.
      ENDIF
   EndIf
Return lRet

*-----------------------------------------------------------------------------*
METHOD ColumnWidth( nColumn, nWidth ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nRet
   nRet := ::Super:ColumnWidth( nColumn, nWidth )
   IF ::AdjustRightScroll()
      ::Refresh()
   ENDIF
Return nRet

*-----------------------------------------------------------------------------*
METHOD ColumnAutoFit( nColumn ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nRet
   nRet := ::Super:ColumnAutoFit( nColumn )
   IF ::AdjustRightScroll()
      ::Refresh()
   ENDIF
Return nRet

*-----------------------------------------------------------------------------*
METHOD ColumnAutoFitH( nColumn ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nRet
   nRet := ::Super:ColumnAutoFitH( nColumn )
   IF ::AdjustRightScroll()
      ::Refresh()
   ENDIF
Return nRet

*-----------------------------------------------------------------------------*
METHOD ColumnsAutoFit() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nRet
   nRet := ::Super:ColumnsAutoFit()
   IF ::AdjustRightScroll()
      ::Refresh()
   ENDIF
Return nRet

*-----------------------------------------------------------------------------*
METHOD ColumnsAutoFitH() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nRet
   nRet := ::Super:ColumnsAutoFitH()
   IF ::AdjustRightScroll()
      ::Refresh()
   ENDIF
Return nRet

*-----------------------------------------------------------------------------*
METHOD BrowseOnChange() CLASS TBrowse
*-----------------------------------------------------------------------------*
LOCAL cWorkArea

   If _OOHG_BrowseSyncStatus

      cWorkArea := ::WorkArea

      If Select( cWorkArea ) != 0 .AND. ( cWorkArea )->( RecNo() ) != ::Value

         ( cWorkArea )->( DbGoTo( ::Value ) )

		EndIf

	EndIf

   ::DoEvent( ::OnChange )

Return nil

*-----------------------------------------------------------------------------*
METHOD FastUpdate( d, nRow ) CLASS TBrowse
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
         * ::VScroll:RangeMax := RecordCount
         ::VScroll:Value := ActualRecord
		EndIf

	EndIf

   ::nValue := ::aRecMap[ nRow ]

   ListView_SetCursel( ::hWnd, nRow )

Return nil

*-----------------------------------------------------------------------------*
METHOD ScrollUpdate() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local ActualRecord , RecordCount
Local oVScroll, cWorkArea

   oVScroll := ::VScroll

	// If vertical scrollbar is used it must be updated
   If oVScroll != nil

      cWorkArea := ::WorkArea
      IF Select( cWorkArea ) == 0
         ::RecCount := 0
         Return NIL
      ENDIF
      RecordCount := ( cWorkArea )->( OrdKeyCount() )
      If RecordCount > 0
         ActualRecord := ( cWorkArea )->( OrdKeyNo() )
		Else
         ActualRecord := ( cWorkArea )->( RecNo() )
         RecordCount := ( cWorkArea )->( RecCount() )
		EndIf

      ::nValue := ( cWorkArea )->( RecNo() )
      ::RecCount := RecordCount

		If RecordCount < 100
         oVScroll:RangeMax := RecordCount
         oVScroll:Value := ActualRecord
		Else
         oVScroll:RangeMax := 100
         oVScroll:Value := Int ( ActualRecord * 100 / RecordCount )
		EndIf

	EndIf

Return NIL





*-----------------------------------------------------------------------------*
METHOD Refresh() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local s , _RecNo , _DeltaScroll, v
Local cWorkArea, hWnd

   cWorkArea := ::WorkArea
   hWnd := ::hWnd

   If Select( cWorkArea ) == 0
      ListViewReset( hWnd )
      Return nil
	EndIf

   v := ::Value

   _DeltaScroll := ListView_GetSubItemRect ( hWnd, 0 , 0 )

   s := LISTVIEW_GETFIRSTITEM ( hWnd )

   _RecNo := ( cWorkArea )->( RecNo() )

   if v <= 0
		v := _RecNo
	EndIf

   ( cWorkArea )->( DbGoTo( v ) )

***************************

	if s == 1 .or. s == 0
// Sin usar DBFILTER()
      ( cWorkArea )->( DBSkip() )
      ( cWorkArea )->( DBSkip( -1 ) )
      IF ( cWorkArea )->( RecNo() ) != v
         ( cWorkArea )->( DbSkip() )
      ENDIF
/*
// Usando DBFILTER()
      cMacroVar := ( c::WorkArea )->( dbfilter() )
      If ! Empty( cMacroVar )
         If ! ( cWorkArea )->( &cMacroVar )
            ( cWorkArea )->( DbSkip() )
         EndIf
      EndIf
*/
	EndIf

***************************

	if s == 0
      if ( cWorkArea )->( INDEXORD() ) != 0
         if ( cWorkArea )->( ORDKEYVAL() ) == Nil
            ( cWorkArea )->( DbGoTop() )
			endif
		EndIf

      if Set( _SET_DELETED )
         if ( cWorkArea )->( Deleted() )
            ( cWorkArea )->( DbGoTop() )
			endif
		EndIf
	endif

   If ( cWorkArea )->( Eof() )

      ListViewReset ( hWnd )

      ( cWorkArea )->( DbGoTo( _RecNo ) )

      Return nil

	EndIf

   ::scrollUpdate()

	if s != 0
      ( cWorkArea )->( DbSkip( -s+1 ) )
	EndIf

   ::Update()

   ListView_Scroll( hWnd, _DeltaScroll[2] * (-1) , 0 )
   ListView_SetCursel ( hWnd, ascan ( ::aRecMap, v ) )

   ( cWorkArea )->( DbGoTo( _RecNo ) )

Return nil

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
      uRet := MoveWindow( ::hWnd, ::ContainerCol + if( ::lRtl .AND. ! ::Parent:lRtl, GETVSCROLLBARWIDTH(), 0 ), ::ContainerRow, ::Width - GETVSCROLLBARWIDTH(), ::Height , .t. )

      // Force button move/resize and browse refresh
      ::nButtonActive := 2
      ::AdjustRightScroll()

   else

      uRet := MoveWindow( ::hWnd, ::ContainerCol + if( ::lRtl .AND. ! ::Parent:lRtl, GETVSCROLLBARWIDTH(), 0 ), ::ContainerRow, ::nWidth, ::nHeight , .T. )

   EndIf
*   ReDrawWindow( ::hWnd )
   ::Refresh()
Return uRet

*-----------------------------------------------------------------------------*
METHOD Value( uValue ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nItem
   IF VALTYPE( uValue ) == "N"
      ::SetValue( uValue )
   ENDIF
   If SELECT( ::WorkArea ) == 0
      ::RecCount := 0
      uValue := 0
   Else
      nItem := LISTVIEW_GETFIRSTITEM( ::hWnd )
      If nItem > 0 .AND. nItem <= Len( ::aRecMap )
         uValue := ::aRecMap[ nItem ]
      Else
         uValue := ::nValue
      Endif
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
      If ::AuxHandle != 0
         IF ::Super:Enabled
            EnableWindow( ::AuxHandle )
         ELSE
            DisableWindow( ::AuxHandle )
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
      If ::AuxHandle != 0
         IF ::ContainerVisible
            CShowControl( ::AuxHandle )
         ELSE
            HideWindow( ::AuxHandle )
         ENDIF
		EndIf
      ProcessMessages()
   ENDIF
RETURN ::Super:Visible

*------------------------------------------------------------------------------*
METHOD ForceHide() CLASS TBrowse
*------------------------------------------------------------------------------*
   If ::VScroll != nil
      ::VScroll:ForceHide()
   EndIf
   If ::AuxHandle != 0
      HideWindow( ::AuxHandle )
   EndIf
RETURN ::Super:ForceHide()

*-----------------------------------------------------------------------------*
METHOD RefreshData() CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nValue := ::nValue
   IF ValType( nValue ) != "N" .OR. nValue == 0
      ::Refresh()
      ::nValue := ::Value
   ElseIf ::Value == nValue
      ::Refresh()
   Else
      ::Value := nValue
   ENDIF
RETURN nil

*-----------------------------------------------------------------------------*
METHOD IsHandle( hWnd ) CLASS TBrowse
*-----------------------------------------------------------------------------*
RETURN ( hWnd == ::hWnd ) .OR. ;
       ( ::VScroll != nil .AND. hWnd == ::VScroll:hWnd ) .OR. ;
       ( ::AuxHandle != 0 .AND. hWnd == ::AuxHandle )

*-----------------------------------------------------------------------------*
METHOD Events_Enter() CLASS TBrowse
*-----------------------------------------------------------------------------*

   if ::AllowEdit .AND. Select( ::WorkArea ) != 0
      if ::InPlace
         ::EditAllCells()
      Else
         ::EditItem( .f. )
      EndIf
   Else

      ::DoEvent( ::OnDblClick )

   Endif

Return nil

#pragma BEGINDUMP
#define s_Super s_TGrid
#include "hbapi.h"
#include "hbvm.h"
#include <windows.h>
#include <commctrl.h>
#include "../include/oohg.h"
extern int TGrid_Notify_CustomDraw( PHB_ITEM pSelf, LPARAM lParam );

// -----------------------------------------------------------------------------
// METHOD Events_Notify( wParam, lParam ) CLASS TBrowse
HB_FUNC_STATIC( TBROWSE_EVENTS_NOTIFY )
// -----------------------------------------------------------------------------
{
   LONG wParam = hb_parnl( 1 );
   LONG lParam = hb_parnl( 2 );

   switch( ( ( NMHDR FAR * ) lParam )->code )
   {
      case NM_CLICK:
      case LVN_BEGINDRAG:
      case LVN_KEYDOWN:
         HB_FUNCNAME( TBROWSE_EVENTS_NOTIFY2 )();
         break;

      case NM_CUSTOMDRAW:
         _OOHG_Send( hb_stackSelfItem(), s_AdjustRightScroll );
         hb_vmSend( 0 );
         hb_retni( TGrid_Notify_CustomDraw( hb_stackSelfItem(), lParam ) );
         break;

      default:
         _OOHG_Send( hb_stackSelfItem(), s_Super );
         hb_vmSend( 0 );
         _OOHG_Send( hb_param( -1, HB_IT_OBJECT ), s_Events_Notify );
         hb_vmPushLong( wParam );
         hb_vmPushLong( lParam );
         hb_vmSend( 2 );
         break;
   }
}
#pragma ENDDUMP

FUNCTION TBrowse_Events_Notify2( wParam, lParam )
Local Self := QSelf()
Local nNotify := GetNotifyCode( lParam )
Local nvKey
Local r, DeltaSelect

   If nNotify == NM_CLICK  .or. nNotify == LVN_BEGINDRAG

      r := LISTVIEW_GETFIRSTITEM( ::hWnd )
      If r > 0
         DeltaSelect := r - ascan ( ::aRecMap, ::nValue )
         ::FastUpdate( DeltaSelect, r )
         ::BrowseOnChange()
      EndIf

      Return nil

   elseIf nNotify == LVN_KEYDOWN

      nvKey := GetGridvKey( lParam )

      Do Case

      Case Select( ::WorkArea ) == 0

         // No database open

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

      Return nil

   EndIf

Return ::Super:Events_Notify( wParam, lParam )

*-----------------------------------------------------------------------------*
METHOD SetScrollPos( nPos ) CLASS TBrowse
*-----------------------------------------------------------------------------*
Local nr , RecordCount , BackRec

   If Select( ::WorkArea ) != 0

      BackRec := ( ::WorkArea )->( RecNo() )

      If ( ::WorkArea )->( OrdKeyCount() ) > 0
         RecordCount := ( ::WorkArea )->( OrdKeyCount() )
      Else
         RecordCount := ( ::WorkArea )->( RecCount() )
      EndIf

      IF nPos == 1
         ( ::WorkArea )->( DBGoTop() )
      ElseIf nPos == ::VScroll:RangeMax
         ( ::WorkArea )->( DBGoBottom() )
      Else
         nr := nPos * RecordCount / ::VScroll:RangeMax
         #ifdef __XHARBOUR__
            ( ::WorkArea )->( OrdKeyGoTo( nr ) )
         #else
            If nr < ( RecordCount / 2 )
               ( ::WorkArea )->( DbGoTop() )
               ( ::WorkArea )->( DbSkip( nr ) )
            Else
               ( ::WorkArea )->( DbGoBottom() )
               ( ::WorkArea )->( DbSkip( nr - RecordCount ) )
            EndIf
         #endif
      ENDIF

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