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

let g:Rudesheim.I = g:Rudesheim.Integer


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

let g:Rudesheim.F = g:Rudesheim.Float


function g:Rudesheim.Collection( vim_value )
        let l:object = self.Primitive( a:vim_value )

	function! l:object.Size()
		return self.RH().Integer( len( self.AsVimValue() ) )
	endfunction

	function! l:object.IsEmpty()
		return 0 == self.Size().AsVimValue()
	endfunction

	function! l:object.Species()
		return self.RH().List( [] )
	endfunction

	function! l:object.Do( block )
	endfunction

	function! l:object.Select( block )
        	let l:loop = self.RH().Object()
        	let l:loop._.result = self.Species()
        	let l:loop._.block = a:block

		function! l:loop.Value1( each )
			if !self._.block.Value1( a:each )
				return 0
			endif

			call self._.result.Add( a:each )

			return 0
		endfunction

		call self.Do( l:loop )

		return l:loop._.result
	endfunction

	function! l:object.Detect( block )
        	let l:loop = self.RH().Object()
        	let l:loop._.result = self.Species()
        	let l:loop._.block = a:block

		function! l:loop.Value1( each )
			if !self._.block.Value1( a:each )
				return 0
			endif

			call self._.result.Add( a:each )

			return 1
		endfunction

		call self.Do( l:loop )

		return l:loop._.result
	endfunction

	function! l:object.Collect( block )
        	let l:loop = self.RH().Object()
        	let l:loop._.result = self.Species()
        	let l:loop._.block = a:block

		function! l:loop.Value1( each )
			call self._.result.Add( self._.block.Value1( a:each ) )

			return 0
		endfunction

		call self.Do( l:loop )

		return l:loop._.result
	endfunction

	function! l:object.InjectInto( value, block )
        	let l:loop = self.RH().Object()
        	let l:loop._.result = a:value
        	let l:loop._.block = a:block

		function! l:loop.Value1( each )
			let self._.result = self._.block.Value2( self._.result, a:each )

			return 0
		endfunction

		call self.Do( l:loop )

		return l:loop._.result
	endfunction

        return l:object
endfunction

function g:Rudesheim.List( vim_value )
        let l:object = self.Collection( a:vim_value )

	function! l:object.Do( block )
		for i in self._.value
			if a:block.Value1( i )
				return
			endif
		endfor
	endfunction

	function! l:object.AddLast( value )
		let self._.value = add( self._.value, a:value )

		return self
	endfunction

	function! l:object.Add( value )
		return self.AddLast( a:value )
	endfunction

	function! l:object.JoinWith( separator )
		return self.RH().String( join( self._.value, a:separator.AsString().AsVimValue() ) )
	endfunction

        return l:object
endfunction

let g:Rudesheim.L = g:Rudesheim.List


function g:Rudesheim.String( vim_value )
        let l:object = self.Collection( a:vim_value )

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

let g:Rudesheim.S = g:Rudesheim.String


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

	if a:file_path_as_string.IsEmpty()
		throw "FilePathIsEmpty"
	endif

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

function g:Rudesheim.Shell()
	let l:object = self.Object()

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

