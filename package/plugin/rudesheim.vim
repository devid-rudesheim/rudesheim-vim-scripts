if exists( 'g:Rudesheim' )
	finish
endif

let g:Rudesheim = {}
let g:Rudesheim._ = {}

function g:Rudesheim.RH()
	return g:Rudesheim
endfunction

function g:Rudesheim.AsString()
	return self.RH().String( string( self ) )
endfunction

function g:Rudesheim.Object()
	return deepcopy( self )
endfunction

let g:Rudesheim = g:Rudesheim.Object()

function g:Rudesheim.Primitive( vim_value )
        let l:object = self.Object()
        let l:object._.value = a:vim_value

        function l:object.AsVimValue()
                return self._.value
        endfunction

        return l:object
endfunction

function g:Rudesheim.Number( vim_value )
        let l:object = self.Primitive( a:vim_value )

        function! l:object.AsString()
                return self.RH().String( string( self._.value ) )
        endfunction

        return l:object
endfunction

function g:Rudesheim.Integer( vim_value )
	let l:object = self.Number( a:vim_value )

	function! l:object.AsInteger()
		return self
	endfunction

	function! l:object.AsFloat()
		return self.RH().Float( 0.0 + self._.value )
	endfunction

	return l:object
endfunction

function g:Rudesheim.Float( vim_value )
	let l:object = self.Number( a:vim_value )

	function! l:object.AsInteger()
		return self.RH().Integer( float2nr( self._.value ) )
	endfunction

	function! l:object.AsFloat()
		return self
	endfunction

	return l:object
endfunction

function g:Rudesheim.String( vim_value )
        let l:object = self.Primitive( a:vim_value )

	function! l:object.AsVimString()
		return self._.value
	endfunction

	function! l:object.AsIntegerByHexadecimal( hexadecimal_as_integer )
		return self.RH().Integer( str2nr( self.AsVimString(), a:hexadecimal_as_integer.AsVimInteger() ) )
	endfunction

	function! l:object.AsInteger()
		return self.AsIntegerByHexadecimal( self.RH().Ten() )
	endfunction

	function! l:object.AsFloat()
		return self.RH().Float( str2float( self.AsVimString() ) )
	endfunction

	function! l:object.AsString()
		return self
	endfunction

	function! l:object.AsFilePath()
		return self.RH().FilePath( self )
	endfunction

	function! l:object.With( value_as_string )
		return self.RH().String( self.AsVimString() . a:value_as_string.AsString().AsVimString() )
	endfunction

	return l:object
endfunction

function g:Rudesheim.Zero()
	return self.Integer( 0 )
endfunction

function g:Rudesheim.One()
	return self.Integer( 1 )
endfunction

function g:Rudesheim.Two()
	return self.Integer( 2 )
endfunction

function g:Rudesheim.Three()
	return self.Integer( 3 )
endfunction

function g:Rudesheim.Eight()
	return self.Integer( 8 )
endfunction

function g:Rudesheim.Ten()
	return self.Integer( 10 )
endfunction

function g:Rudesheim.SixTeen()
	return self.Integer( 16 )
endfunction

function g:Rudesheim.FilePath( file_path_as_string )
	let l:object = self.Object()
	let l:object._.file_path = a:file_path_as_string.AsString()

	function l:object.Name()
		return self.RH().String( fnamemodify( self._.file_path.AsVimValue(), ':p:t' ) )
	endfunction

	function l:object.RelativeString()
		return self._.file_path
	endfunction

	function l:object.FullString()
		return self.RH().String( fnamemodify( self._.file_path.AsVimValue(), ':p' ) )
	endfunction

	function l:object.ParentFilePath()
		return self.RH().String( fnamemodify( self._.file_path.AsVimValue(), ':h' ) ).AsFilePath()
	endfunction

	function! l:object.AsString()
		return self.RelativeString()
	endfunction

	function l:object.With( value_as_file )
		return self.AsString().With( self.RH().String( '/' ) ).With( a:value_as_file.AsFilePath().RelativeString() ).AsFilePath()
	endfunction

	return l:object
endfunction

function g:Rudesheim.This()
	let l:object = self.Object()

	function l:object.File()
		return self.RH().String( expand( "%:p" ) ).AsFilePath()
	endfunction

	function l:object.Vim()
		let l:object = self.RH().Object()

		function l:object.BufferLine( vim_row )
			let l:object = self.RH().Object()
			let l:object._.vim_row = a:vim_row

			function! l:object.Get()
				return self.RH().String( getline( self._.vim_row ) )
			endfunction

			function! l:object.Set( value_as_string )
				return self.RH().String( setline( self._.vim_row, a:value_as_string.AsString().AsVimValue() ) )
			endfunction

			return l:object
		endfunction

		return l:object
	endfunction

	function l:object.ActiveBufferLine()
		return self.Vim().BufferLine( "." )
	endfunction

	function l:object.BufferLine( row_as_integer )
		return self.Vim().BufferLine( a:row_as_integer.AsInteger().AsVimValue() )
	endfunction

	return l:object
endfunction

function g:Rudesheim.FileLocator()
	let l:object = self.Object()

	function l:object.ThisFile()
		return self.This().File().AsFilePath()
	endfunction

	function l:object.HomeDirectory()
		return self.RH().String( $HOME ).AsFilePath()
	endfunction

	return l:object
endfunction

let g:Rudesheim._.this_plugin_file = g:Rudesheim.String( expand( '<sfile>:p' ) ).AsFilePath()

function g:Rudesheim.Plugins()
	let l:object = self.Object()

	function! l:object.This()
		let l:object = self.RH().Object()

		function l:object.Edit()
			tabe `=self._.this_plugin_file.AsString().AsVimValue()`
		endfunction

		function l:object.Reload()
			source `=self._.this_plugin_file.AsString().AsVimValue()`
		endfunction

		return l:object
	endfunction

	return l:object
endfunction

if !exists( 'g:RH' )
	let g:RH = g:Rudesheim
endif

if !exists( ':RHEcho' )
	command -nargs=1 RHEcho echo <args>.AsString().AsVimValue()
endif

