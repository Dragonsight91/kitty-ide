pkgs: prev:

let colors = {

	yellow = rec {
    	normal = "fcfc51";
    	bright = normal;
	};
	
	green = rec {
    	normal = "8aff80";
    	bright = "29f26c";
	};

	blue = rec {
		normal = "30c7ff";
		bright = "00e1ff";
	};

	orange = rec {
		normal = "ff8c26";
		bright = normal;
	};

	cyan = rec {
		normal = "29f8ff";
		bright = normal;
	};

	purple = rec {
		normal = "b58aff";
	};

	pink = rec {
		normal = "ee8fff";
	};
	
};

in let kakrc = pkgs.writeTextFile (rec {
    name = "kakrc.kak";
    destination = "/share/kak/autoload/${name}";
	text = with colors; ''

        # Line numbering
        add-highlighter global/ number-lines -separator ' │ ' -hlcursor

        # Setting the tabstop to 4 (even though I have an ultrawide monitor)
        set-option global tabstop 4

        set global ui_options ncurses_assistant=cat

        # kaktree
		
        hook global WinSetOption filetype=(kaktree) %{
            remove-highlighter global/number-lines
            remove-highlighter buffer/matching
            remove-highlighter buffer/wrap
            remove-highlighter buffer/show-whitespaces
        }
        kaktree-enable

		# Use Alt-Tab to switch between open buffers
        map global insert <a-tab> <esc>:buffer-next<ret>
        map global normal <a-tab> :buffer-next<ret>

        colorscheme colors
        
        face global LineNumbers			rgb:535353
        face global BufferPadding      	rgb:535353
        face global LineNumberCursor    rgb:ffffff
        face global crosshairs_line		"default,rgb:313131"
        face global MenuForeground 		"default,blue"
        face global MenuBackground		"default,rgb:313131"
        face global InlayHint			rgb:828282

        face global comment			rgb:828282

        eval %sh{ kak-lsp --kakoune -s $kak_session }

        # Load language-specific color schemes
        hook global WinSetOption filetype=(haskell) %{

            # colorscheme haskell
            lsp-enable-window

            lsp-inlay-diagnostics-enable window

            map buffer normal <tab> ': lsp-code-actions<ret>'
            map buffer normal <ret> ': lsp-hover<ret>' 

			hook window ModeChange .*:.*:insert %{
				remove-highlighter window/lsp_diagnostics
			}

			hook window ModeChange .*:insert:normal %{
				lsp-inlay-diagnostics-enable window
			}

			face global variable  rgb:${purple.normal}
			face global attribute keyword
			face global operator  keyword
			face global keyword   rgb:${blue.bright}
			face global value     string
			face global meta      rgb:${pink.normal}

        }

        hook global WinSetOption filetype=(nix) %{
            lsp-enable-window

            map buffer normal <tab> ': lsp-code-actions<ret>'
            map buffer normal <ret> ': lsp-hover<ret>' 

            face window builtin keyword
        }

        hook global WinSetOption filetype=(python) %{
            lsp-enable-window

            map buffer normal <tab> ': lsp-code-actions<ret>'
            map buffer normal <ret> ': lsp-hover<ret>' 

			face window keyword rgb:${green.bright}
			face window meta keyword

			scrollbar-enable

			set global scrollbar_char ▍
			set global scrollbar_sel_char ▍

			face global Scrollbar    rgb:616161
			face global ScrollbarSel rgb:616161
        }

        face global InlayDiagnosticWarning 	rgb:a39e31+f
        face global InlayDiagnosticError	rgb:ad494f+f
        face global InlayDiagnosticHint		rgb:4d965a+f

        hook global WinSetOption filetype=(javascript|typescript) %{
            lsp-enable-window
            map buffer normal <tab> ': lsp-code-actions<ret>'
            map buffer normal <ret> ': lsp-hover<ret>' 
		}
    '';
});

kak-lsp-toml = (pkgs.writeTextFile (rec {
	name = "kak-lsp.toml";
	destination = "/share/kak-lsp/${name}";
	text = ''
    	[language.haskell]
    	filetypes = [ "haskell" ]
		roots     = [ "Setup.hs", "stack.yaml", "*.cabal" ]
		command   = "haskell-language-server-wrapper"
		args      = [ "--lsp" ]

		[language.nix]
    	filetypes = [ "nix" ]
    	roots     = [ "flake.nix", "shell.nix", ".git", ".hg" ]
    	command   = "rnix-lsp"

    	[language.python]
       	filetypes = [ "python" ]
       	roots = [ "setup.py", ".git", ".hg" ]
       	command = "pylsp"

       	[language.typescript]
       	filetypes = ["typescript", "javascript"]
       	roots = ["package.json"]
       	command = "rslint-lsp"
	'';
}));

color-scheme = (pkgs.writeTextFile (rec {
	name = "colors.kak";
	destination = "/share/kak/colors/${name}";
	text = with colors; ''
		face global value    rgb:${blue.normal}
		face global string   rgb:${green.normal}
		face global keyword  rgb:${cyan.normal}
		face global operator rgb:${cyan.normal}
		face global function rgb:${cyan.normal}
		face global builtin  rgb:${orange.normal}
		face global module   rgb:${yellow.normal}
		face global meta     rgb:${green.bright}
		face global type	 rgb:${blue.bright}
	''; 
}));

scrollbar = (pkgs.kakouneUtils.buildKakounePlugin (rec {
	name = "scrollbar.kak";
	src = (pkgs.fetchFromGitHub {
		owner = "sawdust-and-diamonds";
		repo = name;
		rev = "f0dffde66458789d6ba58e4dcd1c1e92098eac4f";
		sha256 = "0z39wbd0yxr7f2qcclf2w14lswjqfhdw9bhfcws2glb70l98spky";
	});
}));


buffers = (pkgs.kakouneUtils.buildKakounePlugin (rec {
   	name = "buffers.kak";
   		src = (pkgs.fetchFromGitHub {
       		owner = "Delapouite";
        	repo = "kakoune-buffers";
        	rev = "6b2081f5b7d58c72de319a5cba7bf628b6802881";
        	sha256 = "0pbrgydifw2a8yf3ringyqq91fccfv4lm4v8sk5349hbcz6apr4c";
    });
}));

kaktree = (pkgs.kakouneUtils.buildKakounePlugin (rec {
    name = "kaktree";
    src = (pkgs.fetchFromGitHub {
        owner = "andreyorst";
        repo = "kaktree";
        rev = "acd47e0c8549afe1634a79a5bbd6d883daa8ba0a";
        sha256 = "sha256-9wiJFVxm+xZndUUpqrQ9eld/Df3wcp7gFDZTdInGPQQ=";
    });
}));

in {

    kakoune = with prev; (kakoune.override {

        plugins = with kakounePlugins; [

            # Include kakoune config
            kakrc

			# Colors
            color-scheme

			# Plugins
            scrollbar
            buffers
			kaktree

            # Language servers
            (symlinkJoin {

                paths = [

                    kak-lsp

                    rnix-lsp
                    haskell-language-server
                    python39Packages.python-lsp-server
                    rslint

                    kak-lsp-toml

                ];

                name = "kak-lsp-${kak-lsp.version}";

                nativeBuildInputs = [ makeWrapper ];

                postBuild = ''
                    wrapProgram $out/bin/kak-lsp --add-flags "--config $out/share/kak-lsp/kak-lsp.toml"
                '';

            })

        ];

    });

}
