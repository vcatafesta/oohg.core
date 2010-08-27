/*
 * $Id: h_menu.prg,v 1.28 2010-08-27 21:25:22 guerra000 Exp $
 */
/*
 * ooHG source code:
 * PRG menu functions
 *
 * Copyright 2005-2010 Vicente Guerra <vicente@guerra.com.mx>
 * www - http://www.oohg.org
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

STATIC _OOHG_xMenuActive := {}

CLASS TMenu FROM TControl
   DATA Type      INIT "MENU" READONLY
   DATA lMain     INIT .F.

   DATA lAdjust   INIT .F.

   METHOD Define
   METHOD Activate
   METHOD EndMenu
   METHOD Refresh
   METHOD Release     BLOCK { |Self| DestroyMenu( ::hWnd ), ::Super:Release() }
   METHOD Separator   BLOCK { |Self| TMenuItem():DefineSeparator( , Self ) }

   EMPTY( _OOHG_AllVars )
ENDCLASS

*------------------------------------------------------------------------------*
METHOD Define( Parent, Name ) CLASS TMenu
*------------------------------------------------------------------------------*
   ::SetForm( Name, Parent )
   ::Container := NIL
   ::Register( CreatePopUpMenu() )
   AADD( _OOHG_xMenuActive, Self )
Return Self

*------------------------------------------------------------------------------*
METHOD Activate( nRow, nCol ) CLASS TMenu
*------------------------------------------------------------------------------*
Local aPos
   aPos := GetCursorPos()
   ASSIGN aPos[ 1 ] VALUE nRow TYPE "N"
   ASSIGN aPos[ 2 ] VALUE nCol TYPE "N"
   TrackPopupMenu( ::hWnd, aPos[ 2 ], aPos[ 1 ], ::Parent:hWnd )
Return nil

*------------------------------------------------------------------------------*
METHOD EndMenu() CLASS TMenu
*------------------------------------------------------------------------------*
Local nPos
   nPos := ASCAN( _OOHG_xMenuActive, { |o| o:hWnd == ::hWnd } )
   IF nPos > 0
      ADEL( _OOHG_xMenuActive, nPos )
      ASIZE( _OOHG_xMenuActive, LEN( _OOHG_xMenuActive ) - 1 )
   ENDIF
   ::Refresh()
Return Nil

*------------------------------------------------------------------------------*
METHOD Refresh() CLASS TMenu
*------------------------------------------------------------------------------*
   IF ::lMain
      DrawMenuBar( ::Parent:hWnd )
   ENDIF
Return Nil





CLASS TMenuMain FROM TMenu
   DATA lMain     INIT .T.

   METHOD Define
   METHOD Activate    BLOCK { || nil }
   METHOD Release     BLOCK { |Self| ::Parent:oMenu := nil, ::Super:Release() }
ENDCLASS

*------------------------------------------------------------------------------*
METHOD Define( Parent, Name ) CLASS TMenuMain
*------------------------------------------------------------------------------*
   ::SetForm( Name, Parent )
   ::Container := NIL
   ::Register( CreateMenu() )
   AADD( _OOHG_xMenuActive, Self )
   If ::Parent:oMenu != nil
      // Error: MAIN MENU already defined for this window
      ::Parent:oMenu:Release()
   EndIf
   SetMenu( ::Parent:hWnd, ::hWnd )
   ::Parent:oMenu := Self
Return Self





CLASS TMenuContext FROM TMenu
   METHOD Define
   METHOD Release     BLOCK { |Self| ::Parent:ContextMenu := nil, ::Super:Release() }
ENDCLASS

*------------------------------------------------------------------------------*
METHOD Define( Parent, Name ) CLASS TMenuContext
*------------------------------------------------------------------------------*
   ::Super:Define( Parent, Name )
   If ::Parent:ContextMenu != nil
      ::Parent:ContextMenu:Release()
   EndIf
   ::Parent:ContextMenu := Self
Return Self





CLASS TMenuNotify FROM TMenu
   METHOD Define
   METHOD Release     BLOCK { |Self| ::Parent:NotifyMenu := nil, ::Super:Release() }
ENDCLASS

*------------------------------------------------------------------------------*
METHOD Define( Parent, Name ) CLASS TMenuNotify
*------------------------------------------------------------------------------*
   ::Super:Define( Parent, Name )
   IF ::Parent:NotifyMenu != nil
      ::Parent:NotifyMenu:Release()
   ENDIF
   ::Parent:NotifyMenu := Self
Return Self





CLASS TMenuDropDown FROM TMenu
   METHOD Define
   METHOD Release
ENDCLASS

*------------------------------------------------------------------------------*
METHOD Define( Button, Parent, Name ) CLASS TMenuDropDown
*------------------------------------------------------------------------------*
LOCAL oContainer
   If HB_IsObject( Button )
      Parent := Button:Parent
      Button := Button:Name
   EndIf
   ::Super:Define( Parent, Name )
   oContainer := GetControlObject( Button, ::Parent:Name )
   If oContainer:ContextMenu != nil
      oContainer:ContextMenu:Release()
   EndIf
   oContainer:ContextMenu := Self
Return Self

*------------------------------------------------------------------------------*
METHOD Release() CLASS TMenuDropDown
*------------------------------------------------------------------------------*
   If ::Container != nil
      ::Container:ContextMenu := nil
   Endif
Return ::Super:Release()

*------------------------------------------------------------------------------*
Function _EndMenu()
*------------------------------------------------------------------------------*
   IF LEN( _OOHG_xMenuActive ) > 0
      ATAIL( _OOHG_xMenuActive ):EndMenu()
   ENDIF
Return Nil





CLASS TMenuItem FROM TControl
   DATA Type      INIT "MENUITEM" READONLY
   DATA xId       INIT 0
   DATA lMain     INIT .F.
   DATA cPicture  INIT ""

   DATA lAdjust   INIT .F.

   METHOD DefinePopUp
   METHOD DefineItem
   METHOD DefineSeparator

   METHOD Enabled      SETGET
   METHOD Checked      SETGET
   METHOD Hilited      SETGET
   METHOD Caption      SETGET
   METHOD Release
   METHOD EndPopUp
   METHOD Separator    BLOCK { |Self| TMenuItem():DefineSeparator( , Self ) }
   METHOD Picture      SETGET

   METHOD DefaultItem( nItem )    BLOCK { |Self,nItem| SetMenuDefaultItem( ::Container:hWnd, nItem ) }
ENDCLASS

*------------------------------------------------------------------------------*
METHOD DefinePopUp( Caption, Name, checked, disabled, Parent, hilited, Image, ;
                    lRight ) CLASS TMenuItem
*------------------------------------------------------------------------------*
LOCAL nStyle
   If Empty( Parent )
      Parent := ATAIL( _OOHG_xMenuActive )
   EndIf
   ::SetForm( Name, Parent )
   ::Register( CreatePopupMenu(), Name )
   ::xId := ::hWnd
   AADD( _OOHG_xMenuActive, Self )
   nStyle := MF_POPUP + MF_STRING + IF( ValType( lRight ) == "L" .AND. lRight, MF_RIGHTJUSTIFY, 0 )
   AppendMenu( ::Container:hWnd, ::hWnd, Caption, nStyle )
   ::Picture := image
   ::Checked := checked
   ::Hilited := hilited
   if HB_IsLogical( disabled ) .AND. disabled
      ::Enabled := .F.
   EndIf
Return Self

*------------------------------------------------------------------------------*
METHOD DefineItem( caption, action, name, Image, checked, disabled, Parent, ;
                   hilited, lRight ) CLASS TMenuItem
*------------------------------------------------------------------------------*
Local nStyle, id
   If Empty( Parent )
      Parent := ATAIL( _OOHG_xMenuActive )
   EndIf
   ::SetForm( Name, Parent )
   Id := _GetId()
   nStyle := MF_STRING + IF( HB_IsLogical( lRight ) .AND. lRight, MF_RIGHTJUSTIFY, 0 )
   AppendMenu( ::Container:hWnd, id, caption, nStyle )
   ::Register( 0, Name, , , , Id )
   ::xId := ::Id
   ::OnClick := action
   ::Picture := image
   ::Checked := checked
   ::Hilited := hilited
   if HB_IsLogical( disabled )  .AND. disabled
      ::Enabled := .F.
   EndIf
Return Self

*------------------------------------------------------------------------------*
METHOD DefineSeparator( name, Parent, lRight ) CLASS TMenuItem
*------------------------------------------------------------------------------*
Local nStyle, id
   If Empty( Parent )
      Parent := ATAIL( _OOHG_xMenuActive )
   EndIf
   ::SetForm( Name, Parent )
   Id := _GetId()
   nStyle := MF_SEPARATOR + IF( HB_IsLogical( lRight ) .AND. lRight, MF_RIGHTJUSTIFY, 0 )
   AppendMenu( ::Container:hWnd, Id, nStyle )
   ::Register( 0, Name, , , , Id )
   ::xId := ::Id
Return Self

*------------------------------------------------------------------------------*
METHOD Enabled( lEnabled ) CLASS TMenuItem
*------------------------------------------------------------------------------*
Local lRet
   lRet := MenuEnabled( ::Container:hWnd, ::xId, lEnabled )
   ::Container:Refresh()
Return lRet

*------------------------------------------------------------------------------*
METHOD Checked( lChecked ) CLASS TMenuItem
*------------------------------------------------------------------------------*
Local lRet
   lRet := MenuChecked( ::Container:hWnd, ::xId, lChecked )
   ::Container:Refresh()
Return lRet

*------------------------------------------------------------------------------*
METHOD Hilited( lHilited ) CLASS TMenuItem
*------------------------------------------------------------------------------*
Local lRet
   lRet := MenuHilited( ::Container:hWnd, ::xId, lHilited, ::Parent:hWnd )
   ::Container:Refresh()
Return lRet

*------------------------------------------------------------------------------*
METHOD Caption( cCaption ) CLASS TMenuItem
*------------------------------------------------------------------------------*
Local cRet
   cRet := MenuCaption( ::Container:hWnd, ::xId, cCaption )
   ::Container:Refresh()
Return cRet

*------------------------------------------------------------------------------*
METHOD Picture( cPicture ) CLASS TMenuItem
*------------------------------------------------------------------------------*
   If VALTYPE( cPicture ) $ "CM"
      // TODO: Release old image
      // TODO: Menu items supports two images!
      MenuItem_SetBitMaps( ::Container:hWnd, ::xId, cPicture, '' )
      ::cPicture := cPicture
   EndIf
Return ::cPicture

*------------------------------------------------------------------------------*
METHOD Release() CLASS TMenuItem
*------------------------------------------------------------------------------*
   DeleteMenu( ::Container:hWnd, ::xId )
   ::Container:Refresh()
Return ::Super:Release()

*------------------------------------------------------------------------------*
METHOD EndPopUp() CLASS TMenuItem
*------------------------------------------------------------------------------*
Local nPos
   nPos := ASCAN( _OOHG_xMenuActive, { |o| o:hWnd == ::hWnd } )
   IF nPos > 0
      ADEL( _OOHG_xMenuActive, nPos )
      ASIZE( _OOHG_xMenuActive, LEN( _OOHG_xMenuActive ) - 1 )
   ENDIF
Return Nil

*------------------------------------------------------------------------------*
Function _EndMenuPopup()
*------------------------------------------------------------------------------*
   IF LEN( _OOHG_xMenuActive ) > 0
      ATAIL( _OOHG_xMenuActive ):EndPopUp()
   ENDIF
Return Nil

EXTERN TrackPopUpMenu, SetMenuDefaultItem, GetMenuBarHeight

#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "oohg.h"

HB_FUNC( TRACKPOPUPMENU )
{
   HWND hwnd = HWNDparam( 4 );

   SetForegroundWindow( hwnd );
   TrackPopupMenu( HMENUparam( 1 ), 0, hb_parni( 2 ), hb_parni( 3 ), 0, hwnd, 0 );
   PostMessage( hwnd, WM_NULL, 0, 0 );
}

HB_FUNC( APPENDMENU )
{
   hb_retnl( AppendMenu( HMENUparam( 1 ), hb_parni( 4 ), hb_parni( 2 ), hb_parc( 3 ) ) );
}

HB_FUNC( CREATEMENU )
{
   HMENUret( CreateMenu() );
}

HB_FUNC( CREATEPOPUPMENU )
{
   HMENUret( CreatePopupMenu() );
}

HB_FUNC( SETMENU )
{
   SetMenu( HWNDparam( 1 ), HMENUparam( 2 ) );
}

HB_FUNC( MENUCHECKED )
{
   HMENU hMenu = HMENUparam( 1 );
   int iItem = hb_parni( 2 );

   if( ISLOG( 3 ) )
   {
      CheckMenuItem( hMenu, iItem, MF_BYCOMMAND | ( hb_parl( 3 ) ? MF_CHECKED : MF_UNCHECKED ) );
   }

   hb_retl( ( GetMenuState( hMenu, iItem, MF_BYCOMMAND ) & MF_CHECKED ) );
}

HB_FUNC( MENUENABLED )
{
   HMENU hMenu = HMENUparam( 1 );
   int iItem = hb_parni( 2 );

   if( ISLOG( 3 ) )
   {
      EnableMenuItem( hMenu, iItem, MF_BYCOMMAND | ( hb_parl( 3 ) ? MF_ENABLED : MF_GRAYED ) );
   }

   hb_retl( ! ( GetMenuState( hMenu, iItem, MF_BYCOMMAND ) & MF_GRAYED ) );
}

HB_FUNC( MENUHILITED )
{
   HMENU hMenu = HMENUparam( 1 );
   int iItem = hb_parni( 2 );

   if( ISLOG( 3 ) )
   {
      HiliteMenuItem( HWNDparam( 4 ), hMenu, iItem, MF_BYCOMMAND | ( hb_parl( 3 ) ? MF_HILITE : MF_UNHILITE ) );
   }

   hb_retl( ( GetMenuState( hMenu, iItem, MF_BYCOMMAND ) & MF_HILITE ) );
}

HB_FUNC( MENUCAPTION )
{
   HMENU hMenu = HMENUparam( 1 );
   int iItem = hb_parni( 2 );
   int iLen;
   char *cBuffer;

   if( ISCHAR( 3 ) )
   {
      MENUITEMINFO MenuItem;
      memset( &MenuItem, 0, sizeof( MenuItem ) );
      MenuItem.cbSize = sizeof( MenuItem );
      MenuItem.fMask = MIIM_STRING;
      MenuItem.dwTypeData = ( char * ) hb_parc( 3 );
      MenuItem.cch = hb_parclen( 3 );
      SetMenuItemInfo( hMenu, iItem, MF_BYCOMMAND, &MenuItem );
   }

   iLen = GetMenuString( hMenu, iItem, NULL, 0, MF_BYCOMMAND );
   cBuffer = (char *) hb_xgrab( iLen + 2 );
   iLen = GetMenuString( hMenu, iItem, cBuffer, iLen + 1, MF_BYCOMMAND );
   hb_retclen( cBuffer, iLen );
   hb_xfree( cBuffer );
}

HB_FUNC( MENUITEM_SETBITMAPS )
{
   HMENU hMenu = HMENUparam( 1 );
   HBITMAP himage1, himage2;
   int iAttributes = LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT;

   himage1 = (HBITMAP) _OOHG_LoadImage( ( char * ) hb_parc( 3 ), iAttributes, 0, 0, ( HWND ) hMenu, -1 );
   himage2 = (HBITMAP) _OOHG_LoadImage( ( char * ) hb_parc( 4 ), iAttributes, 0, 0, ( HWND ) hMenu, -1 );

   SetMenuItemBitmaps( hMenu, hb_parni( 2 ), MF_BYCOMMAND, himage1, himage2 );
}

HB_FUNC( SETMENUDEFAULTITEM )
{
   HMENU hMenu = HMENUparam( 1 );

   if( ValidHandler( hMenu ) )
   {
      SetMenuDefaultItem( hMenu, hb_parni( 2 ) - 1, TRUE );
   }
}

HB_FUNC( GETMENUBARHEIGHT )
{
   hb_retni( GetSystemMetrics( SM_CYMENU ) );
}

HB_FUNC( DESTROYMENU )
{
   HMENU hMenu = HMENUparam( 1 );

   if( ValidHandler( hMenu ) )
   {
      DestroyMenu( hMenu );
   }
}

HB_FUNC( DRAWMENUBAR )
{
   HWND hWnd = HWNDparam( 1 );

   if( ValidHandler( hWnd ) )
   {
      DrawMenuBar( hWnd );
   }
}

HB_FUNC( DELETEMENU )
{
   HMENU hMenu = HMENUparam( 1 );

   if( ValidHandler( hMenu ) )
   {
      DeleteMenu( hMenu, hb_parni( 2 ), MF_BYCOMMAND );
   }
}

#pragma ENDDUMP
